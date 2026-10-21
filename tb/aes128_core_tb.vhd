-- aes128_core_tb.vhd  FIPS-197 known-answer tests (Appendix B, Appendix C.1) plus the
-- all-zero key/plaintext vector, and a back-to-back reuse check.
library ieee;
use ieee.std_logic_1164.all;
use std.env.all;

entity aes128_core_tb is
end entity;

architecture sim of aes128_core_tb is
    signal clk, rst, start, busy, done : std_logic := '0';
    signal key, bin, bout : std_logic_vector(127 downto 0) := (others => '0');
begin
    clk <= not clk after 10 ns;
    dut : entity work.aes128_core
        port map (clk => clk, rst => rst, start => start, key => key, block_in => bin,
                  busy => busy, done => done, block_out => bout);

    stim : process
        procedure kat (k, p, c : std_logic_vector(127 downto 0); msg : string) is
            variable cycles : natural := 0;
        begin
            key <= k; bin <= p; start <= '1';
            wait until rising_edge(clk);
            start <= '0';
            loop
                wait until rising_edge(clk);
                cycles := cycles + 1;
                exit when done = '1';
                assert cycles < 20 report msg & ": no done" severity failure;
            end loop;
            assert bout = c report msg & ": ciphertext mismatch" severity failure;
            assert cycles = 11 report msg & ": unexpected latency " & integer'image(cycles) severity failure;
            report msg & " PASS";
        end procedure;
    begin
        rst <= '1'; wait for 50 ns; rst <= '0'; wait until rising_edge(clk);
        kat(x"000102030405060708090a0b0c0d0e0f", x"00112233445566778899aabbccddeeff",
            x"69c4e0d86a7b0430d8cdb78070b4c55a", "FIPS-197 C.1");
        kat(x"2b7e151628aed2a6abf7158809cf4f3c", x"3243f6a8885a308d313198a2e0370734",
            x"3925841d02dc09fbdc118597196a0b32", "FIPS-197 App.B");
        kat(x"00000000000000000000000000000000", x"00000000000000000000000000000000",
            x"66e94bd4ef8a2c3b884cfa59ca342b2e", "zero key/pt");
        kat(x"000102030405060708090a0b0c0d0e0f", x"00112233445566778899aabbccddeeff",
            x"69c4e0d86a7b0430d8cdb78070b4c55a", "reuse after other key");
        report "aes128_core_tb: ALL TESTS PASSED";
        finish;
    end process;
end architecture;
