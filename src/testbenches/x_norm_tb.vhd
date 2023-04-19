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
				rst		: in std_logic;
				q_e 		: in std_logic_vector(numLen - 1 downto 0); 
				mean 		: in std_logic_vector(numLen - 1 downto 0);
				variance : in std_logic_vector(numLen - 1 downto 0); 
				VOB 		: in std_logic_vector(n*numLen - 1 downto 0);
				x_norm_done : out std_logic; 
				x_norm 	: out std_logic_vector(n*numLen - 1 downto 0)
				);
	end COMPONENT;

	SIGNAL CLOCK_50, v_done, x_norm_done, rst : std_logic;
	SIGNAL q_e, mean, variance 			 		: std_logic_vector(numLen - 1 downto 0); 
	SIGNAL VOB, v_x_norm 						 	: std_logic_vector(n*numLen - 1 downto 0);
	SIGNAL correct 									: std_logic; 
	
	TYPE test_case_record IS RECORD
		vob 			  : std_logic_vector(n*numLen - 1 downto 0);
		expected_norm : std_logic_vector(n*numLen - 1 downto 0);
		mean 			  : std_logic_vector(numLen - 1 downto 0); 
		variance 	  : std_logic_vector(numLen - 1 downto 0);
		q_e 			  : std_logic_vector(numLen - 1 downto 0);
   END RECORD;

	
	TYPE test_case_array_type IS ARRAY (0 to 3) OF test_case_record;
	
	   signal test_case_array : test_case_array_type := (
		("011001100110", "000000000000", "0110", "0110","1001"), --mean = 6, variance = 0, epsilon = 9; 
		("010001000100","000100010001","0010","0010","0010"), --mean = 2, variance = 2, epsilon = 2;	
		(x"888",x"222", x"4", x"2", x"2"),--mean = 4, variance = 2, epsilon = 2;
		("101010101010", "001100110011", "0001", "1001", "0000") -- mean = 1, variance = 9, epsilon = 0;
      );
		

BEGIN

	--DUT 
	dut1: x_norm GENERIC MAP(n=> n, numLen => numLen)
	PORT MAP (CLOCK_50 => CLOCK_50, v_done => v_done, rst => rst, q_e => q_e, mean => mean, variance => variance, VOB => VOB,
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
		

		
		--(VOB - mean) / sqrt(variance + epsilon) 
		
		for i in test_case_array'low to test_case_array'high loop
			
			correct <= '0';
			v_done <= '0';
			rst <= '1';
			WAIT FOR 10 ns; 
			
			v_done <= '0';
			rst <= '0';
			VOB <= test_case_array(i).vob;
			mean <=test_case_array(i).mean;
			variance <= test_case_array(i).variance;
			q_e <= test_case_array(i).q_e;
			WAIT FOR 10 ns;
			
			v_done <= '1';		
			WAIT FOR 100 ns;
			
			IF(v_x_norm = test_case_array(i).expected_norm) THEN 
				correct <= '1';
			ELSE
				correct <= '0';
			END IF;
			WAIT FOR 10 ns;
					
		
		end loop; 

	
		
	WAIT; 
	END PROCESS; 

END behaviour;