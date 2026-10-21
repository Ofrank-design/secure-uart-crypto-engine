-- uart_timing.vhd
-- Fractional clock-enable generator (phase accumulator). Produces a one-clock
-- 'tick' at an average rate of BAUD_RATE*OVERSAMPLE with no second fabric clock.
-- Rule: if acc + INC >= CLK_FREQ then acc <= acc + INC - CLK_FREQ and tick.
-- Long-term average is exact; per-tick jitter is at most one clock cycle.
library ieee;
use ieee.std_logic_1164.all;

entity uart_timing is
    generic (
        CLK_FREQ_HZ : positive := 50_000_000;
        BAUD_RATE   : positive := 9_600;
        OVERSAMPLE  : positive := 16
    );
    port (
        clk  : in  std_logic;
        rst  : in  std_logic;
        tick : out std_logic
    );
end entity;

architecture rtl of uart_timing is
    constant INC : natural := BAUD_RATE * OVERSAMPLE;
    signal acc   : natural range 0 to CLK_FREQ_HZ := 0;
begin
    assert INC < CLK_FREQ_HZ
        report "uart_timing: BAUD_RATE*OVERSAMPLE must be below CLK_FREQ_HZ"
        severity failure;

    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                acc  <= 0;
                tick <= '0';
            elsif acc + INC >= CLK_FREQ_HZ then
                acc  <= acc + INC - CLK_FREQ_HZ;
                tick <= '1';
            else
                acc  <= acc + INC;
                tick <= '0';
            end if;
        end if;
    end process;
end architecture;
