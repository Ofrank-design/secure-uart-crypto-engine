-- packet_builder.vhd  Serialises one response frame (protocol v1) into a byte FIFO.
--   A5 01 TYPE SEQ(2) NONCE(12) LEN(2) PAYLOAD [TAG(16)]
-- Contract:
--  * Pulse 'start' while busy='0'. All frame fields are sampled on that clock edge.
--  * Payload bytes are fetched through the combinational read port: while the builder
--    needs byte k it drives pay_blk = k/16, pay_byte = k mod 16 and expects pay_data
--    (same clock cycle) to carry that byte. For error frames (resp_is_err='1') the payload is
--    the single byte resp_code and the read port is not used.
--  * One byte is written per clock while 'full'='0'. When 'full'='1' the builder waits (no
--    byte is ever dropped). 'done' pulses for one clock after the last byte was written.
--  * Reset abandons any frame in progress; no done pulse is produced.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity packet_builder is
    generic (
        MAX_PAYLOAD : positive := 256
    );
    port (
        clk, rst     : in  std_logic;
        start        : in  std_logic;
        busy         : out std_logic;
        done         : out std_logic;

        resp_type    : in  std_logic_vector(7 downto 0);
        resp_seq     : in  std_logic_vector(15 downto 0);
        resp_nonce   : in  std_logic_vector(95 downto 0);
        resp_len     : in  natural range 0 to MAX_PAYLOAD;
        resp_has_tag : in  std_logic;
        resp_is_err  : in  std_logic;
        resp_code    : in  std_logic_vector(7 downto 0);
        resp_tag     : in  std_logic_vector(127 downto 0);

        pay_blk      : out natural range 0 to (MAX_PAYLOAD + 15) / 16 - 1;
        pay_byte     : out natural range 0 to 15;
        pay_data     : in  std_logic_vector(7 downto 0);

        wr_en        : out std_logic;
        wr_data      : out std_logic_vector(7 downto 0);
        full         : in  std_logic
    );
end entity;

architecture rtl of packet_builder is
    constant NBLK : positive := (MAX_PAYLOAD + 15) / 16;
    type state_t is (IDLE, SEND);
    type phase_t is (PH_HDR, PH_PAY, PH_TAG);
    signal state : state_t := IDLE;
    signal phase : phase_t := PH_HDR;

    signal l_type, l_code : std_logic_vector(7 downto 0) := (others => '0');
    signal l_seq   : std_logic_vector(15 downto 0) := (others => '0');
    signal l_nonce : std_logic_vector(95 downto 0) := (others => '0');
    signal l_len   : natural range 0 to MAX_PAYLOAD := 0;
    signal l_tag   : std_logic_vector(127 downto 0) := (others => '0');
    signal l_has_tag, l_is_err : std_logic := '0';

    signal ri      : natural range 0 to 31 := 0;
    signal pay_idx : natural range 0 to MAX_PAYLOAD := 0;
    signal p_blk   : natural range 0 to NBLK - 1 := 0;
    signal p_byte, tag_j : natural range 0 to 15 := 0;
begin
    busy     <= '0' when state = IDLE else '1';
    wr_en    <= '1' when state = SEND and full = '0' else '0';
    pay_blk  <= p_blk;
    pay_byte <= p_byte;

    byte_sel : process (all)
        variable b : std_logic_vector(7 downto 0);
        variable l : std_logic_vector(15 downto 0);
    begin
        b := x"00";
        l := std_logic_vector(to_unsigned(l_len, 16));
        case phase is
            when PH_HDR =>
                case ri is
                    when 0       => b := x"A5";
                    when 1       => b := x"01";
                    when 2       => b := l_type;
                    when 3       => b := l_seq(15 downto 8);
                    when 4       => b := l_seq(7 downto 0);
                    when 5 to 16 => b := l_nonce(95 - 8 * (ri - 5) downto 88 - 8 * (ri - 5));
                    when 17      => b := l(15 downto 8);
                    when others  => b := l(7 downto 0);
                end case;
            when PH_PAY =>
                if l_is_err = '1' then b := l_code; else b := pay_data; end if;
            when PH_TAG =>
                b := l_tag(127 - 8 * tag_j downto 120 - 8 * tag_j);
        end case;
        wr_data <= b;
    end process;

    process (clk)
        procedure finish is
        begin
            done  <= '1';
            state <= IDLE;
        end procedure;
    begin
        if rising_edge(clk) then
            done <= '0';
            if rst = '1' then
                state <= IDLE;
                phase <= PH_HDR;
                ri    <= 0;
            else
                case state is
                    when IDLE =>
                        if start = '1' then
                            l_type    <= resp_type;
                            l_seq     <= resp_seq;
                            l_nonce   <= resp_nonce;
                            l_len     <= resp_len;
                            l_has_tag <= resp_has_tag;
                            l_is_err  <= resp_is_err;
                            l_code    <= resp_code;
                            l_tag     <= resp_tag;
                            phase     <= PH_HDR;
                            ri        <= 0;
                            pay_idx   <= 0;
                            p_blk     <= 0;
                            p_byte    <= 0;
                            tag_j     <= 0;
                            state     <= SEND;
                        end if;

                    when SEND =>
                        if full = '0' then
                            case phase is
                                when PH_HDR =>
                                    if ri = 18 then
                                        if l_len > 0 then
                                            phase <= PH_PAY;
                                        elsif l_has_tag = '1' then
                                            phase <= PH_TAG;
                                        else
                                            finish;
                                        end if;
                                    else
                                        ri <= ri + 1;
                                    end if;
                                when PH_PAY =>
                                    if pay_idx + 1 = l_len then
                                        if l_has_tag = '1' then phase <= PH_TAG; else finish; end if;
                                    else
                                        pay_idx <= pay_idx + 1;
                                        if p_byte = 15 then
                                            p_byte <= 0; p_blk <= p_blk + 1;
                                        else
                                            p_byte <= p_byte + 1;
                                        end if;
                                    end if;
                                when PH_TAG =>
                                    if tag_j = 15 then finish; else tag_j <= tag_j + 1; end if;
                            end case;
                        end if;
                end case;
            end if;
        end if;
    end process;
end architecture;
