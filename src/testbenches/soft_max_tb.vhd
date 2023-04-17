library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity soft_max_tb is
end soft_max_tb;

ARCHITECTURE behaviour OF soft_max_tb IS 

	CONSTANT n : integer := 0; 
	CONSTANT numLen : integer := 4;
	--for this test, we'll represent up to unsigned 15 per element 

	COMPONENT soft_max is
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
	end COMPONENT; 
	
	SIGNAL CLOCK_50, bb3_done, reset : std_logic;
	SIGNAL num_encoded : std_logic_vector(9 downto 0);
	SIGNAL vo_3 : STD_LOGIC_VECTOR(9*numLen - 1 downto 0); 
	

	BEGIN
		
	dut1: soft_max GENERIC MAP(n=> n, numLen => numLen)
	PORT MAP(CLOCK_50 => CLOCK_50, bb3_done => bb3_done, reset => reset, vo_3 => vo_3, num_encoded => num_encoded); 
	
	clock: PROCESS IS
		BEGIN
			CLOCK_50 <= '0'; 
			WAIT FOR 1 ns; 
			CLOCK_50 <= '1';
			WAIT FOR 1 ns;
	END PROCESS; 
	
	sm: PROCESS IS
		BEGIN
		
		reset <= '0';
		bb3_done <= '0';
		WAIT FOR 10 ns; 
		
		bb3_done <= '1';
		vo_3 <= "000101001000000100100010001000100010";
		--given this, the 1 should be at count = 3
		WAIT FOR 100 ns;
			
	WAIT;
	END PROCESS;
	

END behaviour; 
