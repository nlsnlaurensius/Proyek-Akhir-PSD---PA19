

library ieee; 
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL; 
use work.newtype.all;

------------------------------------------------------------------Entity--------------------------------------------------------------------------

entity sudoku is
    port(  
        clk, reset: in std_logic;
        i : in std_logic_vector(3 downto 0);
        j : in std_logic_vector(3 downto 0);
        puzzle_buffer : in std_logic_vector(3 downto 0);
        start: in std_logic;
        ready: out std_logic
    );
end sudoku;

------------------------------------------------------------------Arsitektur--------------------------------------------------------------------------

architecture test of sudoku is
    type state_type is (idle, next_empty_cell, guess, backtrack, solve);
    signal state_present, state_next: state_type;

    --------------------------- Sudoku--------------------------------------------------------
    signal puzzle : sudoku_array := (
        (0,0,0,0,0,3,2,9,0),
        (0,8,6,5,0,0,0,0,0),
        (0,2,0,0,0,1,0,0,0),
        (0,0,3,7,0,5,1,0,0),
        (9,0,0,0,0,0,0,0,8),
        (0,0,2,9,0,8,3,0,0),
        (0,0,0,4,0,0,0,8,0),
        (0,4,7,1,0,0,0,0,0),
        (0,0,0,0,0,0,0,0,0)
    );
    
    signal bitmap_row : bitmap_array := (others => (others => ('0')));
    signal bitmap_col : bitmap_array := (others => (others => ('0')));
    signal bitmap_block : bitmap_array := (others => (others => ('0')));
    
    signal selected_row: integer range 0 to 9;  -- Global signal untuk menyimpan nilai baris yang dipilih dalam operasi
    signal selected_col: integer range 0 to 9;  -- Global signal untuk menyimpan nilai kolom yang dipilih dalam operasi
    signal selected_block: integer range 0 to 9; -- Global signal untuk menyimpan nilai blok yang dipilih dalam operasi
    signal valid: std_logic := '0';  -- Signal untuk memeriksa apakah tebakan yang dibuat oleh state "Guess" adalah elemen yang valid
    signal next_cell_found: std_logic := '0';  -- Signal untuk memeriksa apakah cell kosong berikutnya ditemukan oleh state "Next Empty Cell"
    signal error: std_logic := '0';  -- Jika state "Guess" tidak bisa menghasilkan tebakan, maka akan mengatur error dan melanjutkan ke state "Backtrack"
    signal restored_last_valid_fill: std_logic := '0'; -- Ketika backtrack menghapus bit sebelumnya di stack dan memeriksa elemen valid berikutnya
    signal all_cell_filled: std_logic := '0';  -- Jika tidak ada lagi cell kosong ditemukan
    signal stack_row : stack := (others => (0)); -- Stack untuk menyimpan alamat baris
    signal stack_col : stack := (others => (0)); -- Stack untuk menyimpan alamat kolom
    signal pointer : integer range 0 to 127 := 127; -- Pointer stack
    signal symbol_variable: integer range 0 to 9;  -- Variabel yang dipop dari alamat stack dan disimpan di sini
    signal update: std_logic := '0';  -- Signal untuk memperbarui bitmap
    
    --------------------------------------------------Fungsi untuk menentukan nomor blok dalam puzzle Sudoku berdasarkan baris dan kolom---------------------------------------------------------
    function block_number_function ( i,j: integer) return integer is
        variable block_i : integer range 0 to 10;
        variable block_j : integer range 0 to 10;
        variable block_number: integer range 0 to 9;
        variable index : integer range 0 to 80;   
    begin
        -- Blok ditentukan menggunakan i-i%3 dan j-j%3, dimana i dan j adalah indeks baris dan kolom
        block_i := ((i-1) - ((i-1) mod 3)) + 1;    -- Variabel sementara untuk menyimpan i-i%3
        block_j := ((j-1) - ((j-1) mod 3)) + 1;    -- Variabel sementara untuk menyimpan j-j%3
        index := (block_i)*10 + (block_j);    

        case (index) is  -- Menentukan nomor blok berdasarkan informasi tersebut
            when 11 => block_number := 1;
            when 14 => block_number := 2;
            when 17 => block_number := 3;
            when 41 => block_number := 4;
            when 44 => block_number := 5;
            when 47 => block_number := 6;
            when 71 => block_number := 7;
            when 74 => block_number := 8;
            when 77 => block_number := 9;
            when others => block_number := 0;
        end case;
        return block_number;
    end function;

begin
    ----------------------Untuk inisialisasi dan memperbarui urutan FSM---------------------------------------
    process(clk, reset)
    begin
        if (reset = '1') then
            state_present <= idle;
        elsif (clk'event and clk = '1') then
            state_present <= state_next;
        end if;
    end process;

    ------------------------Jalur kontrol: logika yang menentukan state berikutnya dari FSM-------------------
    process(clk, reset, start)
    begin
        case state_present is
            when idle =>
                if (start = '1') then
                    state_next <= next_empty_cell;
                else
                    state_next <= idle;
                end if;
                
            when next_empty_cell =>
                if (next_cell_found = '1') then
                    state_next <= guess;
                elsif (all_cell_filled = '1') then
                    state_next <= solve;
                else
                    state_next <= next_empty_cell;
                end if;

            when guess =>
                if (error = '1') then
                    state_next <= backtrack;
                elsif (valid = '1') then
                    state_next <= next_empty_cell;
                else
                    state_next <= guess;
                end if;
                
            when backtrack =>
                if (restored_last_valid_fill = '1') then
                    state_next <= guess;
                else
                    state_next <= backtrack;
                end if;
                
            when solve =>
                state_next <= idle;
        end case;
    end process;

    ------------------------Jalur kontrol aliran FSM dan logikanya-----------------------------------------
    process(state_present, clk)
    variable guess_report : guess_type := (others => ('0')); 
    variable Test_variable: integer range 0 to 9;
    variable error_variable: std_logic := '1';
    variable i_var : integer range 1 to 9;
    variable j_var : integer range 1 to 9;
    variable block_number: integer range 1 to 9;
    variable variable1 : integer range 0 to 9;
    begin
        case state_present is
            when idle =>
                i_var := conv_integer(unsigned(i));
                j_var := conv_integer(unsigned(j));
                if (i = "0000") then
                    i_var := 1;
                end if;
                if (j = "0000") then
                    j_var := 1;
                end if;
                puzzle(i_var, j_var) <= conv_integer(unsigned(puzzle_buffer));
                
            when next_empty_cell =>
                valid <= '0';
                loop1: for i in integer range 1 to 9 loop  -- baris
                    loop2: for j in integer range 1 to 9 loop  -- kolom
                        Test_variable := (puzzle(i, j));
                        if (Test_variable = 0) then
                            selected_row <= i;
                            selected_col <= j;
                            selected_block <= block_number_function(i, j);
                            next_cell_found <= '1';
                            symbol_variable <= Test_variable;  
                            exit loop1 when Test_variable = 0;  
                            exit loop2 when Test_variable = 0;
                        elsif (i = 9 and j = 9 and Test_variable /= 0) then
                            all_cell_filled <= '1';  -- Puzzle selesai, saatnya untuk solve
                            exit loop1 when Test_variable = 0;
                            exit loop2 when Test_variable = 0;
                        else 
                            selected_row <= 0;
                            selected_col <= 0;
                            selected_block <= 0;
                            next_cell_found <= '0';
                            all_cell_filled <= '0';
                            symbol_variable <= 0;
                        end if;
                    end loop;
                end loop;
                
            when guess =>  
                error_variable := '1';
                selected_block <= block_number_function(selected_row, selected_col);
                for j in integer range 1 to 9 loop 
                    guess_report(j) := bitmap_row(selected_row, j) or bitmap_col(selected_col, j) or bitmap_block(selected_block, j);
                    error_variable := error_variable and guess_report(j);
                end loop;
                loop_i: for i in integer range 1 to 9 loop 
                    if (guess_report(i) = '0' and restored_last_valid_fill = '0') then
                        stack_row(pointer) <= selected_row;
                        stack_col(pointer) <= selected_col;
                        pointer <= pointer - 1;
                        error <= '0';
                        valid <= '1';  -- Masuk ke state berikutnya
                        puzzle(selected_row, selected_col) <= i;  -- Memperbarui bitmap
                        update <= not update;
                        exit loop_i;
                    elsif (error_variable = '1' and restored_last_valid_fill = '0') then
                        error <= error_variable;
                        valid <= '0';
                        exit loop_i;
                    end if;
                end loop;

                -- Jika elemen ditolak dari backtrack, pilih elemen valid berikutnya yang lebih besar
                if (restored_last_valid_fill = '1') then
                    selected_block <= block_number_function(selected_row, selected_col);
                    for j in integer range 1 to 9 loop 
                        guess_report(j) := bitmap_row(selected_row, j) or bitmap_col(selected_col, j) or bitmap_block(selected_block, j);
                        error_variable := error_variable and guess_report(j);
                    end loop;
                    loop_2 : for i in integer range 1 to 9 loop 
                        if (i > variable1 and guess_report(i) = '0') then
                            stack_row(pointer) <= selected_row;
                            stack_col(pointer) <= selected_col;
                            pointer <= pointer - 1;
                            puzzle(selected_row, selected_col) <= i;
                            update <= not update;
                            error <= '0';
                            valid <= '1';
                            restored_last_valid_fill <= '0';
                            exit loop_2;
                        else
                            restored_last_valid_fill <= '1';
                        end if;
                    end loop;
                end if;

            when backtrack =>  
                pointer <= pointer + 1;
                selected_row <= stack_row(pointer + 1);
                selected_col <= stack_col(pointer + 1);
                selected_block <= block_number_function(stack_row(pointer + 1), stack_col(pointer + 1));
                symbol_variable <= puzzle(stack_row(pointer + 1), stack_col(pointer + 1));
                variable1 := puzzle(stack_row(pointer + 1), stack_col(pointer + 1));
                puzzle(stack_row(pointer + 1), stack_col(pointer + 1)) <= 0;
                update <= not update;
                restored_last_valid_fill <= '1';
                
            when solve =>
                ready <= '1';
        end case;
    end process;

    ----------------------------Memperbarui bitmap dan tabel pemilihan kandidat--------------------------------------
    process(start, puzzle, bitmap_row, bitmap_col, bitmap_block)
    variable block_number: integer range 1 to 9;
    variable Test_variable : integer range 0 to 9;
    begin
        -- MUX untuk menginisialisasi setiap bit menjadi nol kecuali diisi menggunakan logika berikut----------------------------
        bitmap_row <= (others => (others => ('0'))); 
        bitmap_col <= (others => (others => ('0')));
        bitmap_block <= (others => (others => ('0')));

        for i in integer range 1 to 9 loop  -- baris
            for j in integer range 1 to 9 loop  -- kolom
                Test_variable := (puzzle(i, j));  -- Memuat elemen dari puzzle dan memperbarui di bitmap
                block_number := block_number_function(i, j);
                case Test_variable is  -- Memperbarui nomor baris, kolom, dan blok dari elemen yang diidentifikasi
                    when 0 =>
                        bitmap_row(i, Test_variable) <= '0';
                        bitmap_col(j, Test_variable) <= '0';
                        bitmap_block(block_number, Test_variable) <= '0';
                    when 1 =>
                        bitmap_row(i, Test_variable) <= '1';
                        bitmap_col(j, Test_variable) <= '1';
                        bitmap_block(block_number, Test_variable) <= '1';
                    when 2 =>
                        bitmap_row(i, Test_variable) <= '1';
                        bitmap_col(j, Test_variable) <= '1';
                        bitmap_block(block_number, Test_variable) <= '1';
                    when 3 =>
                        bitmap_row(i, Test_variable) <= '1';
                        bitmap_col(j, Test_variable) <= '1';
                        bitmap_block(block_number, Test_variable) <= '1';
                    when 4 =>
                        bitmap_row(i, Test_variable) <= '1';
                        bitmap_col(j, Test_variable) <= '1';
                        bitmap_block(block_number, Test_variable) <= '1';
                    when 5 =>
                        bitmap_row(i, Test_variable) <= '1';
                        bitmap_col(j, Test_variable) <= '1';
                        bitmap_block(block_number, Test_variable) <= '1';
                    when 6 =>
                        bitmap_row(i, Test_variable) <= '1';
                        bitmap_col(j, Test_variable) <= '1';
                        bitmap_block(block_number, Test_variable) <= '1';
                    when 7 =>
                        bitmap_row(i, Test_variable) <= '1';
                        bitmap_col(j, Test_variable) <= '1';
                        bitmap_block(block_number, Test_variable) <= '1';
                    when 8 =>
                        bitmap_row(i, Test_variable) <= '1';
                        bitmap_col(j, Test_variable) <= '1';
                        bitmap_block(block_number, Test_variable) <= '1';
                    when 9 =>
                        bitmap_row(i, Test_variable) <= '1';
                        bitmap_col(j, Test_variable) <= '1';
                        bitmap_block(block_number, Test_variable) <= '1';
                    when others =>
                        bitmap_row(i, j) <= '-';
                        bitmap_col(j, Test_variable) <= '-';
                        bitmap_block(block_number, Test_variable) <= '-';
                end case;
            end loop; 
        end loop;  
    end process;
end test;
