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
      vix : STD_LOGIC_VECTOR(N-1 downto 0);
		qwx : STD_LOGIC_VECTOR(N-1 downto 0);
      expected_vox : INTEGER;
   END RECORD;

   TYPE test_case_array_type IS ARRAY (0 to 5) OF test_case_record;
   SIGNAL zero : STD_LOGIC_VECTOR(N-11 downto 0) := (OTHERS => '0');
   SIGNAL input1 : STD_LOGIC_VECTOR(N-1 downto 0) := "1010100000" & zero;
   SIGNAL input2 : STD_LOGIC_VECTOR(N-1 downto 0) := "0001000000" & zero;
   SIGNAL input3 : STD_LOGIC_VECTOR(N-1 downto 0) := "1100100110" & zero;
   SIGNAL v1 : STD_LOGIC_VECTOR(N-1 downto 0) := "0010100000" & zero;
   SIGNAL v2 : STD_LOGIC_VECTOR(N-1 downto 0) := "1101000000" & zero;
   SIGNAL v3 : STD_LOGIC_VECTOR(N-1 downto 0) := "0100101100" & zero;
    
   signal test_case_array : test_case_array_type := (
        ((OTHERS => '0'), (OTHERS => '0'), 128), -- change these
	((OTHERS => '0'), (OTHERS => '1'), -128),
	((OTHERS => '1'), (OTHERS => '1'), 128),
	(input1, v1, 126),
	(input2, v2, 124),
	(input3, v3, 122)
   ); 

	COMPONENT bmxbv_128_10 IS
		GENERIC(N 	: NATURAL := 128;
				  M	: NATURAL := 10); 
		PORT(CLOCK_50 : IN  STD_LOGIC;
			START	: IN	STD_LOGIC;
			vix 		: IN  STD_LOGIC_VECTOR(N-1 downto 0);
			qwx		: IN	STD_LOGIC_VECTOR(N-1 downto 0);
			vox		: OUT	INTEGER := 0;
			DONE		: OUT STD_LOGIC := '0');  
	END COMPONENT;
  
	SIGNAL START, DONE, CLOCK_50 : STD_LOGIC := '0';
	SIGNAL vix, qwx	:	STD_LOGIC_VECTOR(N-1 downto 0) := (OTHERS => '0');
	SIGNAL vox	:	INTEGER	:= 0;
	
BEGIN

   dut : bmxbv_128_10 PORT MAP(START => START, CLOCK_50 => CLOCK_50, vix => vix, qwx => qwx, vox => vox, DONE => DONE); 
 
   PROCESS
	BEGIN   
      
      FOR i IN test_case_array'LOW TO test_case_array'HIGH LOOP
        
        REPORT "-------------------------------------------";
        REPORT "Test case " & integer'image(i) & ":" & " vix = " & integer'image(to_integer(UNSIGNED(test_case_array(i).vix))) & " qwx = " & integer'image(to_integer(UNSIGNED(test_case_array(i).qwx)));
        
        vix <= test_case_array(i).vix;  
	qwx <= test_case_array(i).qwx;
	START <= '1';	
	WAIT FOR 3 ns;
	START <= '0';  
        WAIT UNTIL (DONE = '1');
	
              
        REPORT "Expected result: vox = " & integer'image(test_case_array(i).expected_vox);
        REPORT "Observed result: vox = " & integer'image(vox);
                                                                    
        ASSERT (vox = test_case_array(i).expected_vox)
            REPORT "MISMATCH.  THERE IS A PROBLEM IN YOUR DESIGN THAT YOU NEED TO FIX"
            SEVERITY warning;	
      END LOOP;
                                           
      REPORT "================== DONE TESTS =============================";
                                                                              
      WAIT; --- we are done.  Wait for ever
    END PROCESS;

clock : PROCESS IS
BEGIN
	CLOCK_50 <= '0';
	WAIT FOR 1 ns;
	CLOCK_50 <= '1';
	WAIT FOR 1 ns;
END PROCESS;
	
END test;