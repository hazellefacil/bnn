library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity part of the description.  Describes inputs and outputs

entity reLU is
	generic(
			n : integer := 256;
		);

	port(
		address_v_o : in integer;
		Bn_x : in std_logic_vector;
		);
end reLU;

-- Architecture part of the description

architecture behavioural of reLU is

begin
	
end behavioural;