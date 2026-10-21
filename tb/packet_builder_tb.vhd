-- packet_builder_tb.vhd  Frame serialisation, payload read port, tag, error frames, and
-- FIFO backpressure (full toggled pseudo-randomly: no byte may be lost or repeated).
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.env.all;

entity packet_builder_tb is
end entity;

architecture sim of packet_builder_tb is
    constant MAXP : positive := 256;
    constant NB   : positive := 16;
    signal clk, rst, start, busy, done : std_logic := '0';
    signal r_type, r_code : std_logic_vector(7 downto 0) := (others => '0');
    signal r_seq : std_logic_vector(15 downto 0) := (others => '0');
    signal r_nonce : std_logic_vector(95 downto 0) := (others => '0');
    signal r_len : natural range 0 to MAXP := 0;
    signal r_tag_f, r_err : std_logic := '0';
    signal r_tag : std_logic_vector(127 downto 0) := (others => '0');
    signal pay_blk : natural range 0 to NB - 1;
    signal pay_byte : natural range 0 to 15;
    signal pay_data : std_logic_vector(7 downto 0);
    signal wr_en, full : std_logic;
    signal wr_data : std_logic_vector(7 downto 0);
    signal full_en : std_logic := '0';          -- enable random backpressure
    signal full_r  : std_logic := '0';

    type bytes_t is array (0 to 511) of std_logic_vector(7 downto 0);
    signal got : bytes_t;
    signal n_got : natural := 0;
    signal done_cnt : natural := 0;
begin
    clk <= not clk after 10 ns;
    full <= full_r;

    dut : entity work.packet_builder
        generic map (MAX_PAYLOAD => MAXP)
        port map (clk => clk, rst => rst, start => start, busy => busy, done => done,
                  resp_type => r_type, resp_seq => r_seq, resp_nonce => r_nonce, resp_len => r_len,
                  resp_has_tag => r_tag_f, resp_is_err => r_err, resp_code => r_code, resp_tag => r_tag,
                  pay_blk => pay_blk, pay_byte => pay_byte, pay_data => pay_data,
                  wr_en => wr_en, wr_data => wr_data, full => full);

    -- payload memory model: byte k = (3k + 11) mod 256
    pay_data <= std_logic_vector(to_unsigned((3 * (16 * pay_blk + pay_byte) + 11) mod 256, 8));

    -- random backpressure
    bp : process (clk)
        variable s1, s2 : positive := 5;
        variable r : real;
    begin
        if rising_edge(clk) then
            uniform(s1, s2, r);
            if full_en = '1' and r < 0.4 then full_r <= '1'; else full_r <= '0'; end if;
        end if;
    end process;

    -- FIFO-side capture: a byte is written on every edge where wr_en='1'
    cap : process (clk)
        variable n : natural := 0;
    begin
        if rising_edge(clk) then
            if wr_en = '1' then
                assert full = '0' report "wr_en while full" severity failure;
                got(n mod 512) <= wr_data; n := n + 1; n_got <= n;
            end if;
            if done = '1' then done_cnt <= done_cnt + 1; end if;
        end if;
    end process;

    stim : process
        variable base : natural;
        variable exp  : bytes_t;
        variable ne   : natural;

        function u8 (n : natural) return std_logic_vector is
        begin return std_logic_vector(to_unsigned(n mod 256, 8)); end function;

        procedure build (typ : natural; seq : natural; len : natural; tagf : std_logic; err : std_logic;
                         code : natural; msg : string) is
            variable d0 : natural;
        begin
            base := n_got; d0 := done_cnt;
            r_type <= u8(typ); r_seq <= std_logic_vector(to_unsigned(seq, 16));
            for k in 0 to 11 loop r_nonce(95 - 8 * k downto 88 - 8 * k) <= u8(16#40# + k); end loop;
            r_len <= len; r_tag_f <= tagf; r_err <= err; r_code <= u8(code);
            for k in 0 to 15 loop r_tag(127 - 8 * k downto 120 - 8 * k) <= u8(16#E0# + k); end loop;
            wait until rising_edge(clk);
            start <= '1'; wait until rising_edge(clk); start <= '0';
            wait for 1 ns;
            assert busy = '1' or done = '1' report msg & ": not busy after start" severity failure;
            wait until done = '1' for 200 us;
            wait until rising_edge(clk); wait until rising_edge(clk);
            assert done_cnt = d0 + 1 report msg & ": expected exactly one done pulse" severity failure;
            -- expected frame
            ne := 0;
            exp(ne) := x"A5"; ne := ne + 1;  exp(ne) := x"01"; ne := ne + 1;
            exp(ne) := u8(typ); ne := ne + 1;
            exp(ne) := u8(seq / 256); ne := ne + 1; exp(ne) := u8(seq); ne := ne + 1;
            for k in 0 to 11 loop exp(ne) := u8(16#40# + k); ne := ne + 1; end loop;
            if err = '1' then
                exp(ne) := x"00"; ne := ne + 1; exp(ne) := x"01"; ne := ne + 1;
                exp(ne) := u8(code); ne := ne + 1;
            else
                exp(ne) := u8(len / 256); ne := ne + 1; exp(ne) := u8(len); ne := ne + 1;
                for k in 0 to len - 1 loop exp(ne) := u8(3 * k + 11); ne := ne + 1; end loop;
            end if;
            if tagf = '1' then
                for k in 0 to 15 loop exp(ne) := u8(16#E0# + k); ne := ne + 1; end loop;
            end if;
            assert n_got - base = ne report msg & ": frame length " & integer'image(n_got - base) &
                " expected " & integer'image(ne) severity failure;
            for k in 0 to ne - 1 loop
                assert got((base + k) mod 512) = exp(k)
                    report msg & ": byte " & integer'image(k) & " mismatch" severity failure;
            end loop;
            assert busy = '0' report msg & ": still busy after done" severity failure;
            report msg & " PASS (" & integer'image(ne) & " bytes)";
        end procedure;
    begin
        rst <= '1'; wait for 100 ns; rst <= '0'; wait for 60 ns;
        for pass in 0 to 1 loop
            if pass = 1 then full_en <= '1'; report "--- with random FIFO backpressure"; end if;
            build(16#E0#, 3, 1, '0', '1', 16#02#, "error frame");
            build(16#82#, 16#0102#, 5, '0', '0', 0, "data, no tag");
            build(16#82#, 7, 0, '0', '0', 0, "empty, no tag");
            build(16#81#, 9, 0, '1', '0', 0, "tag only");
            build(16#81#, 16#FFFF#, 33, '1', '0', 0, "33 bytes + tag");
            build(16#81#, 1, 16, '1', '0', 0, "exactly one block + tag");
            build(16#82#, 2, 17, '0', '0', 0, "block boundary +1");
            build(16#81#, 5, MAXP, '1', '0', 0, "maximum payload + tag");
        end loop;
        report "packet_builder_tb: ALL TESTS PASSED";
        finish;
    end process;

    watchdog : process
    begin
        wait for 50 ms;
        report "packet_builder_tb: TIMEOUT" severity failure;
    end process;
end architecture;
