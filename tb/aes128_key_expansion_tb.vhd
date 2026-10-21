-- aes128_key_expansion_tb.vhd  FIPS-197 Appendix A.1 round keys (all 11), plus final round keys for
-- the all-zero key and the key 00..0f. Expected values cross-checked with an independent Python
-- implementation of the key schedule.
library ieee;
use ieee.std_logic_1164.all;
use std.env.all;

entity aes128_key_expansion_tb is
end entity;

architecture sim of aes128_key_expansion_tb is
    signal rk_in, rk_out : std_logic_vector(127 downto 0) := (others => '0');
    signal rcon : std_logic_vector(7 downto 0) := x"01";
begin
    dut : entity work.aes128_key_expansion port map (rk_in => rk_in, rcon => rcon, rk_out => rk_out);

    stim : process
        type rk_arr is array (0 to 10) of std_logic_vector(127 downto 0);
        constant A1 : rk_arr := (
            x"2b7e151628aed2a6abf7158809cf4f3c", x"a0fafe1788542cb123a339392a6c7605",
            x"f2c295f27a96b9435935807a7359f67f", x"3d80477d4716fe3e1e237e446d7a883b",
            x"ef44a541a8525b7fb671253bdb0bad00", x"d4d1c6f87c839d87caf2b8bc11f915bc",
            x"6d88a37a110b3efddbf98641ca0093fd", x"4e54f70e5f5fc9f384a64fb24ea6dc4f",
            x"ead27321b58dbad2312bf5607f8d292f", x"ac7766f319fadc2128d12941575c006e",
            x"d014f9a8c9ee2589e13f0cc8b6630ca6");
        type rc_arr is array (1 to 10) of std_logic_vector(7 downto 0);
        constant RC_TAB : rc_arr := (x"01", x"02", x"04", x"08", x"10", x"20", x"40", x"80", x"1B", x"36");
        variable k : std_logic_vector(127 downto 0);

        procedure last_key (key0, expect : std_logic_vector(127 downto 0); msg : string) is
            variable cur : std_logic_vector(127 downto 0) := key0;
        begin
            for r in 1 to 10 loop
                rk_in <= cur; rcon <= RC_TAB(r); wait for 1 ns;
                cur := rk_out;
            end loop;
            assert cur = expect report msg & ": round key 10 mismatch" severity failure;
            report msg & " PASS";
        end procedure;
    begin
        k := A1(0);
        for r in 1 to 10 loop
            rk_in <= k; rcon <= RC_TAB(r); wait for 1 ns;
            assert rk_out = A1(r) report "FIPS-197 A.1 round key " & integer'image(r) & " mismatch" severity failure;
            k := rk_out;
        end loop;
        report "FIPS-197 A.1: all 10 derived round keys PASS";
        last_key(x"00000000000000000000000000000000", x"b4ef5bcb3e92e21123e951cf6f8f188e", "all-zero key");
        last_key(x"000102030405060708090a0b0c0d0e0f", x"13111d7fe3944a17f307a78b4d2b30c5", "key 00..0f");
        report "aes128_key_expansion_tb: ALL TESTS PASSED";
        finish;
    end process;
end architecture;
