library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY prevariance_tb IS 
END prevariance_tb; 

ARCHITECTURE behaviour OF prevariance_tb IS 

CONSTANT n : integer := 1; 
CONSTANT numLen : integer := 8;

	COMPONENT prevariance is
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
	end COMPONENT;

SIGNAL START1, START2, CLOCK_50, rst: STD_LOGIC;
SIGNAL MEAN1,MEAN2 : STD_LOGIC_VECTOR(numLen -1 DOWNTO 0);
SIGNAL VOB1, VOB2, PV1, PV2 : STD_LOGIC_VECTOR(n*numLen -1 DOWNTO 0);

BEGIN 
	
	dut1: prevariance GENERIC MAP(n=> n, numLen => numLen)
	PORT MAP(START => START1, CLOCK_50 => CLOCK_50, rst=>rst, MEAN => MEAN1, VOB => VOB1, PV => PV1);
	
		
	--dut2: prevariance GENERIC MAP(n=> 256, numLen => 10)
	--PORT MAP(START => START2, CLOCK_50 => CLOCK_50, MEAN => MEAN2, VOB => VOB2, PV => PV2);
	
	
	clock: PROCESS IS
	BEGIN
		CLOCK_50 <= '0'; 
		WAIT FOR 1 ns; 
		CLOCK_50 <= '1';
		WAIT FOR 1 ns;
	END PROCESS; 
	
	pv: PROCESS IS 
	BEGIN 
		
		--vob = 128, mean = 0, answer should be 1 
		MEAN1 <= "00000000";
		VOB1 <= "10000000";
		START1 <= '0';
		WAIT FOR 10 ns; 
		
		START1 <= '1';
		WAIT FOR 100 ns;
		
		START1 <= '0';
		
		--vob = 158, mean = 128, answer should still be 1 
		MEAN1 <= "00011110";
		VOB1 <= "10011110";
		WAIT FOR 100 ns;
		
	WAIT;
	END PROCESS;

END behaviour;
