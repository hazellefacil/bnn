LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY popcnt IS
	GENERIC(numLen	: NATURAL := 10;
		sumLen	: NATURAL := 4); 
	PORT(INPUT 	: IN  STD_LOGIC_VECTOR(numLen-1 downto 0);
		SUM	: OUT UNSIGNED(sumLen-1 downto 0) := (OTHERS => '0');
		DONE	: OUT STD_LOGIC := '0'); 
END popcnt;

ARCHITECTURE RTL OF popcnt IS	 
	
BEGIN	

	PROCESS(INPUT) 
		VARIABLE tempSUM	:	UNSIGNED(sumLen-1 downto 0) := (OTHERS => '0');
		CONSTANT ZERO		:	UNSIGNED(sumLen-2 downto 0) := (OTHERS => '0');
		CONSTANT COUNT_MAX	:	INTEGER := numLen - 1;
	BEGIN 

		DONE <= '0';
		tempSUM := (OTHERS => '0');
		
		FOR COUNT IN 0 TO COUNT_MAX LOOP
			tempSUM := tempSUM + (ZERO & INPUT(COUNT)); 
		END LOOP;
			
		tempSUM := TO_UNSIGNED((2*TO_INTEGER(tempSUM)), sumLen) - numLen;
			
		SUM <= tempSUM;
		DONE <= '1';

	END PROCESS;

END RTL;