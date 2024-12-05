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

    signal bitmap_row      : bitmap_array := (others => (others => ('0')));
    signal bitmap_col      : bitmap_array := (others => (others => ('0')));
    signal bitmap_block    : bitmap_array := (others => (others => ('0')));
    signal selected_row    : integer range 0 to 9;
    signal selected_col    : integer range 0 to 9;
    signal selected_block  : integer range 0 to 9;
    signal valid           : std_logic := '0';
    signal next_cell_found : std_logic := '0';
    signal error           : std_logic := '0';
    signal restored_last_valid_fill : std_logic := '0';
    signal all_cell_filled : std_logic := '0';
    signal stack_row       : stack := (others => (0));
    signal stack_col       : stack := (others => (0));
    signal pointer         : integer range 0 to 127 := 127;
    signal symbol_variable : integer range 0 to 9;
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

    begin

    process(clk, reset)
    begin
        if (reset = '1') then
            state_present <= idle;
        elsif (clk'event and clk = '1') then
            state_present <= state_next;
        end if;
    end process;

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


    process(state_present, clk)
    variable guess_report : guess_type := (others => ('0'));
    variable Test_variable : integer range 0 to 9;
    variable error_variable : std_logic := '1';
    variable i_var : integer range 1 to 9;
    variable j_var : integer range 1 to 9;
    variable block_number : integer range 1 to 9;
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

                puzzle_in(i_var, j_var) <= conv_integer(unsigned(puzzle_buffer));

            when backtrack =>
                if (pointer > 0) then
                    pointer := pointer - 1;
                    variable1 := stack_row(pointer);
                    guess_report(variable1) <= '0';
                end if;

            when guess =>
                symbol_variable := guess_report(guess_report'range);
                puzzle(symbol_variable) <= conv_integer(unsigned(puzzle_buffer));

            when next_empty_cell =>
                next_cell_found <= '1';

            when solve =>
                ready <= '1';

            when others =>
                null;
        end case;
    end process;

end test;
