library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


-- Entity part of the description.  Describes inputs and outputs

	entity prevariance is
		generic(
			n : integer := 0;
			numLen :integer := 10
			);
		port(
			CLOCK_50 : in STD_LOGIC;
			mean 	: in STD_LOGIC_VECTOR(numLen -1 DOWNTO 0);
			rst : in std_logic;
			start : in std_logic;
			VOB 		: in STD_LOGIC_VECTOR(n*numLen -1 DOWNTO 0);
			PV 		: out STD_LOGIC_VECTOR(n*numLen -1 DOWNTO 0);
			pv_done : out std_logic
			);
	end prevariance;
	

-- Architecture part of the description

architecture behavioural of prevariance is

TYPE state_type IS (s_init, s_wait, s_loop,s_buffer, s_divide, s_done);
SIGNAL state : state_type := s_init; 
SIGNAL VOB_int : STD_LOGIC_VECTOR(n*numLen -1 DOWNTO 0);

begin
	

	PROCESS(CLOCK_50, rst)
	variable vc, m, square, shift, count : integer := 0;
	variable pv_calc, temp2 	: STD_LOGIC_VECTOR(numLen*2 -1 DOWNTO 0);
	
	BEGIN
	
		shift := integer(floor(log2(real(n)))) + 1;

	if rst = '1' then
		state <= s_init;
	ELSIF(rising_edge(CLOCK_50)) THEN 
	
		CASE state IS 
		
		
		
			WHEN s_init =>
				count := 0;
				pv_done <= '0';
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
				
				state <= s_buffer; 
			WHEN s_buffer => 
			
				temp2 := std_logic_vector(to_unsigned(square, temp2'length));
				
				state <= s_divide; 
				
			WHEN s_divide => 
				
				--(x(i) - mean)^2 / length - 1
				-- cannot do length - 1 (ex. 127 or 255) using bit shifting
					--pv_int := std_logic_vector(shift_right(to_unsigned(square, numLen),shift));
					--PV((n-count)*numLen-1 downto (n-count-1)*numLen) <= pv_int; 	
				
				
				pv_calc := '0' & std_logic_vector(to_unsigned(to_integer(shift_right(unsigned(temp2), shift)), pv_calc'length - 1));
				PV((n-count)*numLen-1 downto (n-count-1)*numLen) <= pv_calc(numLen-1 downto 0); 
					
				count := count + 1;
				
				if (count = n) then
					state <= s_done;
				else 
					state <= s_loop;
				end if;
				
			WHEN s_done => 
				pv_done <= '1';
				state <= s_done;
		
		END CASE;
		
	END IF;
	


	END PROCESS;
	
end behavioural;