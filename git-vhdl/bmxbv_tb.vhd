LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use ieee.std_logic_textio.all;

LIBRARY WORK;
USE WORK.ALL;

ENTITY bmxbv_tb IS
		GENERIC(N 	: NATURAL := 128;
				  numLen	: NATURAL := 10);
END bmxbv_tb;

ARCHITECTURE test OF bmxbv_tb IS	

	TYPE test_case_record IS RECORD
      vix : STD_LOGIC_VECTOR((N*numLen)-1 downto 0);
		qwx : STD_LOGIC_VECTOR((N*numLen)-1 downto 0);
      expected_vox : INTEGER;
   END RECORD;

   TYPE test_case_array_type IS ARRAY (0 to 2) OF test_case_record;
    
   signal test_case_array : test_case_array_type := (
             ((OTHERS => '0'), (OTHERS => '0'), 0), -- change these
				 ((OTHERS => '1'), (OTHERS => '1'), 128),
				 (("10101" & (OTHERS => '0')), "001101" & (OTHERS => '0'), -4)
             ); 

	COMPONENT bmxbv_128 IS
		GENERIC(N 	: NATURAL := 128;
				  numLen	: NATURAL := 10); 
		PORT(START	: IN	STD_LOGIC;
			CLOCK_50 : IN  STD_LOGIC;
			vix 		: IN  STD_LOGIC_VECTOR((N*numLen)-1 downto 0);
			qwx		: IN	STD_LOGIC_VECTOR((N*numLen)-1 downto 0);
			vox		: OUT	STD_LOGIC_VECTOR((N*numLen)-1 downto 0) := (OTHERS => '0');
			DONE		: OUT STD_LOGIC := '0');  
	END COMPONENT;
  
	SIGNAL START, DONE, CLOCK_50 : STD_LOGIC := '0';
	SIGNAL vix, qwx	:	STD_LOGIC_VECTOR((N*numLen)-1 downto 0) := (OTHERS => '0');
	SIGNAL vox	:	STD_LOGIC_VECTOR((N*numLen)-1 downto 0)	:= (OTHERS => '0');
	
BEGIN

   dut : bmxbv_128 PORT MAP(START => START, CLOCK_50 => CLOCK_50, vix => vix, qwx => qwx, vox => vox, DONE => DONE); 
 
   PROCESS
	BEGIN   
      
      FOR i IN test_case_array'LOW TO test_case_array'HIGH LOOP
        
        REPORT "-------------------------------------------";
        REPORT "Test case " & integer'image(i) & ":" & " vix = " & integer'image(to_integer(UNSIGNED(test_case_array(i).vix))) & " qwx = " & integer'image(to_integer(UNSIGNED(test_case_array(i).qwx)));
        
        vix <= test_case_array(i).vix;  
		  qwx <= test_case_array(i).qwx; 		  
        WAIT FOR 1 ns;
              
        REPORT "Expected result: SUM = " & integer'image(test_case_array(i).expected_vox);
        REPORT "Observed result: SUM = " & integer'image(TO_INTEGER(UNSIGNED(vox)));
                                                                    
        ASSERT (TO_INTEGER(UNSIGNED(vox)) = test_case_array(i).expected_vox)
            REPORT "MISMATCH.  THERE IS A PROBLEM IN YOUR DESIGN THAT YOU NEED TO FIX"
            SEVERITY warning;
      END LOOP;
                                           
      REPORT "================== DONE TESTS =============================";
                                                                              
      WAIT; --- we are done.  Wait for ever
    END PROCESS;
	
END test;