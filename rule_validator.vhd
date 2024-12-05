library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rule_validator is
    Port ( 
        grid : in STD_LOGIC_VECTOR(323 downto 0);
        row : in integer range 0 to 8;
        col : in integer range 0 to 8;
        number : in integer range 1 to 9;
        is_valid : out STD_LOGIC
    );
end rule_validator;

architecture Behavioral of rule_validator is
    function get_cell_value(grid : STD_LOGIC_VECTOR(323 downto 0); r, c : integer) return integer is
        variable cell_index : integer;
    begin
        cell_index := (r * 9 + c) * 4;
        return to_integer(unsigned(grid(cell_index+3 downto cell_index)));
    end function;
    
begin
    validation_process: process(grid, row, col, number)
        variable row_valid, col_valid, box_valid : STD_LOGIC;
    begin
        row_valid := '1';
        col_valid := '1';
        box_valid := '1';
        
        for c in 0 to 8 loop
            if c /= col and get_cell_value(grid, row, c) = number then
                row_valid := '0';
                exit;
            end if;
        end loop;
        
        for r in 0 to 8 loop
            if r /= row and get_cell_value(grid, r, col) = number then
                col_valid := '0';
                exit;
            end if;
        end loop;
        
        for r in (row/3)*3 to (row/3)*3 + 2 loop
            for c in (col/3)*3 to (col/3)*3 + 2 loop
                if (r /= row or c /= col) and get_cell_value(grid, r, c) = number then
                    box_valid := '0';
                    exit;
                end if;
            end loop;
        end loop;
        
        is_valid <= row_valid and col_valid and box_valid;
    end process;
end Behavioral;
