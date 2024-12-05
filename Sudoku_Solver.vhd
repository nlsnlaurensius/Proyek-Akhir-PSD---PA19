library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sudoku_solver is
    Port ( 
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        input_grid : in STD_LOGIC_VECTOR(323 downto 0);
        solution_grid : out STD_LOGIC_VECTOR(323 downto 0);
        solver_complete : out STD_LOGIC;
        solver_failed : out STD_LOGIC
    );
end sudoku_solver;

architecture Behavioral of sudoku_solver is
    type state_type is (IDLE, VALIDATE, PLACE_NUMBER, BACKTRACK, COMPLETE, FAIL);
    
    signal current_state : state_type;
    signal current_row : integer range 0 to 8 := 0;
    signal current_col : integer range 0 to 8 := 0;
    signal current_number : integer range 1 to 9 := 1;
    signal updated_grid : STD_LOGIC_VECTOR(323 downto 0);
    signal grid_update_enable : STD_LOGIC := '0';
    signal validation_result : STD_LOGIC;

    component rule_validator is
        Port ( 
            grid : in STD_LOGIC_VECTOR(323 downto 0);
            row : in integer range 0 to 8;
            col : in integer range 0 to 8;
            number : in integer range 1 to 9;
            is_valid : out STD_LOGIC
        );
    end component;
    
    component grid_manager is
        Port ( 
            clk : in STD_LOGIC;
            grid_in : in STD_LOGIC_VECTOR(323 downto 0);
            row : in integer range 0 to 8;
            col : in integer range 0 to 8;
            number : in integer range 1 to 9;
            update_grid : in STD_LOGIC;
            grid_out : out STD_LOGIC_VECTOR(323 downto 0)
        );
    end component;

begin
    validator: rule_validator 
    port map (
        grid => updated_grid,
        row => current_row,
        col => current_col,
        number => current_number,
        is_valid => validation_result
    );
    
    grid_mgr: grid_manager
    port map (
        clk => clk,
        grid_in => updated_grid,
        row => current_row,
        col => current_col,
        number => current_number,
        update_grid => grid_update_enable,
        grid_out => updated_grid
    );
    
    solver_process: process(clk, reset)
    begin
        if reset = '1' then
            current_state <= IDLE;
            current_row <= 0;
            current_col <= 0;
            current_number <= 1;
            solution_grid <= (others => '0');
            solver_complete <= '0';
            solver_failed <= '0';
            grid_update_enable <= '0';
            updated_grid <= input_grid;
        elsif rising_edge(clk) then
            case current_state is
                when IDLE =>
                    current_state <= VALIDATE;
                
                when VALIDATE =>
                    if current_number <= 9 then
                        if validation_result = '1' then
                            grid_update_enable <= '1';
                            current_state <= PLACE_NUMBER;
                        else
                            current_number <= current_number + 1;
                        end if;
                    else
                        current_state <= BACKTRACK;
                        current_number <= 1;
                    end if;
                
                when PLACE_NUMBER =>
                    grid_update_enable <= '0';
                    if current_row = 8 and current_col = 8 then
                        current_state <= COMPLETE;
                        solution_grid <= updated_grid;
                        solver_complete <= '1';
                    else
                        if current_col < 8 then
                            current_col <= current_col + 1;
                        else
                            current_col <= 0;
                            current_row <= current_row + 1;
                        end if;
                        current_state <= VALIDATE;
                    end if;
                
                when BACKTRACK =>
                    if current_row = 0 and current_col = 0 then
                        current_state <= FAIL;
                        solver_failed <= '1';
                    else
                        if current_col > 0 then
                            current_col <= current_col - 1;
                        else
                            current_col <= 8;
                            current_row <= current_row - 1;
                        end if;
                        grid_update_enable <= '1';
                        current_number <= 1;
                        current_state <= VALIDATE;
                    end if;
                
                when COMPLETE =>
                    solver_complete <= '1';
                
                when FAIL =>
                    solver_failed <= '1';
                
                when others =>
                    current_state <= IDLE;
            end case;
        end if;
    end process;

end Behavioral;
