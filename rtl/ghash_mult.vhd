-- ghash_mult.vhd  Bit-serial GF(2^128) multiplier for GHASH (SP 800-38D, Algorithm 1).
-- p = a * h. 128 clocks per product; 'done' pulses when p is valid. start ignored while busy.
-- Bit numbering follows the standard: vector bit 127 is the standard's bit 0 (leftmost).
library ieee;
use ieee.std_logic_1164.all;

entity ghash_mult is
    port (
        clk   : in  std_logic;
        rst   : in  std_logic;
        start : in  std_logic;
        a     : in  std_logic_vector(127 downto 0);
        h     : in  std_logic_vector(127 downto 0);
        busy  : out std_logic;
        done  : out std_logic;
        p     : out std_logic_vector(127 downto 0)
    );
end entity;

architecture rtl of ghash_mult is
    signal x, v, z : std_logic_vector(127 downto 0) := (others => '0');
    signal cnt     : natural range 0 to 127 := 0;
    signal busy_r  : std_logic := '0';
begin
    busy <= busy_r;

    process (clk)
        variable zn, vn : std_logic_vector(127 downto 0);
    begin
        if rising_edge(clk) then
            done <= '0';
            if rst = '1' then
                busy_r <= '0';
                cnt    <= 0;
            elsif busy_r = '0' then
                if start = '1' then
                    x      <= a;
                    v      <= h;
                    z      <= (others => '0');
                    cnt    <= 0;
                    busy_r <= '1';
                end if;
            else
                zn := z;
                if x(127) = '1' then zn := zn xor v; end if;
                vn := '0' & v(127 downto 1);
                if v(0) = '1' then vn(127 downto 120) := vn(127 downto 120) xor x"E1"; end if;
                x <= x(126 downto 0) & '0';
                v <= vn;
                z <= zn;
                if cnt = 127 then
                    p      <= zn;
                    done   <= '1';
                    busy_r <= '0';
                else
                    cnt <= cnt + 1;
                end if;
            end if;
        end if;
    end process;
end architecture;
