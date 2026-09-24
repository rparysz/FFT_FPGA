library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity BFU is
    generic(
                logN        :       integer := 10;
                sample_size :       integer := 29
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
                                    
            tw_addr         :       in integer := 0;
                        
            clk             :       in std_logic;
            en              :       in std_logic
        );
            
end BFU;
    
architecture Behavioral of BFU is
    
    component twiddle_rom is
    generic(
                logN        :   integer := 5;
                sample_size :   integer := 16
           );
        port(
                addr	: in integer range 0 to 2**logN;
                tw_re   : out std_logic_vector(sample_size-1 downto 0);
                tw_im   : out std_logic_vector(sample_size-1 downto 0);
                
                clk     : in std_logic
                );
    end component;
    
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

    signal bre_d, bre_dd, bre_ddd, bre_dddd, bre_ddddd, bre_dddddd  :   std_logic_vector(sample_size-1 downto 0);
    signal bim_d, bim_dd, bim_ddd, bim_dddd, bim_ddddd, bim_dddddd  :   std_logic_vector(sample_size-1 downto 0);
    
    signal ar, ai   		:   std_logic_vector(sample_size-1 downto 0);
    signal pr, pi           :   std_logic_vector(2*(sample_size) downto 0);
	signal tw_re, tw_im		:	std_logic_vector(sample_size-1 downto 0);
    signal tw_re_d, tw_im_d, tw_re_dd, tw_im_dd		:	std_logic_vector(sample_size-1 downto 0);
begin     

	TW_ROM: twiddle_rom 
		generic map(
						logN			=>	logN,
						sample_size		=>	sample_size
					)
			port map(
						addr		=>		tw_addr,
						tw_re		=>		tw_re,
						tw_im		=>		tw_im,
						
						clk         =>      clk
					);
					
	CX_MPL:	cmult
         generic map(
                        AWIDTH      =>       sample_size,
                        BWIDTH      =>       sample_size
                    )
		port map(
						clk			=>		clk,
						ar			=>		ar,
						ai			=>		ai,
						br			=>		tw_re_d,
						bi			=>		tw_im_d,
						pr			=>		pr,
						pi			=>		pi
					);
		  
	out_re_odd <= pr(2*sample_size-15 downto sample_size-14);
	out_im_odd <= pi(2*sample_size-15 downto sample_size-14);
	

    process(clk)
    begin
        if(en = '1') then
            if(rising_edge(clk)) then
                bre_d  	<= std_logic_vector(signed(in_re_even) + signed(in_re_odd));       
                bim_d  	<= std_logic_vector(signed(in_im_even) + signed(in_im_odd));
                 
                ar      <= std_logic_vector(signed(in_re_even) - signed(in_re_odd));            
                ai		<= std_logic_vector(signed(in_im_even) - signed(in_im_odd));
                
                tw_re_d <= tw_re;
                tw_im_d <= tw_im;
            end if;
        end if;
	end process;
	
	process(clk)
	begin
	   if(en = '1') then
            if(rising_edge(clk)) then
                bre_dd		<= bre_d;
                bre_ddd 	<= bre_dd;
                bre_dddd	<= bre_ddd;
                bre_ddddd	<= bre_dddd;
                bre_dddddd	<= bre_ddddd;
                out_re_even <= bre_dddddd;
            end if;
        end if;
	end process;
	
	process(clk)
	begin
	   if(en = '1') then
            if(rising_edge(clk)) then
                bim_dd		<= bim_d;
                bim_ddd 	<= bim_dd;
                bim_dddd	<= bim_ddd;
                bim_ddddd	<= bim_dddd;
                bim_dddddd	<= bim_ddddd;
                out_im_even <= bim_dddddd;
            end if;
        end if;
	end process;	
    
end Behavioral;
