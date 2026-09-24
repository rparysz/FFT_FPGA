library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity and_gate is
    Port ( in_A : in STD_LOGIC;
           in_b : in STD_LOGIC;
           o_and : out STD_LOGIC);
end and_gate;

architecture Behavioral of and_gate is
begin

    o_and <= in_A and in_B;
    
end Behavioral;
