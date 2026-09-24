library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;
entity fft_mag_tb is

end fft_mag_tb;

architecture Behavioral of fft_mag_tb is

    component fft_mag_wrapper is
      port (
            clk_0 : in STD_LOGIC;
            data_out_av : out STD_LOGIC;
            fft_busy_0 : out STD_LOGIC;
            fft_done : out STD_LOGIC;
            load_samples_0 : out STD_LOGIC;
            m_axis_dout_tdata_0 : out STD_LOGIC_VECTOR ( 31 downto 0 );
            sample_in_re_0 : in STD_LOGIC_VECTOR ( 28 downto 0 );
            st_0 : in STD_LOGIC
      );
    end component;
    
    constant s_size : integer := 29;
    signal clk, fft_done, load_samples          : std_logic := '0';
    signal fft_busy, st, data_out_av            : std_logic := '0';
    signal fft_mag                              : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal sample_in                            : STD_LOGIC_VECTOR ( 28 downto 0 );
    signal fft_mag_sc                             : STD_LOGIC_VECTOR ( 9 downto 0 );
    file file_DATA            :   text;
begin

    fft_mag_sc <= fft_mag(24 downto 15);
    DUT: fft_mag_wrapper
        port map(
                    clk_0               =>  clk,
                    data_out_av         =>  data_out_av,
                    fft_busy_0          =>  fft_busy,
                    fft_done            =>  fft_done,
                    load_samples_0      =>  load_samples,
                    m_axis_dout_tdata_0 =>  fft_mag,
                    sample_in_re_0      =>  sample_in,
                    st_0                =>  st
                );
                
    process 
        variable data_LINE     : line;
        variable sample        : std_logic_vector(s_size-1-5 downto 0);
    begin
        wait for 60ns;
        wait until rising_edge(clk);
        st <= '1';
        wait for 20ns;
        st <= '0';
        
        file_open(file_DATA, "C:\Users\45527\Desktop\Study_documents\Semester_4\Project\data2.txt",  read_mode);
          wait until rising_edge(clk);
        for i in 0 to 1023 loop
            readline(file_DATA, data_LINE);
            hread(data_LINE, sample);
            sample_in <= std_logic_vector(resize(signed(sample)/10, s_size));
            --sample_in <= std_logic_vector(to_signed(1, s_size));
            wait until rising_edge(clk);
        end loop;
        wait;
    end process;

    clk <= not clk after 10ns;
end Behavioral;
