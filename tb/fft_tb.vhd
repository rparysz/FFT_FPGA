library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity fft_tb is

end fft_tb;

architecture Behavioral of fft_tb is
    
    component FFT_TOP is
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
    end component;
    
    constant s_size        : integer := 29;
    
    signal clk             :       std_logic := '0';
    signal st              :       std_logic;
    signal load_samples    :       std_logic;
    signal data_out_av     :       std_logic;
    signal fft_done        :       std_logic;
    signal fft_busy        :       std_logic;
        
    signal sample_in_re    :       std_logic_vector(s_size-1 downto 0) := (others=>'0');
    signal sample_in_im    :       std_logic_vector(s_size-1 downto 0) := (others=>'0');
    signal data_out_re     :       std_logic_vector(s_size-1-5 downto 0);
    signal data_out_im     :       std_logic_vector(s_size-1-5 downto 0);  
        
    file file_DATA            :   text;
    file file_OUT_RE          :   text;
    file file_OUT_IM          :   text;
    
begin
    
    DUT: FFT_TOP
        generic map(
                        logN        =>      10,
                        sample_size =>      s_size
                   )
           port map(
                        clk             =>      clk,
                        st              =>      st,
                        load_samples    =>      load_samples,
                        data_out_av     =>      data_out_av,
                        fft_done        =>      fft_done,
                        fft_busy        =>      fft_busy,
                        
                        sample_in_re    =>      sample_in_re,
                        sample_in_im    =>      sample_in_im,
                        data_out_re     =>      data_out_re,
                        data_out_im     =>      data_out_im
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
            sample_in_re <= std_logic_vector(resize(signed(sample), s_size));
            --sample_in_re <= std_logic_vector(to_signed(1, 8));
            sample_in_im <= std_logic_vector(to_signed(0, s_size));
            wait until rising_edge(clk);
        end loop;
        
        wait;
    end process;
    
    
    process
        variable out_re_line    :   line;
        variable out_im_line    :   line;
    begin
        file_open(file_OUT_RE, "C:\Users\45527\Desktop\Study_documents\Semester_4\Project\data_out_re.txt",  write_mode);
        file_open(file_OUT_IM, "C:\Users\45527\Desktop\Study_documents\Semester_4\Project\data_out_im.txt",  write_mode);
        wait until rising_edge(data_out_av);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        for i in 0 to 1023 loop
            write(out_re_line, to_integer(signed(data_out_re)));
            writeline(file_OUT_RE, out_re_line);
            write(out_im_line, to_integer(signed(data_out_im)));
            writeline(file_OUT_IM, out_im_line);
            wait until rising_edge(clk);
        end loop;
        wait;
    end process;          

    clk <= not clk after 10ns;
end Behavioral;
