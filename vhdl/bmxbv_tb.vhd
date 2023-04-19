LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use ieee.std_logic_textio.all;

LIBRARY WORK;
USE WORK.ALL;

ENTITY bmxbv_tb IS
		GENERIC(N 	: NATURAL := 128;
			M	: NATURAL := 10);
END bmxbv_tb;

ARCHITECTURE test OF bmxbv_tb IS	

   TYPE test_case_record IS RECORD
      vix : STD_LOGIC_VECTOR(N-1 downto 0);
      expected_vox : STD_LOGIC_VECTOR((10*M) -1 downto 0);
   END RECORD;

   TYPE test_case_array_type IS ARRAY (0 to 4) OF test_case_record;
   SIGNAL zero : STD_LOGIC_VECTOR(N-11 downto 0) := (OTHERS => '0');
   SIGNAL v1 : STD_LOGIC_VECTOR(N-1 downto 0) := "0010100000" & zero;
   SIGNAL v2 : STD_LOGIC_VECTOR(N-1 downto 0) := "1101000000" & zero;
   SIGNAL o1 : STD_LOGIC_VECTOR((10*M) -1 downto 0) := "0010000000001000000000100000000010000000001000000000100000000010000000001000000000100000000010000000";
   SIGNAL o2 : STD_LOGIC_VECTOR((10*M) -1 downto 0) := "1110000000111000000011100000001110000000111000000011100000001110000000111000000011100000001110000000";
   SIGNAL o3 : STD_LOGIC_VECTOR((10*M) -1 downto 0) := "0001111110000111111000011111100001111110000111111000011111100001111110000111111000011111100001111110";
   SIGNAL o4 : STD_LOGIC_VECTOR((10*M) -1 downto 0) := "0001111100000111110000011111000001111100000111110000011111000001111100000111110000011111000001111100";

   signal test_case_array : test_case_array_type := (
        ((OTHERS => '0'), o1), --128
	((OTHERS => '0'), o1), -- 128
	((OTHERS => '1'), o2), ---128
	(v1, o3), --126
	(v2, o4) -- 124
   ); 

	COMPONENT bmxbv_128_10 IS
		GENERIC(N 	: NATURAL := 128;
				  M	: NATURAL := 10); 
		PORT(CLOCK_50 : IN  STD_LOGIC;
			START	: IN	STD_LOGIC;
			vix 		: IN  STD_LOGIC_VECTOR(N-1 downto 0);
			vox		: OUT	STD_LOGIC_VECTOR((10*M) -1 downto 0) := (OTHERS => '0');
			DONE		: OUT STD_LOGIC := '0');  
	END COMPONENT;
  
	SIGNAL START, DONE, CLOCK_50 : STD_LOGIC := '0';
	SIGNAL vix	:	STD_LOGIC_VECTOR(N-1 downto 0) := (OTHERS => '0');
	SIGNAL vox	:	STD_LOGIC_VECTOR((10*M) -1 downto 0) := (OTHERS => '0');
	
BEGIN

   dut : bmxbv_128_10 PORT MAP(START => START, CLOCK_50 => CLOCK_50, vix => vix, vox => vox, DONE => DONE); 
 
   PROCESS
	BEGIN   
      
      FOR i IN test_case_array'LOW TO test_case_array'HIGH LOOP
        
        REPORT "-------------------------------------------";
        REPORT "Test case " & integer'image(i) & ":" & " vix = " & integer'image(to_integer(UNSIGNED(test_case_array(i).vix)));
        
        vix <= test_case_array(i).vix;  
		  START <= '1';	
		  WAIT FOR 1 ns;
		  START <= '0';  
        WAIT UNTIL (DONE = '1');
	
              
        REPORT "Expected result: vox = " & integer'image(TO_INTEGER(UNSIGNED(test_case_array(i).expected_vox)));
        REPORT "Observed result: vox = " & integer'image(TO_INTEGER(UNSIGNED(vox)));
                                                                    
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