-- secure_uart_hardening_tb.vhd  Stress and boundary tests on the full device.
--  Instance A (FIFO_DEPTH=16): while the controller is stalled waiting for the nonce NV store,
--    flood the RX path. Checks: RX FIFO overflow is flagged and drops bytes without corrupting the
--    held packet, the response (39 bytes, larger than the 16-byte TX FIFO) arrives complete
--    (TX backpressure, nothing lost), junk does not produce frames, and the device recovers.
--  Instance B (ALLOW_UNAUTH_ENCRYPT=false): ENCRYPT_REQ is refused with E0 06 and the nonce NV
--    store is never touched.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;

entity secure_uart_hardening_tb is
end entity;

architecture sim of secure_uart_hardening_tb is
    constant CLK_PERIOD : time := 20 ns;
    constant BAUD_G     : positive := 115200;
    constant T_BIT      : time := 1 sec / BAUD_G;

    subtype byte_t is std_logic_vector(7 downto 0);
    type queue_t is array (0 to 1023) of byte_t;

    signal clk : std_logic := '0';
    signal rst_in : std_logic := '0';

    -- instance A
    signal a_rx, a_tx : std_logic := '1';
    signal a_creq, a_cack : std_logic;
    signal a_cval : std_logic_vector(63 downto 0);
    signal a_hold : std_logic := '1';             -- keep NV store from acknowledging
    signal a_rts : std_logic;
    signal a_ovf, a_ferr, a_perr, a_auth, a_replay, a_busy : std_logic;
    signal a_n_ovf, a_n_perr : natural := 0;
    signal a_q : queue_t; signal a_qw : natural := 0;
    signal a_stores : natural := 0;

    -- instance B
    signal b_rx, b_tx : std_logic := '1';
    signal b_creq, b_cack : std_logic;
    signal b_cval : std_logic_vector(63 downto 0);
    signal b_q : queue_t; signal b_qw : natural := 0;
    signal b_stores : natural := 0;
    signal b_ovf, b_ferr, b_perr, b_auth, b_replay, b_busy : std_logic;
    signal b_sreq : std_logic; signal b_sval : std_logic_vector(15 downto 0);
begin
    clk <= not clk after CLK_PERIOD / 2;

    dut_a : entity work.secure_uart_crypto_top
        generic map (BAUD_RATE => BAUD_G, FIFO_DEPTH => 16, PARSER_TIMEOUT_CLKS => 2_000_000)
        port map (clk => clk, rst_in => rst_in, uart_rx_pin => a_rx, uart_tx_pin => a_tx,
                  zeroize => '0', key_load => '0', key_in => (others => '0'),
                  ctr_init => x"0000000000002000", ctr_valid => '1',
                  ctr_store_req => a_creq, ctr_store_val => a_cval, ctr_store_ack => a_cack,
                  seq_init => x"0000", seq_have_init => '0', seq_valid => '1',
                  seq_store_req => open, seq_store_val => open, seq_store_ack => '0',
                  uart_rts_n => a_rts, busy => a_busy, st_framing_err => a_ferr, st_rx_overflow => a_ovf,
                  st_parse_err => a_perr, st_auth_fail => a_auth, st_replay => a_replay);

    dut_b : entity work.secure_uart_crypto_top
        generic map (BAUD_RATE => BAUD_G, ALLOW_UNAUTH_ENCRYPT => false)
        port map (clk => clk, rst_in => rst_in, uart_rx_pin => b_rx, uart_tx_pin => b_tx,
                  zeroize => '0', key_load => '0', key_in => (others => '0'),
                  ctr_init => x"0000000000003000", ctr_valid => '1',
                  ctr_store_req => b_creq, ctr_store_val => b_cval, ctr_store_ack => b_cack,
                  seq_init => x"0000", seq_have_init => '0', seq_valid => '1',
                  seq_store_req => b_sreq, seq_store_val => b_sval, seq_store_ack => '0',
                  busy => b_busy, st_framing_err => b_ferr, st_rx_overflow => b_ovf,
                  st_parse_err => b_perr, st_auth_fail => b_auth, st_replay => b_replay);

    -- NV model A: acknowledges only when a_hold = '0'
    nv_a : process
    begin
        a_cack <= '0';
        loop
            wait until rising_edge(clk) and a_creq = '1';
            a_stores <= a_stores + 1;
            wait until rising_edge(clk) and a_hold = '0';
            a_cack <= '1'; wait until rising_edge(clk); a_cack <= '0';
            wait until a_creq = '0';
        end loop;
    end process;

    -- NV model B: must never be used; counts requests
    nv_b : process
    begin
        b_cack <= '0';
        wait until b_creq = '1';
        b_stores <= b_stores + 1;
        wait;
    end process;

    cnt : process (clk)
    begin
        if rising_edge(clk) then
            if a_ovf = '1' then a_n_ovf <= a_n_ovf + 1; end if;
            if a_perr = '1' then a_n_perr <= a_n_perr + 1; end if;
        end if;
    end process;

    -- serial decoders
    mon_a : process
        variable d : byte_t; variable n : natural := 0;
    begin
        loop
            wait until a_tx = '0';
            wait for T_BIT / 2;
            for i in 0 to 7 loop wait for T_BIT; d(i) := a_tx; end loop;
            wait for T_BIT;
            assert a_tx = '1' report "A: stop bit" severity failure;
            a_q(n mod 1024) <= d; n := n + 1; a_qw <= n;
        end loop;
    end process;

    mon_b : process
        variable d : byte_t; variable n : natural := 0;
    begin
        loop
            wait until b_tx = '0';
            wait for T_BIT / 2;
            for i in 0 to 7 loop wait for T_BIT; d(i) := b_tx; end loop;
            wait for T_BIT;
            assert b_tx = '1' report "B: stop bit" severity failure;
            b_q(n mod 1024) <= d; n := n + 1; b_qw <= n;
        end loop;
    end process;

    stim : process
        procedure send_a (b : byte_t) is
        begin
            a_rx <= '0'; wait for T_BIT;
            for i in 0 to 7 loop a_rx <= b(i); wait for T_BIT; end loop;
            a_rx <= '1'; wait for T_BIT;
        end procedure;

        procedure send_b (b : byte_t) is
        begin
            b_rx <= '0'; wait for T_BIT;
            for i in 0 to 7 loop b_rx <= b(i); wait for T_BIT; end loop;
            b_rx <= '1'; wait for T_BIT;
        end procedure;

        -- ENCRYPT_REQ header + payload, 'n' payload bytes
        procedure send_enc_a (seq : natural; n : natural) is
        begin
            send_a(x"A5"); send_a(x"01"); send_a(x"02");
            send_a(std_logic_vector(to_unsigned(seq / 256, 8))); send_a(std_logic_vector(to_unsigned(seq mod 256, 8)));
            for k in 0 to 11 loop send_a(x"00"); end loop;
            send_a(x"00"); send_a(std_logic_vector(to_unsigned(n, 8)));
            for k in 0 to n - 1 loop send_a(std_logic_vector(to_unsigned(16#30# + k, 8))); end loop;
        end procedure;

        variable base : natural;
        variable nonce1 : unsigned(63 downto 0);
        type nonce_t is array (0 to 1) of unsigned(63 downto 0);
        variable nonces : nonce_t;
    begin
        rst_in <= '1'; wait for 10 * CLK_PERIOD; rst_in <= '0';
        wait for 100 * CLK_PERIOD;

        ---------------------------------------------------------------- A1: flood while stalled
        send_enc_a(1, 4);                           -- controller now waits on the NV store
        wait for 2000 * CLK_PERIOD;
        assert a_busy = '1' and a_stores = 1 report "A1: controller should be stalled on NV store" severity failure;
        for k in 0 to 59 loop send_a(x"55"); end loop;     -- 60 junk bytes into a 16-byte FIFO
        assert a_rts = '1' report "A1: RTS must be deasserted (stop sending) when the RX FIFO is more than half full" severity failure;
        assert a_n_ovf > 0 report "A1: RX FIFO overflow was not flagged" severity failure;
        assert a_qw = 0 report "A1: output produced while stalled" severity failure;
        report "A1 PASS: RX FIFO overflow flagged (" & integer'image(a_n_ovf) & " dropped bytes)";

        ---------------------------------------------------------------- A2: release; full response despite 16-byte TX FIFO
        a_hold <= '0';
        wait for 10 ms;                            -- 39 bytes need ~4 ms at 115200 baud
        assert a_qw = 39 report "A2: expected a 39-byte response, got " & integer'image(a_qw) severity failure;
        assert a_q(0) = x"A5" and a_q(1) = x"01" and a_q(2) = x"81" and a_q(3) = x"00" and a_q(4) = x"01"
            report "A2: response header wrong" severity failure;
        assert a_q(17) = x"00" and a_q(18) = x"04" report "A2: response length wrong" severity failure;
        for k in 0 to 7 loop nonces(0)(63 - 8 * k downto 56 - 8 * k) := unsigned(a_q(9 + k)); end loop;
        assert a_q(5) = x"C0" and a_q(6) = x"FF" and a_q(7) = x"EE" and a_q(8) = x"01"
            report "A2: nonce device-id prefix wrong" severity failure;
        assert nonces(0) = x"0000000000002000" report "A2: first nonce counter not the NV value" severity failure;
        assert a_rts = '0' report "A2: RTS must return to ready after the FIFO drains" severity failure;
        assert a_perr = '0' report "A2: parse error on junk (should be silently skipped)" severity failure;
        report "A2 PASS: 39-byte response through 16-byte TX FIFO, junk ignored";

        ---------------------------------------------------------------- A3: recovery, counter advances by exactly one
        base := a_qw;
        send_enc_a(2, 4);
        wait for 10 ms;
        assert a_qw = base + 39 report "A3: second response missing" severity failure;
        for k in 0 to 7 loop nonces(1)(63 - 8 * k downto 56 - 8 * k) := unsigned(a_q((base + 9 + k) mod 1024)); end loop;
        assert nonces(1) = nonces(0) + 1 report "A3: nonce counter did not advance by one" severity failure;
        assert a_q((base + 4) mod 1024) = x"02" report "A3: sequence number not echoed" severity failure;
        report "A3 PASS: recovery after flood, nonce counter +1";

        ---------------------------------------------------------------- B: encrypt disabled
        send_b(x"A5"); send_b(x"01"); send_b(x"02"); send_b(x"00"); send_b(x"07");
        for k in 0 to 11 loop send_b(x"00"); end loop;
        send_b(x"00"); send_b(x"02"); send_b(x"11"); send_b(x"22");
        wait for 5 ms;
        assert b_qw = 20 report "B: expected 20-byte error frame, got " & integer'image(b_qw) severity failure;
        assert b_q(2) = x"E0" and b_q(4) = x"07" and b_q(18) = x"01" and b_q(19) = x"06"
            report "B: wrong error frame (want E0, seq 7, code 06)" severity failure;
        assert b_stores = 0 report "B: nonce NV store touched although encrypt is disabled" severity failure;
        report "B PASS: ENCRYPT_REQ refused (code 06), NV store untouched";

        report "secure_uart_hardening_tb: ALL TESTS PASSED";
        finish;
    end process;

    watchdog : process
    begin
        wait for 2 sec;
        report "secure_uart_hardening_tb: TIMEOUT" severity failure;
    end process;
end architecture;
