library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity vga_input_controller is

    generic(
                s_size      : integer := 32;
                logN        : natural := 10
            );
    port(
            i_clk_100MHZ      :   in std_logic;
            i_clk_148MHZ      :   in std_logic;
            i_data_out_av     :   in std_logic;
            i_frame_ready     :   in std_logic;
            o_read_ena        :   out std_logic;
            i_read_addr       :   in std_logic_vector(logN-1   downto 0);
            din               :   in std_logic_vector(s_size-1 downto 0);
            dout              :   out std_logic_vector(9 downto 0)
        );
        
end vga_input_controller;

architecture Behavioral of vga_input_controller is

    constant N: integer := 2**logN;
    type state_type is(ram_reading, frame_ready, ram_loading);  
    signal state : state_type;
    signal data_cnt_ovfl : std_logic := '0';
    signal data_cnt_on   : std_logic := '0';
    signal data_cnt : integer := 0;
    signal o_ren             : std_logic := '0';
    
    signal din_d: std_logic_vector(s_size-1 downto 0);
    signal we_d : std_logic := '0';
    
    component fft_out_ram is
         generic(
                    s_size : integer := 24;
                    depth  : integer := 10
                );
         port(
                  clk_r   : in std_logic;
                  clk_w   : in std_logic;
                  we   : in  std_logic;
                  re   : in  std_logic;
                  w_addr : in  integer := 0;
                  r_addr : in  integer := 0;
                  di    : in  std_logic_vector(s_size-1 downto 0);
                  do    : out std_logic_vector(s_size-1 downto 0)
         );
    end component;
    
begin

    process(i_clk_100MHZ)
    begin
        if(rising_edge(i_clk_100MHZ)) then
            din_d   <= din;
            we_d    <= i_data_out_av;
        end if;
    end process;
    
    process(i_clk_100MHZ)
    begin
        if(rising_edge(i_clk_100MHZ)) then
            case state is
                when ram_reading =>
                    if(i_frame_ready = '1') then
                        state <= frame_ready; 
                    else
                        state <= ram_reading;
                    end if;
                when frame_ready => 
                    if(i_data_out_av = '1') then
                        state <= ram_loading;
                    else
                        state <= frame_ready;
                    end if;
                when ram_loading =>
                    if(data_cnt_ovfl = '1') then
                        state <= ram_reading;
                    else
                        state <= ram_loading;
                    end if;
            end case;
        end if;
    end process;                    
    
    process(state)
    begin
        case state is
            when ram_reading =>
                o_ren <= '1';
                data_cnt_on <= '0';
            when frame_ready =>
                o_ren <= '1';
            when ram_loading =>
                o_ren <= '0';
                data_cnt_on <= '1';
        end case;
    end process;
    
    o_read_ena <= o_ren;
    
	process(i_clk_100MHZ)
	begin
		if(rising_edge(i_clk_100MHZ)) then
			if(data_cnt_on = '1') then
				if(data_cnt < N-1) then
					data_cnt <= data_cnt + 1;
				else
					data_cnt_ovfl <= '1';
					data_cnt <= 0;
				end if;
			else
				data_cnt_ovfl <= '0';
				data_cnt <= 0;
			end if;
		end if;
	end process;
	
    RAM: fft_out_ram
        generic map(
                        s_size => 10,
                        depth  => N
                   )
           port map(
                        clk_r  => i_clk_148MHZ,
                        clk_w  => i_clk_100MHZ,
                        we     => data_cnt_on,
                        re     => o_ren,
                        w_addr => data_cnt,
                        r_addr => to_integer(unsigned(i_read_addr)),
                        di     => din_d(24 downto 15),
                        do     => dout
                    );
end Behavioral;
