-- aes128_core.vhd  Iterative AES-128 encryption: one round per clock, round keys
-- derived on the fly. Latency: 10 round clocks (done pulses on the
-- cycle block_out becomes valid, i.e. 11 clock edges after the one that latched start).
-- start is ignored while busy.
-- Only the encrypt direction is implemented because GCM (CTR + GHASH) needs nothing else.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.aes_pkg.all;

entity aes128_core is
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        start     : in  std_logic;
        key       : in  std_logic_vector(127 downto 0);
        block_in  : in  std_logic_vector(127 downto 0);
        busy      : out std_logic;
        done      : out std_logic;
        block_out : out std_logic_vector(127 downto 0)
    );
end entity;

architecture rtl of aes128_core is
    signal st    : block_t := (others => '0');
    signal rk    : block_t := (others => '0');
    signal rcon  : byte_t  := x"01";
    signal rnd   : natural range 0 to 10 := 0;
    signal busy_r : std_logic := '0';
    signal nrk    : block_t;
begin
    busy <= busy_r;

    u_kx : entity work.aes128_key_expansion
        port map (rk_in => rk, rcon => rcon, rk_out => nrk);

    process (clk)
        variable res : block_t;
    begin
        if rising_edge(clk) then
            done <= '0';
            if rst = '1' then
                busy_r <= '0';
                rnd    <= 0;
            elsif busy_r = '0' then
                if start = '1' then
                    st     <= block_in xor key;     -- initial AddRoundKey
                    rk     <= key;
                    rcon   <= x"01";
                    rnd    <= 1;
                    busy_r <= '1';
                end if;
            else
                if rnd < 10 then
                    res := mix_columns(shift_rows(sub_bytes(st))) xor nrk;
                else
                    res := shift_rows(sub_bytes(st)) xor nrk;   -- final round: no MixColumns
                end if;
                st   <= res;
                rk   <= nrk;
                rcon <= xtime(rcon);
                if rnd = 10 then
                    block_out <= res;
                    done      <= '1';
                    busy_r    <= '0';
                    rnd       <= 0;
                else
                    rnd <= rnd + 1;
                end if;
            end if;
        end if;
    end process;
end architecture;
