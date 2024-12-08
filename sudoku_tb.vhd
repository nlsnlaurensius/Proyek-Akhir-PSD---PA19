-- Library yang digunakan
library IEEE;
use IEEE.STD_LOGIC_1164.ALL; -- Library untuk sinyal logika
use IEEE.NUMERIC_STD.ALL;    -- Library untuk operasi numerik
use work.newtype.ALL;        -- Library user-defined untuk tipe data 'sudoku_array'

-- Entity untuk testbench (tanpa input/output karena ini adalah testbench)
entity sudoku_tb is
end sudoku_tb;

-- Arsitektur testbench
architecture behavioral of sudoku_tb is
    -- Deklarasi komponen "sudoku" yang akan diuji
    component sudoku
        port(
            clk             : in std_logic;                       -- Clock input
            reset           : in std_logic;                       -- Reset input
            i               : in std_logic_vector(3 downto 0);    -- Indeks baris input
            j               : in std_logic_vector(3 downto 0);    -- Indeks kolom input
            puzzle_buffer   : in std_logic_vector(3 downto 0);    -- Nilai sel puzzle yang dimasukkan
            start           : in std_logic;                       -- Sinyal mulai proses
            ready           : out std_logic                       -- Sinyal selesai pemrosesan
        );
    end component;

    -- Deklarasi sinyal internal untuk menghubungkan testbench dengan UUT (Unit Under Test)
    signal clk             : std_logic := '0';                    -- Sinyal clock
    signal reset           : std_logic := '0';                    -- Sinyal reset
    signal i               : std_logic_vector(3 downto 0) := (others => '0'); -- Indeks baris
    signal j               : std_logic_vector(3 downto 0) := (others => '0'); -- Indeks kolom
    signal puzzle_buffer   : std_logic_vector(3 downto 0) := (others => '0'); -- Nilai sel puzzle
    signal start           : std_logic := '0';                    -- Sinyal start
    signal ready           : std_logic;                           -- Sinyal ready dari modul sudoku

    -- Deklarasi tipe data untuk inisialisasi puzzle awal
    type initial_puzzle_type is array(1 to 9, 1 to 9) of integer;
    constant initial_puzzle : initial_puzzle_type := (
        -- Puzzle awal (soal sudoku yang belum diselesaikan)
        (0, 0, 0, 0, 0, 3, 2, 9, 0),
        (0, 8, 6, 5, 0, 0, 0, 0, 0),
        (0, 2, 0, 0, 1, 0, 0, 0, 0),
        (0, 0, 3, 7, 0, 5, 1, 0, 0),
        (9, 0, 0, 0, 0, 0, 0, 0, 8),
        (0, 0, 2, 9, 0, 8, 3, 0, 0),
        (0, 0, 0, 4, 0, 0, 0, 8, 0),
        (0, 4, 7, 1, 0, 0, 0, 0, 0),
        (0, 0, 0, 0, 0, 0, 0, 0, 0)
    );

    -- Deklarasi state FSM yang akan diikuti oleh testbench
    type state_type is (idle, next_empty_cell, guess, backtrack, solve);
    signal state_present, state_next : state_type; -- Sinyal state sekarang dan berikutnya

    -- Sinyal puzzle untuk memantau solusi
    signal puzzle : sudoku_array := (others => (others => 0));

    -- Konstanta periode clock
    constant CLK_PERIOD : time := 10 ns;

begin
    -- Instansiasi unit yang diuji (UUT: Unit Under Test)
    uut: sudoku
        port map (
            clk             => clk,             -- Hubungkan clock
            reset           => reset,           -- Hubungkan reset
            i               => i,               -- Hubungkan baris
            j               => j,               -- Hubungkan kolom
            puzzle_buffer   => puzzle_buffer,   -- Hubungkan buffer nilai sel
            start           => start,           -- Hubungkan start
            ready           => ready            -- Hubungkan sinyal ready
        );

    -- Proses untuk menghasilkan clock (sinyal clock toggle setiap CLK_PERIOD/2)
    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Proses stimulus untuk memberikan input ke modul sudoku
    stimulus: process
    begin
        -- **Langkah 1: Reset sistem**
        reset <= '1';                -- Aktifkan reset
        wait for CLK_PERIOD;         -- Tunggu satu siklus clock
        reset <= '0';                -- Nonaktifkan reset

        -- **Langkah 2: Masukkan data puzzle ke modul sudoku**
        for row in 1 to 9 loop       -- Loop melalui setiap baris puzzle
            for col in 1 to 9 loop   -- Loop melalui setiap kolom puzzle
                i <= std_logic_vector(to_unsigned(row-1, 4)); -- Baris ke-i
                j <= std_logic_vector(to_unsigned(col-1, 4)); -- Kolom ke-j
                puzzle_buffer <= std_logic_vector(to_unsigned(initial_puzzle(row, col), 4)); -- Isi nilai puzzle
                wait for CLK_PERIOD; -- Tunggu satu siklus clock untuk setiap input
                puzzle(row, col) <= initial_puzzle(row, col); -- Perbarui nilai puzzle
            end loop;
        end loop;

        -- **Langkah 3: Mulai pemrosesan Sudoku**
        start <= '1';                -- Aktifkan sinyal start
        wait for CLK_PERIOD;         -- Tunggu satu siklus clock
        start <= '0';                -- Nonaktifkan sinyal start

        -- **Langkah 4: Tunggu hingga proses selesai (ready = '1')**
        wait until ready = '1' for 100 ms;

        -- **Langkah 5: Verifikasi hasil akhir**
        for row in 1 to 9 loop       -- Loop melalui setiap baris
            for col in 1 to 9 loop   -- Loop melalui setiap kolom
                assert puzzle(row, col) = 5 -- Verifikasi nilai akhir puzzle
                    report "Mismatch at (" & integer'image(row) & ", " & integer'image(col) & ")" 
                    severity error; -- Laporkan error jika nilai tidak sesuai
            end loop;
        end loop;

        -- **Langkah 6: Pastikan state mencapai solve**
        assert state_present = solve
            report "Final state should be solve" severity error;

        -- **Langkah 7: Beri laporan akhir simulasi**
        assert false report "Sudoku solved. Simulation complete." severity note;

        wait; -- Hentikan proses
    end process;

end behavioral;
