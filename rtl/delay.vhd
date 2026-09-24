library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity delay is
    generic(
                D_TIME      :   natural := 26
            );
       port(
                clk     :   in std_logic;
                i_sig   :   in std_logic;
                o_sig   :   out std_logic
            );
end delay;

architecture Behavioral of delay is

    type d_arr is array (0 to D_TIME-1) of std_logic;
    
    signal delay : d_arr := (others=>'0');
    
begin
    
    process(clk)
    begin
        if(rising_edge(clk)) then
            delay(0) <= i_sig;
                for i in 0 to D_TIME-2 loop
                    delay(i+1) <= delay(i);
                end loop;
        end if;
    end process;
        
    o_sig <= delay(D_TIME-1);    
                

end Behavioral;
