library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity x_norm_tb is
end x_norm_tb; 


ARCHITECTURE behaviour OF  x_norm_tb IS 
--signals here

	CONSTANT n : integer := 3; 
	CONSTANT numLen : integer := 4;

	COMPONENT x_norm is
		generic(
			n : integer := 0;
			numLen :integer := 4
		);
	  port(
			CLOCK_50 : in std_logic; 
			v_done 	: in std_logic;
			q_e 		: in std_logic_vector(numLen - 1 downto 0); 
			mean 		: in std_logic_vector(numLen - 1 downto 0);
			variance : in std_logic_vector(numLen - 1 downto 0); 
			VOB 		: in std_logic_vector(n*numLen - 1 downto 0);
			x_norm_done : out std_logic; 
			x_norm 	: out std_logic_vector(n*numLen - 1 downto 0)
			);
	end COMPONENT;

	SIGNAL CLOCK_50, v_done, x_norm_done : std_logic;
	SIGNAL q_e, mean, variance 			 : std_logic_vector(numLen - 1 downto 0); 
	SIGNAL VOB, v_x_norm 						 : std_logic_vector(n*numLen - 1 downto 0);
	

BEGIN

	--DUT 
	dut1: x_norm GENERIC MAP(n=> n, numLen => numLen)
	PORT MAP (CLOCK_50 => CLOCK_50, v_done => v_done, q_e => q_e, mean => mean, variance => variance, VOB => VOB,
				x_norm_done => x_norm_done, x_norm => v_x_norm); 
	

	clock: PROCESS IS
		BEGIN
			CLOCK_50 <= '0'; 
			WAIT FOR 1 ns; 
			CLOCK_50 <= '1';
			WAIT FOR 1 ns;
	END PROCESS; 
	
	xnrm: PROCESS IS 
		BEGIN
		
		v_done <= '0';
		WAIT FOR 10 ns;
		
		--(VOB - mean) / sqrt(variance + epsilon) 
		--mean = 2, variance = 2, epsilon = 2;
		--resulting normalized vector should be: "000100010001"
		
		v_done <= '1';
		VOB <= "010001000100";
		mean <= "0010";
		variance <= "0010";
		q_e <= "0010";
		
		WAIT FOR 100 ns;		
		
	WAIT; 
	END PROCESS; 

END behaviour;