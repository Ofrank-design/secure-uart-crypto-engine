-- aes128_key_expansion.vhd  One step of the AES-128 key schedule (FIPS 197 section 5.2), combinational.
-- rk_out = round key N+1 derived from rk_in (round key N) and rcon (Rcon[N+1], 0x01 for the first step).
-- Used by aes128_core (one step per round) and verified standalone against FIPS-197 Appendix A.1.
library ieee;
use ieee.std_logic_1164.all;
use work.aes_pkg.all;

entity aes128_key_expansion is
    port (
        rk_in  : in  std_logic_vector(127 downto 0);
        rcon   : in  std_logic_vector(7 downto 0);
        rk_out : out std_logic_vector(127 downto 0)
    );
end entity;

architecture rtl of aes128_key_expansion is
begin
    rk_out <= next_round_key(rk_in, rcon);
end architecture;
