-- aes_gcm_engine.vhd  AES-128-GCM, 96-bit IV, full 128-bit tag (SP 800-38D).
--
-- Transaction contract (buffered/block-stream):
--  * Pulse 'start' while busy='0'. key, iv, aad_len, data_len (bytes), decrypt and
--    tag_in are sampled on that clock edge and need not stay stable afterwards.
--  * The engine requests input blocks: while in_ready='1' it wants one 16-byte block
--    (in_is_aad='1' -> AAD block, else data block). A block is accepted on the edge where
--    in_valid and in_ready are both '1'. Byte 0 is in_block(127 downto 120). Final partial
--    blocks may carry any padding; the engine masks bytes beyond the length.
--  * Data blocks are returned on out_block with a one-clock out_valid pulse; out_bytes
--    gives the number of valid bytes (1..16, MSB-first), the rest are zero.
--  * 'done' pulses for one clock when the transaction ends; tag_out and auth_ok are then valid.
--      encrypt: tag_out is the computed tag, auth_ok='1'.
--      decrypt: auth_ok='1' only if the computed tag equals tag_in.
--  * !! In decrypt mode out_block carries UNAUTHENTICATED plaintext. The consumer (crypto
--    controller) must hold it in a private buffer and release it only if auth_ok='1' at done.
--  * 'error' pulses for one clock if 'start' arrives while busy; the running transaction is unaffected.
--  * Cancellation: only reset cancels a transaction; no done/auth_ok pulse is produced for an aborted one.
-- Sequencing is serial (one AES or GHASH operation at a time) to keep area small.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.aes_pkg.all;

entity aes_gcm_engine is
    port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        start      : in  std_logic;
        decrypt    : in  std_logic;
        key        : in  std_logic_vector(127 downto 0);
        iv         : in  std_logic_vector(95 downto 0);
        aad_len    : in  natural range 0 to 4095;
        data_len   : in  natural range 0 to 4095;
        tag_in     : in  std_logic_vector(127 downto 0);

        in_ready   : out std_logic;
        in_is_aad  : out std_logic;
        in_valid   : in  std_logic;
        in_block   : in  std_logic_vector(127 downto 0);

        out_valid  : out std_logic;
        out_block  : out std_logic_vector(127 downto 0);
        out_bytes  : out natural range 0 to 16;

        busy       : out std_logic;
        done       : out std_logic;
        error      : out std_logic;   -- 1-clock pulse: 'start' received while busy (ignored)
        tag_out    : out std_logic_vector(127 downto 0);
        auth_ok    : out std_logic
    );
end entity;

architecture rtl of aes_gcm_engine is
    type state_t is (IDLE, H_GO, H_WAIT, J0_GO, J0_WAIT, AAD_IN, DATA_IN,
                     KS_GO, KS_WAIT, GM_GO, GM_WAIT);
    signal state : state_t := IDLE;

    type phase_t is (PH_AAD, PH_DATA, PH_LEN);
    signal phase : phase_t := PH_AAD;

    signal key_r   : block_t := (others => '0');
    signal iv_r    : std_logic_vector(95 downto 0) := (others => '0');
    signal tag_r   : block_t := (others => '0');
    signal dec_r   : std_logic := '0';
    signal alen_r, dlen_r : natural range 0 to 4095 := 0;
    signal aidx, didx : natural range 0 to 256 := 0;
    signal ctr     : unsigned(31 downto 0) := (others => '0');
    signal h_r, ej0, y, blk_r, din_r : block_t := (others => '0');

    signal aes_start, aes_busy, aes_done : std_logic;
    signal aes_in, aes_out : block_t;
    signal gm_start, gm_busy, gm_done : std_logic;
    signal gm_a, gm_p : block_t;

    function nbytes_of (total, idx : natural) return natural is
        variable rem_b : integer;
    begin
        rem_b := total - 16 * idx;
        if rem_b > 16 then return 16; else return rem_b; end if;
    end function;

    function mask_blk (b : block_t; nb : natural) return block_t is
        variable r : block_t := (others => '0');
    begin
        for i in 0 to 15 loop
            if i < nb then
                r(127 - 8 * i downto 120 - 8 * i) := b(127 - 8 * i downto 120 - 8 * i);
            end if;
        end loop;
        return r;
    end function;

    function blocks_of (total : natural) return natural is
    begin
        return (total + 15) / 16;
    end function;
begin
    u_aes : entity work.aes128_core
        port map (clk => clk, rst => rst, start => aes_start, key => key_r, block_in => aes_in,
                  busy => aes_busy, done => aes_done, block_out => aes_out);
    u_gm : entity work.ghash_mult
        port map (clk => clk, rst => rst, start => gm_start, a => gm_a, h => h_r,
                  busy => gm_busy, done => gm_done, p => gm_p);

    -- combinational strobes and operand selection from the state register
    aes_start <= '1' when state = H_GO or state = J0_GO or state = KS_GO else '0';
    aes_in    <= (others => '0') when state = H_GO else
                 iv_r & x"00000001" when state = J0_GO else
                 iv_r & std_logic_vector(ctr);
    gm_start  <= '1' when state = GM_GO else '0';
    gm_a      <= y xor blk_r;

    in_ready  <= '1' when state = AAD_IN or state = DATA_IN else '0';
    in_is_aad <= '1' when state = AAD_IN else '0';
    busy      <= '0' when state = IDLE else '1';

    process (clk)
        variable ks_out  : block_t;
        variable nb      : natural;
        variable tagv    : block_t;
    begin
        if rising_edge(clk) then
            done      <= '0';
            out_valid <= '0';
            error     <= '0';
            if start = '1' and state /= IDLE then error <= '1'; end if;

            if rst = '1' then
                state   <= IDLE;
                phase   <= PH_AAD;
                auth_ok <= '0';
            else
                case state is
                    when IDLE =>
                        if start = '1' then
                            key_r  <= key;
                            iv_r   <= iv;
                            alen_r <= aad_len;
                            dlen_r <= data_len;
                            dec_r  <= decrypt;
                            tag_r  <= tag_in;
                            y      <= (others => '0');
                            aidx   <= 0;
                            didx   <= 0;
                            ctr    <= to_unsigned(2, 32);   -- inc32(J0)
                            auth_ok <= '0';
                            state  <= H_GO;
                        end if;

                    when H_GO =>
                        state <= H_WAIT;

                    when H_WAIT =>
                        if aes_done = '1' then
                            h_r   <= aes_out;
                            state <= J0_GO;
                        end if;

                    when J0_GO =>
                        state <= J0_WAIT;

                    when J0_WAIT =>
                        if aes_done = '1' then
                            ej0 <= aes_out;
                            if alen_r > 0 then
                                state <= AAD_IN;
                            elsif dlen_r > 0 then
                                state <= DATA_IN;
                            else
                                phase <= PH_LEN;
                                blk_r <= std_logic_vector(to_unsigned(alen_r * 8, 64)) &
                                         std_logic_vector(to_unsigned(dlen_r * 8, 64));
                                state <= GM_GO;
                            end if;
                        end if;

                    when AAD_IN =>
                        if in_valid = '1' then
                            blk_r <= mask_blk(in_block, nbytes_of(alen_r, aidx));
                            phase <= PH_AAD;
                            state <= GM_GO;
                        end if;

                    when DATA_IN =>
                        if in_valid = '1' then
                            din_r <= mask_blk(in_block, nbytes_of(dlen_r, didx));
                            state <= KS_GO;
                        end if;

                    when KS_GO =>
                        state <= KS_WAIT;

                    when KS_WAIT =>
                        if aes_done = '1' then
                            nb := nbytes_of(dlen_r, didx);
                            ks_out := mask_blk(din_r xor aes_out, nb);
                            out_block <= ks_out;
                            out_bytes <= nb;
                            out_valid <= '1';
                            if dec_r = '1' then
                                blk_r <= din_r;          -- GHASH over ciphertext (input)
                            else
                                blk_r <= ks_out;         -- GHASH over ciphertext (output)
                            end if;
                            ctr   <= ctr + 1;
                            phase <= PH_DATA;
                            state <= GM_GO;
                        end if;

                    when GM_GO =>
                        state <= GM_WAIT;

                    when GM_WAIT =>
                        if gm_done = '1' then
                            y <= gm_p;
                            case phase is
                                when PH_AAD =>
                                    aidx <= aidx + 1;
                                    if aidx + 1 < blocks_of(alen_r) then
                                        state <= AAD_IN;
                                    elsif dlen_r > 0 then
                                        state <= DATA_IN;
                                    else
                                        phase <= PH_LEN;
                                        blk_r <= std_logic_vector(to_unsigned(alen_r * 8, 64)) &
                                                 std_logic_vector(to_unsigned(dlen_r * 8, 64));
                                        state <= GM_GO;
                                    end if;
                                when PH_DATA =>
                                    didx <= didx + 1;
                                    if didx + 1 < blocks_of(dlen_r) then
                                        state <= DATA_IN;
                                    else
                                        phase <= PH_LEN;
                                        blk_r <= std_logic_vector(to_unsigned(alen_r * 8, 64)) &
                                                 std_logic_vector(to_unsigned(dlen_r * 8, 64));
                                        state <= GM_GO;
                                    end if;
                                when PH_LEN =>
                                    tagv    := gm_p xor ej0;
                                    tag_out <= tagv;
                                    if dec_r = '1' then
                                        if tagv = tag_r then auth_ok <= '1'; else auth_ok <= '0'; end if;
                                    else
                                        auth_ok <= '1';
                                    end if;
                                    done  <= '1';
                                    state <= IDLE;
                            end case;
                        end if;
                end case;
            end if;
        end if;
    end process;
end architecture;
