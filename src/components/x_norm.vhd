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
			v_done 	: in std_logic;
			q_e 		: in std_logic_vector(numLen - 1 downto 0); 
			mean 		: in std_logic_vector(numLen - 1 downto 0);
			variance : in std_logic_vector(numLen - 1 downto 0); 
			VOB 		: in std_logic_vector(n*numLen - 1 downto 0);
			x_norm_done : out std_logic; 
			x_norm 	: out std_logic_vector(n*numLen - 1 downto 0)
			);
end x_norm;

-- Architecture part of the description

architecture behavioural of x_norm is
--signals here: 
		TYPE state_type IS (s_init, s_wait, s_calculate, s_done); 
		SIGNAL state : state_type := s_init;
		SIGNAL x_norm_temp : std_logic_vector(n*numLen - 1 downto 0);

	
	begin

	--two things: 1) convert to real to be able to use the square root function (non-synthesizable) 
	--				  2) same thing, cannot divide by a half number (ex. 127), have to divide by something close enough 	
	
	PROCESS(CLOCK_50) 
		--variables here 
		variable count, square, var, eps, num, t_vob : integer := 0;

		BEGIN
		--calculate sqrt(variance + epsilon (unclocked) 
			eps := to_integer(unsigned(q_e)); 
			var := to_integer(unsigned(variance)); 
			square := integer(sqrt(real(eps+var)));
			
		-- round this value st we can divide by it 
			
		CASE state IS 
			WHEN s_init =>
				x_norm_done <= '0';
				num := 0;
				x_norm_temp <= (others => '0');
				
				state <= s_wait; 
			
			WHEN s_wait => 
			
				IF(v_done = '1') THEN 
					
					num := n*numLen - 1;
					state <= s_calculate;
				ELSE 
					state <= s_wait; 
				END IF;
			
			WHEN s_calculate => 
				
				
				IF(num-numLen +1 >= 0) THEN
					
					--x_Norm(count) = VOB(count) - mean / sqrt(variance + epsilon) 
				
					t_vob := (to_integer(unsigned(VOB(num DOWNTO num-numLen + 1))) - to_integer(unsigned(mean))) / square;
					x_norm_temp(num DOWNTO num-numLen +1) <= std_logic_vector(to_unsigned(t_vob, numLen));
				
				END IF; 
				
				num := num - numLen;
				count := count + 1;
				
				IF(count > n) THEN 
					state <= s_done;
				END IF; 
			
			WHEN s_done => 
				x_norm <= x_norm_temp;
				x_norm_done <= '1';
				state <= s_done;
		
		END CASE; 
		
	END PROCESS; 
	
end behavioural;