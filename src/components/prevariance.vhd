library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity part of the description.  Describes inputs and outputs

entity prevariance is
	generic(
		n : integer := 0;
		numLen :integer := 10
	);
  port(
	START 	: in STD_LOGIC;
	CLOCK_50 : in STD_LOGIC;
	MEAN 		: in STD_LOGIC_VECTOR(numLen -1 DOWNTO 0);
	VOB 		: in STD_LOGIC_VECTOR(n*numLen -1 DOWNTO 0);
	PV 		: out STD_LOGIC_VECTOR(n*numLen -1 DOWNTO 0)
		);
end prevariance;

-- Architecture part of the description

architecture behavioural of prevariance is

TYPE state_type IS (s_init, s_wait, s_loop, s_done);
SIGNAL state : state_type := s_init; 
SIGNAL VOB_int : STD_LOGIC_VECTOR(n*numLen -1 DOWNTO 0);

begin
	

	PROCESS(CLOCK_50)
	variable vc, m, square, shift, count : integer := 0;
	variable pv_int : STD_LOGIC_VECTOR(numLen -1 DOWNTO 0);
	
	BEGIN
	
	IF(n = 256) THEN
		shift := 8; 
	ELSIF (n = 128) THEN
		shift := 7;
	END IF;
	
	IF(rising_edge(CLOCK_50)) THEN 
	
		CASE state IS 
		
		
		
			WHEN s_init =>
				count := 0;
				
				state <= s_wait; 
				
				
			
			WHEN s_wait => 
			
				IF(start = '1') THEN 
					VOB_int <= VOB;
					state <= s_loop;
				ELSE 
					state <= s_wait; 
				END IF;
				
			WHEN s_loop =>
				
				vc := to_integer(unsigned(VOB((n-count)*numLen-1 downto (n-count-1)*numLen)));
				m := to_integer(unsigned(mean));
				
				square := (vc-m)*(vc-m);
				
				-- cannot do length - 1 (ex. 127 or 255) using bit shifting
				pv_int := std_logic_vector(shift_right(to_unsigned(square, numLen),shift));
				
				PV((n-count)*numLen-1 downto (n-count-1)*numLen) <= pv_int; 		
				
				count := count + 1;
				
				if (count = n) then
					state <= s_done;
				end if;
				
			WHEN s_done => 
				state <= s_done;
		
		END CASE;
		
	END IF;
	


	END PROCESS;
	
end behavioural;