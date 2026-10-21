-- uart_timing_tb.vhd  Verifies exact long-term tick rate and one-clock pulses.
library ieee;
use ieee.std_logic_1164.all;
use std.env.all;

entity uart_timing_tb is
end entity;

architecture sim of uart_timing_tb is
    constant CLK_PERIOD : time := 20 ns;
    signal clk, rst : std_logic := '0';
    signal tick16, tick1 : std_logic;
    signal c16, c1 : natural := 0;
begin
    clk <= not clk after CLK_PERIOD / 2;

    d16 : entity work.uart_timing generic map (OVERSAMPLE => 16)
        port map (clk => clk, rst => rst, tick => tick16);
    d1  : entity work.uart_timing generic map (OVERSAMPLE => 1)
        port map (clk => clk, rst => rst, tick => tick1);

    count : process (clk)
        variable p16, p1 : std_logic := '0';
    begin
        if rising_edge(clk) then
            if tick16 = '1' then
                assert p16 = '0' report "16x tick wider than one clock" severity failure;
                c16 <= c16 + 1;
            end if;
            if tick1 = '1' then
                assert p1 = '0' report "1x tick wider than one clock" severity failure;
                c1 <= c1 + 1;
            end if;
            p16 := tick16; p1 := tick1;
        end if;
    end process;

    check : process
    begin
        rst <= '1'; wait for 5 * CLK_PERIOD; rst <= '0';
        wait for 50 ms;                  -- 2,500,000 clocks
        wait for 2 * CLK_PERIOD;
        -- expected: 153600 * 0.05 = 7680 ; 9600 * 0.05 = 480
        assert c16 >= 7679 and c16 <= 7681
            report "16x tick count off: " & integer'image(c16) severity failure;
        assert c1 >= 479 and c1 <= 481
            report "1x tick count off: " & integer'image(c1) severity failure;
        report "uart_timing_tb: PASS  16x=" & integer'image(c16) & " 1x=" & integer'image(c1);
        finish;
    end process;
end architecture;
