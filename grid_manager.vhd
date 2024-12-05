library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity grid_manager is
    Port ( 
        clk : in STD_LOGIC;
        grid_in : in STD_LOGIC_VECTOR(323 downto 0);
        row : in integer range 0 to 8;
        col : in integer range 0 to 8;
        number : in integer range 0 to 9;
        update_grid : in STD_LOGIC;
        grid_out : out STD_LOGIC_VECTOR(323 downto 0)
    );
end grid_manager;

architecture Behavioral of grid_manager is
begin
    grid_update: process(clk)
        variable cell_index : integer;
    begin
        if rising_edge(clk) then
            grid_out <= grid_in;
            
            if update_grid = '1' then
                cell_index := (row * 9 + col) * 4;
                grid_out(cell_index+3 downto cell_index) <= std_logic_vector(to_unsigned(number, 4));
            end if;
        end if;
    end process;
end Behavioral;
