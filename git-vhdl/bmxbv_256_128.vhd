LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY bmxbv_256_128 IS
	GENERIC(N 	: NATURAL := 128;
			  M	: NATURAL := 10); 
	PORT(CLOCK_50 : IN  STD_LOGIC;
		START	: IN	STD_LOGIC;
		vix 		: IN  STD_LOGIC_VECTOR(N-1 downto 0);
		qwx		: IN	STD_LOGIC_VECTOR(N-1 downto 0);
		vox		: OUT	INTEGER := 0;
		DONE		: OUT STD_LOGIC := '0'); 
END bmxbv_256_128;

ARCHITECTURE RTL OF bmxbv_256_128 IS

	COMPONENT popcnt_256 IS
	GENERIC(N	: NATURAL := 128); 
	PORT(INPUT 	: IN  STD_LOGIC_VECTOR(N-1 downto 0);
		SUM		: OUT INTEGER := 0;
		DONE		: OUT STD_LOGIC := '0');  
	END COMPONENT;

	SIGNAL p_DONE : STD_LOGIC := '0';
	SIGNAL p_INPUT : STD_LOGIC_VECTOR(N-1 downto 0) := (OTHERS => '0');
	SIGNAL p_SUM : INTEGER := 0; 
	
	TYPE state_type IS (s_XNOR, s_popcnt, s_done);
	SIGNAL state	: state_type;
	
BEGIN

	popcnt0 : popcnt_256 PORT MAP(INPUT => p_INPUT, SUM => p_SUM, DONE => p_DONE);
	
	PROCESS(START, CLOCK_50)
		VARIABLE XNOR_RESULT		:	STD_LOGIC_VECTOR(N-1 downto 0) := (OTHERS => '0');
	BEGIN 
	
	IF Rising_Edge(START) THEN
		DONE <= '0';
		state <= s_XNOR;
	
	ELSIF Rising_Edge(CLOCK_50) THEN
	
		CASE state IS
			WHEN s_XNOR =>			
				XNOR_RESULT := vix XNOR qwx;
				p_INPUT <= XNOR_RESULT;
				state <= s_popcnt;
				
			WHEN s_popcnt =>
				--p_INPUT <= XNOR_RESULT; -- may need to add a clock to let p_INPUT get its value
				
				IF(p_DONE = '1') THEN
					vox <= p_SUM;
					DONE <= '1';
					state <= s_done;					
				ELSE
					state <= s_popcnt;
				END IF;
			
			WHEN s_done =>	
				DONE <= '0';
		
		END CASE;
		
	END IF;

	END PROCESS;

END RTL;