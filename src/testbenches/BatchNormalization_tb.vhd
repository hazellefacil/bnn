library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity BatchNormalization_tb is
end BatchNormalization_tb; 

ARCHITECTURE behaviour OF  BatchNormalization_tb IS 

	-- example values: it would actually be n =128 and numLen = # of bits to rep. (2^8)
	CONSTANT n : integer := 8; 
	CONSTANT numLen : integer := 6;
	
	COMPONENT BatchNormalization is
		generic(
			n 		 : integer := 256; -- could be 128 or 256
			numLen : integer := 10
			);
		port(
			CLOCK_50 : in std_logic;
			rst 		: in std_logic;
			start 	: in std_logic;
			vob 		: in std_logic_vector(n*numLen - 1 downto 0);
			epsilon  : in std_logic_vector(numLen - 1  downto 0);
			gamma 	: in std_logic_vector(numLen - 1  downto 0);
			g 			: in std_logic;
			beta 		: in std_logic_vector(numLen - 1 downto 0);
			b 			: in std_logic;
			Bn_out 	: out std_logic_vector(n*numLen - 1 downto 0);
			Bn_done 	: out std_logic
			 );
	end COMPONENT;
	
	SIGNAL CLOCK_50, rst, start, b, g, Bn_done, correct : std_logic; 
	SIGNAL gamma, beta, epsilon  					 : std_logic_vector(numLen -1 downto 0);
	SIGNAL vob, Bn_out 						 		 : std_logic_vector(n*numLen - 1 downto 0); 
	
	
	BEGIN
	
	--DUT 
	dut1: batchNormalization GENERIC MAP(n=> n, numLen => numLen)
        PORT MAP (
            CLOCK_50 => CLOCK_50,
            rst => rst,
            start => start,
            vob => vob,
				epsilon => epsilon,
            gamma => gamma,
            g => g,
            beta => beta,
            b => b,
            Bn_out => Bn_out,
            Bn_done => Bn_done
        );
		  
	clock: PROCESS IS
		BEGIN
			CLOCK_50 <= '0'; 
			WAIT FOR 1 ns; 
			CLOCK_50 <= '1';
			WAIT FOR 1 ns;
	END PROCESS; 
	
	testing: PROCESS IS 
		
		BEGIN
			rst <= '1';
			start <= '0';
			g <= '1';
			b <= '1';
			correct <= '0';
			WAIT FOR 10 ns;
			
			--test 1: zero case 
			rst <= '0';
			start <= '1';
			vob <= "010000010000010000010000010000010000010000010000";
			gamma <= "000001";
			beta <= "000001";
			epsilon <= "000100";
			WAIT FOR 300 ns; 
			
			IF(Bn_out = "000001000001000001000001000001000001000001000001") THEN
				correct <= '1';
			ELSE 
				correct <= '0';
			END IF;
			
			WAIT FOR 10 ns;
			
			rst <= '1';
			start <= '0';
			correct <= '0';
			WAIT FOR 50 ns;
			
			--test 2: 
			rst <= '0';
			start <= '1';
			vob <= "000100000100000100000100000000000000000000000000";
			gamma <= "000001";
			beta <= "000001";
			epsilon <= "000000";

			
			WAIT FOR 300 ns; 
			
			IF(Bn_out = "000011000011000011000011000001000001000001000001") THEN
				correct <= '1';
			ELSE 
				correct <= '0';
			END IF;
			
			WAIT FOR 10 ns; 
			
			correct <= '0';
			

	WAIT; 
	END PROCESS;
		  
END behaviour; 
