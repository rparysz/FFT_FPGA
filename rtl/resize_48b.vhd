library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity resize_29b is
    generic(
                in_size : natural := 24
            );
       port(
                in_data : in std_logic_vector(in_size-1 downto 0);
                out_48b : out std_logic_vector(28 downto 0)
            );
            
end resize_29b;

architecture Behavioral of resize_29b is

    function reverse_any_vector (a: in std_logic_vector)
    return std_logic_vector is
      variable result: std_logic_vector(a'RANGE);
      alias aa: std_logic_vector(a'REVERSE_RANGE) is a;
    begin
      for i in aa'RANGE loop
        result(i) := aa(i);
      end loop;
      return result;
    end; -- function reverse_any_vector
    
    signal temp, temp2: std_logic_vector(in_size-1 downto 0);
    
begin
    
    out_48b <= std_logic_vector(resize(signed(in_data), 29));
    
end Behavioral;
