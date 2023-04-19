LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY bmxbv_128_10 IS
	GENERIC(N 	: NATURAL := 128;
			  M	: NATURAL := 10); 
	PORT(CLOCK_50 : IN  STD_LOGIC;
		START	: IN	STD_LOGIC;
		vix 		: IN  STD_LOGIC_VECTOR(N-1 downto 0);
		vox		: OUT	STD_LOGIC_VECTOR((10*M) -1 downto 0) := (OTHERS => '0');
		DONE		: OUT STD_LOGIC := '0'); 
END bmxbv_128_10;

ARCHITECTURE RTL OF bmxbv_128_10 IS

	COMPONENT w3 IS
		GENERIC(i 	: NATURAL := 10;
				  j 	: NATURAL := 128);
		PORT(address			: IN	INTEGER;  
			 vector		: OUT STD_LOGIC_VECTOR(j-1 downto 0) := (OTHERS => '0')
			 );
	END COMPONENT; 

	COMPONENT popcnt_128 IS
	GENERIC(N	: NATURAL := 128); 
	PORT(INPUT 	: IN  STD_LOGIC_VECTOR(N-1 downto 0);
		SUM		: OUT INTEGER := 0;
		DONE		: OUT STD_LOGIC := '0');  
	END COMPONENT;
	
	SIGNAL w3_address : INTEGER := 0;
	SIGNAL w3_vector 	: STD_LOGIC_VECTOR(N-1 downto 0) := (OTHERS => '0');

	SIGNAL p_DONE : STD_LOGIC := '0';
	SIGNAL p_INPUT : STD_LOGIC_VECTOR(N-1 downto 0) := (OTHERS => '0');
	SIGNAL p_SUM : INTEGER := 0; 
		
	SIGNAL count : INTEGER := 0;
	
	TYPE state_type IS (s_init, s_XNOR, s_popcnt, s_done);
	SIGNAL state	: state_type;
	
BEGIN

	weight3: w3 PORT MAP(address => w3_address, vector => w3_vector);

	popcnt0 : popcnt_128 PORT MAP(INPUT => p_INPUT, SUM => p_SUM, DONE => p_DONE);
	
	PROCESS(START, CLOCK_50)
		VARIABLE XNOR_RESULT		:	STD_LOGIC_VECTOR(N-1 downto 0) := (OTHERS => '0');
	BEGIN 	

	IF (START = '1') THEN
		count <= 0;
		DONE <= '0';
		state <= s_init;
	
	ELSIF Rising_Edge(CLOCK_50) THEN
	
		CASE state IS
			WHEN s_init =>
					-- vi3 updated in relu
					-- get weight row vector
					w3_address <= count;
					
					state <= s_XNOR;
					
			WHEN s_XNOR =>			
				XNOR_RESULT := vix XNOR w3_vector;
				p_INPUT <= XNOR_RESULT;
				state <= s_popcnt;
				
			WHEN s_popcnt =>
				
				IF(p_DONE = '1') THEN
					vox(10*(M-count) -1 downto 10*(M-1-count)) <= STD_LOGIC_VECTOR(TO_UNSIGNED(p_SUM, 10));
					
					IF(count < M-1) THEN
						count <= count + 1;
						state <= s_init;
					ELSE
						state <= s_done;
					END IF;	
					
				ELSE
					state <= s_popcnt;
				END IF;
			
			WHEN s_done =>	
				DONE <= '1';
				w3_address <= 0;
				state <= s_done;
		
		END CASE;
		
	END IF;

	END PROCESS;

END RTL;