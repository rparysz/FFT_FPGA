library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity BFU_tb is

end BFU_tb;

architecture Behavioral of BFU_tb is
    
    component BFU is
        generic(
                    logN        :       integer := 5;
                    sample_size :       integer := 16
               );
        port(
                in_re_even      :       in std_logic_vector(sample_size-1 downto 0);
                in_re_odd       :       in std_logic_vector(sample_size-1 downto 0);
                in_im_even      :       in std_logic_vector(sample_size-1 downto 0);
                in_im_odd       :       in std_logic_vector(sample_size-1 downto 0);
                
                out_re_even     :       out std_logic_vector(sample_size-1 downto 0);
                out_re_odd      :       out std_logic_vector(sample_size-1 downto 0);
                out_im_even     :       out std_logic_vector(sample_size-1 downto 0);
                out_im_odd      :       out std_logic_vector(sample_size-1 downto 0);
                            
                fft_stage       :       in integer;
                tw_addr         :       in integer;
                
                clk             :       in std_logic;
                en              :       in std_logic
                
                
            );
    end component;
    
    signal in_re_even      :       std_logic_vector(15 downto 0);
    signal in_re_odd       :       std_logic_vector(15 downto 0);
    signal in_im_even      :       std_logic_vector(15 downto 0);
    signal in_im_odd       :       std_logic_vector(15 downto 0);
                
    signal out_re_even     :       std_logic_vector(15 downto 0);
    signal out_re_odd      :       std_logic_vector(15 downto 0);
    signal out_im_even     :       std_logic_vector(15 downto 0);
    signal out_im_odd      :       std_logic_vector(15 downto 0);
                            
    signal fft_stage       :       integer := 0;
    signal tw_addr         :       integer := 0;
    
    signal clk             :       std_logic := '0';
begin

    DUT: BFU 
        generic map(
                        logN        =>      3,
                        sample_size =>      16
                    )
           port map(
                        in_re_even      =>      in_re_even,
                        in_re_odd       =>      in_re_odd,
                        in_im_even      =>      in_im_even,
                        in_im_odd       =>      in_im_odd,
                        
                        out_re_even     =>      out_re_even,
                        out_re_odd      =>      out_re_odd,
                        out_im_even     =>      out_im_even,
                        out_im_odd      =>      out_im_odd,
                        
                        fft_stage       =>      0,
                        tw_addr         =>      0,
                        
                        clk             =>      clk,
                        en              =>      '1'
                    );
 
    process
    begin
        wait until rising_edge(clk);

        in_re_even <= std_logic_vector(to_signed(5, 16));
        in_re_odd  <= std_logic_vector(to_signed(6, 16));
        in_im_even <= std_logic_vector(to_signed(7, 16));
        in_im_odd  <= std_logic_vector(to_signed(8, 16));
        
        wait until rising_edge(clk);
        
        in_re_even <= std_logic_vector(to_signed(9, 16));
        in_re_odd  <= std_logic_vector(to_signed(10, 16));
        in_im_even <= std_logic_vector(to_signed(11, 16));
        in_im_odd  <= std_logic_vector(to_signed(11, 16));
        
        wait;
    end process;
    
    clk <= not clk after 10ns;
end Behavioral;
