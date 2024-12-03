LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY Backtracking_Solver IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        grid : INOUT STD_LOGIC_VECTOR(323 DOWNTO 0); -- Sudoku grid as 81 cells, 4 bits per cell
        done : OUT STD_LOGIC;
        valid : IN STD_LOGIC
    );
END ENTITY Backtracking_Solver;

ARCHITECTURE Behavioral OF Backtracking_Solver IS
    SIGNAL row, col : INTEGER RANGE 0 TO 8 := 0;
    SIGNAL num : INTEGER RANGE 1 TO 9 := 1;
    SIGNAL backtrack : STD_LOGIC := '0';
BEGIN
    PROCESS(clk, reset)
    BEGIN
        IF reset = '1' THEN
            row <= 0;
            col <= 0;
            num <= 1;
            done <= '0';
            backtrack <= '0';
        ELSIF rising_edge(clk) THEN
            -- Check if all cells are processed
            IF row < 9 THEN
                -- Check if the current cell is empty
                IF TO_INTEGER(UNSIGNED(grid((row * 9 + col) * 4 + 3 DOWNTO (row * 9 + col) * 4))) = 0 THEN
                    -- Try numbers 1 to 9
                    IF num <= 9 THEN
                        -- Place number in the current cell
                        grid((row * 9 + col) * 4 + 3 DOWNTO (row * 9 + col) * 4) <= STD_LOGIC_VECTOR(TO_UNSIGNED(num, 4));
                        -- Check validity
                        IF valid = '1' THEN
                            -- Move to the next cell
                            col <= col + 1;
                            IF col = 9 THEN
                                col <= 0;
                                row <= row + 1;
                            END IF;
                            num <= 1;
                        ELSE
                            num <= num + 1;
                        END IF;
                    ELSE
                        -- Backtrack if no valid number
                        grid((row * 9 + col) * 4 + 3 DOWNTO (row * 9 + col) * 4) <= (OTHERS => '0');
                        backtrack <= '1';
                        -- Move back to the previous cell
                        IF col > 0 THEN
                            col <= col - 1;
                        ELSE
                            row <= row - 1;
                            col <= 8;
                        END IF;
                        num <= 1;
                    END IF;
                ELSE
                    -- Move to the next cell if current cell is not empty
                    col <= col + 1;
                    IF col = 9 THEN
                        col <= 0;
                        row <= row + 1;
                    END IF;
                END IF;
            ELSE
                -- Grid is fully solved
                done <= '1';
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE Behavioral;
