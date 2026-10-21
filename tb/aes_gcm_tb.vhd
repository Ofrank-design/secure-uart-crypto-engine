-- aes_gcm_tb.vhd  Known-answer and negative tests for aes_gcm_engine.
-- Vectors come from tests/reference_vectors/gcm_vectors.txt, produced by an independent
-- implementation (scripts/gen_gcm_vectors.py; published NIST/McGrew-Viega cases 1-4 are
-- cross-checked there). Per vector: encrypt, decrypt, and four tamper cases that must
-- fail authentication (tag bit, ciphertext bit, AAD bit, IV bit).
-- Final partial blocks are padded with 0xA5 garbage to prove the engine masks them.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use std.env.all;

entity aes_gcm_tb is
end entity;

architecture sim of aes_gcm_tb is
    signal clk, rst, start, decrypt : std_logic := '0';
    signal key      : std_logic_vector(127 downto 0) := (others => '0');
    signal iv       : std_logic_vector(95 downto 0) := (others => '0');
    signal aad_len, data_len : natural range 0 to 4095 := 0;
    signal tag_in   : std_logic_vector(127 downto 0) := (others => '0');
    signal in_ready, in_is_aad, in_valid : std_logic := '0';
    signal in_block : std_logic_vector(127 downto 0) := (others => '0');
    signal out_valid, busy, done, auth_ok, eng_error : std_logic;
    signal err_cnt : natural := 0;
    signal out_block, tag_out : std_logic_vector(127 downto 0);
    signal out_bytes : natural range 0 to 16;

    subtype byte_t is std_logic_vector(7 downto 0);
    type bytes_t is array (0 to 127) of byte_t;
begin
    clk <= not clk after 10 ns;

    dut : entity work.aes_gcm_engine
        port map (clk => clk, rst => rst, start => start, decrypt => decrypt, key => key, iv => iv,
                  aad_len => aad_len, data_len => data_len, tag_in => tag_in,
                  in_ready => in_ready, in_is_aad => in_is_aad, in_valid => in_valid, in_block => in_block,
                  out_valid => out_valid, out_block => out_block, out_bytes => out_bytes,
                  busy => busy, done => done, error => eng_error, tag_out => tag_out, auth_ok => auth_ok);

    err_mon : process (clk)
    begin
        if rising_edge(clk) and eng_error = '1' then err_cnt <= err_cnt + 1; end if;
    end process;

    stim : process
        file f : text open read_mode is "tests/reference_vectors/gcm_vectors.txt";
        variable l : line;
        variable nvec : natural := 0;

        variable k_b, iv_b, aad_b, pt_b, ct_b, tag_b : bytes_t;
        variable k_n, iv_n, aad_n, pt_n, ct_n, tag_n : natural;
        variable obuf   : bytes_t;
        variable otag   : std_logic_vector(127 downto 0);
        variable ok     : std_logic;
        variable onum   : natural;
        variable mod_b  : bytes_t;

        function hex_val (c : character) return natural is
        begin
            case c is
                when '0' to '9' => return character'pos(c) - character'pos('0');
                when 'a' to 'f' => return character'pos(c) - character'pos('a') + 10;
                when 'A' to 'F' => return character'pos(c) - character'pos('A') + 10;
                when others => report "bad hex char" severity failure; return 0;
            end case;
        end function;

        procedure parse_hex (s : string; buf : out bytes_t; n : out natural) is
            variable cnt : natural;
        begin
            buf := (others => (others => '0'));
            if s'length = 1 and s(s'left) = '-' then
                n := 0;
            else
                cnt := s'length / 2;
                for i in 0 to cnt - 1 loop
                    buf(i) := std_logic_vector(to_unsigned(hex_val(s(s'left + 2 * i)) * 16 +
                                                           hex_val(s(s'left + 2 * i + 1)), 8));
                end loop;
                n := cnt;
            end if;
        end procedure;

        procedure get_tok (ln : string; pos : inout natural; s : out natural; e : out natural) is
        begin
            while pos <= ln'right and ln(pos) = ' ' loop pos := pos + 1; end loop;
            s := pos;
            while pos <= ln'right and ln(pos) /= ' ' loop pos := pos + 1; end loop;
            e := pos - 1;
        end procedure;

        function pack (b : bytes_t; n : natural) return std_logic_vector is
            variable r : std_logic_vector(8 * n - 1 downto 0);
        begin
            for i in 0 to n - 1 loop
                r(8 * n - 1 - 8 * i downto 8 * n - 8 - 8 * i) := b(i);
            end loop;
            return r;
        end function;

        function get_block (b : bytes_t; len, idx : natural) return std_logic_vector is
            variable r : std_logic_vector(127 downto 0);
        begin
            for i in 0 to 15 loop
                if 16 * idx + i < len then
                    r(127 - 8 * i downto 120 - 8 * i) := b(16 * idx + i);
                else
                    r(127 - 8 * i downto 120 - 8 * i) := x"A5";   -- garbage padding
                end if;
            end loop;
            return r;
        end function;

        procedure run (dec : std_logic; k : std_logic_vector(127 downto 0);
                       ivv : std_logic_vector(95 downto 0);
                       aad : bytes_t; alen : natural; dat : bytes_t; dlen : natural;
                       tg : std_logic_vector(127 downto 0);
                       variable ob : out bytes_t; variable otg : out std_logic_vector(127 downto 0);
                       variable okv : out std_logic; variable nout : out natural) is
            variable ai, di, oi : natural := 0;
        begin
            ob := (others => (others => '0'));
            decrypt <= dec; key <= k; iv <= ivv; aad_len <= alen; data_len <= dlen; tag_in <= tg;
            start <= '1';
            wait until rising_edge(clk);
            start <= '0';
            loop
                wait until rising_edge(clk);
                if out_valid = '1' then
                    for i in 0 to out_bytes - 1 loop
                        ob(oi * 16 + i) := out_block(127 - 8 * i downto 120 - 8 * i);
                    end loop;
                    oi := oi + 1;
                end if;
                if done = '1' then
                    otg := tag_out; okv := auth_ok; nout := oi;
                    exit;
                end if;
                if in_valid = '1' and in_ready = '1' then
                    in_valid <= '0';
                    if in_is_aad = '1' then ai := ai + 1; else di := di + 1; end if;
                elsif in_ready = '1' and in_valid = '0' then
                    in_valid <= '1';
                    if in_is_aad = '1' then in_block <= get_block(aad, alen, ai);
                    else in_block <= get_block(dat, dlen, di); end if;
                end if;
            end loop;
            wait until rising_edge(clk);
        end procedure;

        variable ln_s : natural;
        variable p, s, e : natural;
        variable kk  : std_logic_vector(127 downto 0);
        variable ivv : std_logic_vector(95 downto 0);
        variable tgv : std_logic_vector(127 downto 0);
        variable lbuf : line;
    begin
        rst <= '1'; wait for 50 ns; rst <= '0'; wait until rising_edge(clk);

        while not endfile(f) loop
            readline(f, l);
            next when l'length = 0;
            p := l'left;
            get_tok(l.all, p, s, e); parse_hex(l.all(s to e), k_b, k_n);
            get_tok(l.all, p, s, e); parse_hex(l.all(s to e), iv_b, iv_n);
            get_tok(l.all, p, s, e); parse_hex(l.all(s to e), aad_b, aad_n);
            get_tok(l.all, p, s, e); parse_hex(l.all(s to e), pt_b, pt_n);
            get_tok(l.all, p, s, e); parse_hex(l.all(s to e), ct_b, ct_n);
            get_tok(l.all, p, s, e); parse_hex(l.all(s to e), tag_b, tag_n);
            assert k_n = 16 and iv_n = 12 and tag_n = 16 and pt_n = ct_n
                report "malformed vector line" severity failure;
            kk := pack(k_b, 16); ivv := pack(iv_b, 12); tgv := pack(tag_b, 16);
            nvec := nvec + 1;

            -- encrypt
            run('0', kk, ivv, aad_b, aad_n, pt_b, pt_n, tgv, obuf, otag, ok, onum);
            assert onum = (pt_n + 15) / 16 report "enc: block count, vector " & integer'image(nvec) severity failure;
            for i in 0 to pt_n - 1 loop
                assert obuf(i) = ct_b(i) report "enc: ciphertext byte " & integer'image(i) &
                    " vector " & integer'image(nvec) severity failure;
            end loop;
            assert otag = tgv report "enc: tag mismatch, vector " & integer'image(nvec) severity failure;

            -- decrypt with correct tag
            run('1', kk, ivv, aad_b, aad_n, ct_b, ct_n, tgv, obuf, otag, ok, onum);
            for i in 0 to pt_n - 1 loop
                assert obuf(i) = pt_b(i) report "dec: plaintext byte " & integer'image(i) &
                    " vector " & integer'image(nvec) severity failure;
            end loop;
            assert ok = '1' and otag = tgv report "dec: authentication failed, vector " & integer'image(nvec) severity failure;

            -- tamper: tag
            run('1', kk, ivv, aad_b, aad_n, ct_b, ct_n, tgv xor x"00000000000000000000000000000001",
                obuf, otag, ok, onum);
            assert ok = '0' report "tamper tag accepted, vector " & integer'image(nvec) severity failure;
            -- tamper: IV
            run('1', kk, ivv xor x"000000000000000000000100", aad_b, aad_n, ct_b, ct_n, tgv,
                obuf, otag, ok, onum);
            assert ok = '0' report "tamper IV accepted, vector " & integer'image(nvec) severity failure;
            -- tamper: ciphertext
            if ct_n > 0 then
                mod_b := ct_b; mod_b(ct_n - 1) := mod_b(ct_n - 1) xor x"80";
                run('1', kk, ivv, aad_b, aad_n, mod_b, ct_n, tgv, obuf, otag, ok, onum);
                assert ok = '0' report "tamper ciphertext accepted, vector " & integer'image(nvec) severity failure;
            end if;
            -- tamper: AAD
            if aad_n > 0 then
                mod_b := aad_b; mod_b(0) := mod_b(0) xor x"01";
                run('1', kk, ivv, mod_b, aad_n, ct_b, ct_n, tgv, obuf, otag, ok, onum);
                assert ok = '0' report "tamper AAD accepted, vector " & integer'image(nvec) severity failure;
            end if;
        end loop;

        -- start while busy: error pulse, running transaction unaffected
        assert err_cnt = 0 report "engine error pulsed during legal use" severity failure;
        run('0', kk, ivv, aad_b, 0, pt_b, 0, tgv, obuf, otag, ok, onum);        -- reference tag, no data
        decrypt <= '0'; key <= kk; iv <= ivv; aad_len <= 0; data_len <= 0; tag_in <= tgv;
        start <= '1'; wait until rising_edge(clk); start <= '0';
        for i in 1 to 30 loop wait until rising_edge(clk); end loop;
        key <= not kk;                                      -- a corrupting second start must not matter
        start <= '1'; wait until rising_edge(clk); start <= '0';
        wait until done = '1' for 100 us;
        assert done = '1' report "misuse: transaction did not complete" severity failure;
        assert err_cnt = 1 report "misuse: expected exactly one error pulse, got " & integer'image(err_cnt) severity failure;
        assert tag_out = otag report "misuse: tag changed by start-while-busy" severity failure;
        wait until rising_edge(clk);
        report "start-while-busy: error pulse, transaction intact PASS";

        report "aes_gcm_tb: " & integer'image(nvec) & " vectors x (enc, dec, tamper) PASSED";
        report "aes_gcm_tb: ALL TESTS PASSED";
        finish;
    end process;

    watchdog : process
    begin
        wait for 500 ms;
        report "aes_gcm_tb: TIMEOUT" severity failure;
    end process;
end architecture;
