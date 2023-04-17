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
		x_norm_done : out std_logic; 
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
		TYPE state_type IS (s_init, s_wait, s_calculate, s_done); 
		SIGNAL state : state_type := s_init;

		BEGIN
		--calculate sqrt(variance + epsilon (unclocked) 
			eps := to_integer(unsigned(q_e)); 
			var := to_integer(unsigned(variance)); 
			square := integer(sqrt(real(eps+var)));
			
		-- round this value st we can divide by it 
			
		CASE state IS 
			WHEN s_init =>
				x_norm_done <= '0';
			
			WHEN s_wait => 
			
				IF(v_done = '1') THEN 
					state <= s_calculate;
				ELSE 
					state <= s_wait; 
				END IF;
			
			WHEN s_calculate => 
				
				
				-- for each element in vob, normalize
				
				count := count + 1;
				IF(count > n) THEN 
					state <= s_done;
				END IF; 
			
			WHEN s_done => 
				x_norm_done <= '1';
				state <= s_done;
		
		END CASE; 
		
	END PROCESS; 
	
end behavioural;