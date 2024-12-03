LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY Rule_Checker IS
    PORT (
        clk : IN STD_LOGIC;
        grid : IN STD_LOGIC_VECTOR(323 DOWNTO 0); -- Sudoku grid as 81 cells, 4 bits per cell
        row, col : IN INTEGER RANGE 0 TO 8;
        num : IN INTEGER RANGE 1 TO 9;
        valid : OUT STD_LOGIC
    );
END ENTITY Rule_Checker;

ARCHITECTURE Behavioral OF Rule_Checker IS
    SIGNAL is_valid : BOOLEAN := TRUE; -- Use a signal instead of a variable
BEGIN
    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            is_valid <= TRUE;

            -- Check if num is 0 (not valid)
            IF num = 0 THEN
                is_valid <= FALSE;
            END IF;

            -- Check row
            IF is_valid THEN
                FOR i IN 0 TO 8 LOOP
                    IF i /= col AND 
                       TO_INTEGER(UNSIGNED(grid((row * 9 + i) * 4 + 3 DOWNTO (row * 9 + i) * 4))) = num THEN
                        is_valid <= FALSE;
                    END IF;
                END LOOP;
            END IF;

            -- Check column
            IF is_valid THEN
                FOR i IN 0 TO 8 LOOP
                    IF i /= row AND 
                       TO_INTEGER(UNSIGNED(grid((i * 9 + col) * 4 + 3 DOWNTO (i * 9 + col) * 4))) = num THEN
                        is_valid <= FALSE;
                    END IF;
                END LOOP;
            END IF;

            -- Check 3x3 box
            IF is_valid THEN
                FOR i IN (row / 3) * 3 TO (row / 3) * 3 + 2 LOOP
                    FOR j IN (col / 3) * 3 TO (col / 3) * 3 + 2 LOOP
                        IF (i /= row OR j /= col) AND 
                           TO_INTEGER(UNSIGNED(grid((i * 9 + j) * 4 + 3 DOWNTO (i * 9 + j) * 4))) = num THEN
                            is_valid <= FALSE;
                        END IF;
                    END LOOP;
                END LOOP;
            END IF;

            -- Set the output valid signal
            IF is_valid THEN
                valid <= '1';
            ELSE
                valid <= '0';
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE Behavioral;
