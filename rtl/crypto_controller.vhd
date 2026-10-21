-- crypto_controller.vhd  Transaction controller (packet builder is merged in here).
--
-- Security rules implemented here:
--  * Plaintext of a failed authentication is never sent: decrypt output sits in a private
--    block buffer, is zeroed on failure, and an ERROR frame (code 01) is sent instead.
--  * Replay: DECRYPT_REQ is accepted only if SEQ is strictly greater than the last
--    AUTHENTICATED SEQ (checked early, updated only after a successful tag check, so
--    forged packets can never advance it). The last SEQ is persisted through the NV store
--    (seq_store_*) BEFORE the plaintext is released, and reloaded after reset/power loss.
--    If the NV write is not acknowledged the plaintext is wiped and error 03 is sent.
--    After SEQ 0xFFFF everything is rejected until the key/NV state is reprovisioned.
--  * Nonce spaces: DECRYPT_REQ nonces whose first 4 bytes equal DEVICE_ID are refused (code 05),
--    so a host can never choose a nonce that collides with the device-generated space.
--  * ALLOW_UNAUTH_ENCRYPT=false refuses ENCRYPT_REQ (code 06) for links that are not trusted.
--  * Nonce (ENCRYPT_REQ): DEVICE_ID(32) || counter(64). Before a counter value is used,
--    counter+1 is written to non-volatile storage (ctr_store_req/val) and the controller
--    waits for ctr_store_ack. The counter is only trusted when ctr_valid='1'. A power cycle
--    therefore can never reuse a nonce, provided the NV store is honest.
--  * Parser errors produce an ERROR frame with SEQ 0 and code 0x10|parser_code.
--  * One packet at a time; the parser holds the packet (and its inputs) until pkt_ack.
--
-- Response frame: A5 01 TYPE SEQ(2) NONCE(12) LEN(2) PAYLOAD [TAG(16) for TYPE 81]
--   81 encrypt ok (ciphertext + tag, device nonce) | 82 decrypt ok (plaintext, request nonce echoed)
--   E0 error (LEN=1, payload = code; 01 auth, 02 replay, 03 NV/nonce unavailable, 04 no key,
--             05 reserved nonce prefix, 06 encrypt disabled, 1x parser)
-- AAD = 01 || TYPE || SEQ || LEN where TYPE is the type of the frame carrying the tag (01 or 81).
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.aes_pkg.all;

entity crypto_controller is
    generic (
        MAX_PAYLOAD    : positive := 256;
        DEVICE_ID      : std_logic_vector(31 downto 0) := x"C0FFEE01";
        NV_TIMEOUT_CLKS : positive := 50_000_000;
        ALLOW_UNAUTH_ENCRYPT : boolean := true
    );
    port (
        clk, rst      : in  std_logic;

        -- packet parser
        pkt_valid     : in  std_logic;
        pkt_ack       : out std_logic;
        pkt_err       : in  std_logic;
        err_code      : in  std_logic_vector(2 downto 0);
        hdr_type      : in  std_logic_vector(7 downto 0);
        hdr_seq       : in  std_logic_vector(15 downto 0);
        hdr_nonce     : in  std_logic_vector(95 downto 0);
        hdr_len       : in  natural range 0 to MAX_PAYLOAD;
        tag_in        : in  std_logic_vector(127 downto 0);
        buf_addr      : out natural range 0 to MAX_PAYLOAD - 1;
        buf_data      : in  std_logic_vector(7 downto 0);

        -- key manager
        key           : in  std_logic_vector(127 downto 0);
        key_valid     : in  std_logic;

        -- nonce counter non-volatile store
        ctr_init      : in  std_logic_vector(63 downto 0);
        ctr_valid     : in  std_logic;
        ctr_store_req : out std_logic;
        ctr_store_val : out std_logic_vector(63 downto 0);
        ctr_store_ack : in  std_logic;

        -- replay state (last authenticated SEQ) non-volatile store
        seq_init      : in  std_logic_vector(15 downto 0);
        seq_have_init : in  std_logic;
        seq_valid     : in  std_logic;
        seq_store_req : out std_logic;
        seq_store_val : out std_logic_vector(15 downto 0);
        seq_store_ack : in  std_logic;

        -- AES-GCM engine
        eng_start     : out std_logic;
        eng_decrypt   : out std_logic;
        eng_key       : out std_logic_vector(127 downto 0);
        eng_iv        : out std_logic_vector(95 downto 0);
        eng_aad_len   : out natural range 0 to 4095;
        eng_data_len  : out natural range 0 to 4095;
        eng_tag_in    : out std_logic_vector(127 downto 0);
        eng_in_ready  : in  std_logic;
        eng_in_is_aad : in  std_logic;
        eng_in_valid  : out std_logic;
        eng_in_block  : out std_logic_vector(127 downto 0);
        eng_out_valid : in  std_logic;
        eng_out_block : in  std_logic_vector(127 downto 0);
        eng_done      : in  std_logic;
        eng_tag_out   : in  std_logic_vector(127 downto 0);
        eng_auth_ok   : in  std_logic;

        -- TX byte FIFO
        tx_wr_en      : out std_logic;
        tx_wr_data    : out std_logic_vector(7 downto 0);
        tx_full       : in  std_logic;

        -- status
        busy          : out std_logic;
        evt_parse_err : out std_logic;
        evt_auth_fail : out std_logic;
        evt_replay    : out std_logic
    );
end entity;

architecture rtl of crypto_controller is
    constant NBLK : positive := (MAX_PAYLOAD + 15) / 16;

    type state_t is (IDLE, NONCE_WAIT, SEQ_WAIT, ENG_GO, ENG_RUN, LOAD_BLK, PRESENT, CLEAR, RESP, RESP_WAIT, ACK);
    type obuf_t  is array (0 to NBLK - 1) of block_t;

    signal state : state_t := IDLE;
    signal obuf  : obuf_t := (others => (others => '0'));

    signal is_dec, held, cur_aad     : std_logic := '0';
    signal have_last, ctr_seen, seq_seen : std_logic := '0';
    signal last_seq                  : std_logic_vector(15 downto 0) := (others => '0');
    signal ctr                       : unsigned(63 downto 0) := (others => '0');
    signal iv_sel, nonce_used        : std_logic_vector(95 downto 0) := (others => '0');
    signal di, oi, ci                : natural range 0 to NBLK := 0;
    signal ld_i                      : natural range 0 to 16 := 0;
    signal in_reg, res_tag           : block_t := (others => '0');
    signal nv_cnt                    : natural range 0 to NV_TIMEOUT_CLKS := 0;

    signal resp_type, resp_code      : std_logic_vector(7 downto 0) := (others => '0');
    signal resp_seq                  : std_logic_vector(15 downto 0) := (others => '0');
    signal resp_nonce                : std_logic_vector(95 downto 0) := (others => '0');
    signal resp_len                  : natural range 0 to MAX_PAYLOAD := 0;
    signal resp_has_tag, resp_is_err : std_logic := '0';
    signal resp_tag                  : block_t := (others => '0');
    signal pay_blk                   : natural range 0 to NBLK - 1 := 0;
    signal pay_byte                  : natural range 0 to 15 := 0;
    signal pay_data                  : std_logic_vector(7 downto 0);
    signal bld_start, bld_done       : std_logic;

    signal aad_type  : std_logic_vector(7 downto 0);
    signal aad_block : block_t;
    signal len16     : std_logic_vector(15 downto 0);
begin
    ------------------------------------------------------------------ combinational
    len16     <= std_logic_vector(to_unsigned(hdr_len, 16));
    aad_type  <= x"01" when is_dec = '1' else x"81";
    aad_block <= x"01" & aad_type & hdr_seq & len16 & x"00000000000000000000";

    eng_start     <= '1' when state = ENG_GO else '0';
    eng_decrypt   <= is_dec;
    eng_key       <= key;
    eng_iv        <= iv_sel;
    eng_aad_len   <= 6;
    eng_data_len  <= hdr_len;
    eng_tag_in    <= tag_in;
    eng_in_valid  <= '1' when state = PRESENT else '0';
    eng_in_block  <= in_reg;

    ctr_store_req <= '1' when state = NONCE_WAIT else '0';
    ctr_store_val <= std_logic_vector(ctr + 1);
    seq_store_req <= '1' when state = SEQ_WAIT else '0';
    seq_store_val <= hdr_seq;

    buf_addr <= 16 * di + ld_i when 16 * di + ld_i < MAX_PAYLOAD else 0;
    pkt_ack  <= '1' when state = ACK else '0';
    busy     <= '0' when state = IDLE else '1';

    bld_start <= '1' when state = RESP else '0';
    pay_data  <= obuf(pay_blk)(127 - 8 * pay_byte downto 120 - 8 * pay_byte);

    u_bld : entity work.packet_builder
        generic map (MAX_PAYLOAD => MAX_PAYLOAD)
        port map (clk => clk, rst => rst, start => bld_start, busy => open, done => bld_done,
                  resp_type => resp_type, resp_seq => resp_seq, resp_nonce => resp_nonce,
                  resp_len => resp_len, resp_has_tag => resp_has_tag, resp_is_err => resp_is_err,
                  resp_code => resp_code, resp_tag => resp_tag,
                  pay_blk => pay_blk, pay_byte => pay_byte, pay_data => pay_data,
                  wr_en => tx_wr_en, wr_data => tx_wr_data, full => tx_full);

    ------------------------------------------------------------------ sequential
    process (clk)
        procedure set_err (code : std_logic_vector(7 downto 0);
                           seq  : std_logic_vector(15 downto 0);
                           h    : std_logic) is
        begin
            resp_type    <= x"E0";
            resp_seq     <= seq;
            resp_nonce   <= (others => '0');
            resp_len     <= 1;
            resp_has_tag <= '0';
            resp_is_err  <= '1';
            resp_code    <= code;
            held         <= h;
        end procedure;

        procedure finish_frame is
        begin
            if held = '1' then state <= ACK; else state <= IDLE; end if;
        end procedure;
    begin
        if rising_edge(clk) then
            evt_parse_err <= '0';
            evt_auth_fail <= '0';
            evt_replay    <= '0';

            if rst = '1' then
                state     <= IDLE;
                is_dec    <= '0';
                cur_aad   <= '0';
                di        <= 0;
                oi        <= 0;
                ci        <= 0;
                ld_i      <= 0;
                held      <= '0';
                have_last <= '0';
                last_seq  <= (others => '0');
                ctr_seen  <= '0';
                seq_seen  <= '0';
                nv_cnt    <= 0;
            else
                if ctr_valid = '1' and ctr_seen = '0' then
                    ctr      <= unsigned(ctr_init);
                    ctr_seen <= '1';
                end if;
                if seq_valid = '1' and seq_seen = '0' then
                    last_seq  <= seq_init;
                    have_last <= seq_have_init;
                    seq_seen  <= '1';
                end if;

                case state is
                    when IDLE =>
                        if pkt_valid = '1' then
                            held <= '1';
                            di   <= 0;
                            oi   <= 0;
                            if key_valid = '0' then
                                set_err(x"04", hdr_seq, '1'); state <= RESP;
                            elsif hdr_type = x"01" then                  -- DECRYPT_REQ
                                if hdr_nonce(95 downto 64) = DEVICE_ID then
                                    set_err(x"05", hdr_seq, '1'); state <= RESP;
                                elsif seq_valid = '0' or seq_seen = '0' then
                                    set_err(x"03", hdr_seq, '1'); state <= RESP;
                                elsif have_last = '1' and unsigned(hdr_seq) <= unsigned(last_seq) then
                                    evt_replay <= '1';
                                    set_err(x"02", hdr_seq, '1'); state <= RESP;
                                else
                                    is_dec <= '1';
                                    iv_sel <= hdr_nonce;
                                    state  <= ENG_GO;
                                end if;
                            else                                         -- ENCRYPT_REQ
                                if not ALLOW_UNAUTH_ENCRYPT then
                                    set_err(x"06", hdr_seq, '1'); state <= RESP;
                                elsif ctr_valid = '0' or ctr_seen = '0' or (and ctr) = '1' then
                                    set_err(x"03", hdr_seq, '1'); state <= RESP;
                                else
                                    is_dec <= '0';
                                    nv_cnt <= 0;
                                    state  <= NONCE_WAIT;
                                end if;
                            end if;
                        elsif pkt_err = '1' then
                            evt_parse_err <= '1';
                            set_err("00010" & err_code, x"0000", '0');
                            state <= RESP;
                        end if;

                    when NONCE_WAIT =>
                        if ctr_store_ack = '1' then
                            iv_sel     <= DEVICE_ID & std_logic_vector(ctr);
                            nonce_used <= DEVICE_ID & std_logic_vector(ctr);
                            ctr        <= ctr + 1;
                            state      <= ENG_GO;
                        elsif nv_cnt = NV_TIMEOUT_CLKS then
                            set_err(x"03", hdr_seq, '1'); state <= RESP;
                        else
                            nv_cnt <= nv_cnt + 1;
                        end if;

                    when SEQ_WAIT =>
                        if seq_store_ack = '1' then
                            last_seq     <= hdr_seq;
                            have_last    <= '1';
                            resp_type    <= x"82";
                            resp_seq     <= hdr_seq;
                            resp_nonce   <= hdr_nonce;
                            resp_len     <= hdr_len;
                            resp_has_tag <= '0';
                            resp_is_err  <= '0';
                            state        <= RESP;
                        elsif nv_cnt = NV_TIMEOUT_CLKS then
                            set_err(x"03", hdr_seq, '1');
                            ci    <= 0;
                            state <= CLEAR;               -- plaintext must not leave without a durable SEQ
                        else
                            nv_cnt <= nv_cnt + 1;
                        end if;

                    when ENG_GO =>
                        state <= ENG_RUN;

                    when ENG_RUN =>
                        if eng_out_valid = '1' then
                            obuf(oi) <= eng_out_block;
                            oi       <= oi + 1;
                        end if;
                        if eng_done = '1' then
                            res_tag <= eng_tag_out;
                            if is_dec = '1' and eng_auth_ok = '0' then
                                evt_auth_fail <= '1';
                                set_err(x"01", hdr_seq, '1');
                                ci    <= 0;
                                state <= CLEAR;           -- wipe unauthenticated plaintext
                            elsif is_dec = '1' then
                                nv_cnt <= 0;
                                state  <= SEQ_WAIT;       -- persist SEQ before releasing plaintext
                            else
                                resp_type    <= x"81";
                                resp_seq     <= hdr_seq;
                                resp_nonce   <= nonce_used;
                                resp_len     <= hdr_len;
                                resp_has_tag <= '1';
                                resp_is_err  <= '0';
                                resp_tag     <= eng_tag_out;
                                state        <= RESP;
                            end if;
                        elsif eng_in_ready = '1' then
                            cur_aad <= eng_in_is_aad;
                            if eng_in_is_aad = '1' then
                                in_reg <= aad_block;
                                state  <= PRESENT;
                            else
                                in_reg <= (others => '0');
                                ld_i   <= 0;
                                state  <= LOAD_BLK;
                            end if;
                        end if;

                    when LOAD_BLK =>
                        if ld_i = 16 then
                            state <= PRESENT;
                        else
                            if 16 * di + ld_i < hdr_len then
                                in_reg(127 - 8 * ld_i downto 120 - 8 * ld_i) <= buf_data;
                            end if;
                            ld_i <= ld_i + 1;
                        end if;

                    when PRESENT =>                       -- eng_in_valid='1' this cycle
                        if eng_in_ready = '1' then
                            if cur_aad = '0' then di <= di + 1; end if;
                            state <= ENG_RUN;
                        end if;

                    when CLEAR =>
                        obuf(ci) <= (others => '0');
                        if ci = NBLK - 1 then
                            state <= RESP;
                        else
                            ci <= ci + 1;
                        end if;

                    when RESP =>                          -- bld_start='1' this cycle
                        state <= RESP_WAIT;

                    when RESP_WAIT =>
                        if bld_done = '1' then
                            finish_frame;
                        end if;

                    when ACK =>                           -- pkt_ack='1' this cycle
                        held  <= '0';
                        state <= IDLE;
                end case;
            end if;
        end if;
    end process;
end architecture;
