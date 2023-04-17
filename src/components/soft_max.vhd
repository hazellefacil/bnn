library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity part of the description.  Describes inputs and outputs
--vo_3 : out : unsigned(7 downto 0); -- 2^7 = 128 (max), 2^8 for negatives

entity soft_max is
	generic(
		n : integer := 0;
		numLen :integer := 4
	);
  port(
		CLOCK_50 : in std_logic; 
		bb3_done : in std_logic;  
		reset : in std_logic;
		vo_3 : in STD_LOGIC_VECTOR(9*numLen - 1 downto 0); 
		num_encoded : out std_logic_vector(9 downto 0)
		);
end soft_max;
		
architecture behavioural of soft_max is

TYPE state_type IS (s_init, s_wait, s_findMax, s_oneHot, s_done); 
SIGNAL state : state_type := s_init; 
SIGNAL softmax_output, encoded_value : std_logic_vector(9 downto 0);
SIGNAL vector_temp : std_logic_vector(3 DOWNTO 0); 

begin

-- softmax output will be a 10-element array 

--from this it finds the max
--return one hot encoded value

	PROCESS(CLOCK_50) 
	--variables here 
	variable count, max_index, t_max_index, t_max, num: integer := 0;
	
	BEGIN
	
		CASE state IS 

			WHEN s_init => 
				count := 0;  
				vector_temp <= (others => '0');
				
				state <= s_wait; 
				
			WHEN s_wait => 
			
				IF(bb3_done = '1') THEN 
					t_max := 0;
					num := 35; 
					state <= s_findMax;
				ELSE 
					state <= s_wait; 
				END IF;
				
			WHEN s_findMax => 
				
				IF(num-numLen +1 >= 0) THEN
					vector_temp <= vo_3(num DOWNTO num-numLen +1); 
				END IF; 
				
				IF(to_integer(unsigned(vector_temp)) > t_max) THEN 
					t_max := to_integer(unsigned(vector_temp)); 
					t_max_index := count; 
				END IF;
			
				num := num - numLen; 
				count := count + 1; 
				
				IF (count > 10) THEN 
					max_index := t_max_index; 
					state <= s_oneHot;
				END IF; 
				
			WHEN s_oneHot => 
				
				encoded_value <= (others => '0');
				encoded_value(max_index) <= '1'; 
				state <= s_done; 
				
			WHEN s_done => 
		
			num_encoded <= encoded_value;
			state <= s_done;
			
		END CASE; 
	END PROCESS; 
	
	
end behavioural;