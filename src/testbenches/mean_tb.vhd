library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mean_tb is
end mean_tb;

architecture Behavioural of mean_tb is

	constant n : integer := 8;
	constant numLen : integer := 5;
	constant T : time := 10 ns;

	TYPE test_case_record IS RECORD
		vob : std_logic_vector(n*numLen - 1 downto 0);
		expected_mean : std_logic_vector(numLen - 1 downto 0);
   END RECORD;

   -- Define a type that is an array of the record.

   TYPE test_case_array_type IS ARRAY (0 to 3) OF test_case_record;

   -- Define the array itself.  We will initialize it, one line per test vector.
   -- If we want to add more tests, or change the tests, we can do it here.
   -- Note that each line of the array is one record, and the 7 numbers in each
   -- line correspond to the 7 entries in the record.  Four of these entries 
   -- represent inputs to apply, and three represent the expected outputs.
    
   signal test_case_array : test_case_array_type := (
		('0' & x"5" & '0' & x"2" & '0' & x"3" & '0' & x"4" & '0' & x"5" & '0' & x"6" & '0' & x"7" & '0' & x"8",
		 '0' & x"5")
		,
		('1' & x"5" & '1' & x"2" & '1' & x"3" & '1' & x"4" & '1' & x"5" & '1' & x"6" & '1' & x"7" & '1' & x"8",
		 '1' & x"5")
		,
		('1' & x"0" & '1' & x"0" & '1' & x"0" & '1' & x"0" & '1' & x"0" & '1' & x"0" & '1' & x"0" & '1' & x"0",
		 '0' & x"0")
		,
		('0' & x"8" & '0' & x"8" & '0' & x"8" & '0' & x"8" & '0' & x"8" & '0' & x"8" & '0' & x"8" & '0' & x"8",
		 '0' & x"8")
      );

	component mean is
		generic(
			n : integer := 256; -- could be 128 or 256
			numLen : integer := 10
			);
		port(
			CLOCK_50 : in std_logic;
			vob : in std_logic_vector(n*numLen - 1 downto 0);
			rst : in std_logic;
			start : in std_logic;
			mean : out std_logic_vector(numLen - 1 downto 0);
			mean_done : out std_logic
			);
	end component;
	
	signal CLOCK_50 : std_logic := '0';
	signal vob : std_logic_vector(n*numLen - 1 downto 0) := (others => '0');
	signal rst : std_logic := '0';
	signal start : std_logic := '0';
	
	signal mean_o : std_logic_vector(numLen - 1 downto 0);
	signal mean_done : std_logic;
	signal correct : std_logic := '0';
	
	begin

	DUT : mean
	generic map(
		n => n,
		numLen => numLen -- MSB tells if negative or positive
		)
	port map(
		CLOCK_50,
		vob,
		rst,
		start,
		mean_o,
		mean_done
		);
	
	process is
	begin 
		CLOCK_50 <= not CLOCK_50;
		wait for T/2;
	end process;
	
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
		wait for T/2;
		-- wait to settle
		start <= '1';
		wait for (n+2)*T;
		-- takes n*T ns to calculate + extra time
		if mean_o = test_case_array(i).expected_mean then 
			correct <= '1';
		else
			correct <= '0';
		end if;
		
   end loop;
	
	wait;
	end process;

end Behavioural;