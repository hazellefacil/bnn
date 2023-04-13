LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

LIBRARY WORK;
USE WORK.ALL;

--------------------------------------------------------------
--
--  This is a testbench you can use to test the win subblock in Modelsim.
--  The testbench repeatedly applies test vectors and checks the output to
--  make sure they match the expected values.  You can use this without
--  modification (unless you want to add more test vectors, which is not a
--  bad idea).  However, please be sure you understand it before trying to
--  use it in Modelsim.
--
---------------------------------------------------------------

ENTITY full_adder_tb IS
  -- no inputs or outputs
END full_adder_tb;

-- The architecture part decribes the behaviour of the test bench

ARCHITECTURE behavioural OF full_adder_tb IS

   -- We will use an array of records to hold a list of test vectors and expected outputs.
   -- This simplifies adding more tests; we just have to add another line in the array.
   -- Each element of the array is a record that corresponds to one test vector.
   
   -- Define the record that describes one test vector
   
   TYPE test_case_record IS RECORD
		pv : std_logic_vector(8*4 - 1 downto 0);
		expected_sum : std_logic_vector(4 - 1 downto 0);
   END RECORD;

   -- Define a type that is an array of the record.

   TYPE test_case_array_type IS ARRAY (0 to 1) OF test_case_record;
     
   -- Define the array itself.  We will initialize it, one line per test vector.
   -- If we want to add more tests, or change the tests, we can do it here.
   -- Note that each line of the array is one record, and the 7 numbers in each
   -- line correspond to the 7 entries in the record.  Four of these entries 
   -- represent inputs to apply, and three represent the expected outputs.
    
   signal test_case_array : test_case_array_type := (
             (x"11111111", x"8"),
				 (x"22222221", x"F")
             );             

  -- Define the win subblock, which is the component we are testing

	COMPONENT full_adder is
		generic(
			n : integer := 1;
			numLen : integer := 10
			);
		port(
			pv : in std_logic_vector(n*numLen - 1 downto 0);
			start : in std_logic;
			sum : out std_logic_vector(numLen - 1 downto 0)
			);
	end COMPONENT;

   -- local signals we will use in the testbench 

   signal pv : std_logic_vector(8*4 - 1 downto 0);
	signal start : std_logic;
	signal sum : std_logic_vector(4 - 1 downto 0);

begin

   -- instantiate the design-under-test

	
   dut : full_adder
	GENERIC MAP(
		n => 8, -- 		practically 128 or 256
		numLen => 4)
	PORT MAP(
		pv => pv,
		start => start,
		sum => sum);

   -- Code to drive inputs and check outputs.  This is written by one process.
   -- Note there is nothing in the sensitivity list here; this means the process is
   -- executed at time 0.  It would also be restarted immediately after the process
   -- finishes, however, in this case, the process will never finish (because there is
   -- a wait statement at the end of the process).

   process
   begin   
       
      -- starting values for simulation.  Not really necessary, since we initialize
      -- them above anyway
		
		pv <= (others => '0');
		start <= '0';
		sum <= (others => '0');

      -- Loop through each element in our test case array.  Each element represents
      -- one test case (along with expected outputs).
      
      for i in test_case_array'low to test_case_array'high loop
        
        -- Print information about the testcase to the transcript window (make sure when
        -- you run this, your transcript window is large enough to see what is happening)
        
        report "-------------------------------------------";
        report "Test case " & integer'image(i) & ":" &
                 " pv=" & integer'image(to_integer(unsigned(test_case_array(i).pv))) & 
                 " sum=" & integer'image(to_integer(unsigned(test_case_array(i).expected_sum)));

        -- assign the values to the inputs of the DUT (design under test)
        
        pv <= test_case_array(i).pv;
		  
		  wait for 1 ns;
		  
		  start <= '1';

        -- wait for some time, to give the DUT circuit time to respond (1ns is arbitrary)                

        wait for 1 ns;
		  
		  
        
        -- now print the results along with the expected results
      
        report "Expected result: sum=" & integer'image(to_integer(unsigned(test_case_array(i).expected_sum)));
        report "Observed result: sum=" & integer'image(to_integer(unsigned(sum)));

        -- This assert statement causes a fatal error if there is a mismatch
                                                                    
        assert (sum = test_case_array(i).expected_sum)
            report "MISMATCH.  THERE IS A PROBLEM IN YOUR DESIGN THAT YOU NEED TO FIX"
            severity failure;
				
			start <= '0';
      end loop;
                                           
      report "================== ALL TESTS PASSED =============================";
                                                                              
      wait; --- we are done.  Wait for ever
    end process;
end behavioural;