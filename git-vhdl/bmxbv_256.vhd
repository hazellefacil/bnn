LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY bmxbv_256 IS
	GENERIC(N 	: NATURAL := 256;
			  numLen	: NATURAL := 10); 
	PORT(START	: IN	STD_LOGIC;
		CLOCK_50 : IN  STD_LOGIC;
		vix 		: IN  STD_LOGIC_VECTOR((N*numLen)-1 downto 0);
		qwx		: IN	STD_LOGIC_VECTOR((N*numLen)-1 downto 0);
		vox		: OUT	STD_LOGIC_VECTOR((N*numLen)-1 downto 0) := (OTHERS => '0');
		DONE		: OUT STD_LOGIC := '0'); 
END bmxbv_256;

ARCHITECTURE RTL OF bmxbv_256 IS

	COMPONENT popcnt IS
		GENERIC(numLen	: NATURAL := 10;
				  sumLen	: NATURAL := 4); 
		PORT(START	: IN	STD_LOGIC;  
			INPUT 	: IN  STD_LOGIC_VECTOR(numLen-1 downto 0);
			SUM		: OUT UNSIGNED(sumLen-1 downto 0) := (OTHERS => '0');
			DONE		: OUT STD_LOGIC := '0'); 
	END COMPONENT;

	SIGNAL p_START, p_DONE : STD_LOGIC := '0';
	SIGNAL p_INPUT : STD_LOGIC_VECTOR(numLen-1 downto 0) := (OTHERS => '0');
	SIGNAL p_SUM : UNSIGNED(3 downto 0) := (OTHERS => '0');
	
	TYPE state_type IS (s_XNOR, s_popcnt, s_done);
	SIGNAL state	: state_type;
	SIGNAL count	: INTEGER := 0;
	SIGNAL MSB, LSB	: INTEGER := 0;
	
BEGIN

	popcnt0 : popcnt PORT MAP(START => p_START, INPUT => p_INPUT, SUM => p_SUM, DONE => p_DONE); 
	
	-- always statements to clean up bit ranges
	MSB <= (N - count)*numLen - 1;
	LSB <= (N - count - 1)*numLen - 1;
	
	PROCESS(START, CLOCK_50)
		VARIABLE XNOR_RESULT		:	STD_LOGIC_VECTOR((N*numLen)-1 downto 0) := (OTHERS => '0');
	BEGIN 
	
	IF Rising_Edge(START) THEN
		state <= s_XNOR;
		done <= '0';
		count <= 0;
	
	ELSIF Rising_Edge(CLOCK_50) THEN
	
		CASE state IS
			WHEN s_XNOR =>			
				XNOR_RESULT := vix(MSB downto LSB) XNOR qwx(MSB downto LSB);
				
			WHEN s_popcnt =>
				p_INPUT <= XNOR_RESULT;
				p_START <= '1'; -- may need to add in a clock to let p_INPUT get value
				
				IF(p_DONE = '1') THEN
					vox(MSB downto LSB) <= STD_LOGIC_VECTOR(p_SUM);
					state <= s_done;
					
					IF(count = (N - 1)) THEN
						state <= s_done;
					ELSE
						count <= count + 1;
						state <= s_XNOR;
					END IF;
					
				ELSE
					state <= s_popcnt;
				END IF;
			
			WHEN s_done =>	
				DONE <= '1';
		
		END CASE;
		
	END IF;

	END PROCESS;

END RTL;