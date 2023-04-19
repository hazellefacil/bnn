LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY bmxbv_256_128 IS
	GENERIC(N 	: NATURAL := 256;
			  M	: NATURAL := 128); 
	PORT(CLOCK_50 : IN  STD_LOGIC;
		START	: IN	STD_LOGIC;
		vix 		: IN  STD_LOGIC_VECTOR(N-1 downto 0);
		vox		: OUT	STD_LOGIC_VECTOR((11*M) -1 downto 0) := (OTHERS => '0');
		DONE		: OUT STD_LOGIC := '0'); 
END bmxbv_256_128;

ARCHITECTURE RTL OF bmxbv_256_128 IS

	COMPONENT w2 IS
		GENERIC(i 	: NATURAL := 128;
				  j 	: NATURAL := 256);
		PORT(address			: IN	INTEGER;  
			 vector		: OUT STD_LOGIC_VECTOR(j-1 downto 0) := (OTHERS => '0')
			 );
	END COMPONENT; 

	COMPONENT popcnt_256 IS
	GENERIC(N	: NATURAL := 256); 
	PORT(INPUT 	: IN  STD_LOGIC_VECTOR(N-1 downto 0);
		SUM		: OUT INTEGER := 0;
		DONE		: OUT STD_LOGIC := '0');  
	END COMPONENT;
	
	SIGNAL w2_address : INTEGER := 0;
	SIGNAL w2_vector 	: STD_LOGIC_VECTOR(N-1 downto 0) := (OTHERS => '0');

	SIGNAL p_DONE : STD_LOGIC := '0';
	SIGNAL p_INPUT : STD_LOGIC_VECTOR(N-1 downto 0) := (OTHERS => '0');
	SIGNAL p_SUM : INTEGER := 0; 
		
	SIGNAL count : INTEGER := 0;
	
	TYPE state_type IS (s_init, s_XNOR, s_popcnt, s_done);
	SIGNAL state	: state_type;
	
BEGIN

	weight2: w2 PORT MAP(address => w2_address, vector => w2_vector);

	popcnt0 : popcnt_256 PORT MAP(INPUT => p_INPUT, SUM => p_SUM, DONE => p_DONE);
	
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
					-- vi2 updated in relu
					-- get weight row vector
					w2_address <= count;
					
					state <= s_XNOR;
					
			WHEN s_XNOR =>			
				XNOR_RESULT := vix XNOR w2_vector;
				p_INPUT <= XNOR_RESULT;
				state <= s_popcnt;
				
			WHEN s_popcnt =>
				
				IF(p_DONE = '1') THEN
					vox(11*(M-count) -1 downto 11*(M-1-count)) <= STD_LOGIC_VECTOR(TO_UNSIGNED(p_SUM, 11));
					
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
				w2_address <= 0;
				state <= s_done;
		
		END CASE;
		
	END IF;

	END PROCESS;

END RTL;