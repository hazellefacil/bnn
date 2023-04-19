LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY bnn IS 
	GENERIC(N1 	: NATURAL := 256;
			  N2 	: NATURAL := 128;
			  i2	: NATURAL := 128;
			  j2	: NATURAL := 256;
			  i3	: NATURAL := 10;
			  j3	: NATURAL := 128;
			  numLen_sm	: NATURAL := 10);
	PORT(RESET			: IN	STD_LOGIC;  
		CLOCK_50 		: IN  STD_LOGIC;
		NUM_ENCODED		: OUT STD_LOGIC_VECTOR(9 downto 0) := (OTHERS => '0');  
		DONE				: OUT STD_LOGIC := '0');
END bnn;

ARCHITECTURE RTL OF bnn IS

	COMPONENT bmxbv_256_128 IS
	GENERIC(N 	: NATURAL := 256;
			  M	: NATURAL := 128); 
	PORT(CLOCK_50 : IN  STD_LOGIC;
		START	: IN	STD_LOGIC;
		vix 		: IN  STD_LOGIC_VECTOR(N-1 downto 0);
		vox		: OUT	STD_LOGIC_VECTOR((11*M) -1 downto 0) := (OTHERS => '0');
		DONE		: OUT STD_LOGIC := '0'); 
	END COMPONENT;
		
	COMPONENT bmxbv_128_10 IS
		GENERIC(N 	: NATURAL := 128;
				  M	: NATURAL := 10); 
		PORT(CLOCK_50 : IN  STD_LOGIC;
			START	: IN	STD_LOGIC;
			vix 		: IN  STD_LOGIC_VECTOR(N-1 downto 0);
			vox		: OUT	STD_LOGIC_VECTOR((10*M) -1 downto 0) := (OTHERS => '0');
			DONE		: OUT STD_LOGIC := '0');  
	END COMPONENT;
	
	COMPONENT reLU IS
		generic(
			n : integer := 1; -- could be 128 or 256
			numLen : integer := 10
			);
		port(
			CLOCK_50 : in std_logic;
			Bn_x : in std_logic_vector(n*numLen_sm - 1 downto 0);
			rst : in std_logic;
			Bn_done : in std_logic;
			relu_x : out std_logic_vector(n - 1 downto 0);
			relu_done : out std_logic
			);
	END COMPONENT;
	
	COMPONENT soft_max IS
		GENERIC(
			n 		 : INTEGER := 0;
			numLen : INTEGER := 10
		);
	  PORT(
			CLOCK_50 : IN STD_LOGIC; 
			bb3_done : IN STD_LOGIC;  
			reset 	: IN STD_LOGIC;
			vo_3 		: IN STD_LOGIC_VECTOR(10*numLen - 1 downto 0); 
			num_encoded : OUT STD_LOGIC_VECTOR(9 downto 0)
			);
	END COMPONENT;
	
	SIGNAL b2_START, b2_DONE 	: STD_LOGIC := '0';
	SIGNAL vi2 		: STD_LOGIC_VECTOR(N1-1 downto 0) := (OTHERS => '0');
	SIGNAL b2_vox 	: STD_LOGIC_VECTOR((11*i2) -1 downto 0) := (OTHERS => '0');
	
	SIGNAL b3_START, b3_DONE	: STD_LOGIC := '0';
	SIGNAL vi3		: STD_LOGIC_VECTOR(N2-1 downto 0) := (OTHERS => '0');
	SIGNAL b3_vox 	: STD_LOGIC_VECTOR((10*i3) -1 downto 0) := (OTHERS => '0');
	
	SIGNAL bb3_done, reset_sm : STD_LOGIC := '0';
	--SIGNAL vo_3_sm : STD_LOGIC_VECTOR(9*numLen_sm - 1 downto 0) := (OTHERS => '0');	
	
	SIGNAL rst, Bn_done, relu_done : STD_LOGIC := '0';
	SIGNAL Bn_x : std_logic_vector(1*numLen_sm - 1 downto 0);
	SIGNAL relu_x : std_logic_vector(1 - 1 downto 0);
	
BEGIN

	reLU0 : reLU PORT MAP(CLOCK_50 => CLOCK_50, Bn_x => Bn_x, rst => rst, Bn_done => Bn_done, relu_x => relu_x, relu_done => relu_done);

	soft_max0 : soft_max PORT MAP(CLOCK_50 => CLOCK_50, bb3_done => bb3_done, reset => reset_sm, vo_3 => b3_vox, num_encoded => NUM_ENCODED);

	b2: bmxbv_256_128 PORT MAP(CLOCK_50 => CLOCK_50, START => b2_START, vix => vi2, vox => b2_vox, DONE => b2_DONE);
	
	--b3: bmxbv_128_10 PORT MAP(CLOCK_50 => CLOCK_50, START => b3_START, vix => vi3, vox => b3_vox, DONE => b3_DONE);


END RTL;