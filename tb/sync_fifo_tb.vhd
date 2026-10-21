-- sync_fifo_tb.vhd  Directed + randomized scoreboard test of sync_fifo.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.env.all;

entity sync_fifo_tb is
end entity;

architecture sim of sync_fifo_tb is
    constant DEPTH : positive := 8;
    signal clk, rst : std_logic := '0';
    signal wr_en, rd_en : std_logic := '0';
    signal wr_data : std_logic_vector(7 downto 0) := (others => '0');
    signal rd_data : std_logic_vector(7 downto 0);
    signal full, empty, overflow, underflow : std_logic;
    signal level : natural range 0 to DEPTH;
    signal ovf_cnt, unf_cnt : natural := 0;
begin
    clk <= not clk after 10 ns;

    dut : entity work.sync_fifo
        generic map (WIDTH => 8, DEPTH => DEPTH)
        port map (clk => clk, rst => rst, wr_en => wr_en, wr_data => wr_data,
                  full => full, rd_en => rd_en, rd_data => rd_data, empty => empty,
                  level => level, overflow => overflow, underflow => underflow);

    count : process (clk)
    begin
        if rising_edge(clk) then
            if overflow = '1' then ovf_cnt <= ovf_cnt + 1; end if;
            if underflow = '1' then unf_cnt <= unf_cnt + 1; end if;
        end if;
    end process;

    stim : process
        type model_t is array (0 to 4095) of std_logic_vector(7 downto 0);
        variable model : model_t;
        variable m_head, m_tail : natural := 0;   -- model queue
        variable seed1, seed2 : positive := 7;
        variable r : real;
        variable w, rd : boolean;
        variable v : natural := 0;
        variable o0, u0 : natural;
    begin
        rst <= '1'; wait for 50 ns; rst <= '0'; wait until rising_edge(clk);
        assert empty = '1' and full = '0' and level = 0 report "reset state" severity failure;

        -- 1. Fill to full, overflow write must be dropped
        for i in 1 to DEPTH loop
            wr_en <= '1'; wr_data <= std_logic_vector(to_unsigned(i, 8));
            wait until rising_edge(clk);
        end loop;
        wr_en <= '1'; wr_data <= x"EE";               -- overflow attempt
        wait until rising_edge(clk);
        wr_en <= '0';
        wait until rising_edge(clk); wait until rising_edge(clk);
        assert full = '1' and level = DEPTH report "T1: not full" severity failure;
        assert ovf_cnt = 1 report "T1: overflow pulse count " & integer'image(ovf_cnt) severity failure;

        -- 2. Drain: order preserved, dropped byte absent, FWFT valid
        for i in 1 to DEPTH loop
            assert empty = '0' and rd_data = std_logic_vector(to_unsigned(i, 8))
                report "T2: order/data error at " & integer'image(i) severity failure;
            rd_en <= '1'; wait until rising_edge(clk); wait for 1 ns;
        end loop;
        rd_en <= '0';
        wait until rising_edge(clk); wait until rising_edge(clk);
        assert empty = '1' and level = 0 report "T2: not empty" severity failure;

        -- 3. Underflow is flagged and harmless
        u0 := unf_cnt;
        rd_en <= '1'; wait until rising_edge(clk); rd_en <= '0';
        wait until rising_edge(clk); wait until rising_edge(clk);
        assert unf_cnt = u0 + 1 and level = 0 report "T3: underflow handling" severity failure;
        report "T1-T3 PASS: fill, overflow drop, order, underflow";

        -- 4. Randomized simultaneous read/write vs. software model
        for n in 1 to 20000 loop
            uniform(seed1, seed2, r); w := r < 0.55;
            uniform(seed1, seed2, r); rd := r < 0.50;
            -- Check head against model before the edge (FWFT)
            if empty = '0' then
                assert m_tail /= m_head report "T4: model empty but DUT not" severity failure;
                assert rd_data = model(m_tail mod 4096) report "T4: data mismatch" severity failure;
            else
                assert m_tail = m_head report "T4: DUT empty but model not" severity failure;
            end if;
            assert level = (m_head - m_tail) report "T4: level mismatch" severity failure;

            if w then wr_en <= '1'; wr_data <= std_logic_vector(to_unsigned(v mod 256, 8)); else wr_en <= '0'; end if;
            if rd then rd_en <= '1'; else rd_en <= '0'; end if;
            -- update model using pre-edge status
            if w and full = '0' then
                model(m_head mod 4096) := std_logic_vector(to_unsigned(v mod 256, 8));
                m_head := m_head + 1; v := v + 1;
            end if;
            if rd and empty = '0' then
                m_tail := m_tail + 1;
            end if;
            wait until rising_edge(clk);
            wait for 1 ns;
        end loop;
        wr_en <= '0'; rd_en <= '0';
        report "T4 PASS: 20000 random cycles vs model";

        -- 5. Reset flushes
        wait until rising_edge(clk);
        rst <= '1'; wait until rising_edge(clk); wait until rising_edge(clk); rst <= '0';
        wait until rising_edge(clk);
        assert empty = '1' and level = 0 report "T5: reset did not flush" severity failure;
        report "T5 PASS: reset flush";

        report "sync_fifo_tb: ALL TESTS PASSED";
        finish;
    end process;
end architecture;
