-- uart_rx_tb.vhd  Self-checking receiver testbench (VHDL-2008).
-- RX stimulus uses real-time bit periods with an arbitrary phase offset, so
-- edges are NOT aligned to the 50 MHz clock.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;

entity uart_rx_tb is
end entity;

architecture sim of uart_rx_tb is
    constant CLK_PERIOD : time := 20 ns;
    constant T_BIT      : time := 104167 ns;   -- 1/9600 s, rounded to 1 ns

    signal clk, rst : std_logic := '0';
    signal rx       : std_logic := '1';
    signal data_out : std_logic_vector(7 downto 0);
    signal data_valid, busy, framing_err : std_logic;

    type byte_arr is array (0 to 1023) of std_logic_vector(7 downto 0);
    signal rx_buf   : byte_arr;
    signal rx_count : natural := 0;
    signal fe_count : natural := 0;
begin
    clk <= not clk after CLK_PERIOD / 2;

    dut : entity work.uart_rx
        port map (clk => clk, rst => rst, rx => rx, data_out => data_out,
                  data_valid => data_valid, busy => busy, framing_err => framing_err);

    -- Monitor: capture bytes, enforce one-clock pulses and mutual exclusion
    monitor : process (clk)
        variable prev_valid, prev_fe : std_logic := '0';
    begin
        if rising_edge(clk) then
            if data_valid = '1' then
                assert prev_valid = '0' report "data_valid wider than one clock" severity failure;
                assert framing_err = '0' report "valid and framing_err together" severity failure;
                rx_buf(rx_count mod 1024) <= data_out;
                rx_count <= rx_count + 1;
            end if;
            if framing_err = '1' then
                assert prev_fe = '0' report "framing_err wider than one clock" severity failure;
                fe_count <= fe_count + 1;
            end if;
            prev_valid := data_valid;
            prev_fe    := framing_err;
        end if;
    end process;

    stim : process
        variable n0, f0 : natural;

        procedure send_byte (d : std_logic_vector(7 downto 0);
                             tb : time := T_BIT;
                             stop : std_logic := '1') is
        begin
            rx <= '0'; wait for tb;
            for i in 0 to 7 loop
                rx <= d(i); wait for tb;
            end loop;
            rx <= stop; wait for tb;
        end procedure;

        procedure idle (t : time) is
        begin
            rx <= '1'; wait for t;
        end procedure;
    begin
        rst <= '1';
        wait for 10 * CLK_PERIOD;
        rst <= '0';
        wait for 7 ns;                     -- arbitrary phase vs. clock
        idle(3 * T_BIT);

        -- 1. All 256 byte values, back-to-back, nominal baud
        n0 := rx_count;
        for v in 0 to 255 loop
            send_byte(std_logic_vector(to_unsigned(v, 8)));
        end loop;
        idle(2 * T_BIT);
        assert rx_count - n0 = 256 report "T1: wrong byte count" severity failure;
        for v in 0 to 255 loop
            assert rx_buf((n0 + v) mod 1024) = std_logic_vector(to_unsigned(v, 8))
                report "T1: data mismatch at " & integer'image(v) severity failure;
        end loop;
        assert fe_count = 0 report "T1: unexpected framing error" severity failure;
        report "T1 PASS: all 256 byte values, back-to-back";

        -- 2. Baud tolerance: sender 3 % fast and 3 % slow, back-to-back
        for k in 0 to 1 loop
            n0 := rx_count;
            for v in 0 to 15 loop
                if k = 0 then
                    send_byte(std_logic_vector(to_unsigned((16#A5# + v * 7) mod 256, 8)), T_BIT * 97 / 100);
                else
                    send_byte(std_logic_vector(to_unsigned((16#A5# + v * 7) mod 256, 8)), T_BIT * 103 / 100);
                end if;
            end loop;
            idle(2 * T_BIT);
            assert rx_count - n0 = 16 report "T2: wrong count, k=" & integer'image(k) severity failure;
            for v in 0 to 15 loop
                assert rx_buf((n0 + v) mod 1024) = std_logic_vector(to_unsigned((16#A5# + v * 7) mod 256, 8))
                    report "T2: mismatch k=" & integer'image(k) severity failure;
            end loop;
        end loop;
        assert fe_count = 0 report "T2: unexpected framing error" severity failure;
        report "T2 PASS: +/-3 % baud tolerance";

        -- 3. Invalid stop bit -> framing error, no valid byte, clean recovery
        n0 := rx_count; f0 := fe_count;
        send_byte(x"41", T_BIT, '0');
        idle(2 * T_BIT);
        assert fe_count - f0 = 1 report "T3: expected one framing error" severity failure;
        assert rx_count = n0 report "T3: byte released despite bad stop bit" severity failure;
        send_byte(x"42");
        idle(2 * T_BIT);
        assert rx_count - n0 = 1 and rx_buf(n0 mod 1024) = x"42"
            report "T3: no recovery after framing error" severity failure;
        report "T3 PASS: framing error and recovery";

        -- 4. Start-bit glitch (20 % of a bit) is rejected
        n0 := rx_count; f0 := fe_count;
        rx <= '0'; wait for T_BIT / 5;
        idle(3 * T_BIT);
        assert rx_count = n0 and fe_count = f0 report "T4: glitch accepted" severity failure;
        send_byte(x"3C");
        idle(2 * T_BIT);
        assert rx_count - n0 = 1 and rx_buf(n0 mod 1024) = x"3C"
            report "T4: no recovery after glitch" severity failure;
        report "T4 PASS: start-bit glitch rejected";

        -- 5. Reset in the middle of a frame (line returns idle), then normal byte
        n0 := rx_count; f0 := fe_count;
        rx <= '0'; wait for T_BIT;
        rx <= '1'; wait for T_BIT;
        rx <= '0'; wait for T_BIT;
        rx <= '1'; wait for T_BIT / 2;
        rst <= '1'; wait for 4 * CLK_PERIOD; rst <= '0';
        idle(12 * T_BIT);
        assert rx_count = n0 and fe_count = f0 report "T5: output after mid-frame reset" severity failure;
        send_byte(x"C3");
        idle(2 * T_BIT);
        assert rx_count - n0 = 1 and rx_buf(n0 mod 1024) = x"C3"
            report "T5: no recovery after reset" severity failure;
        report "T5 PASS: reset during reception";

        -- 6. Long idle, then a byte
        idle(200 * T_BIT);
        n0 := rx_count;
        send_byte(x"96");
        idle(2 * T_BIT);
        assert rx_count - n0 = 1 and rx_buf(n0 mod 1024) = x"96"
            report "T6: failed after long idle" severity failure;
        report "T6 PASS: long idle";

        -- 7. Break condition (line held low for > one frame): exactly one framing error, no data,
        --    receiver waits for the line to return high, then recovers
        n0 := rx_count; f0 := fe_count;
        rx <= '0'; wait for 125 * T_BIT / 10;     -- 12.5 bit times low
        idle(3 * T_BIT);
        assert fe_count - f0 = 1 report "T7: break must give exactly one framing error, got " &
            integer'image(fe_count - f0) severity failure;
        assert rx_count = n0 report "T7: data released during break" severity failure;
        send_byte(x"5A");
        idle(2 * T_BIT);
        assert rx_count - n0 = 1 and rx_buf(n0 mod 1024) = x"5A" report "T7: no recovery after break" severity failure;
        report "T7 PASS: break condition and recovery";

        -- 8. Frames starting at different phases of the 50 MHz clock (0..18 ns offsets)
        n0 := rx_count; f0 := fe_count;
        for o in 0 to 6 loop
            idle(2 * T_BIT + o * 3 ns);
            send_byte(std_logic_vector(to_unsigned(16#40# + o, 8)));
        end loop;
        idle(2 * T_BIT);
        assert rx_count - n0 = 7 and fe_count = f0 report "T8: wrong count" severity failure;
        for o in 0 to 6 loop
            assert rx_buf((n0 + o) mod 1024) = std_logic_vector(to_unsigned(16#40# + o, 8))
                report "T8: data mismatch at offset " & integer'image(o * 3) & " ns" severity failure;
        end loop;
        report "T8 PASS: asynchronous phase offsets";

        report "uart_rx_tb: ALL TESTS PASSED";
        finish;
    end process;

    watchdog : process
    begin
        wait for 2 sec;
        report "uart_rx_tb: TIMEOUT" severity failure;
    end process;
end architecture;
