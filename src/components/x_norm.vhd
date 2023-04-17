library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- Entity part of the description.  Describes inputs and outputs

entity x_norm is
	generic(
		n : integer := 0;
		numLen :integer := 4
	);
  port(
		CLOCK_50 : in std_logic; 
		v_done : in std_logic;
		q_e : in std_logic_vector(numLen - 1 downto 0); 
		mean : in std_logic_vector(numLen - 1 downto 0);
		variance : in std_logic_vector(numLen - 1 downto 0); 
		VOB : in STD_LOGIC_VECTOR(n*numLen - 1 downto 0);
		n_norm_done : out std_logic; 
		x_norm : out std_logic_vector(n*numLen - 1 downto 0)
		);
end x_norm;

-- Architecture part of the description

architecture behavioural of x_norm is
--signals here: 

	
	begin

	--two things: 1) convert to real to be able to use the square root function (non-synthesizable) 
	--				  2) same thing, cannot divide by a half number (ex. 127), have to divide by something close enough 	

	--x_Norm(count) = VOB(count) - mean / sqrt(variance + epsilon) 
	PROCESS(CLOCK_50) 
		--variables here 
		variable count, square, var, eps : integer := 0;
		
		BEGIN
		--calculate sqrt(variance + epsilon (unclocked) 
			eps := to_integer(unsigned(q_e)); 
			var := to_integer(unsigned(variance)); 
			square := integer(sqrt(real(eps+var)));
			
		
		--CASE state IS 
		--END CASE; 
		
	END PROCESS; 
	
end behavioural;