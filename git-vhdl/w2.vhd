LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;


ENTITY w2 IS 
	GENERIC(i 	: NATURAL := 128;
			  j 	: NATURAL := 256);
	PORT(address			: IN	INTEGER;  
		 vector		: OUT STD_LOGIC_VECTOR(j-1 downto 0) := (OTHERS => '0')
		 );
END w2;


ARCHITECTURE RTL OF w2 IS 

	TYPE matrix_grid IS ARRAY (0 to i-1) of STD_LOGIC_VECTOR(j-1 downto 0);
	SIGNAL matrix : matrix_grid;
	
BEGIN

	-- set matrix
	--matrix(0) <= "";
	--matrix(1) <= "";
	--matrix(2) <= "";
	--matrix(3) <= "";
	--matrix(4) <= "";
	--matrix(5) <= "";
	--matrix(6) <= "";
	--matrix(7) <= "";
	--matrix(8) <= "";
	--matrix(9) <= "";

	PROCESS(address)
	BEGIN
	
		vector <= matrix(address);
	
	END PROCESS;

END RTL;