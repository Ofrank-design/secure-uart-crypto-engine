-- uart_tx.vhd  8-N-1 UART transmitter. Bit timing from a 1x fractional tick.
-- Handshake: a byte is accepted on the clock edge where data_valid and ready
-- are both '1'. ready is high only in IDLE. 'done' pulses one clock when the
-- stop bit has been held for one full bit period.
-- Note: frame start waits for the next bit tick (<= 1 bit of latency), so
-- back-to-back frames may carry extra idle time. Stop bit is always >= 1 bit.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is
    generic (
        CLK_FREQ_HZ : positive := 50_000_000;
        BAUD_RATE   : positive := 9_600
    );
    port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        data_in    : in  std_logic_vector(7 downto 0);
        data_valid : in  std_logic;
        ready      : out std_logic;
        tx         : out std_logic;
        busy       : out std_logic;
        done       : out std_logic
    );
end entity;

architecture rtl of uart_tx is
    type state_t is (IDLE, START_WAIT, DATA_BITS, STOP_BIT, STOP_HOLD);
    signal state   : state_t := IDLE;
    signal tick    : std_logic;
    signal shreg   : std_logic_vector(7 downto 0) := (others => '0');
    signal bit_idx : unsigned(2 downto 0) := (others => '0');
begin
    u_timing : entity work.uart_timing
        generic map (CLK_FREQ_HZ => CLK_FREQ_HZ, BAUD_RATE => BAUD_RATE, OVERSAMPLE => 1)
        port map (clk => clk, rst => rst, tick => tick);

    process (clk)
    begin
        if rising_edge(clk) then
            done <= '0';
            if rst = '1' then
                state   <= IDLE;
                tx      <= '1';
                bit_idx <= (others => '0');
            else
                case state is
                    when IDLE =>
                        tx <= '1';
                        if data_valid = '1' then
                            shreg <= data_in;
                            state <= START_WAIT;
                        end if;

                    when START_WAIT =>
                        if tick = '1' then
                            tx      <= '0';                 -- start bit
                            bit_idx <= (others => '0');
                            state   <= DATA_BITS;
                        end if;

                    when DATA_BITS =>
                        if tick = '1' then
                            tx    <= shreg(0);              -- LSB first
                            shreg <= '0' & shreg(7 downto 1);
                            if bit_idx = 7 then
                                state <= STOP_BIT;
                            else
                                bit_idx <= bit_idx + 1;
                            end if;
                        end if;

                    when STOP_BIT =>
                        if tick = '1' then
                            tx    <= '1';                   -- stop bit begins
                            state <= STOP_HOLD;
                        end if;

                    when STOP_HOLD =>
                        if tick = '1' then                  -- stop bit lasted 1 bit
                            done  <= '1';
                            state <= IDLE;
                        end if;
                end case;
            end if;
        end if;
    end process;

    ready <= '1' when state = IDLE else '0';
    busy  <= '0' when state = IDLE else '1';
end architecture;
