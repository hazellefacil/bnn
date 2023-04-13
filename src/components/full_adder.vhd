library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity part of the description.  Describes inputs and outputs

entity full_adder is
	generic(
		n : integer := 1;
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
	
		variable temp : unsigned(numLen - 1 downto 0) := to_unsigned(0, sum'length);
		
	begin
	
		if (start = '1') then
		
			temp := to_unsigned(0, temp'length);
			
			iterate : for i in 0 to n-1 loop
				
				temp := temp + unsigned( pv( (i+1)*numLen-1 downto i*numLen ) );
				
			end loop iterate;
			
			if (temp > 0) then
				sum <= std_logic_vector(temp);
			else
				sum <= (others => '0');
			end if;
			
			
		else
			
			sum <= (others => '1');
			
		end if;
	
	end process;
	
end behavioural;