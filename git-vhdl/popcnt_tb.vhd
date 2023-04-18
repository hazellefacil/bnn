LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use ieee.std_logic_textio.all;

LIBRARY WORK;
USE WORK.ALL;

ENTITY popcnt_tb IS
		GENERIC(N	: NATURAL := 128);
END popcnt_tb;

ARCHITECTURE test OF popcnt_tb IS	

	TYPE test_case_record IS RECORD
      INPUT : STD_LOGIC_VECTOR(N-1 downto 0);
      expected_SUM : INTEGER;
   END RECORD;

   TYPE test_case_array_type IS ARRAY (0 to 4) OF test_case_record;
	SIGNAL zero : STD_LOGIC_VECTOR(117 downto 0) := (OTHERS => '0');
	SIGNAL input1 : STD_LOGIC_VECTOR(N-1 downto 0) := "1010100000" & zero;
	SIGNAL input2 : STD_LOGIC_VECTOR(N-1 downto 0) := "0001000000" & zero;
	SIGNAL input3 : STD_LOGIC_VECTOR(N-1 downto 0) := "1100100110" & zero;
    
   signal test_case_array : test_case_array_type := (
      ((OTHERS => '0'), -128),
		((OTHERS => '1'), 128),
		(input1, -122),
		(input2, -126),
		(input3, -118)
    ); 

	COMPONENT popcnt_128 IS
		GENERIC(N	: NATURAL := 128); 
		PORT(INPUT 	: IN  STD_LOGIC_VECTOR(N-1 downto 0);
			SUM		: OUT INTEGER := 0;
			DONE		: OUT STD_LOGIC := '0'); 
	END COMPONENT;
  
	SIGNAL DONE : STD_LOGIC := '0';
	SIGNAL INPUT : STD_LOGIC_VECTOR(N-1 downto 0) := (OTHERS => '0');
	SIGNAL SUM : INTEGER := 0;
	
BEGIN

   dut : popcnt_128 PORT MAP(INPUT => INPUT, SUM => SUM, DONE => DONE); 
 
   PROCESS
	BEGIN   
	
      
      FOR i IN test_case_array'LOW TO test_case_array'HIGH LOOP
        
        REPORT "-------------------------------------------";
        REPORT "Test case " & integer'image(i) & ":" & " INPUT = " & integer'image(to_integer(UNSIGNED(test_case_array(i).INPUT)));
        
        INPUT <= test_case_array(i).INPUT;                
        WAIT FOR 1 ns;
              
        REPORT "Expected result: SUM = " & integer'image(test_case_array(i).expected_SUM);
        REPORT "Observed result: SUM = " & integer'image(SUM);
                                                                    
        ASSERT (SUM = test_case_array(i).expected_SUM)
            REPORT "MISMATCH.  THERE IS A PROBLEM IN YOUR DESIGN THAT YOU NEED TO FIX"
            SEVERITY warning;

      END LOOP;
                                           
      REPORT "================== DONE TESTS =============================";
                                                                              
      WAIT; --- we are done.  Wait for ever
    END PROCESS;
	
END test;