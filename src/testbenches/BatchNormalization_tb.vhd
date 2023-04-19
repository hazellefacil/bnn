library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity BatchNormalization_tb is
end BatchNormalization_tb; 

ARCHITECTURE behaviour OF  BatchNormalization_tb IS 

	CONSTANT n : integer := 3; 
	CONSTANT numLen : integer := 4;
	
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
			gamma 	: in std_logic_vector(numLen downto 0);
			g 			: in std_logic;
			beta 		: in std_logic_vector(numLen downto 0);
			b 			: in std_logic;
			Bn 		: out std_logic_vector(n*numLen - 1 downto 0);
			Bn_done 	: out std_logic
			 );
	end COMPONENT;
	
	SIGNAL CLOCK_50, rst, start, b, g, Bn_done : std_logic; 
	SIGNAL gamma, beta   							 : std_logic_vector(numLen downto 0);
	SIGNAL vob, Bn 						 			 : std_logic_vector(n*numLen - 1 downto 0);
	
	
	BEGIN
	
	--DUT 
	dut1: batchNormalization GENERIC MAP(n=> n, numLen => numLen)
        PORT MAP (
            CLOCK_50 => CLOCK_50,
            rst => rst,
            start => start,
            vob => vob,
            gamma => gamma,
            g => g,
            beta => beta,
            b => b,
            Bn => Bn,
            Bn_done => Bn_done
        );
	


END behaviour; 
