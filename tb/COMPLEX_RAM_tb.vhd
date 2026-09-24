library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity COMPLEX_RAM_tb is

end COMPLEX_RAM_tb;

architecture Behavioral of COMPLEX_RAM_tb is

	constant sample_size : integer := 8;
	constant depth		 : integer := 8;
	
    component COMPLEX_RAM is
         generic
        (
            sample_size : integer := 16;
            depth       : integer := 32
        );
        port
        (
            in_even_re:      in std_logic_vector(sample_size-1 downto 0);
            in_odd_re:       in std_logic_vector(sample_size-1 downto 0);
            in_even_im:      in std_logic_vector(sample_size-1 downto 0);
            in_odd_im:       in std_logic_vector(sample_size-1 downto 0);
            
            out_even_re:     out std_logic_vector(sample_size-1 downto 0);
            out_odd_re:      out std_logic_vector(sample_size-1 downto 0);
            out_even_im:     out std_logic_vector(sample_size-1 downto 0);
            out_odd_im:      out std_logic_vector(sample_size-1 downto 0);
            
            we_a, we_b:      in std_logic;
           
            r_addr_even:     in integer;
            r_addr_odd:		 in integer;
            
            w_addr_even:     in integer;
            w_addr_odd:		 in integer;
                
            clk:			 in std_logic
        );
	end component;
	
	signal	in_even_re:		std_logic_vector(7 downto 0);
	signal	in_odd_re:		std_logic_vector(7 downto 0);
	signal	in_even_im:		std_logic_vector(7 downto 0);
	signal	in_odd_im:		std_logic_vector(7 downto 0);
	
	signal	out_even_re:	std_logic_vector(7 downto 0);
	signal	out_odd_re:		std_logic_vector(7 downto 0);
	signal	out_even_im:	std_logic_vector(7 downto 0);
	signal	out_odd_im:		std_logic_vector(7 downto 0);
	
	signal	r_addr_even:		integer := 0;
	signal	r_addr_odd:		    integer := 0;
	signal	w_addr_even:		integer := 0;
	signal	w_addr_odd:		    integer := 0;
	
	signal clk:				std_logic := '0';
	signal wea:             std_logic := '0';
	signal web:             std_logic := '0';
	signal we_odd_a:        std_logic := '0';
	signal we_odd_b:        std_logic := '0';
	
	signal bfu_on:          std_logic := '0';
begin

	DUT: COMPLEX_RAM
		generic map(
						sample_size =>	sample_size,
						depth		=>	depth
					)
		   port map(
                        in_even_re  =>  in_even_re,
                        in_odd_re   =>  in_odd_re,
                        in_even_im  =>  in_even_im,
                        in_odd_im   =>  in_odd_im,
                        
                        out_even_re  =>  out_even_re,
                        out_odd_re   =>  out_odd_re,
                        out_even_im  =>  out_even_im,
                        out_odd_im   =>  out_odd_im,
                        
                        we_a         =>  wea,
                        we_b         =>  web,
                        
                        r_addr_even  => r_addr_even,
                        r_addr_odd   => r_addr_odd,
                        
                        w_addr_even  => w_addr_even,
                        w_addr_odd   => w_addr_odd,
                        
                        clk          => clk
                    );
		
	process
	begin
        wait for 20ns;
        wea <= '1';
        web <= '0';
        wait until rising_edge(clk);
        w_addr_even   <= 0;
        in_even_re   <= std_logic_vector(to_signed(0, sample_size));
        wait until rising_edge(clk);        
        w_addr_even   <= 1;
        in_even_re   <= std_logic_vector(to_signed(1, sample_size));
        wait until rising_edge(clk);      
        w_addr_even   <= 2;
        in_even_re   <= std_logic_vector(to_signed(2, sample_size));
        wait until rising_edge(clk); 
        w_addr_even   <= 3;
        in_even_re   <= std_logic_vector(to_signed(3, sample_size));
        wait until rising_edge(clk);
        w_addr_even   <= 4;
        in_even_re   <= std_logic_vector(to_signed(4, sample_size));
        wait until rising_edge(clk);        
        w_addr_even   <= 5;
        in_even_re   <= std_logic_vector(to_signed(5, sample_size));
        wait until rising_edge(clk);      
        w_addr_even   <= 6;
        in_even_re   <= std_logic_vector(to_signed(6, sample_size));
        wait until rising_edge(clk); 
        w_addr_even   <= 7;
        in_even_re   <= std_logic_vector(to_signed(7, sample_size));
        wait until rising_edge(clk);
        wea  <= '0';       
        web  <= '0';
        
        wait for 20ns;
        bfu_on <= '1';

        for i in 0 to (depth/2)-1 loop
            r_addr_even <= i;
            r_addr_odd <= i+4;
            wait until rising_edge(clk);
        end loop;
        wait;      
	end process;
			
	clk <= not clk after 10ns;
end Behavioral;
