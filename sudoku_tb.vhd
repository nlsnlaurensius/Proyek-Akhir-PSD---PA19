library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.newtype.ALL;

entity sudoku_tb is
end sudoku_tb;

architecture behavioral of sudoku_tb is
    component sudoku
        port(
            clk             : in std_logic;
            reset           : in std_logic;
            i               : in std_logic_vector(3 downto 0);
            j               : in std_logic_vector(3 downto 0);
            puzzle_buffer   : in std_logic_vector(3 downto 0);
            start           : in std_logic;
            ready           : out std_logic
        );
    end component;

    signal clk             : std_logic := '0';
    signal reset           : std_logic := '0';
    signal i               : std_logic_vector(3 downto 0) := (others => '0');
    signal j               : std_logic_vector(3 downto 0) := (others => '0');
    signal puzzle_buffer   : std_logic_vector(3 downto 0) := (others => '0');
    signal start           : std_logic := '0';
    signal ready           : std_logic;

    constant CLK_PERIOD    : time := 10 ns;

begin
    uut: sudoku
        port map (
            clk             => clk,
            reset           => reset,
            i               => i,
            j               => j,
            puzzle_buffer   => puzzle_buffer,
            start           => start,
            ready           => ready
        );

    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    stimulus: process
    begin
        reset <= '1';
        wait for CLK_PERIOD;
        reset <= '0';

        i <= "0001"; j <= "0001"; puzzle_buffer <= "0000"; wait for CLK_PERIOD;
        i <= "0001"; j <= "0010"; puzzle_buffer <= "0000"; wait for CLK_PERIOD;
        i <= "0001"; j <= "0011"; puzzle_buffer <= "0000"; wait for CLK_PERIOD;
        i <= "0001"; j <= "0100"; puzzle_buffer <= "0000"; wait for CLK_PERIOD;
        i <= "0001"; j <= "0101"; puzzle_buffer <= "0000"; wait for CLK_PERIOD;
        i <= "0001"; j <= "0110"; puzzle_buffer <= "0011"; wait for CLK_PERIOD;
        i <= "0001"; j <= "0111"; puzzle_buffer <= "0010"; wait for CLK_PERIOD;
        i <= "0001"; j <= "1000"; puzzle_buffer <= "1001"; wait for CLK_PERIOD;
        i <= "0001"; j <= "1001"; puzzle_buffer <= "0000"; wait for CLK_PERIOD;

        i <= "0010"; j <= "0001"; puzzle_buffer <= "0000"; wait for CLK_PERIOD;
        i <= "0010"; j <= "0010"; puzzle_buffer <= "1000"; wait for CLK_PERIOD;
        i <= "0010"; j <= "0011"; puzzle_buffer <= "0110"; wait for CLK_PERIOD;
        i <= "0010"; j <= "0100"; puzzle_buffer <= "0105"; wait for CLK_PERIOD;
        i <= "0010"; j <= "0101"; puzzle_buffer <= "0000"; wait for CLK_PERIOD;
        i <= "0010"; j <= "0110"; puzzle_buffer <= "0000"; wait for CLK_PERIOD;
        i <= "0010"; j <= "0111"; puzzle_buffer <= "0000"; wait for CLK_PERIOD;
        i <= "0010"; j <= "1000"; puzzle_buffer <= "0000"; wait for CLK_PERIOD;
        i <= "0010"; j <= "1001"; puzzle_buffer <= "0000"; wait for CLK_PERIOD;

        i <= "0011"; j <= "0001"; puzzle_buffer <= "0000"; wait for CLK_PERIOD;
        i <= "0011"; j <= "0010"; puzzle_buffer <= "0010"; wait for CLK_PERIOD;
        i <= "0011"; j <= "0011"; puzzle_buffer <= "0000"; wait for CLK_PERIOD;
        i <= "0011"; j <= "0100"; puzzle_buffer <= "0000"; wait for CLK_PERIOD;
        i <= "0011"; j <= "0101"; puzzle_buffer <= "0001"; wait for CLK_PERIOD;
        i <= "0011"; j <= "0110"; puzzle_buffer <= "0000"; wait for CLK_PERIOD;
        i <= "0011"; j <= "0111"; puzzle_buffer <= "0000"; wait for CLK_PERIOD;
        i <= "0011"; j <= "1000"; puzzle_buffer <= "0000"; wait for CLK_PERIOD;
        i <= "0011"; j <= "1001"; puzzle_buffer <= "0000"; wait for CLK_PERIOD;

        i <= "0100"; j <= "0001"; puzzle_buffer <= "0000"; wait for CLK_PERIOD;
        i <= "0100"; j <= "0010"; puzzle_buffer <= "0000"; wait for CLK_PERIOD;
        i <= "0100"; j <= "0011"; puzzle_buffer <= "0013"; wait for CLK_PERIOD;
        i <= "0100"; j <= "0100"; puzzle_buffer <= "0117"; wait for CLK_PERIOD;
        i <= "0100"; j <= "0101"; puzzle_buffer <= "0000"; wait for CLK_PERIOD;
        i <= "0100"; j <= "0110"; puzzle_buffer <= "0105"; wait for CLK_PERIOD;
        i <= "0100"; j <= "0111"; puzzle_buffer <= "0001"; wait for CLK_PERIOD;
        i <= "0100"; j <= "1000"; puzzle_buffer <= "0000"; wait for CLK_PERIOD;
        i <= "0100"; j <= "1001"; puzzle_buffer <= "0000"; wait for CLK_PERIOD;

        i <= "0101"; j <= "0001"; puzzle_buffer <= "1009"; wait for CLK_PERIOD;
        i <= "0101"; j <= "1001"; puzzle_buffer <= "1008"; wait for CLK_PERIOD;

        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';

        wait until ready = '1' for 100 ms;

        assert false report "Sudoku solved. Simulation complete." severity note;

        wait;
    end process;
end behavioral;
