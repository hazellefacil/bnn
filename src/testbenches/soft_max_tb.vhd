library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity soft_max_tb is
end soft_max_tb;

ARCHITECTURE behaviour OF soft_max_tb IS 

	CONSTANT n : integer := 10; 
	CONSTANT numLen : integer := 4;
	
	constant T : time := 10 ns;

	TYPE test_case_record IS RECORD
		vo_3 : std_logic_vector(n*numLen - 1 downto 0);
		expected_num_encoded : std_logic_vector(n - 1 downto 0);
   END RECORD;

   -- Define a type that is an array of the record.

   TYPE test_case_array_type IS ARRAY (0 to 3) OF test_case_record;

   -- Define the array itself.  We will initialize it, one line per test vector.
   -- If we want to add more tests, or change the tests, we can do it here.
   -- Note that each line of the array is one record, and the 7 numbers in each
   -- line correspond to the 7 entries in the record.  Four of these entries 
   -- represent inputs to apply, and three represent the expected outputs.
    
   signal test_case_array : test_case_array_type := (
		(x"0123456789",
		  "0000000001")
		,
		(x"8093426156",
		  "0010000000")
		,
		(x"8703487093",
		  "0000000010")
		,
		(x"0000000001",
		  "0000000001")
      );

	COMPONENT soft_max is
		generic(
			n : integer := 0;
			numLen :integer := 4
		);
	  port(
			CLOCK_50 : in std_logic; 
			bb3_done : in std_logic;  
			reset : in std_logic;
			vo_3 : in STD_LOGIC_VECTOR(n*numLen - 1 downto 0); 
			num_encoded : out std_logic_vector(n - 1 downto 0);
			done : out std_logic
			);
	end COMPONENT; 
	
	SIGNAL CLOCK_50, bb3_done, reset, correct, done : std_logic := '0';
	SIGNAL num_encoded : std_logic_vector(n - 1 downto 0);
	SIGNAL vo_3 : STD_LOGIC_VECTOR(n*numLen - 1 downto 0); 
	

	BEGIN
		
	dut1: soft_max GENERIC MAP(n=> n, numLen => numLen)
	PORT MAP(CLOCK_50 => CLOCK_50, bb3_done => bb3_done, reset => reset, vo_3 => vo_3, num_encoded => num_encoded, done => done); 
	
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
	
      bb3_done <= '0';
		reset <= '1';
		wait for T/2;
		correct <= '0';
		reset <= '0';
		wait for (n+2)*T;
		-- takes n*T ns to reset + extra time
		-- should be in wait state now
		
		-- set input vector
		vo_3 <= test_case_array(i).vo_3;
		wait for T/2;
		-- wait to settle
		bb3_done <= '1';
		wait for (n + 2)*T;
		-- takes n*T ns to calculate + extra time
		if num_encoded = test_case_array(i).expected_num_encoded then 
			correct <= '1';
		else
			correct <= '0';
		end if;
		
   end loop;
	
	wait;
	end process;
	

END behaviour; 
