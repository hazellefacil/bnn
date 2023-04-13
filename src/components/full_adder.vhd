library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity part of the description.  Describes inputs and outputs

entity full_adder is
	generic(
		n : integer := 0;
		numLen : integer := 10
		);
	port(
		pv : in std_logic_vector(n*numLen - 1 downto 0);
		start : in std_logic;
		sum : out std_logic_vector(numLen - 1 downto 0)
		);
end full_adder;

-- Architecture part of the description

architecture behavioural of full_adder is

begin

	process(start)
	
		variable temp : integer := 0;
		
	begin
	
		if rising_edge(start) then
		
			temp := 0;
			
			iterate : for i in n to 1 loop
				
				temp := temp + to_integer(unsigned(pv(i*numLen-1 downto (i-1)*numLen)));
				
			end loop iterate;
			
		end if;
		
		sum <= std_logic_vector(to_unsigned(temp, sum'length));
	
	end process;
	
end behavioural;