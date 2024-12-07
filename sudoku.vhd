LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.newtype.ALL;

ENTITY sudoku IS
    PORT (
        clk, reset : IN STD_LOGIC;
        i : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        j : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        puzzle_buffer : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        start : IN STD_LOGIC;
        ready : OUT STD_LOGIC
    );
END sudoku;

ARCHITECTURE test OF sudoku IS
    TYPE state_type IS (idle, next_empty_cell, guess, backtrack, solve);
    SIGNAL state_present, state_next : state_type;
    SIGNAL puzzle : sudoku_array := ((0, 0, 0, 0, 0, 3, 2, 9, 0), 
                                    (0, 8, 6, 5, 0, 0, 0, 0, 0), 
                                    (0, 2, 0, 0, 1, 0, 0, 0, 0),
                                    (0, 0, 3, 7, 0, 5, 1, 0, 0), 
                                    (9, 0, 0, 0, 0, 0, 0, 0, 8), 
                                    (0, 0, 2, 9, 0, 8, 3, 0, 0),
                                    (0, 0, 0, 4, 0, 0, 0, 8, 0), 
                                    (0, 4, 7, 1, 0, 0, 0, 0, 0), 
                                    (0, 0, 0, 0, 0, 0, 0, 0, 0));

    SIGNAL bitmap_row : bitmap_array := (OTHERS => (OTHERS => ('0')));
    SIGNAL bitmap_col : bitmap_array := (OTHERS => (OTHERS => ('0')));
    SIGNAL bitmap_block : bitmap_array := (OTHERS => (OTHERS => ('0')));
    SIGNAL selected_row : INTEGER RANGE 0 TO 9;
    SIGNAL selected_col : INTEGER RANGE 0 TO 9;
    SIGNAL selected_block : INTEGER RANGE 0 TO 9;
    SIGNAL valid : STD_LOGIC := '0';
    SIGNAL next_cell_found : STD_LOGIC := '0';
    SIGNAL error : STD_LOGIC := '0';
    SIGNAL restored_last_valid_fill : STD_LOGIC := '0';
    SIGNAL all_cell_filled : STD_LOGIC := '0';
    SIGNAL stack_row : stack := (OTHERS => (0));
    SIGNAL stack_col : stack := (OTHERS => (0));
    SIGNAL pointer : INTEGER RANGE 0 TO 127 := 127;
    SIGNAL symbol_variable : INTEGER RANGE 0 TO 9;
    SIGNAL update : STD_LOGIC := '0';

    FUNCTION block_number_function (i, j : INTEGER) RETURN INTEGER IS
        VARIABLE block_i : INTEGER RANGE 0 TO 10;
        VARIABLE block_j : INTEGER RANGE 0 TO 10;
        VARIABLE block_number : INTEGER RANGE 0 TO 9;
        VARIABLE index : INTEGER RANGE 0 TO 80;
    BEGIN
        block_i := ((i - 1) - ((i - 1) MOD 3)) + 1;
        block_j := ((j - 1) - ((j - 1) MOD 3)) + 1;
        index := (block_i) * 10 + (block_j);
        CASE (index) IS
            WHEN 11 => block_number := 1;
            WHEN 14 => block_number := 2;
            WHEN 17 => block_number := 3;
            WHEN 41 => block_number := 4;
            WHEN 44 => block_number := 5;
            WHEN 47 => block_number := 6;
            WHEN 71 => block_number := 7;
            WHEN 74 => block_number := 8;
            WHEN 77 => block_number := 9;
            WHEN OTHERS => block_number := 0;
        END CASE;
        RETURN block_number;
    END FUNCTION;

BEGIN
    PROCESS (clk, reset)
    BEGIN
        IF (reset = '1') THEN
            state_present <= idle;
        ELSIF (clk'event AND clk = '1') THEN
            state_present <= state_next;
        END IF;
    END PROCESS;

    PROCESS (clk, reset, start)
    BEGIN
        CASE state_present IS
            WHEN idle =>
                IF (start = '1') THEN
                    state_next <= next_empty_cell;
                ELSE
                    state_next <= idle;
                END IF;
            WHEN next_empty_cell =>
                IF (next_cell_found = '1') THEN
                    state_next <= guess;
                ELSIF (all_cell_filled = '1') THEN
                    state_next <= solve;
                ELSE
                    state_next <= next_empty_cell;
                END IF;
            WHEN guess =>
                IF (error = '1') THEN
                    state_next <= backtrack;
                ELSIF (valid = '1') THEN
                    state_next <= next_empty_cell;
                ELSE
                    state_next <= guess;
                END IF;
            WHEN backtrack =>
                IF (restored_last_valid_fill = '1') THEN
                    state_next <= guess;
                ELSE
                    state_next <= backtrack;
                END IF;
            WHEN solve =>
                state_next <= idle;
        END CASE;
    END PROCESS;

    PROCESS (state_present, clk)
        VARIABLE guess_report : guess_type := (OTHERS => ('0'));
        VARIABLE Test_variable : INTEGER RANGE 0 TO 9;
        VARIABLE error_variable : STD_LOGIC := '1';
        VARIABLE i_var : INTEGER RANGE 1 TO 9;
        VARIABLE j_var : INTEGER RANGE 1 TO 9;
        VARIABLE block_number : INTEGER RANGE 1 TO 9;
        VARIABLE variable1 : INTEGER RANGE 0 TO 9;
    BEGIN
        CASE state_present IS
            WHEN idle =>
                i_var := conv_integer(unsigned(i));
                j_var := conv_integer(unsigned(j));
                IF (i = "0000") THEN
                    i_var := 1;
                END IF;
                IF (j = "0000") THEN
                    j_var := 1;
                END IF;
                puzzle(i_var, j_var) <= conv_integer(unsigned(puzzle_buffer));
            WHEN next_empty_cell =>
                valid <= '0';
                FOR i IN INTEGER RANGE 1 TO 9 LOOP
                    FOR j IN INTEGER RANGE 1 TO 9 LOOP
                        Test_variable := (puzzle(i, j));
                        IF (Test_variable = 0) THEN
                            selected_row <= i;
                            selected_col <= j;
                            selected_block <= block_number_function(i, j);
                            next_cell_found <= '1';
                            symbol_variable <= Test_variable;
                            EXIT;
                        ELSIF (i = 9 AND j = 9 AND Test_variable /= 0) THEN
                            all_cell_filled <= '1';
                            EXIT;
                        ELSE
                            selected_row <= 0;
                            selected_col <= 0;
                            selected_block <= 0;
                            next_cell_found <= '0';
                            all_cell_filled <= '0';
                            symbol_variable <= 0;
                        END IF;
                    END LOOP;
                END LOOP;
            WHEN guess =>
                error_variable := '1';
                selected_block <= block_number_function(selected_row, selected_col);
                FOR j IN INTEGER RANGE 1 TO 9 LOOP
                    guess_report(j) := bitmap_row(selected_row, j) OR bitmap_col(selected_col, j) OR bitmap_block(selected_block, j);
                    error_variable := error_variable AND guess_report(j);
                END LOOP;
                FOR i IN INTEGER RANGE 1 TO 9 LOOP
                    IF (guess_report(i) = '0' AND restored_last_valid_fill = '0') THEN
                        stack_row(pointer) <= selected_row;
                        stack_col(pointer) <= selected_col;
                        pointer <= pointer - 1;
                        error <= '0';
                        valid <= '1';
                        puzzle(selected_row, selected_col) <= i;
                        update <= NOT update;
                        EXIT;
                    ELSIF (error_variable = '1' AND restored_last_valid_fill = '0') THEN
                        error <= error_variable;
                        valid <= '0';
                        EXIT;
                    END IF;
                END LOOP;
                IF (restored_last_valid_fill = '1') THEN
                    selected_block <= block_number_function(selected_row, selected_col);
                    FOR j IN INTEGER RANGE 1 TO 9 LOOP
                        guess_report(j) := bitmap_row(selected_row, j) OR bitmap_col(selected_col, j) OR bitmap_block(selected_block, j);
                        error_variable := error_variable AND guess_report(j);
                    END LOOP;
                    FOR i IN INTEGER RANGE 1 TO 9 LOOP
                        IF (i > variable1 AND guess_report(i) = '0') THEN
                            stack_row(pointer) <= selected_row;
                            stack_col(pointer) <= selected_col;
                            pointer <= pointer - 1;
                            puzzle(selected_row, selected_col) <= i;
                            update <= NOT update;
                            error <= '0';
                            valid <= '1';
                            restored_last_valid_fill <= '0';
                            EXIT;
                        ELSE
                            restored_last_valid_fill <= '1';
                        END IF;
                    END LOOP;
                END IF;
            WHEN backtrack =>
                pointer <= pointer + 1;
                selected_row <= stack_row(pointer + 1);
                selected_col <= stack_col(pointer + 1);
                selected_block <= block_number_function(stack_row(pointer + 1), stack_col(pointer + 1));
                symbol_variable <= puzzle(stack_row(pointer + 1), stack_col(pointer + 1));
                variable1 := puzzle(stack_row(pointer + 1), stack_col(pointer + 1));
                puzzle(stack_row(pointer + 1), stack_col(pointer + 1)) <= 0;
                update <= NOT update;
                restored_last_valid_fill <= '1';
            WHEN solve =>
                ready <= '1';
        END CASE;
    END PROCESS;

    PROCESS (start, puzzle, bitmap_row, bitmap_col, bitmap_block)
        VARIABLE block_number : INTEGER RANGE 1 TO 9;
        VARIABLE Test_variable : INTEGER RANGE 0 TO 9;
    BEGIN
        bitmap_row <= (OTHERS => (OTHERS => ('0')));
        bitmap_col <= (OTHERS => (OTHERS => ('0')));
        bitmap_block <= (OTHERS => (OTHERS => ('0')));
        FOR i IN INTEGER RANGE 1 TO 9 LOOP
            FOR j IN INTEGER RANGE 1 TO 9 LOOP
                Test_variable := (puzzle(i, j));
                block_number := block_number_function(i, j);
                CASE Test_variable IS
                    WHEN 0 =>
                        bitmap_row(i, Test_variable) <= '0';
                        bitmap_col(j, Test_variable) <= '0';
                        bitmap_block(block_number, Test_variable) <= '0';
                    WHEN 1 =>
                        bitmap_row(i, Test_variable) <= '1';
                        bitmap_col(j, Test_variable) <= '1';
                        bitmap_block(block_number, Test_variable) <= '1';
                    WHEN 2 =>
                        bitmap_row(i, Test_variable) <= '1';
                        bitmap_col(j, Test_variable) <= '1';
                        bitmap_block(block_number, Test_variable) <= '1';
                    WHEN 3 =>
                        bitmap_row(i, Test_variable) <= '1';
                        bitmap_col(j, Test_variable) <= '1';
                        bitmap_block(block_number, Test_variable) <= '1';
                    WHEN 4 =>
                        bitmap_row(i, Test_variable) <= '1';
                        bitmap_col(j, Test_variable) <= '1';
                        bitmap_block(block_number, Test_variable) <= '1';
                    WHEN 5 =>
                        bitmap_row(i, Test_variable) <= '1';
                        bitmap_col(j, Test_variable) <= '1';
                        bitmap_block(block_number, Test_variable) <= '1';
                    WHEN 6 =>
                        bitmap_row(i, Test_variable) <= '1';
                        bitmap_col(j, Test_variable) <= '1';
                        bitmap_block(block_number, Test_variable) <= '1';
                    WHEN 7 =>
                        bitmap_row(i, Test_variable) <= '1';
                        bitmap_col(j, Test_variable) <= '1';
                        bitmap_block(block_number, Test_variable) <= '1';
                    WHEN 8 =>
                        bitmap_row(i, Test_variable) <= '1';
                        bitmap_col(j, Test_variable) <= '1';
                        bitmap_block(block_number, Test_variable) <= '1';
                    WHEN 9 =>
                        bitmap_row(i, Test_variable) <= '1';
                        bitmap_col(j, Test_variable) <= '1';
                        bitmap_block(block_number, Test_variable) <= '1';
                    WHEN OTHERS =>
                        bitmap_row(i, j) <= '-';
                        bitmap_col(j, Test_variable) <= '-';
                        bitmap_block(block_number, Test_variable) <= '-';
                END CASE;
            END LOOP;
        END LOOP;
    END PROCESS;
END test;
