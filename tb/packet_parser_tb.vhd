-- packet_parser_tb.vhd  Positive and negative protocol tests for packet_parser.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;

entity packet_parser_tb is
end entity;

architecture sim of packet_parser_tb is
    constant MAXP : positive := 256;
    constant TMO  : positive := 1000;

    signal clk, rst : std_logic := '0';
    signal byte_in  : std_logic_vector(7 downto 0) := (others => '0');
    signal byte_valid, byte_rd : std_logic := '0';
    signal hdr_type : std_logic_vector(7 downto 0);
    signal hdr_seq  : std_logic_vector(15 downto 0);
    signal hdr_nonce : std_logic_vector(95 downto 0);
    signal hdr_len  : natural range 0 to MAXP;
    signal tag_out  : std_logic_vector(127 downto 0);
    signal buf_addr : natural range 0 to MAXP - 1 := 0;
    signal buf_data : std_logic_vector(7 downto 0);
    signal pkt_valid, pkt_ack, pkt_err : std_logic := '0';
    signal err_code : std_logic_vector(2 downto 0);
    signal err_cnt  : natural := 0;
    signal last_err : std_logic_vector(2 downto 0) := "000";
begin
    clk <= not clk after 10 ns;

    dut : entity work.packet_parser
        generic map (MAX_PAYLOAD => MAXP, TIMEOUT_CLKS => TMO)
        port map (clk => clk, rst => rst, byte_in => byte_in, byte_valid => byte_valid,
                  byte_rd => byte_rd, hdr_type => hdr_type, hdr_seq => hdr_seq,
                  hdr_nonce => hdr_nonce, hdr_len => hdr_len, tag_out => tag_out,
                  buf_addr => buf_addr, buf_data => buf_data, pkt_valid => pkt_valid,
                  pkt_ack => pkt_ack, pkt_err => pkt_err, err_code => err_code);

    errmon : process (clk)
    begin
        if rising_edge(clk) then
            if pkt_err = '1' then
                err_cnt  <= err_cnt + 1;
                last_err <= err_code;
            end if;
        end if;
    end process;

    stim : process
        variable e0 : natural;

        procedure send_byte (b : std_logic_vector(7 downto 0)) is
        begin
            byte_in <= b; byte_valid <= '1';
            loop
                wait until rising_edge(clk);
                exit when byte_rd = '1';
            end loop;
            byte_valid <= '0';
        end procedure;

        procedure send_u8 (n : natural) is
        begin
            send_byte(std_logic_vector(to_unsigned(n mod 256, 8)));
        end procedure;

        -- payload byte i / tag byte j / nonce byte k patterns
        function pay (seed, i : natural) return natural is begin return (seed + i * 3) mod 256; end function;
        function tg  (seed, j : natural) return natural is begin return (seed * 5 + j + 100) mod 256; end function;

        procedure send_packet (ver, typ, seq, len_decl, n_pay, n_tag, seed : natural;
                               skip_sync : boolean := false) is
        begin
            if not skip_sync then send_u8(16#A5#); end if;
            send_u8(ver); send_u8(typ);
            send_u8(seq / 256); send_u8(seq);
            for k in 0 to 11 loop send_u8(16#10# + k); end loop;
            send_u8(len_decl / 256); send_u8(len_decl);
            for i in 0 to n_pay - 1 loop send_u8(pay(seed, i)); end loop;
            for j in 0 to n_tag - 1 loop send_u8(tg(seed, j)); end loop;
        end procedure;

        procedure ack is
        begin
            pkt_ack <= '1'; wait until rising_edge(clk); pkt_ack <= '0';
            wait until rising_edge(clk);
        end procedure;

        procedure expect_valid (typ, seq, len, seed : natural; with_tag : boolean; msg : string) is
        begin
            if pkt_valid /= '1' then wait until pkt_valid = '1' for 100 us; end if;
            assert pkt_valid = '1' report msg & ": pkt_valid not asserted" severity failure;
            assert hdr_type = std_logic_vector(to_unsigned(typ, 8)) report msg & ": type" severity failure;
            assert hdr_seq = std_logic_vector(to_unsigned(seq, 16)) report msg & ": seq" severity failure;
            assert hdr_len = len report msg & ": len" severity failure;
            for k in 0 to 11 loop
                assert hdr_nonce(95 - 8 * k downto 88 - 8 * k) = std_logic_vector(to_unsigned(16#10# + k, 8))
                    report msg & ": nonce byte " & integer'image(k) severity failure;
            end loop;
            for i in 0 to len - 1 loop
                buf_addr <= i; wait for 1 ns;
                assert buf_data = std_logic_vector(to_unsigned(pay(seed, i), 8))
                    report msg & ": payload byte " & integer'image(i) severity failure;
            end loop;
            if with_tag then
                for j in 0 to 15 loop
                    assert tag_out(127 - 8 * j downto 120 - 8 * j) = std_logic_vector(to_unsigned(tg(seed, j), 8))
                        report msg & ": tag byte " & integer'image(j) severity failure;
                end loop;
            end if;
        end procedure;

        procedure expect_error (code : std_logic_vector(2 downto 0); before : natural; msg : string) is
        begin
            wait for 200 ns;
            assert err_cnt = before + 1 report msg & ": expected exactly one error" severity failure;
            assert last_err = code report msg & ": wrong error code" severity failure;
            assert pkt_valid = '0' report msg & ": pkt_valid asserted on error" severity failure;
        end procedure;
    begin
        rst <= '1'; wait for 100 ns; rst <= '0'; wait for 40 ns;

        -- 1. Valid DECRYPT_REQ, with garbage before SYNC
        send_u8(16#00#); send_u8(16#FF#); send_u8(16#12#);
        send_packet(1, 1, 16#BEEF#, 5, 5, 16, 7);
        expect_valid(1, 16#BEEF#, 5, 7, true, "T1");
        ack;
        report "T1 PASS: valid DECRYPT_REQ, garbage before SYNC ignored";

        -- 2. Maximum-length ENCRYPT_REQ (no tag)
        send_packet(1, 2, 16#0102#, MAXP, MAXP, 0, 33);
        expect_valid(2, 16#0102#, MAXP, 33, false, "T2");
        ack;
        report "T2 PASS: maximum payload, no tag";

        -- 3. Zero-length DECRYPT_REQ (tag only) and zero-length ENCRYPT_REQ
        send_packet(1, 1, 3, 0, 0, 16, 9);
        expect_valid(1, 3, 0, 9, true, "T3a");
        ack;
        send_packet(1, 2, 4, 0, 0, 0, 0);
        expect_valid(2, 4, 0, 0, false, "T3b");
        ack;
        report "T3 PASS: zero-length packets";

        -- 4. Payload containing 0xA5 is data, not a new sync (seed makes byte 0xA5 appear)
        send_packet(1, 2, 5, 40, 40, 0, 16#A5#);
        expect_valid(2, 5, 40, 16#A5#, false, "T4");
        ack;
        report "T4 PASS: 0xA5 inside payload treated as data";

        -- 5. Bad version / bad type / bad length, each followed by recovery
        e0 := err_cnt;
        send_packet(2, 1, 1, 0, 0, 0, 0);
        wait for 400 ns;
        assert err_cnt = e0 + 1 and last_err = "001" report "T5a: bad version" severity failure;
        -- remaining bytes of the rejected frame may be hunted; flush with a timeout gap
        wait for 40 us;
        e0 := err_cnt;
        send_packet(1, 9, 1, 0, 0, 0, 0);
        wait for 400 ns;
        assert err_cnt = e0 + 1 and last_err = "010" report "T5b: bad type" severity failure;
        wait for 40 us;
        e0 := err_cnt;
        send_u8(16#A5#); send_u8(1); send_u8(2); send_u8(0); send_u8(0);
        for k in 0 to 11 loop send_u8(0); end loop;
        send_u8(1); send_u8(1);   -- LEN = 257
        expect_error("011", e0, "T5c: bad length");
        wait for 40 us;
        send_packet(1, 1, 77, 3, 3, 16, 5);
        expect_valid(1, 77, 3, 5, true, "T5d: recovery");
        ack;
        report "T5 PASS: bad version/type/length rejected, recovery OK";

        -- 6. Truncated packet times out; idle hunting never times out
        wait for 3000 * 20 ns;
        e0 := err_cnt;
        wait for 3000 * 20 ns;
        assert err_cnt = e0 report "T6: timeout while hunting" severity failure;
        send_u8(16#A5#); send_u8(1); send_u8(1); send_u8(0);
        wait for (TMO + 50) * 20 ns;
        assert err_cnt = e0 + 1 and last_err = "100" report "T6: truncated packet timeout" severity failure;
        send_packet(1, 1, 88, 2, 2, 16, 6);
        expect_valid(1, 88, 2, 6, true, "T6: recovery");
        ack;
        report "T6 PASS: truncation timeout and recovery";

        -- 7. Backpressure: held packet blocks reading; next packet parsed after ack
        send_packet(1, 2, 100, 4, 4, 0, 1);
        expect_valid(2, 100, 4, 1, false, "T7a");
        byte_in <= x"A5"; byte_valid <= '1';
        wait for 20 * 20 ns;
        assert byte_rd = '0' report "T7: byte consumed while packet held" severity failure;
        pkt_ack <= '1'; wait until rising_edge(clk); pkt_ack <= '0';
        loop
            wait until rising_edge(clk);
            exit when byte_rd = '1';
        end loop;
        byte_valid <= '0';
        send_packet(1, 2, 101, 2, 2, 0, 2, true);
        expect_valid(2, 101, 2, 2, false, "T7b");
        ack;
        report "T7 PASS: backpressure while packet held";

        -- 8. Reset mid-packet
        send_u8(16#A5#); send_u8(1); send_u8(1); send_u8(0); send_u8(1);
        rst <= '1'; wait until rising_edge(clk); wait until rising_edge(clk); rst <= '0';
        wait for 100 ns;
        assert pkt_valid = '0' report "T8: pkt_valid after reset" severity failure;
        send_packet(1, 1, 55, 1, 1, 16, 4);
        expect_valid(1, 55, 1, 4, true, "T8: recovery");
        ack;
        report "T8 PASS: reset mid-packet";

        report "packet_parser_tb: ALL TESTS PASSED";
        finish;
    end process;

    watchdog : process
    begin
        wait for 50 ms;
        report "packet_parser_tb: TIMEOUT" severity failure;
    end process;
end architecture;
