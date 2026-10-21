-- aes_pkg.vhd  AES-128 primitives (FIPS 197). S-box table generated from the GF(2^8) definition
-- (inverse + affine transform) and spot-checked: S(00)=63, S(01)=7C, S(53)=ED, S(FF)=16.
-- Byte order: a 128-bit block is bytes 0..15 with byte 0 in bits 127..120 (input order).
-- State matrix is column-major: byte i is row (i mod 4), column (i / 4).
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package aes_pkg is
    subtype byte_t is std_logic_vector(7 downto 0);
    subtype block_t is std_logic_vector(127 downto 0);
    function sub_bytes   (s : block_t) return block_t;
    function shift_rows  (s : block_t) return block_t;
    function mix_columns (s : block_t) return block_t;
    function xtime       (b : byte_t) return byte_t;
    function next_round_key (rk : block_t; rcon : byte_t) return block_t;
end package;

package body aes_pkg is
    type sbox_t is array (0 to 255) of byte_t;
    constant SBOX : sbox_t := (
        x"63", x"7C", x"77", x"7B", x"F2", x"6B", x"6F", x"C5",
        x"30", x"01", x"67", x"2B", x"FE", x"D7", x"AB", x"76",
        x"CA", x"82", x"C9", x"7D", x"FA", x"59", x"47", x"F0",
        x"AD", x"D4", x"A2", x"AF", x"9C", x"A4", x"72", x"C0",
        x"B7", x"FD", x"93", x"26", x"36", x"3F", x"F7", x"CC",
        x"34", x"A5", x"E5", x"F1", x"71", x"D8", x"31", x"15",
        x"04", x"C7", x"23", x"C3", x"18", x"96", x"05", x"9A",
        x"07", x"12", x"80", x"E2", x"EB", x"27", x"B2", x"75",
        x"09", x"83", x"2C", x"1A", x"1B", x"6E", x"5A", x"A0",
        x"52", x"3B", x"D6", x"B3", x"29", x"E3", x"2F", x"84",
        x"53", x"D1", x"00", x"ED", x"20", x"FC", x"B1", x"5B",
        x"6A", x"CB", x"BE", x"39", x"4A", x"4C", x"58", x"CF",
        x"D0", x"EF", x"AA", x"FB", x"43", x"4D", x"33", x"85",
        x"45", x"F9", x"02", x"7F", x"50", x"3C", x"9F", x"A8",
        x"51", x"A3", x"40", x"8F", x"92", x"9D", x"38", x"F5",
        x"BC", x"B6", x"DA", x"21", x"10", x"FF", x"F3", x"D2",
        x"CD", x"0C", x"13", x"EC", x"5F", x"97", x"44", x"17",
        x"C4", x"A7", x"7E", x"3D", x"64", x"5D", x"19", x"73",
        x"60", x"81", x"4F", x"DC", x"22", x"2A", x"90", x"88",
        x"46", x"EE", x"B8", x"14", x"DE", x"5E", x"0B", x"DB",
        x"E0", x"32", x"3A", x"0A", x"49", x"06", x"24", x"5C",
        x"C2", x"D3", x"AC", x"62", x"91", x"95", x"E4", x"79",
        x"E7", x"C8", x"37", x"6D", x"8D", x"D5", x"4E", x"A9",
        x"6C", x"56", x"F4", x"EA", x"65", x"7A", x"AE", x"08",
        x"BA", x"78", x"25", x"2E", x"1C", x"A6", x"B4", x"C6",
        x"E8", x"DD", x"74", x"1F", x"4B", x"BD", x"8B", x"8A",
        x"70", x"3E", x"B5", x"66", x"48", x"03", x"F6", x"0E",
        x"61", x"35", x"57", x"B9", x"86", x"C1", x"1D", x"9E",
        x"E1", x"F8", x"98", x"11", x"69", x"D9", x"8E", x"94",
        x"9B", x"1E", x"87", x"E9", x"CE", x"55", x"28", x"DF",
        x"8C", x"A1", x"89", x"0D", x"BF", x"E6", x"42", x"68",
        x"41", x"99", x"2D", x"0F", x"B0", x"54", x"BB", x"16"
    );

    function sbox_f (b : byte_t) return byte_t is
    begin
        return SBOX(to_integer(unsigned(b)));
    end function;

    function xtime (b : byte_t) return byte_t is
        variable r : byte_t;
    begin
        r := b(6 downto 0) & '0';
        if b(7) = '1' then r := r xor x"1B"; end if;
        return r;
    end function;

    function sub_bytes (s : block_t) return block_t is
        variable r : block_t;
    begin
        for i in 0 to 15 loop
            r(127 - 8 * i downto 120 - 8 * i) := sbox_f(s(127 - 8 * i downto 120 - 8 * i));
        end loop;
        return r;
    end function;

    function shift_rows (s : block_t) return block_t is
        variable r : block_t;
        variable src : natural;
    begin
        for c in 0 to 3 loop
            for row in 0 to 3 loop
                src := row + 4 * ((c + row) mod 4);
                r(127 - 8 * (row + 4 * c) downto 120 - 8 * (row + 4 * c)) :=
                    s(127 - 8 * src downto 120 - 8 * src);
            end loop;
        end loop;
        return r;
    end function;

    function mix_columns (s : block_t) return block_t is
        variable r : block_t;
        variable a0, a1, a2, a3 : byte_t;
        variable t0, t1, t2, t3 : byte_t;   -- 2*a
        variable b  : natural;
    begin
        for c in 0 to 3 loop
            b := 4 * c;
            a0 := s(127 - 8 * b       downto 120 - 8 * b);
            a1 := s(127 - 8 * (b + 1) downto 120 - 8 * (b + 1));
            a2 := s(127 - 8 * (b + 2) downto 120 - 8 * (b + 2));
            a3 := s(127 - 8 * (b + 3) downto 120 - 8 * (b + 3));
            t0 := xtime(a0); t1 := xtime(a1); t2 := xtime(a2); t3 := xtime(a3);
            r(127 - 8 * b       downto 120 - 8 * b)       := t0 xor (t1 xor a1) xor a2 xor a3;
            r(127 - 8 * (b + 1) downto 120 - 8 * (b + 1)) := a0 xor t1 xor (t2 xor a2) xor a3;
            r(127 - 8 * (b + 2) downto 120 - 8 * (b + 2)) := a0 xor a1 xor t2 xor (t3 xor a3);
            r(127 - 8 * (b + 3) downto 120 - 8 * (b + 3)) := (t0 xor a0) xor a1 xor a2 xor t3;
        end loop;
        return r;
    end function;

    function next_round_key (rk : block_t; rcon : byte_t) return block_t is
        variable w0, w1, w2, w3, t, n0, n1, n2, n3 : std_logic_vector(31 downto 0);
    begin
        w0 := rk(127 downto 96); w1 := rk(95 downto 64);
        w2 := rk(63 downto 32);  w3 := rk(31 downto 0);
        -- RotWord then SubWord, then Rcon on the most significant byte
        t := sbox_f(w3(23 downto 16)) & sbox_f(w3(15 downto 8)) & sbox_f(w3(7 downto 0)) & sbox_f(w3(31 downto 24));
        t(31 downto 24) := t(31 downto 24) xor rcon;
        n0 := w0 xor t;
        n1 := w1 xor n0;
        n2 := w2 xor n1;
        n3 := w3 xor n2;
        return n0 & n1 & n2 & n3;
    end function;
end package body;
