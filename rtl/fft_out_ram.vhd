library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity fft_out_ram is
 generic(
            s_size : integer := 24;
            depth  : integer := 1024
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
end fft_out_ram;

architecture syn of fft_out_ram is

    type ram_type is array (depth-1 downto 0) of std_logic_vector(s_size-1 downto 0);
    shared variable RAM : ram_type := (others=>(others=>'0'));
    
begin

 process(CLK_w)
 begin
    if rising_edge(clk_w) then
        if WE = '1' then
             RAM(w_ADDR) := DI;
        end if;
    end if;
 end process;

 process(CLK_r)
 begin
    if rising_edge(clk_r) then
        if RE = '1' then
             do <= ram(r_addr);
        end if;
    end if;
 end process;

end syn;
