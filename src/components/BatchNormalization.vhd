library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity part of the description.  Describes inputs and outputs

entity BatchNormalization is
		generic(
			n 		 : integer := 256; -- could be 128 or 256
			numLen : integer := 10
			);
		port(
			CLOCK_50 : in std_logic;
			rst 		: in std_logic;
			start 	: in std_logic;
			vob 		: in std_logic_vector(n*numLen - 1 downto 0);
			epsilon  : in std_logic_vector(numLen - 1  downto 0);
			gamma 	: in std_logic_vector(numLen - 1  downto 0);
			g 			: in std_logic;
			beta 		: in std_logic_vector(numLen - 1 downto 0);
			b 			: in std_logic;
			Bn_out 	: out std_logic_vector(n*numLen - 1 downto 0);
			Bn_done 	: out std_logic
			 );
end BatchNormalization;

-- Architecture part of the description

architecture behavioural of BatchNormalization is

	type state_type is (s_reset, s_wait, s_Bn, s_done);
	
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
	
	signal mean1 : std_logic_vector(numLen - 1 downto 0) := (others => '0');
	signal mean_done : std_logic := '0';
	
	component prevariance is
		generic(
			n : integer := 0;
			numLen :integer := 10
			);
		port(
			CLOCK_50 : in STD_LOGIC;
			mean 	: in STD_LOGIC_VECTOR(numLen -1 DOWNTO 0);
			rst : in std_logic;
			start : in std_logic;
			VOB 		: in STD_LOGIC_VECTOR(n*numLen -1 DOWNTO 0);
			PV 		: out STD_LOGIC_VECTOR(n*numLen -1 DOWNTO 0);
			pv_done : out std_logic
			);
	end component;
	
	signal pv : STD_LOGIC_VECTOR(n*numLen -1 DOWNTO 0);
	signal pv_done : std_logic;
	
	component full_adder is
		generic(
			n : integer := 1;
			numLen : integer := 10
			);
		port(
			pv : in std_logic_vector(n*numLen - 1 downto 0);
			start : in std_logic;
			variance : out std_logic_vector(numLen - 1 downto 0)
			);
	end component;
	
	signal variance : std_logic_vector(numLen - 1 downto 0);
	
	component x_norm is
		generic(
			n : integer := 0;
			numLen :integer := 4
		);
		  port(
				CLOCK_50 : in std_logic; 
				v_done 	: in std_logic;
				rst		: in std_logic;
				q_e 		: in std_logic_vector(numLen - 1 downto 0); 
				mean 		: in std_logic_vector(numLen - 1 downto 0);
				variance : in std_logic_vector(numLen - 1 downto 0); 
				VOB 		: in std_logic_vector(n*numLen - 1 downto 0);
				x_norm_done : out std_logic; 
				x_norm 	: out std_logic_vector(n*numLen - 1 downto 0)
			);
	end component;
	
	signal q_e : std_logic_vector(numLen - 1 downto 0) := "000100";
	signal x_norm1 : std_logic_vector(n*numLen - 1 downto 0);
	signal x_norm_done : std_logic;
	
	component Bn is
		generic(
			n : integer := 256; -- could be 128 or 256
			numLen : integer := 10
			);
		port(
			CLOCK_50 : in std_logic;
			rst : in std_logic;
			start : in std_logic;
			x_norm : in std_logic_vector(n*numLen - 1 downto 0);
			gamma : in std_logic_vector(numLen - 1 downto 0);
			g : in std_logic;
			beta : in std_logic_vector(numLen - 1 downto 0);
			b : in std_logic;
			Bn : out std_logic_vector(n*numLen - 1 downto 0);
			Bn_done : out std_logic
			 );
	end component;
	

begin

	u0 : mean
	generic map(
		n => n, numLen => numLen)
	port map(
		CLOCK_50, vob, rst, start, mean1, mean_done);
		
	u1 : prevariance
	generic map(
		n => n, numLen => numLen)
	port map(
		CLOCK_50, mean1, rst, mean_done, vob, pv, pv_done);
		
	u2 : full_adder
	generic map(
		n => n, numLen => numLen)
	port map(
		pv, pv_done, variance);
		
	u3 : x_norm
	generic map(
		n => n, numLen => numLen)
	port map(
		CLOCK_50, pv_done,rst, q_e, mean1, variance, vob, x_norm_done, x_norm1);
	
	u4 : Bn
	generic map(
		n => n, numLen => numLen)
	port map(
		CLOCK_50 => CLOCK_50, rst=> rst, start => x_norm_done,x_norm => x_norm1, gamma =>gamma, g=>g, beta=> beta, b=>b,Bn => Bn_out,Bn_done => Bn_done);
	
end behavioural;