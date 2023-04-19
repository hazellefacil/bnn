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

ENTITY fullprecision_tb IS
  -- no inputs or outputs
END fullprecision_tb;

-- The architecture part decribes the behaviour of the test bench

ARCHITECTURE behavioural OF fullprecision_tb IS

   -- We will use an array of records to hold a list of test vectors and expected outputs.
   -- This simplifies adding more tests; we just have to add another line in the array.
   -- Each element of the array is a record that corresponds to one test vector.
   
   -- Define the record that describes one test vector
   
   TYPE test_case_record IS RECORD
				ld_temp, q_w1, ld_mat, rst_temp: std_logic;
				q_im: unsigned(7 downto 0);
				expected_done: std_logic;
				expected_v_o: std_logic_vector(9 downto 0); -- 784 10 bit unsigned numbers
   END RECORD;

   -- Define a type that is an array of the record.

   TYPE test_case_array_type IS ARRAY (0 to 9) OF test_case_record;
     
   -- Define the array itself.  We will initialize it, one line per test vector.
   -- If we want to add more tests, or change the tests, we can do it here.
   -- Note that each line of the array is one record, and the 7 numbers in each
   -- line correspond to the 7 entries in the record.  Four of these entries 
   -- represent inputs to apply, and three represent the expected outputs.
    
   signal test_case_array : test_case_array_type := (
             ('0','1','1','0',"10110011",'0',"0000000000"),
				 ('1','1','0','0',"00000000",'0',"0000000000"),
				 ('0','1','1','0',"01111111",'0',"0010110011"),
				 ('0','1','0','0',"00000000",'0',"0000000000"),
				 ('0','1','1','0',"00011000",'0',"0000000000"),
				 ('1','1','0','0',"00000000",'0',"0000000000"),
				 ('0','1','0','0',"00000000",'0',"0010010111"),
				 ('0','1','1','0',"01110110",'0',"0000000000"),
				 ('1','1','0','0',"00000000",'0',"0000000000"),
				 ('0','1','0','0',"00000000",'0',"0001110110")
             );

  -- Define the win subblock, which is the component we are testing

	COMPONENT fullprecision is
		port(
				CLOCK_50: in std_logic;
				ld_temp, q_w1, ld_mat, rst_temp: in std_logic; 
				q_im: in unsigned(7 downto 0);
				done: out std_logic;
				v_o: out std_logic_vector(7839 downto 0) -- 784 10 bit unsigned numbers
			);
	end COMPONENT;

   -- local signals we will use in the testbench 

	signal CLOCK_50: std_logic;
	signal ld_temp, q_w1, ld_mat, rst_temp: std_logic;
	signal q_im: unsigned(7 downto 0);
	signal done: std_logic;
	signal v_o: std_logic_vector(7839 downto 0);
	signal isEqual : integer := 1;
	
	-- function for displaying std_logic_vectors
	function to_hstring(slv: std_logic_vector) return string is
		 constant hexlen : integer := (slv'length+3)/4;
		 variable longslv : std_logic_vector(slv'length+3 downto 0) := (others => '0');
		 variable hex : string(1 to hexlen);
		 variable fourbit : std_logic_vector(3 downto 0);
	begin
		 longslv(slv'length-1 downto 0) := slv;
		 for i in hexlen-1 downto 0 loop
			  fourbit := longslv(i*4+3 downto i*4);
			  case fourbit is
					when "0000" => hex(hexlen-i) := '0';
					when "0001" => hex(hexlen-i) := '1';
					when "0010" => hex(hexlen-i) := '2';
					when "0011" => hex(hexlen-i) := '3';
					when "0100" => hex(hexlen-i) := '4';
					when "0101" => hex(hexlen-i) := '5';
					when "0110" => hex(hexlen-i) := '6';
					when "0111" => hex(hexlen-i) := '7';
					when "1000" => hex(hexlen-i) := '8';
					when "1001" => hex(hexlen-i) := '9';
					when "1010" => hex(hexlen-i) := 'A';
					when "1011" => hex(hexlen-i) := 'B';
					when "1100" => hex(hexlen-i) := 'C';
					when "1101" => hex(hexlen-i) := 'D';
					when "1110" => hex(hexlen-i) := 'E';
					when "1111" => hex(hexlen-i) := 'F';
					when "ZZZZ" => hex(hexlen-i) := 'Z';
					when "UUUU" => hex(hexlen-i) := 'U';
					when "XXXX" => hex(hexlen-i) := 'X';
					when others => hex(hexlen-i) := '?';
			  end case;
		 end loop;
		 return hex;
	end function to_hstring;

begin

   -- instantiate the design-under-test


   dut : fullprecision
	PORT MAP(
		CLOCK_50 => CLOCK_50, 
		ld_temp => ld_temp, 
		q_w1 => q_w1, 
		ld_mat => ld_mat,
		rst_temp => rst_temp, 
		q_im => q_im, 
		done => done, 
		v_o => v_o);

   -- Code to drive inputs and check outputs.  This is written by one process.
   -- Note there is nothing in the sensitivity list here; this means the process is
   -- executed at time 0.  It would also be restarted immediately after the process
   -- finishes, however, in this case, the process will never finish (because there is
   -- a wait statement at the end of the process).

   process
   begin   
       
      -- starting values for simulation.  Not really necessary, since we initialize
      -- them above anyway
		
		q_im <= (others => '0');
		rst_temp <= '0';
		ld_mat <= '0';
		q_w1 <= '0';
		ld_temp <= '0';
		

      -- Loop through each element in our test case array.  Each element represents
      -- one test case (along with expected outputs).
      
      for i in test_case_array'low to test_case_array'high loop
        
        -- Print information about the testcase to the transcript window (make sure when
        -- you run this, your transcript window is large enough to see what is happening)
        
        report "-------------------------------------------";
        report LF & "Test case " & integer'image(i) & ":" &
					LF & " q_im=" & to_hstring(std_logic_vector(test_case_array(i).q_im));

        -- assign the values to the inputs of the DUT (design under test)
        
			q_im <= test_case_array(i).q_im;
			rst_temp <= test_case_array(i).rst_temp;
			ld_mat <= test_case_array(i).ld_mat;
			q_w1 <= test_case_array(i).q_w1;
			ld_temp <= test_case_array(i).ld_temp;
			
        -- wait for some time, to give the DUT circuit time to respond (1ns is arbitrary)                

        wait for 5 ns;
        
        -- now print the results along with the expected results
		  
       -- report LF & "Expected result: v_o=" & to_hstring(test_case_array(i).expected_v_o) & LF & "Observed result: v_o=" & to_hstring(v_o(7839 downto 7830));

        -- This assert statement causes a fatal error if there is a mismatch
        
		  if i < 3 then
				if (unsigned(v_o(7839 downto 7830)) = unsigned(test_case_array(i).expected_v_o)) then
					isEqual <= 1;
				else 
					isEqual <= 0;
				end if;
				
			  report LF & "Expected result: v_o=" & to_hstring(test_case_array(i).expected_v_o) & LF & "Observed result: v_o=" & to_hstring(v_o(7839 downto 7830));

		  elsif i < 7 then
				if (unsigned(v_o(7829 downto 7820)) = unsigned(test_case_array(i).expected_v_o)) then
					isEqual <= 1;
				else 
					isEqual <= 0;
				end if;
				
			 report LF & "Expected result: v_o=" & to_hstring(test_case_array(i).expected_v_o) & LF & "Observed result: v_o=" & to_hstring(v_o(7829 downto 7820));
			
		  else
				if (unsigned(v_o(7819 downto 7810)) = unsigned(test_case_array(i).expected_v_o)) then
					isEqual <= 1;
				else 
					isEqual <= 0;
				end if;
				
			 report LF & "Expected result: v_o=" & to_hstring(test_case_array(i).expected_v_o) & LF & "Observed result: v_o=" & to_hstring(v_o(7819 downto 7810));

		  end if;
		  
			  assert (isEqual = 1)
            report "MISMATCH.  THERE IS A PROBLEM IN YOUR DESIGN THAT YOU NEED TO FIX"
            severity failure;	


			wait for 5 ns;
      end loop;
                                           
      report "================== ALL TESTS PASSED =============================";
                                                                              
      wait; --- we are done.  Wait for ever
    end process;
	 
	clock: PROCESS IS
		BEGIN
		CLOCK_50 <= '0'; 
		WAIT FOR 1 ns; 
		CLOCK_50 <= '1';
		WAIT FOR 1 ns;
		
	END PROCESS; 
	 
end behavioural;