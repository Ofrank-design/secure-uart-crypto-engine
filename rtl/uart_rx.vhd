-- uart_rx.vhd  8-N-1 UART receiver, 16x oversampling via clock enable.
-- Policy: after a framing error the receiver waits for the line to return high
-- before hunting for a new start bit (handles break / mid-frame resync safely).
-- framing_err and data_valid are one-clock pulses and are mutually exclusive.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx is
    generic (
        CLK_FREQ_HZ : positive := 50_000_000;
        BAUD_RATE   : positive := 9_600
    );
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        rx          : in  std_logic;
        data_out    : out std_logic_vector(7 downto 0);
        data_valid  : out std_logic;
        busy        : out std_logic;
        framing_err : out std_logic
    );
end entity;

architecture rtl of uart_rx is
    type state_t is (IDLE, START_BIT, DATA_BITS, STOP_BIT, ERROR_WAIT);
    signal state : state_t := IDLE;

    signal sync : std_logic_vector(1 downto 0) := "11";
    attribute async_reg : string;
    attribute async_reg of sync : signal is "true";
    signal rx_s : std_logic;

    signal tick    : std_logic;
    signal tcnt    : unsigned(3 downto 0) := (others => '0');
    signal bit_idx : unsigned(2 downto 0) := (others => '0');
    signal shreg   : std_logic_vector(7 downto 0) := (others => '0');
begin
    rx_s <= sync(1);

    u_timing : entity work.uart_timing
        generic map (CLK_FREQ_HZ => CLK_FREQ_HZ, BAUD_RATE => BAUD_RATE, OVERSAMPLE => 16)
        port map (clk => clk, rst => rst, tick => tick);

    process (clk)
    begin
        if rising_edge(clk) then
            sync        <= sync(0) & rx;
            data_valid  <= '0';
            framing_err <= '0';

            if rst = '1' then
                sync     <= "11";
                state    <= IDLE;
                tcnt     <= (others => '0');
                bit_idx  <= (others => '0');
                data_out <= (others => '0');
            else
                case state is
                    when IDLE =>
                        if rx_s = '0' then
                            tcnt  <= (others => '0');
                            state <= START_BIT;
                        end if;

                    when START_BIT =>            -- confirm near middle of start bit
                        if tick = '1' then
                            if tcnt = 6 then
                                if rx_s = '0' then
                                    tcnt    <= (others => '0');
                                    bit_idx <= (others => '0');
                                    state   <= DATA_BITS;
                                else
                                    state <= IDLE;    -- false start
                                end if;
                            else
                                tcnt <= tcnt + 1;
                            end if;
                        end if;

                    when DATA_BITS =>
                        if tick = '1' then
                            if tcnt = 15 then
                                tcnt  <= (others => '0');
                                shreg <= rx_s & shreg(7 downto 1);   -- LSB first
                                if bit_idx = 7 then
                                    state <= STOP_BIT;
                                else
                                    bit_idx <= bit_idx + 1;
                                end if;
                            else
                                tcnt <= tcnt + 1;
                            end if;
                        end if;

                    when STOP_BIT =>
                        if tick = '1' then
                            if tcnt = 15 then
                                if rx_s = '1' then
                                    data_out   <= shreg;
                                    data_valid <= '1';
                                    state      <= IDLE;
                                else
                                    framing_err <= '1';
                                    state       <= ERROR_WAIT;
                                end if;
                            else
                                tcnt <= tcnt + 1;
                            end if;
                        end if;

                    when ERROR_WAIT =>
                        if rx_s = '1' then
                            state <= IDLE;
                        end if;
                end case;
            end if;
        end if;
    end process;

    busy <= '0' when state = IDLE else '1';
end architecture;
