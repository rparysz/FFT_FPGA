library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity AGU is
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
         

         tw_addr    :   out integer
         );
         
        
end AGU;

architecture Behavioral of AGU is

	--State machine declaration
    type state_type is(off, samples_load, last_sample_in, span_load, on_cnt, last_cnt, mem_flush, last_flush, shift, data_out);
    
    signal agu_state : state_type;

    --Bit reverse function
    function bit_reverse (a: in std_logic_vector)
        return std_logic_vector is
          variable result: std_logic_vector(a'RANGE);
          alias aa: std_logic_vector(a'REVERSE_RANGE) is a;
        begin
          for i in aa'RANGE loop
            result(i) := aa(i);
          end loop;
          return result;
    end function; 
                 
    constant N       : integer := 2**logN;
    constant flushN  : integer := 5;
    
    signal t1_odd    :       integer := 0;
    signal t2_odd    :       integer := 0;
    signal t_even    :       integer := 0;
    signal w_even_t  :       integer := 0;
    signal flush_cnt :       integer := 0;
	signal s_in_addr :		 integer := 0;
	signal d_out_addr:		 integer := 0;
	signal fft_stage :		 integer := 0;
    
    signal span      :       unsigned(logN-1 downto 0) := to_unsigned(N/2, logN);
    
    signal last_addr  	:     std_logic := '0';
    signal stage_ovfl 	:     std_logic := '0';
	signal samples_ovfl	:	  std_logic	:= '0';
	signal flush_ovfl   :     std_logic := '0';
	signal data_o_ovfl  :	  std_logic := '0';
     
	signal samples_on :		std_logic := '0';
    signal cnt_on     :     std_logic := '0';
	signal load_on	  :		std_logic := '0';
    signal shift_on   :     std_logic := '0';
    signal flush_on   :     std_logic := '0';
	signal data_o_on  :		std_logic := '0';
    signal mem_sel, mem_sel_on : std_logic := '0';
	
	signal we_a       :   std_logic := '0';
    signal we_b       :   std_logic := '0';
    signal web_t, web_tt:   std_logic := '0';
    
    signal web_d, web_dd, web_ddd, web_dddd, web_ddddd, web_dddddd, web_ddddddd, web_dddddddd       : std_logic := '0';
    signal abe_d, abe_dd, abe_ddd, abe_dddd, abe_ddddd, abe_dddddd, abe_ddddddd                     : integer   := 0;
    signal abo_d, abo_dd, abo_ddd, abo_dddd, abo_ddddd, abo_dddddd, abo_ddddddd                     : integer   := 0;
begin
	--State Machine 
    process(clk)
    begin
        if(rising_edge(clk)) then
            case agu_state is
                when off=>
                    if(agu_en = '1') then
                       agu_state <= samples_load;
                    else
                       agu_state <= off;
                    end if;
                    cnt_on      <= '0';
                    shift_on    <= '0';
                    stage_ov    <= '0';
                    d_in_time   <= '0';
                    d_out_time  <= '0';
                    agu_done	<= '1';
                    fft_calc    <= '0';
                    data_o_on 	<= '0';
                    mem_sel_on  <= '0';
                    we_a        <= '0';
                    we_b	    <= '0';
                when samples_load=>
					if(samples_ovfl = '1') then
					   agu_state <= last_sample_in;
					else
					   agu_state <= samples_load;
					end if;
                    samples_on  <= '1';
                    agu_done 	<= '0';
                    d_in_time   <= '1';
                    
                    we_a        <= '1';
				when last_sample_in =>
                    agu_state <= span_load;
                    samples_on  <= '0';
                    we_a        <= '0';
                    we_b	    <= '0';
				                
                when span_load=>
                    agu_state <= on_cnt;
                    mem_sel_on  <= '1';
                    agu_done	<= '0';
                    load_on 	<= '1';
                    d_in_time   <= '0';
                    we_b	    <= '1';
                    
                when on_cnt=>
                    if(last_addr = '1') then
                        agu_state <= last_cnt;
                    else
                        agu_state <= on_cnt;
                    end if;
                    mem_sel_on  <= '0';
                    fft_calc    <= '1';
                    cnt_on	    <= '1';
                    load_on     <= '0';
                    shift_on    <= '0';
                    stage_ov    <= '0';
				when last_cnt=>
					agu_state <= mem_flush;
                    stage_ov    <= '1';	
                    we_b	    <= '0';
			    when mem_flush =>
			        if(flush_ovfl = '1') then
			            agu_state <= last_flush;
			        else
			            agu_state <= mem_flush;
			        end if;
		        flush_on <= '1';
			    when last_flush =>
			         agu_state <= shift;
		        flush_on <= '0'; 
		        shift_on    <= '1';
                when shift=>
                    if(stage_ovfl = '1') then
                        agu_state <= data_out;
                    else
                        agu_state <= span_load;
                    end if;
			    flush_on    <= '0';           
				cnt_on      <= '0';
				load_on     <= '1';
				shift_on    <= '0';
				when others=>
					if(data_o_ovfl = '1') then
						agu_state <= off;
					else
						agu_state <= data_out;
					end if;
			    fft_calc    <= '0';
			    stage_ov    <= '0';
				data_o_on 	<= '1';
				load_on   	<= '0';
				d_out_time  <= '1';
            end case;
        end if;
    end process;
    	
	process(mem_sel_on)
	begin
	   if(rising_edge(mem_sel_on)) then
            mem_sel <= not mem_sel;
	   end if;
    end process;
    
	--Address counter
    process(clk)
    begin
        if(rising_edge(clk)) then
			if(load_on = '1') then
				t1_odd <= to_integer(span);
				last_addr <= '0';
            elsif(cnt_on = '1') then
                if(t2_odd < N-2) then
                    t1_odd <= t2_odd + 1;
				else
				    t1_odd <= t2_odd + 1;
					last_addr <= '1';
                end if;
			else
			    t1_odd <= 0;
				last_addr <= '0';
            end if;
        end if;
    end process;
    
    --Span shift register and fft level counter
	process(shift_on)
	begin
		if(rising_edge(shift_on)) then
			if(fft_stage < logN-1) then
				span <= '0' & span(logN-1 downto 1);
				fft_stage <= fft_stage + 1;
				stage_ovfl <= '0';
			else
				stage_ovfl <= '1';
				fft_stage  <= 0;
				span <= to_unsigned(N/2, logN);
			end if;
		end if;
	end process;
	
	--Data in counter
	process(clk)
	begin
		if(rising_edge(clk)) then
			if(samples_on = '1') then
				if(s_in_addr < N-1) then
					s_in_addr <= s_in_addr + 1;
				else
					samples_ovfl <= '1';
				end if;
			else
				samples_ovfl <= '0';
				s_in_addr <= 0;
			end if;
		end if;
	end process;
	
	--Data out counter	
	process(clk)
	begin
		if(rising_edge(clk)) then
			if(data_o_on = '1') then
				if(d_out_addr < N-1) then
					d_out_addr <= d_out_addr + 1;
				else
					data_o_ovfl <= '1';
				end if;
			else
				data_o_ovfl <= '0';
				d_out_addr <= 0;
			end if;
		end if;
	end process;
	
	--Memory flush conunter
	process(clk)
	begin
	   if(rising_edge(clk)) then
	       if(flush_on = '1') then
	           if(flush_cnt < flushN-2) then
	               flush_cnt <= flush_cnt + 1;
	           else
	               flush_cnt <= flush_cnt + 1;
	               flush_ovfl <= '1';
	           end if;
	       else
	           flush_cnt <= 0;
	           flush_ovfl <= '0';
	       end if;     
	   end if;
	end process;
    
            
    --Delayed even write address
    process(clk)
    begin
        if(rising_edge(clk)) then
            abe_d       <= t_even;
            abe_dd      <= abe_d;
            abe_ddd     <= abe_dd;
            abe_dddd    <= abe_ddd;
            abe_ddddd   <= abe_dddd;
            abe_dddddd  <= abe_ddddd;
            abe_ddddddd <= abe_dddddd;
            w_even_t    <= abe_ddddddd;
        end if;
    end process;
    
    --Delayed odd write address
    process(clk)
    begin
        if(rising_edge(clk)) then
            abo_d       <= t2_odd;
            abo_dd      <= abo_d;
            abo_ddd     <= abo_dd;
            abo_dddd    <= abo_ddd;
            abo_ddddd   <= abo_dddd;
            abo_dddddd  <= abo_ddddd;
            abo_ddddddd <= abo_dddddd;
            w_odd       <= abo_ddddddd;
        end if;
    end process;
    
    --Delayed write enable for port b
    process(clk)
    begin
        if(rising_edge(clk)) then
            web_d       <=  we_b;
            web_dd      <=  web_d;
            web_ddd     <=  web_dd;
            web_dddd    <=  web_ddd;
            web_ddddd   <=  web_dddd;
            web_dddddd  <=  web_ddddd;
            web_ddddddd <=  web_dddddd;
            web_t         <=  web_ddddddd;
        end if;
    end process;
    
    wea <= we_a  when (agu_state = samples_load) else web_t when(mem_sel = '0') else '0';
    web <= web_t when (mem_sel = '1') else '0';
    
    w_even <= t_even when (agu_state = samples_load) else w_even_t;
    
    t2_odd <= 0 when (agu_state = off or agu_state = mem_flush or agu_state = samples_load) 
				else to_integer(unsigned(bit_reverse(std_logic_vector(to_unsigned(d_out_addr, logN))))) when (agu_state = data_out)
				else to_integer(to_unsigned(t1_odd, logN) or span);
				
    t_even <= 0 when (agu_state = off or agu_state = data_out or agu_state = mem_flush)
                     else s_in_addr when(agu_state = samples_load)
                     else to_integer(to_unsigned(t2_odd, logN) xor span);
    
    tw_addr     <= (to_integer(shift_left(to_unsigned(t_even, logN), fft_stage) and to_unsigned(N-1, logN))) 
                    when(agu_state = on_cnt or agu_state = last_cnt) else 5;
                    
    r_odd     	<= t2_odd;
    r_even    	<= t_even;

end Behavioral;
