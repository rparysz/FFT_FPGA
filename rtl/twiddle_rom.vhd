library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity twiddle_rom is
    generic(
                logN        :   integer := 5;
                sample_size :   integer := 16
           );
    port(addr	: in integer range 0 to 2**logN;
	    tw_re   : out std_logic_vector(sample_size-1 downto 0);
	    tw_im   : out std_logic_vector(sample_size-1 downto 0);
	    
	    clk     : in std_logic
	    );
	
end entity;

architecture Behavioral of twiddle_rom is

    constant N : integer := 2**logN;
	subtype word_t is std_logic_vector(sample_size-1 downto 0);
	type memory_t is array(0 to (N/2)-1) of word_t;
	
    function re_rom_init return memory_t is
        variable temp        :  memory_t;
        begin
        for i in 0 to (N/2)-1 loop
            temp(i) := std_logic_vector(to_signed(integer((((2.0**15)-1.0))*cos(MATH_2_PI * real(i)/real(N))), sample_size));
            --temp(i) := std_logic_vector(to_signed(1, sample_size));
        end loop;
        return temp;
    end function;
    
    function im_rom_init return memory_t is
        variable temp        :  memory_t;
        begin
        for i in 0 to (N/2)-1 loop
            temp(i) := std_logic_vector(to_signed(integer((-((2.0**15)-1.0))*sin(MATH_2_PI * real(i)/real(N))), sample_size));
            --temp(i) := std_logic_vector(to_signed(1, sample_size));
        end loop;
        return temp;
    end function;
    
    signal rom_im : memory_t := im_rom_init;
	signal rom_re : memory_t := re_rom_init;
	
begin

    process(clk)
    begin
        if(rising_edge(clk)) then
             tw_re <= rom_re(addr);
        end if;
    end process;

    process(clk)
    begin
        if(rising_edge(clk)) then
             tw_im <= rom_im(addr);
        end if;
    end process;
	
end Behavioral;
