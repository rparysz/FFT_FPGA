library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity cmult_tb is

end cmult_tb;

architecture Behavioral of cmult_tb is

    component cmult is
         generic(
                    AWIDTH : natural := 16;
                    BWIDTH : natural := 16
                 );
         port(
                clk    : in  std_logic;
                ar, ai : in  std_logic_vector(AWIDTH - 1 downto 0);
                br, bi : in  std_logic_vector(BWIDTH - 1 downto 0);
                pr, pi : out std_logic_vector(AWIDTH + BWIDTH downto 0)
             );
    end component;
    
    signal clk      :     std_logic := '0';
    signal ar, ai   :     std_logic_vector(7 downto 0);
    signal br, bi   :     std_logic_vector(7 downto 0);
    signal pr, pi   :     std_logic_vector(16 downto 0);
    
    signal pr_sh, pi_sh     :   std_logic_vector(16 downto 0);
    
    signal pr_sc, pi_sc     :   std_logic_vector(7 downto 0);
begin

    DUT: cmult
        generic map(
                        AWIDTH      =>      8,
                        BWIDTH      =>      8
                    )
        port map(
                    clk     =>      clk,
                    ar      =>      ar,
                    ai      =>      ai,
                    br      =>      br,
                    bi      =>      bi,
                    pr      =>      pr,
                    pi      =>      pi
                );
    
    
    process
    begin
        wait for 50ns;
        
        ar <= std_logic_vector(to_signed(122, 8));
        ai <= std_logic_vector(to_signed(98, 8));
        br <= std_logic_vector(to_signed(48, 8));
        bi <= std_logic_vector(to_signed(46, 8));
        
        wait for 40ns;
        
        ar <= std_logic_vector(to_signed(65, 8));
        ai <= std_logic_vector(to_signed(77, 8));
        br <= std_logic_vector(to_signed(89, 8));
        bi <= std_logic_vector(to_signed(91, 8));
        
        wait for 40ns;
        
        ar <= std_logic_vector(to_signed(103, 8));
        ai <= std_logic_vector(to_signed(-105, 8));
        br <= std_logic_vector(to_signed(102, 8));
        bi <= std_logic_vector(to_signed(-104, 8));     
        wait;
        
    end process;
    
    --pr_sc <= std_logic_vector(shift_right(signed(pr), 2));
    --pi_sc <= std_logic_vector(shift_right(signed(pi), 2));
    
    pr_sh <= std_logic_vector(shift_right(signed(pr), 8));
    pi_sh <= std_logic_vector(shift_right(signed(pi), 8));
    
    pr_sc <= pr_sh(7 downto 0);
    pi_sc <= pi_sh(7 downto 0);
    clk <= not clk after 10ns;
    
end Behavioral;
