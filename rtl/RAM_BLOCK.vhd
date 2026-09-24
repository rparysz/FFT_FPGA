library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram is
 generic(
            s_size : integer := 8;
            depth  : integer := 8
        );
     port(
          clk   : in std_logic;
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
end ram;

architecture syn of ram is

    type ram_type is array (depth-1 downto 0) of std_logic_vector(s_size-1 downto 0);
    shared variable RAM : ram_type := (others=>(others=>'0'));
 
begin

 process(CLK)
 begin
    if CLK'event and CLK = '1' then
        if ENA = '1' then
        DOA <= RAM(ADDRA);
            if WEA = '1' then
                RAM(ADDRA) := DIA;
            end if;
        end if;
    end if;
 end process;

 process(CLK)
 begin
    if CLK'event and CLK = '1' then
        if ENB = '1' then
        DOB <= RAM(ADDRB);
            if WEB = '1' then
                RAM(ADDRB) := DIB;
            end if;
        end if;
    end if;
 end process;

end syn;
