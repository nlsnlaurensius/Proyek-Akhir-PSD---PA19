LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY sudoku_solver_tb IS
END sudoku_solver_tb;

ARCHITECTURE Behavioral OF sudoku_solver_tb IS
    COMPONENT sudoku_solver
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            input_grid : IN STD_LOGIC_VECTOR(323 DOWNTO 0);
            solution_grid : OUT STD_LOGIC_VECTOR(323 DOWNTO 0);
            solver_complete : OUT STD_LOGIC;
            solver_failed : OUT STD_LOGIC
        );
    END COMPONENT;

    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL reset : STD_LOGIC := '1';
    SIGNAL input_grid : STD_LOGIC_VECTOR(323 DOWNTO 0);

    SIGNAL solution_grid : STD_LOGIC_VECTOR(323 DOWNTO 0) := (OTHERS => '0');
    SIGNAL solver_complete : STD_LOGIC := '0';
    SIGNAL solver_failed : STD_LOGIC := '0';

    CONSTANT clk_period : TIME := 10 ns;

BEGIN
    uut : sudoku_solver
        PORT MAP (
            clk => clk,
            reset => reset,
            input_grid => input_grid,
            solution_grid => solution_grid,
            solver_complete => solver_complete,
            solver_failed => solver_failed
        );

    clk_process : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR clk_period / 2;
        clk <= '1';
        WAIT FOR clk_period / 2;
    END PROCESS;

    stim_proc : PROCESS
    BEGIN
        reset <= '1';
        WAIT FOR clk_period * 2;

        reset <= '0';

        input_grid <= B"010100110000000001110000000000000000011000000000000110010101000000000000000010011000000000000000000001100000100000000000000001100000000000000011010000000000100000000011000000000001011100000000000000100000000000000110000001100000000000000000001010000000000000000000010000011001000000000101000000000000000010000000000001111001";

        WAIT UNTIL solver_complete = '1' OR solver_failed = '1';

        WAIT;
    END PROCESS;

    display_process : PROCESS (solver_complete, solver_failed)
        VARIABLE row_data : STRING(1 TO 100);
        VARIABLE cell_value : INTEGER;
    BEGIN
        IF solver_complete = '1' THEN
            REPORT "Sudoku Solution Found:";
            FOR i IN 0 TO 8 LOOP
                row_data := (OTHERS => ' ');
                FOR j IN 0 TO 8 LOOP
                    cell_value := to_integer(unsigned(solution_grid((i*9+j)*4+3 DOWNTO (i*9+j)*4)));
                    row_data((j*3)+1 TO (j*3)+2) := INTEGER'image(cell_value)(INTEGER'image(cell_value)'LEFT TO INTEGER'image(cell_value)'RIGHT);
                    row_data((j*3)+3) := ' ';
                END LOOP;
                REPORT "Row " & INTEGER'image(i) & ": " & row_data;
            END LOOP;
        ELSIF solver_failed = '1' THEN
            REPORT "Sudoku Solution Failed!";
        END IF;
    END PROCESS;
END Behavioral;
