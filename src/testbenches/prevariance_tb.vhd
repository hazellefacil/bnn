library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY prevariance_tb IS 
END prevariance_tb; 

ARCHITECTURE behaviour OF prevariance_tb IS 

COMPONENT prevariance is
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

BEGIN 

	dut: prevariance PORT MAP (
	
	clock: PROCESS IS
	BEGIN
		CLOCK_50 <= '0'; 
		WAIT FOR 1 ns; 
		CLOCK_50 <= '1';
		WAIT FOR 1 ns;
		
	
	END PROCESS; 
	


END behaviour; 
