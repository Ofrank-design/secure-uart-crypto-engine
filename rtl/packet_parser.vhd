-- packet_parser.vhd  Parses protocol v1 request frames (see docs/protocol-specification.md).
-- Input: first-word-fall-through byte source (e.g. sync_fifo). A byte is consumed on
-- every clock where byte_valid='1' and byte_rd='1'. byte_rd drops while a packet is held.
-- Output: header fields, payload buffer (async read by buf_addr), tag; pkt_valid is a
-- level held until pkt_ack. Errors are one-clock pulses with a code that stays valid
-- until the next error.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity packet_parser is
    generic (
        MAX_PAYLOAD  : positive := 256;
        TIMEOUT_CLKS : positive := 5_000_000   -- 100 ms at 50 MHz
    );
    port (
        clk        : in  std_logic;
        rst        : in  std_logic;

        byte_in    : in  std_logic_vector(7 downto 0);
        byte_valid : in  std_logic;
        byte_rd    : out std_logic;

        hdr_type   : out std_logic_vector(7 downto 0);
        hdr_seq    : out std_logic_vector(15 downto 0);
        hdr_nonce  : out std_logic_vector(95 downto 0);
        hdr_len    : out natural range 0 to MAX_PAYLOAD;
        tag_out    : out std_logic_vector(127 downto 0);

        buf_addr   : in  natural range 0 to MAX_PAYLOAD - 1;
        buf_data   : out std_logic_vector(7 downto 0);

        pkt_valid  : out std_logic;
        pkt_ack    : in  std_logic;

        pkt_err    : out std_logic;
        err_code   : out std_logic_vector(2 downto 0)
    );
end entity;

architecture rtl of packet_parser is
    constant SYNC_BYTE : std_logic_vector(7 downto 0) := x"A5";
    constant VERSION   : std_logic_vector(7 downto 0) := x"01";
    constant T_DECRYPT : std_logic_vector(7 downto 0) := x"01";
    constant T_ENCRYPT : std_logic_vector(7 downto 0) := x"02";

    constant E_NONE    : std_logic_vector(2 downto 0) := "000";
    constant E_VERSION : std_logic_vector(2 downto 0) := "001";
    constant E_TYPE    : std_logic_vector(2 downto 0) := "010";
    constant E_LENGTH  : std_logic_vector(2 downto 0) := "011";
    constant E_TIMEOUT : std_logic_vector(2 downto 0) := "100";

    type state_t is (HUNT, HDR, PAYLOAD, TAG, HOLD);
    signal state : state_t := HUNT;

    type mem_t is array (0 to MAX_PAYLOAD - 1) of std_logic_vector(7 downto 0);
    signal mem : mem_t := (others => (others => '0'));

    signal idx     : natural range 0 to MAX_PAYLOAD + 32 := 0;
    signal type_r  : std_logic_vector(7 downto 0) := (others => '0');
    signal seq_r   : std_logic_vector(15 downto 0) := (others => '0');
    signal nonce_r : std_logic_vector(95 downto 0) := (others => '0');
    signal len_hi  : std_logic_vector(7 downto 0) := (others => '0');
    signal len_r   : natural range 0 to MAX_PAYLOAD := 0;
    signal tag_r   : std_logic_vector(127 downto 0) := (others => '0');
    signal tmo     : natural range 0 to TIMEOUT_CLKS := 0;
    signal err_r   : std_logic_vector(2 downto 0) := E_NONE;
begin
    byte_rd   <= byte_valid when state /= HOLD else '0';
    pkt_valid <= '1' when state = HOLD else '0';
    hdr_type  <= type_r;
    hdr_seq   <= seq_r;
    hdr_nonce <= nonce_r;
    hdr_len   <= len_r;
    tag_out   <= tag_r;
    buf_data  <= mem(buf_addr);
    err_code  <= err_r;

    process (clk)
        variable full_len : natural range 0 to 65535;
        variable consume  : boolean;
    begin
        if rising_edge(clk) then
            pkt_err <= '0';

            if rst = '1' then
                state <= HUNT;
                idx   <= 0;
                tmo   <= 0;
                len_r <= 0;
                err_r <= E_NONE;
            else
                consume := (byte_valid = '1') and (state /= HOLD);

                -- inter-byte timeout (only inside a packet)
                if state = HUNT or state = HOLD or consume then
                    tmo <= 0;
                elsif tmo = TIMEOUT_CLKS - 1 then
                    tmo     <= 0;
                    pkt_err <= '1';
                    err_r   <= E_TIMEOUT;
                    state   <= HUNT;
                else
                    tmo <= tmo + 1;
                end if;

                case state is
                    when HUNT =>
                        if consume and byte_in = SYNC_BYTE then
                            idx   <= 0;
                            state <= HDR;
                        end if;

                    when HDR =>
                        if consume then
                            case idx is
                                when 0 =>
                                    if byte_in /= VERSION then
                                        pkt_err <= '1'; err_r <= E_VERSION; state <= HUNT;
                                    else
                                        idx <= idx + 1;
                                    end if;
                                when 1 =>
                                    if byte_in /= T_DECRYPT and byte_in /= T_ENCRYPT then
                                        pkt_err <= '1'; err_r <= E_TYPE; state <= HUNT;
                                    else
                                        type_r <= byte_in;
                                        idx    <= idx + 1;
                                    end if;
                                when 2 | 3 =>
                                    seq_r <= seq_r(7 downto 0) & byte_in;
                                    idx   <= idx + 1;
                                when 4 to 15 =>
                                    nonce_r <= nonce_r(87 downto 0) & byte_in;
                                    idx     <= idx + 1;
                                when 16 =>
                                    len_hi <= byte_in;
                                    idx    <= idx + 1;
                                when others =>  -- 17: low length byte, header complete
                                    full_len := to_integer(unsigned(std_logic_vector'(len_hi & byte_in)));
                                    idx <= 0;
                                    if full_len > MAX_PAYLOAD then
                                        pkt_err <= '1'; err_r <= E_LENGTH; state <= HUNT;
                                    else
                                        len_r <= full_len;
                                        if full_len > 0 then
                                            state <= PAYLOAD;
                                        elsif type_r = T_DECRYPT then
                                            state <= TAG;
                                        else
                                            state <= HOLD;
                                        end if;
                                    end if;
                            end case;
                        end if;

                    when PAYLOAD =>
                        if consume then
                            mem(idx) <= byte_in;
                            if idx + 1 = len_r then
                                idx <= 0;
                                if type_r = T_DECRYPT then
                                    state <= TAG;
                                else
                                    state <= HOLD;
                                end if;
                            else
                                idx <= idx + 1;
                            end if;
                        end if;

                    when TAG =>
                        if consume then
                            tag_r <= tag_r(119 downto 0) & byte_in;
                            if idx = 15 then
                                idx   <= 0;
                                state <= HOLD;
                            else
                                idx <= idx + 1;
                            end if;
                        end if;

                    when HOLD =>
                        if pkt_ack = '1' then
                            state <= HUNT;
                        end if;
                end case;
            end if;
        end if;
    end process;
end architecture;
