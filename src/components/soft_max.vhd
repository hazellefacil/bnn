library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity part of the description.  Describes inputs and outputs

entity soft_max is
  port(
  		vo_3 : out : unsigned(7 downto 0); -- 2^7 = 128 (max), 2^8 for negatives
		reset : in std_logic;
		num_encoded : out std_logic_vector(9 downto 0)
		);
end soft_max;

-- Architecture part of the description

architecture behavioural of soft_max is

begin
	
end behavioural;