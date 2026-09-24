library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity AGU_tb is

end AGU_tb;

architecture Behavioral of AGU_tb is
    
    component AGU is
        generic(
                logN    :   integer := 10
                );
        port(clk    	: 	in std_logic;
             agu_en 	:   in std_logic;
             stage_ov	:	out std_logic;
             d_in_time  :   out std_logic;
             d_out_time :   out std_logic;
             fft_calc   :   out std_logic;
             agu_done	:	out std_logic;
             
             web        :   out std_logic;
                       
             stage_cnt  :   out integer;
             
             r_even   	:   out integer;
             r_odd    	:   out integer;
             
             w_even     :   out integer;
             w_odd      :   out integer;
             
    
             tw_addr    :   out integer
             );
     end component;
     
     signal clk:        std_logic := '0';
     signal en:         std_logic := '0';
     signal stage_ov:	std_logic := '0';
     signal d_in_time:  std_logic := '0';
     signal d_out_time: std_logic := '0';
     signal fft_calc:   std_logic := '0';
     signal agu_done:   std_logic := '0';
     signal stage_cnt:  integer;
     signal r_even:       integer;
     signal r_odd:        integer;
     signal w_even:       integer;
     signal w_odd:        integer;
     signal tw_addr:    integer;
     
     signal web	:   std_logic := '0';
       
begin

    clk <= not clk after 10ns;
    
    process
    begin
        wait for 50ns;
        en <= '1';
        wait for 30ns;
        en <= '0';
        wait;
    end process;
    
    DUT: AGU
            generic map(
                        logN => 3
                        )
            port map(clk         =>  clk,
                      agu_en     =>  en,
                      stage_ov   =>  stage_ov,
					  d_in_time  =>  d_in_time,
					  d_out_time =>  d_out_time,
					  fft_calc   =>  fft_calc,
                      agu_done   =>  agu_done,
                      web        =>  web,
                      
                      stage_cnt    =>  stage_cnt,
                      
                      r_even       =>  r_even,
                      r_odd        =>  r_odd,
                      
                      w_even       =>  w_even,
                      w_odd        =>  w_odd,
                      
                      tw_addr    =>  tw_addr
                      );
                        
end Behavioral;
