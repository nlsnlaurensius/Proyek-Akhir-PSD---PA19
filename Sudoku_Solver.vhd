LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY Sudoku_Solver IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        grid_input : IN STD_LOGIC_VECTOR(323 DOWNTO 0); -- Input grid, 4 bits per cell
        grid_output : OUT STD_LOGIC_VECTOR(323 DOWNTO 0); -- Solved grid
        done : OUT STD_LOGIC
    );
END ENTITY Sudoku_Solver;

ARCHITECTURE Structural OF Sudoku_Solver IS
    SIGNAL grid : STD_LOGIC_VECTOR(323 DOWNTO 0); -- Internal grid signal
    SIGNAL valid : STD_LOGIC;
    SIGNAL row, col : INTEGER RANGE 0 TO 8;
    SIGNAL num : INTEGER RANGE 1 TO 9;

    COMPONENT Rule_Checker
        PORT (
            clk : IN STD_LOGIC;
            grid : IN STD_LOGIC_VECTOR(323 DOWNTO 0); -- Input grid
            row, col : IN INTEGER RANGE 0 TO 8;
            num : IN INTEGER RANGE 1 TO 9;
            valid : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT Backtracking_Solver
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            grid : INOUT STD_LOGIC_VECTOR(323 DOWNTO 0); -- In/Out grid
            done : OUT STD_LOGIC;
            valid : IN STD_LOGIC
        );
    END COMPONENT;

BEGIN
    -- Instantiate Rule Checker
    rule_checker_inst : Rule_Checker
        PORT MAP (
            clk => clk,
            grid => grid,
            row => row,
            col => col,
            num => num,
            valid => valid
        );

    -- Instantiate Backtracking Solver
    backtracking_solver_inst : Backtracking_Solver
        PORT MAP (
            clk => clk,
            reset => reset,
            grid => grid,
            done => done,
            valid => valid
        );

    -- Manage grid input and output
    PROCESS(clk, reset)
    BEGIN
        IF reset = '1' THEN
            grid <= grid_input;
            grid_output <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            grid_output <= grid;
        END IF;
    END PROCESS;
END ARCHITECTURE Structural;
