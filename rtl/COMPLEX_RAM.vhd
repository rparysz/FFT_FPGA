library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity COMPLEX_RAM is
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
end COMPLEX_RAM;

architecture Behavioral of COMPLEX_RAM is

    component ram is
         generic(
                    s_size : integer := 8;
                    depth  : integer := 8
                );
         port(
          clk  : in  std_logic;
          ena   : in  std_logic;
          enb   : in  std_logic;
          wea   : in  std_logic;
          web   : in  std_logic;
          addra : in  integer := 0;
          addrb : in  integer := 0;
          dia   : in  std_logic_vector(s_size-1 downto 0);
          dib   : in  std_logic_vector(s_size-1 downto 0);
          doa   : out std_logic_vector(s_size-1 downto 0);
          dob   : out std_logic_vector(s_size-1 downto 0)
         );
    end component;
    
    signal A_addr_a : integer := 0;
    signal A_addr_b : integer := 0;
    signal B_addr_a : integer := 0;
    signal B_addr_b : integer := 0;
    
    signal out_even_re_A:     std_logic_vector(sample_size-1 downto 0);
    signal out_odd_re_A:      std_logic_vector(sample_size-1 downto 0);
    signal out_even_im_A:     std_logic_vector(sample_size-1 downto 0);
    signal out_odd_im_A:      std_logic_vector(sample_size-1 downto 0);
    
    signal out_even_re_B:     std_logic_vector(sample_size-1 downto 0);
    signal out_odd_re_B:      std_logic_vector(sample_size-1 downto 0);
    signal out_even_im_B:     std_logic_vector(sample_size-1 downto 0);
    signal out_odd_im_B:      std_logic_vector(sample_size-1 downto 0);
    
begin
    
    A_addr_a <= w_addr_even when (we_a = '1') else r_addr_even;
    A_addr_b <= w_addr_odd  when (we_a = '1') else r_addr_odd;
    B_addr_a <= w_addr_even when (we_b = '1') else r_addr_even;
    B_addr_b <= w_addr_odd  when (we_b = '1') else r_addr_odd;
    
    out_even_re <= out_even_re_B when(we_a = '1') else out_even_re_A;
    out_odd_re  <= out_odd_re_B  when(we_a = '1') else out_odd_re_A;
    
    out_even_im <= out_even_im_B when(we_a = '1') else out_even_im_A;
    out_odd_im  <= out_odd_im_B  when(we_a = '1') else out_odd_im_A;
    
    RAM_RE_A: ram 
        generic map(
                        s_size      =>      sample_size,
                        depth       =>      depth
                    )
           port map(
                        clk         =>      clk,
                        ena         =>      '1',
                        enb         =>      '1',
                        wea         =>      we_a,
                        web         =>      we_a,
                        addra       =>      A_addr_a,
                        addrb       =>      A_addr_b,
                        dia         =>      in_even_re,
                        dib         =>      in_odd_re,
                        doa         =>      out_even_re_A,
                        dob         =>      out_odd_re_A
                    );
                    
    RAM_RE_B: ram 
        generic map(
                        s_size      =>      sample_size,
                        depth       =>      depth
                    )
           port map(
                        clk         =>      clk,
                        ena         =>      '1',
                        enb         =>      '1',
                        wea         =>      we_b,
                        web         =>      we_b,
                        addra       =>      B_addr_a,
                        addrb       =>      B_addr_b,
                        dia         =>      in_even_re,
                        dib         =>      in_odd_re,
                        doa         =>      out_even_re_B,
                        dob         =>      out_odd_re_B
                    );
                               
    RAM_IM_A: ram 
        generic map(
                        s_size      =>      sample_size,
                        depth       =>      depth
                    )
           port map(
                        clk         =>      clk,
                        ena         =>      '1',
                        enb         =>      '1',
                        wea         =>      we_a,
                        web         =>      we_a,
                        addra       =>      A_addr_a,
                        addrb       =>      A_addr_b,
                        dia         =>      in_even_im,
                        dib         =>      in_odd_im,
                        doa         =>      out_even_im_A,
                        dob         =>      out_odd_im_A
                    );
                    
    RAM_IM_B: ram 
        generic map(
                        s_size      =>      sample_size,
                        depth       =>      depth
                    )
           port map(
                        clk         =>      clk,
                        ena         =>      '1',
                        enb         =>      '1',
                        wea         =>      we_b,
                        web         =>      we_b,
                        addra       =>      B_addr_a,
                        addrb       =>      B_addr_b,
                        dia         =>      in_even_im,
                        dib         =>      in_odd_im,
                        doa         =>      out_even_im_B,
                        dob         =>      out_odd_im_B
                    );

end Behavioral;
