library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


entity FFT_TOP is
    generic(
                logN        :   integer := 10;
                sample_size :   integer := 29
           );
           
    port(
            clk             :       in std_logic;
            st              :       in std_logic;
            load_samples    :       out std_logic;
            data_out_av     :       out std_logic;
            fft_busy        :       out std_logic;
            fft_done        :       out std_logic;
           
            sample_in_re    :       in std_logic_vector(sample_size-1 downto 0);
            sample_in_im    :       in std_logic_vector(sample_size-1 downto 0);
            data_out_re     :       out std_logic_vector(sample_size-1-5 downto 0);
            data_out_im     :       out std_logic_vector(sample_size-1-5 downto 0)
            
        );
            
end FFT_TOP;

architecture Behavioral of FFT_TOP is
    attribute keep_hierarchy : string;
    attribute keep_hierarchy of FFT_AGU : label is "yes";
    attribute keep_hierarchy of FFT_BFU : label is "yes";
    attribute keep_hierarchy of FFT_RAM : label is "yes"; 
	constant N	: integer := 2**logN;
		
    signal agu_en      :       std_logic := '0';
    signal stage_ov    :       std_logic := '0';
    signal d_in_time   :       std_logic := '0';
    signal d_out_time  :       std_logic := '0';
    signal fft_calc    :       std_logic := '0';
    signal agu_done    :       std_logic := '0';
    
	signal even			:		integer := 0;
	signal odd			:		integer := 0;
	signal tw_addr		:		integer := 0;
	
	signal samples_in		:		std_logic_vector(sample_size-1 downto 0);
	
    signal in_even_re		:       std_logic_vector(sample_size-1 downto 0);
    signal in_odd_re		:       std_logic_vector(sample_size-1 downto 0);
    signal in_even_im		:       std_logic_vector(sample_size-1 downto 0);
    signal in_odd_im		:       std_logic_vector(sample_size-1 downto 0);
           
    signal out_even_re		:       std_logic_vector(sample_size-1 downto 0);
    signal out_odd_re		:       std_logic_vector(sample_size-1 downto 0);
    signal out_even_im		:       std_logic_vector(sample_size-1 downto 0);
    signal out_odd_im		:       std_logic_vector(sample_size-1 downto 0);
           
    signal r_addr_even		    :		integer := 0;
    signal r_addr_odd			:		integer := 0;
    signal w_addr_even		    :		integer := 0;
    signal w_addr_odd			:		integer := 0;
    
    signal wea, web             :       std_logic;
              	
    signal bf_in_re_even     	:       std_logic_vector(sample_size-1 downto 0);
    signal bf_in_re_odd       	:       std_logic_vector(sample_size-1 downto 0);
    signal bf_in_im_even     	:       std_logic_vector(sample_size-1 downto 0);
    signal bf_in_im_odd         :       std_logic_vector(sample_size-1 downto 0);
              
    signal bf_out_re_even     	:       std_logic_vector(sample_size-1 downto 0);
    signal bf_out_re_odd      	:       std_logic_vector(sample_size-1 downto 0);
    signal bf_out_im_even     	:       std_logic_vector(sample_size-1 downto 0);
    signal bf_out_im_odd      	:       std_logic_vector(sample_size-1 downto 0);
                            
	
    --RAM component
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
    
    --AGU component
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
             wea        :   out std_logic;
             web        :   out std_logic;
                                    
             r_even   	:   out integer := 0;
             r_odd    	:   out integer := 0;
             
             w_even     :   out integer := 0;
             w_odd      :   out integer := 0;
             
    
             tw_addr    :   out integer := 0
             );
     end component;

     --BFU component
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
                            
                tw_addr         :       in integer;
                            
                clk             :       in std_logic;
                en              :       in std_logic
            );
    end component;
    
begin
	
	FFT_AGU: AGU 
		generic map(
						logN	=>	logN
					)
			port map(
						clk			=>		clk,
						agu_en		=>		st,
						stage_ov    =>      stage_ov,
						d_in_time	=>		d_in_time,
						d_out_time	=>		d_out_time,
						fft_calc	=>		fft_calc,
						agu_done	=>		agu_done,
						
						wea	        =>		wea,
						web         =>      web,
						
						r_even		=>		r_addr_even,
						r_odd		=>		r_addr_odd,
						
						w_even		=>		w_addr_even,
						w_odd		=>		w_addr_odd,
						
						tw_addr		=>		tw_addr
					);

	--AGU signals to FFT_TOP				
	load_samples <=	d_in_time;
	data_out_av  <= d_out_time;
	fft_done	 <= agu_done;
	fft_busy     <= fft_calc;
	
	FFT_BFU: BFU
		generic map(
						logN		=>		logN,
						sample_size	=>		sample_size
					)
			port map(
						in_re_even  =>	bf_in_re_even,
						in_re_odd	=>	bf_in_re_odd,
						in_im_even	=>	bf_in_im_even,
						in_im_odd	=>	bf_in_im_odd,
						
						out_re_even =>	bf_out_re_even,
						out_re_odd	=>	bf_out_re_odd,
						out_im_even	=>	bf_out_im_even,
						out_im_odd	=>	bf_out_im_odd,

						tw_addr		=>	tw_addr,
						
						clk         =>  clk,
						en          =>  fft_calc
					);
					
						
	FFT_RAM: COMPLEX_RAM
		generic map(
						sample_size		=>		sample_size,
						depth			=>		N
					)
		   port map(
						in_even_re		=>		in_even_re,
						in_odd_re		=>		in_odd_re,
						in_even_im		=>		in_even_im,
						in_odd_im		=>		in_odd_im,
						
						out_even_re		=>		bf_in_re_even,
						out_odd_re		=>		bf_in_re_odd,
						out_even_im		=>		bf_in_im_even,
						out_odd_im		=>		bf_in_im_odd,
						
						we_a            =>      wea,
						we_b            =>      web,             
						
						r_addr_even		=>		r_addr_even,
						r_addr_odd		=>		r_addr_odd,
						
						w_addr_even		=>		w_addr_even,
						w_addr_odd		=>		w_addr_odd,	
						
						clk				=>		clk
						
					);
	
	--Inout data multiplexer	
	in_even_re <= sample_in_re when(d_in_time = '1') else bf_out_re_even;
	in_even_im <= sample_in_im when(d_in_time = '1') else bf_out_im_even;
	
	in_odd_re  <= std_logic_vector(to_unsigned(0, sample_size)) when(d_in_time = '1') else bf_out_re_odd;
	in_odd_im  <= std_logic_vector(to_unsigned(0, sample_size)) when(d_in_time = '1') else bf_out_im_odd;
		
	data_out_re <= bf_in_re_odd(28 downto 5) when(d_out_time = '1') else (others=>'0');
	data_out_im <= bf_in_im_odd(28 downto 5) when(d_out_time = '1') else (others=>'0');	
	
end Behavioral;
