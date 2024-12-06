library ieee;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.newtype.all;

entity sudoku is
    port(
        clk             : in std_logic;
        reset           : in std_logic;
        i               : in std_logic_vector(3 downto 0);
        j               : in std_logic_vector(3 downto 0);
        puzzle_buffer   : in std_logic_vector(3 downto 0);
        start           : in std_logic;
        ready           : out std_logic
    );
end sudoku;

architecture test of sudoku is
    type state_type is (idle, next_empty_cell, guess, backtrack, solve);
    signal state_present, state_next : state_type;

    signal puzzle : sudoku_array := (
        (0,0,0,0,0,3,2,9,0),
        (0,8,6,5,0,0,0,0,0),
        (0,2,0,0,1,0,0,0,0),
        (0,0,3,7,0,5,1,0,0),
        (9,0,0,0,0,0,0,0,8),
        (0,0,2,9,0,8,3,0,0),
        (0,0,0,4,0,0,0,8,0),
        (0,4,7,1,0,0,0,0,0),
        (0,0,0,0,0,0,0,0,0)
    );

    signal bitmap_row      : bitmap_array := (others => (others => '0'));
    signal bitmap_col      : bitmap_array := (others => (others => '0'));
    signal bitmap_block    : bitmap_array := (others => (others => '0'));
    signal selected_row    : integer range 0 to 9 := 0;
    signal selected_col    : integer range 0 to 9 := 0;
    signal selected_block  : integer range 0 to 9 := 0;
    signal valid           : std_logic := '0';
    signal next_cell_found : std_logic := '0';
    signal error           : std_logic := '0';
    signal restored_last_valid_fill : std_logic := '0';
    signal all_cell_filled : std_logic := '0';
    signal stack_row       : stack := (others => 0);
    signal stack_col       : stack := (others => 0);
    signal pointer         : integer range 0 to 127 := 127;
    signal symbol_variable : integer range 0 to 9 := 0;
    signal update          : std_logic := '0';

    function block_number_function(i, j: integer) return integer is
        variable block_i : integer range 0 to 10;
        variable block_j : integer range 0 to 10;
        variable block_number : integer range 0 to 9;
        variable index : integer range 0 to 80;
    begin
        block_i := ((i-1) - ((i-1) mod 3)) + 1;
        block_j := ((j-1) - ((j-1) mod 3)) + 1;
        index := (block_i) * 10 + (block_j);

        case (index) is
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

    function is_valid_placement(puzzle: sudoku_array; row, col, value: integer) return boolean is
        variable i, j : integer;
        variable block_num : integer;
    begin
        -- Check row
        for j in 1 to 9 loop
            if j /= col and puzzle(row, j) = value then
                return false;
            end if;
        end loop;

        -- Check column
        for i in 1 to 9 loop
            if i /= row and puzzle(i, col) = value then
                return false;
            end if;
        end loop;

        -- Check 3x3 block
        block_num := block_number_function(row, col);
        for i in 1 to 9 loop
            for j in 1 to 9 loop
                if block_number_function(i, j) = block_num and 
                   (i /= row or j /= col) and 
                   puzzle(i, j) = value then
                    return false;
                end if;
            end loop;
        end loop;

        return true;
    end function;

begin
    -- State Transition Process
    state_transition: process(clk, reset)
    begin
        if (reset = '1') then
            state_present <= idle;
        elsif rising_edge(clk) then
            state_present <= state_next;
        end if;
    end process state_transition;

    -- State Machine Process
    state_machine: process(state_present, start, next_cell_found, error, valid, restored_last_valid_fill)
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
    end process state_machine;

    -- Main Processing Process
    main_process: process(clk, reset)
    variable i_var : integer range 1 to 9;
    variable j_var : integer range 1 to 9;
    variable symbol_var : integer range 0 to 9;
    begin
        if rising_edge(clk) then
            if reset = '1' then
                -- Reset signals
                selected_row <= 0;
                selected_col <= 0;
                next_cell_found <= '0';
                all_cell_filled <= '0';
                error <= '0';
                valid <= '0';
                restored_last_valid_fill <= '0';
                ready <= '0';
                pointer <= 127;
            else
                case state_present is
                    when idle =>
                        -- Convert input to integers
                        i_var := conv_integer(unsigned(i));
                        j_var := conv_integer(unsigned(j));

                        -- Adjust indices if zero
                        if (i = "0000") then i_var := 1; end if;
                        if (j = "0000") then j_var := 1; end if;

                        -- Load puzzle values
                        puzzle(i_var, j_var) <= conv_integer(unsigned(puzzle_buffer));

                    when next_empty_cell =>
                        -- Find next empty cell
                        next_cell_found <= '0';
                        for row in 1 to 9 loop
                            for col in 1 to 9 loop
                                if puzzle(row, col) = 0 then
                                    selected_row <= row;
                                    selected_col <= col;
                                    next_cell_found <= '1';
                                    exit when next_cell_found = '1';
                                end if;
                            end loop;
                            exit when next_cell_found = '1';
                        end loop;

                        -- Check if all cells are filled
                        if next_cell_found = '0' then
                            all_cell_filled <= '1';
                        end if;

                    when guess =>
                        -- Try placing a number
                        symbol_var := conv_integer(unsigned(puzzle_buffer));
                        
                        if is_valid_placement(puzzle, selected_row, selected_col, symbol_var) then
                            puzzle(selected_row, selected_col) <= symbol_var;
                            valid <= '1';
                            
                            -- Save backtracking information
                            stack_row(pointer) <= selected_row;
                            stack_col(pointer) <= selected_col;
                            pointer <= pointer - 1;
                        else
                            error <= '1';
                        end if;

                    when backtrack =>
                        -- Restore previous state
                        if pointer < 127 then
                            pointer <= pointer + 1;
                            selected_row <= stack_row(pointer);
                            selected_col <= stack_col(pointer);
                            puzzle(selected_row, selected_col) <= 0;
                            restored_last_valid_fill <= '1';
                        else
                            -- No solution possible
                            error <= '1';
                        end if;

                    when solve =>
                        ready <= '1';

                    when others => null;
                end case;
            end if;
        end if;
    end process main_process;
end test;
