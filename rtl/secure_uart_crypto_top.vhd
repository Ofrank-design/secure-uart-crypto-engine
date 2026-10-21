-- secure_uart_crypto_top.vhd  UART -> RX FIFO -> packet parser -> controller/AES-GCM -> TX FIFO -> UART.
-- Single clock domain. External reset (active high, asynchronous to clk) is synchronised here.
-- The nonce-counter NV store is an external block (flash/EEPROM/battery-backed): see ctr_* ports.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity secure_uart_crypto_top is
    generic (
        CLK_FREQ_HZ       : positive := 50_000_000;
        BAUD_RATE         : positive := 9_600;
        MAX_PAYLOAD       : positive := 256;
        FIFO_DEPTH        : positive := 512;
        PARSER_TIMEOUT_CLKS : positive := 5_000_000;
        NV_TIMEOUT_CLKS   : positive := 50_000_000;
        DEVICE_ID         : std_logic_vector(31 downto 0)  := x"C0FFEE01";
        KEY_INIT          : std_logic_vector(127 downto 0) := x"000102030405060708090a0b0c0d0e0f";
        KEY_INIT_VALID    : boolean := true;
        ALLOW_UNAUTH_ENCRYPT : boolean := true
    );
    port (
        clk            : in  std_logic;
        rst_in         : in  std_logic;
        uart_rx_pin    : in  std_logic;
        uart_tx_pin    : out std_logic;

        zeroize        : in  std_logic;                       -- clear key (tamper hook)
        key_load       : in  std_logic;                       -- provisioning, from TRUSTED logic only
        key_in         : in  std_logic_vector(127 downto 0);  -- (not reachable from the UART)

        ctr_init       : in  std_logic_vector(63 downto 0);   -- next unused counter, from NV store
        ctr_valid      : in  std_logic;
        ctr_store_req  : out std_logic;
        ctr_store_val  : out std_logic_vector(63 downto 0);
        ctr_store_ack  : in  std_logic;

        seq_init       : in  std_logic_vector(15 downto 0);   -- last authenticated SEQ, from NV store
        seq_have_init  : in  std_logic;
        seq_valid      : in  std_logic;
        seq_store_req  : out std_logic;
        seq_store_val  : out std_logic_vector(15 downto 0);
        seq_store_ack  : in  std_logic;

        uart_rts_n     : out std_logic;                       -- '1' = host should stop sending (RX FIFO > half full)

        busy           : out std_logic;
        st_framing_err : out std_logic;
        st_rx_overflow : out std_logic;
        st_parse_err   : out std_logic;
        st_auth_fail   : out std_logic;
        st_replay      : out std_logic;
        st_crypto_err  : out std_logic                        -- engine misuse (start while busy); never expected
    );
end entity;

architecture rtl of secure_uart_crypto_top is
    signal rst_s : std_logic_vector(1 downto 0) := "11";
    attribute async_reg : string;
    attribute async_reg of rst_s : signal is "true";
    signal rst   : std_logic;

    -- UART RX / FIFO / parser
    signal rx_data  : std_logic_vector(7 downto 0);
    signal rx_valid, rx_ferr : std_logic;
    signal rxf_data : std_logic_vector(7 downto 0);
    signal rxf_empty, rxf_full, rxf_rd, rxf_ovf, rxf_unf : std_logic;
    signal rxf_level : natural range 0 to FIFO_DEPTH;

    signal hdr_type  : std_logic_vector(7 downto 0);
    signal hdr_seq   : std_logic_vector(15 downto 0);
    signal hdr_nonce : std_logic_vector(95 downto 0);
    signal hdr_len   : natural range 0 to MAX_PAYLOAD;
    signal p_tag     : std_logic_vector(127 downto 0);
    signal buf_addr  : natural range 0 to MAX_PAYLOAD - 1;
    signal buf_data  : std_logic_vector(7 downto 0);
    signal pkt_valid, pkt_ack, pkt_err : std_logic;
    signal err_code  : std_logic_vector(2 downto 0);

    -- key
    signal key       : std_logic_vector(127 downto 0);
    signal key_valid : std_logic;

    -- engine
    signal e_start, e_dec, e_in_ready, e_in_is_aad, e_in_valid, e_out_valid, e_done, e_auth : std_logic;
    signal e_key, e_in_block, e_out_block, e_tag_in, e_tag_out : std_logic_vector(127 downto 0);
    signal e_iv      : std_logic_vector(95 downto 0);
    signal e_alen, e_dlen : natural range 0 to 4095;
    signal e_out_bytes : natural range 0 to 16;
    signal e_busy, e_error : std_logic;

    -- TX
    signal txf_wr, txf_full, txf_empty, txf_ovf, txf_unf : std_logic;
    signal txf_wdata, txf_rdata : std_logic_vector(7 downto 0);
    signal txf_level : natural range 0 to FIFO_DEPTH;
    signal utx_ready, utx_valid, utx_busy, utx_done : std_logic;
begin
    ---------------------------------------------------------------- reset synchroniser
    process (clk)
    begin
        if rising_edge(clk) then
            rst_s <= rst_s(0) & rst_in;
        end if;
    end process;
    rst <= rst_s(1);

    ---------------------------------------------------------------- receive path
    u_rx : entity work.uart_rx
        generic map (CLK_FREQ_HZ => CLK_FREQ_HZ, BAUD_RATE => BAUD_RATE)
        port map (clk => clk, rst => rst, rx => uart_rx_pin, data_out => rx_data,
                  data_valid => rx_valid, busy => open, framing_err => rx_ferr);

    u_rxf : entity work.sync_fifo
        generic map (WIDTH => 8, DEPTH => FIFO_DEPTH)
        port map (clk => clk, rst => rst, wr_en => rx_valid, wr_data => rx_data, full => rxf_full,
                  rd_en => rxf_rd, rd_data => rxf_data, empty => rxf_empty, level => rxf_level,
                  overflow => rxf_ovf, underflow => rxf_unf);

    u_parser : entity work.packet_parser
        generic map (MAX_PAYLOAD => MAX_PAYLOAD, TIMEOUT_CLKS => PARSER_TIMEOUT_CLKS)
        port map (clk => clk, rst => rst, byte_in => rxf_data, byte_valid => not rxf_empty,
                  byte_rd => rxf_rd, hdr_type => hdr_type, hdr_seq => hdr_seq, hdr_nonce => hdr_nonce,
                  hdr_len => hdr_len, tag_out => p_tag, buf_addr => buf_addr, buf_data => buf_data,
                  pkt_valid => pkt_valid, pkt_ack => pkt_ack, pkt_err => pkt_err, err_code => err_code);

    ---------------------------------------------------------------- key + crypto
    u_key : entity work.key_manager
        generic map (KEY_INIT => KEY_INIT, KEY_INIT_VALID => KEY_INIT_VALID)
        port map (clk => clk, rst => rst, zeroize => zeroize, load => key_load,
                  key_in => key_in, key => key, key_valid => key_valid);

    u_eng : entity work.aes_gcm_engine
        port map (clk => clk, rst => rst, start => e_start, decrypt => e_dec, key => e_key, iv => e_iv,
                  aad_len => e_alen, data_len => e_dlen, tag_in => e_tag_in,
                  in_ready => e_in_ready, in_is_aad => e_in_is_aad, in_valid => e_in_valid,
                  in_block => e_in_block, out_valid => e_out_valid, out_block => e_out_block,
                  out_bytes => e_out_bytes, busy => e_busy, done => e_done, error => e_error, tag_out => e_tag_out,
                  auth_ok => e_auth);

    u_ctrl : entity work.crypto_controller
        generic map (MAX_PAYLOAD => MAX_PAYLOAD, DEVICE_ID => DEVICE_ID, NV_TIMEOUT_CLKS => NV_TIMEOUT_CLKS,
                      ALLOW_UNAUTH_ENCRYPT => ALLOW_UNAUTH_ENCRYPT)
        port map (clk => clk, rst => rst,
                  pkt_valid => pkt_valid, pkt_ack => pkt_ack, pkt_err => pkt_err, err_code => err_code,
                  hdr_type => hdr_type, hdr_seq => hdr_seq, hdr_nonce => hdr_nonce, hdr_len => hdr_len,
                  tag_in => p_tag, buf_addr => buf_addr, buf_data => buf_data,
                  key => key, key_valid => key_valid,
                  ctr_init => ctr_init, ctr_valid => ctr_valid, ctr_store_req => ctr_store_req,
                  ctr_store_val => ctr_store_val, ctr_store_ack => ctr_store_ack,
                  seq_init => seq_init, seq_have_init => seq_have_init, seq_valid => seq_valid,
                  seq_store_req => seq_store_req, seq_store_val => seq_store_val,
                  seq_store_ack => seq_store_ack,
                  eng_start => e_start, eng_decrypt => e_dec, eng_key => e_key, eng_iv => e_iv,
                  eng_aad_len => e_alen, eng_data_len => e_dlen, eng_tag_in => e_tag_in,
                  eng_in_ready => e_in_ready, eng_in_is_aad => e_in_is_aad, eng_in_valid => e_in_valid,
                  eng_in_block => e_in_block, eng_out_valid => e_out_valid, eng_out_block => e_out_block,
                  eng_done => e_done, eng_tag_out => e_tag_out, eng_auth_ok => e_auth,
                  tx_wr_en => txf_wr, tx_wr_data => txf_wdata, tx_full => txf_full,
                  busy => busy, evt_parse_err => st_parse_err, evt_auth_fail => st_auth_fail,
                  evt_replay => st_replay);

    ---------------------------------------------------------------- transmit path
    u_txf : entity work.sync_fifo
        generic map (WIDTH => 8, DEPTH => FIFO_DEPTH)
        port map (clk => clk, rst => rst, wr_en => txf_wr, wr_data => txf_wdata, full => txf_full,
                  rd_en => utx_valid, rd_data => txf_rdata, empty => txf_empty, level => txf_level,
                  overflow => txf_ovf, underflow => txf_unf);

    utx_valid <= (not txf_empty) and utx_ready;

    u_tx : entity work.uart_tx
        generic map (CLK_FREQ_HZ => CLK_FREQ_HZ, BAUD_RATE => BAUD_RATE)
        port map (clk => clk, rst => rst, data_in => txf_rdata, data_valid => utx_valid,
                  ready => utx_ready, tx => uart_tx_pin, busy => utx_busy, done => utx_done);

    uart_rts_n     <= '1' when rxf_level > FIFO_DEPTH / 2 else '0';
    st_crypto_err  <= e_error;
    st_framing_err <= rx_ferr;
    st_rx_overflow <= rxf_ovf;
end architecture;
