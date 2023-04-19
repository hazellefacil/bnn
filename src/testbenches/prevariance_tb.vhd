library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY prevariance_tb IS 
END prevariance_tb; 

ARCHITECTURE behaviour OF prevariance_tb IS 

	CONSTANT n : integer := 8; 
	CONSTANT numLen : integer := 4;
	constant T : time := 10 ns;

	TYPE test_case_record IS RECORD
		vob : std_logic_vector(n*numLen - 1 downto 0);
		mean : std_logic_vector(numLen - 1 downto 0);
		expected_pv : std_logic_vector(n*numLen - 1 downto 0);
   END RECORD;

   -- Define a type that is an array of the record.

   TYPE test_case_array_type IS ARRAY (0 to 3) OF test_case_record;

   -- Define the array itself.  We will initialize it, one line per test vector.
   -- If we want to add more tests, or change the tests, we can do it here.
   -- Note that each line of the array is one record, and the 7 numbers in each
   -- line correspond to the 7 entries in the record.  Four of these entries 
   -- represent inputs to apply, and three represent the expected outputs.
    
   signal test_case_array : test_case_array_type := (
		(x"00000000",
		 x"0",
		 x"00000000")
		,
		(x"00000000",
		 x"2",
		 x"44444444")
		,
		(x"44444444",
		 x"1",
		 x"99999999")
		,
		(x"66666666",
		 x"6",
		 x"00000000")
      );

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

SIGNAL START, CLOCK_50, rst, correct, pv_done: STD_LOGIC;
SIGNAL MEAN : STD_LOGIC_VECTOR(numLen -1 DOWNTO 0);
SIGNAL VOB, PV : STD_LOGIC_VECTOR(n*numLen -1 DOWNTO 0);

BEGIN 
	
	dut1: prevariance GENERIC MAP(n=> n, numLen => numLen)
	PORT MAP(START => START, CLOCK_50 => CLOCK_50, rst=>rst, MEAN => MEAN, VOB => VOB, PV => PV, pv_done => pv_done);
	
		
	--dut2: prevariance GENERIC MAP(n=> 256, numLen => 10)
	--PORT MAP(START => START2, CLOCK_50 => CLOCK_50, MEAN => MEAN2, VOB => VOB2, PV => PV2);
	
	
	clock: PROCESS IS
	BEGIN
		CLOCK_50 <= '0'; 
		WAIT FOR T/2; 
		CLOCK_50 <= '1';
		WAIT FOR T/2;
	END PROCESS; 
	
	process is
	begin
	
	for i in test_case_array'low to test_case_array'high loop
	
      start <= '0';
		rst <= '1';
		wait for T/2;
		correct <= '0';
		rst <= '0';
		wait for (n+2)*T;
		-- takes n*T ns to reset + extra time
		-- should be in wait state now
		
		-- set input vector
		vob <= test_case_array(i).vob;
		mean <= test_case_array(i).mean;
		wait for T/2;
		-- wait to settle
		start <= '1';
		wait for (4*n)*T;
		-- takes n*T ns to calculate + extra time
		if pv = test_case_array(i).expected_pv then 
			correct <= '1';
		else
			correct <= '0';
		end if;
		
   end loop;
	
	wait;
	end process;
	
	

END behaviour;
