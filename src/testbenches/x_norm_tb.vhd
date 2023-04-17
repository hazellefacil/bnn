library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity x_norm_tb is
end x_norm_tb; 


ARCHITECTURE behaviour OF  x_norm_tb IS 
--signals here
	SIGNAL CLOCK_50 : std_logic;

BEGIN

	--DUT 
	clock: PROCESS IS
		BEGIN
			CLOCK_50 <= '0'; 
			WAIT FOR 1 ns; 
			CLOCK_50 <= '1';
			WAIT FOR 1 ns;
	END PROCESS; 
	
	xnrm: PROCESS IS 
		BEGIN
		
		
		
		
	WAIT; 
	END PROCESS; 

END behaviour;