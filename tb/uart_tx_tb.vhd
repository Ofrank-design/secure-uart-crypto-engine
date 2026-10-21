-- uart_tx_tb.vhd  Self-checking transmitter testbench (VHDL-2008).
-- An independent monitor decodes the TX pin using real-time sampling at
-- mid-bit instants, and checks frame-to-frame spacing (stop bit length).
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;

entity uart_tx_tb is
end entity;

architecture sim of uart_tx_tb is
    constant CLK_PERIOD : time := 20 ns;
    constant T_BIT      : time := 104167 ns;

    signal clk, rst   : std_logic := '0';
    signal data_in    : std_logic_vector(7 downto 0) := (others => '0');
    signal data_valid : std_logic := '0';
    signal ready, tx, busy, done : std_logic;

    type byte_arr is array (0 to 1023) of std_logic_vector(7 downto 0);
    signal mon_buf   : byte_arr;
    signal mon_count : natural := 0;
    signal done_cnt  : natural := 0;
    signal mon_en    : boolean := true;
begin
    clk <= not clk after CLK_PERIOD / 2;

    dut : entity work.uart_tx
        port map (clk => clk, rst => rst, data_in => data_in, data_valid => data_valid,
                  ready => ready, tx => tx, busy => busy, done => done);

    -- Protocol monitor on the serial pin
    monitor : process
        variable t_prev, t0 : time := 0 ns;
        variable d : std_logic_vector(7 downto 0);
        variable first : boolean := true;
    begin
        wait until tx = '0' and mon_en;
        t0 := now;
        if not first then
            assert t0 - t_prev >= 10 * T_BIT - 2 * CLK_PERIOD
                report "TX: frame spacing shorter than 10 bit times (stop bit too short)"
                severity failure;
        end if;
        first := false;
        wait for T_BIT / 2;
        assert tx = '0' report "TX: start bit not low at mid-bit" severity failure;
        for i in 0 to 7 loop
            wait for T_BIT;
            d(i) := tx;
        end loop;
        wait for T_BIT;
        assert tx = '1' report "TX: stop bit not high at mid-bit" severity failure;
        mon_buf(mon_count mod 1024) <= d;
        mon_count <= mon_count + 1;
        t_prev := t0;
        wait for T_BIT / 2;       -- finish the stop bit before hunting next start
    end process;

    -- done must be a one-clock pulse
    done_chk : process (clk)
        variable prev : std_logic := '0';
    begin
        if rising_edge(clk) then
            if done = '1' then
                assert prev = '0' report "done wider than one clock" severity failure;
                done_cnt <= done_cnt + 1;
            end if;
            prev := done;
        end if;
    end process;

    stim : process
        variable n0 : natural;

        procedure send (d : std_logic_vector(7 downto 0)) is
        begin
            wait until rising_edge(clk) and ready = '1';
            data_in    <= d;
            data_valid <= '1';
            wait until rising_edge(clk);
            data_valid <= '0';
            data_in    <= (others => 'X');   -- must not matter after acceptance
        end procedure;
    begin
        rst <= '1';
        wait for 10 * CLK_PERIOD;
        rst <= '0';
        wait for 5 * CLK_PERIOD;
        assert tx = '1' and ready = '1' and busy = '0' report "idle state wrong" severity failure;

        -- 1. Single byte, then busy/ready behaviour
        n0 := mon_count;
        send(x"A5");
        wait for 4 * CLK_PERIOD;
        assert ready = '0' and busy = '1' report "ready must drop while busy" severity failure;
        wait until done = '1';
        wait for 2 * CLK_PERIOD;
        assert ready = '1' and tx = '1' report "did not return to idle" severity failure;
        wait for T_BIT;
        assert mon_count - n0 = 1 and mon_buf(n0 mod 1024) = x"A5"
            report "T1: byte mismatch" severity failure;
        report "T1 PASS: single byte, handshake, done";

        -- 2. All 256 values, back-to-back
        n0 := mon_count;
        for v in 0 to 255 loop
            send(std_logic_vector(to_unsigned(v, 8)));
        end loop;
        wait until done = '1' and done_cnt >= 256;
        wait for 2 * T_BIT;
        assert mon_count - n0 = 256 report "T2: wrong frame count" severity failure;
        for v in 0 to 255 loop
            assert mon_buf((n0 + v) mod 1024) = std_logic_vector(to_unsigned(v, 8))
                report "T2: mismatch at " & integer'image(v) severity failure;
        end loop;
        report "T2 PASS: 256 back-to-back frames, spacing checked";

        -- 3. Reset while busy: line returns to idle high, ready returns
        mon_en <= false;
        send(x"FF");
        wait for 3 * T_BIT;
        rst <= '1';
        wait for 4 * CLK_PERIOD;
        rst <= '0';
        wait for 2 * CLK_PERIOD;
        assert tx = '1' and ready = '1' report "T3: not idle after reset" severity failure;
        wait for 12 * T_BIT;
        assert tx = '1' report "T3: tx moved after reset" severity failure;
        report "T3 PASS: reset while busy";

        report "uart_tx_tb: ALL TESTS PASSED";
        finish;
    end process;

    watchdog : process
    begin
        wait for 5 sec;
        report "uart_tx_tb: TIMEOUT" severity failure;
    end process;
end architecture;
