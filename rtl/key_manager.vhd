-- key_manager.vhd  Holds the AES-128 key and its valid flag.
-- Reset loads KEY_INIT (a BUILD-TIME TEST KEY by default; never use it in production).
-- Set KEY_INIT_VALID=false for a device that must be provisioned through 'load'.
-- 'zeroize' clears the key immediately and has priority over 'load'.
-- Key-load is NOT reachable from the UART in this release (top ties it off): who may
-- load keys is an open security decision (see docs/security-review.md).
library ieee;
use ieee.std_logic_1164.all;

entity key_manager is
    generic (
        KEY_INIT       : std_logic_vector(127 downto 0) := x"000102030405060708090a0b0c0d0e0f";
        KEY_INIT_VALID : boolean := true
    );
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        zeroize   : in  std_logic;
        load      : in  std_logic;
        key_in    : in  std_logic_vector(127 downto 0);
        key       : out std_logic_vector(127 downto 0);
        key_valid : out std_logic
    );
end entity;

architecture rtl of key_manager is
    signal key_r   : std_logic_vector(127 downto 0) := (others => '0');
    signal valid_r : std_logic := '0';
begin
    key       <= key_r;
    key_valid <= valid_r;

    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                if KEY_INIT_VALID then
                    key_r   <= KEY_INIT;
                    valid_r <= '1';
                else
                    key_r   <= (others => '0');
                    valid_r <= '0';
                end if;
            elsif zeroize = '1' then
                key_r   <= (others => '0');
                valid_r <= '0';
            elsif load = '1' then
                key_r   <= key_in;
                valid_r <= '1';
            end if;
        end if;
    end process;
end architecture;
