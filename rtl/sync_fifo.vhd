-- sync_fifo.vhd  Single-clock first-word-fall-through FIFO.
-- Used for both RX and TX byte buffering (WIDTH=8).
-- Policy: a write while full is DROPPED and raises a one-clock 'overflow'
-- pulse (stored data is never corrupted). A read while empty is ignored and
-- raises a one-clock 'underflow' pulse. 'rd_data' is valid whenever empty='0'.
-- Reset flushes the FIFO. Asynchronous-read array: maps to distributed RAM.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sync_fifo is
    generic (
        WIDTH : positive := 8;
        DEPTH : positive := 512
    );
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        wr_en     : in  std_logic;
        wr_data   : in  std_logic_vector(WIDTH - 1 downto 0);
        full      : out std_logic;
        rd_en     : in  std_logic;
        rd_data   : out std_logic_vector(WIDTH - 1 downto 0);
        empty     : out std_logic;
        level     : out natural range 0 to DEPTH;
        overflow  : out std_logic;
        underflow : out std_logic
    );
end entity;

architecture rtl of sync_fifo is
    type mem_t is array (0 to DEPTH - 1) of std_logic_vector(WIDTH - 1 downto 0);
    signal mem    : mem_t := (others => (others => '0'));
    signal wr_ptr : natural range 0 to DEPTH - 1 := 0;
    signal rd_ptr : natural range 0 to DEPTH - 1 := 0;
    signal cnt    : natural range 0 to DEPTH := 0;
    signal full_i, empty_i : std_logic;
begin
    full_i  <= '1' when cnt = DEPTH else '0';
    empty_i <= '1' when cnt = 0 else '0';
    full    <= full_i;
    empty   <= empty_i;
    level   <= cnt;
    rd_data <= mem(rd_ptr);

    process (clk)
        variable do_wr, do_rd : boolean;
    begin
        if rising_edge(clk) then
            overflow  <= '0';
            underflow <= '0';
            if rst = '1' then
                wr_ptr <= 0;
                rd_ptr <= 0;
                cnt    <= 0;
            else
                do_wr := (wr_en = '1') and (full_i = '0');
                do_rd := (rd_en = '1') and (empty_i = '0');
                if wr_en = '1' and full_i = '1' then
                    overflow <= '1';
                end if;
                if rd_en = '1' and empty_i = '1' then
                    underflow <= '1';
                end if;

                if do_wr then
                    mem(wr_ptr) <= wr_data;
                    wr_ptr <= (wr_ptr + 1) mod DEPTH;
                end if;
                if do_rd then
                    rd_ptr <= (rd_ptr + 1) mod DEPTH;
                end if;

                if do_wr and not do_rd then
                    cnt <= cnt + 1;
                elsif do_rd and not do_wr then
                    cnt <= cnt - 1;
                end if;
            end if;
        end if;
    end process;
end architecture;
