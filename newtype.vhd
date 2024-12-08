library IEEE;
use IEEE.NUMERIC_STD.all;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL; 

package newtype is 
    subtype cell_type is integer range 0 to 9;
    subtype symbol is std_logic;
    type sudoku_array is array (integer range 1 to 9, integer range 1 to 9) of cell_type;
    type bitmap_array is array (integer range 0 to 9, integer range 0 to 9) of symbol;
    type guess_type is array (integer range 1 to 9) of symbol;
    type stack is array (integer range 0 to 127) of integer range 0 to 9;
end newtype; 
