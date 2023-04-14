library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bnn is
  port(CLOCK_50            : in  std_logic;
		 KEY                 : in  std_logic_vector(3 downto 0);
		 SW                  : in  std_logic_vector(17 downto 0);
		 LEDG 					: out std_logic_vector(7 downto 0)
		 );
end bnn;

architecture behavioural of bnn is 

	component fullprecision
	port(
	clk: 										in std_logic;
	ld_temp, q_w1, ld_mat, rst_temp: in std_logic;
	q_im: 									in unsigned(7 downto 0);
	done: 									out std_logic;
	v_o: 										out std_logic_vector(7840 downto 0) -- 784 10 bit unsigned numbers
	);
	end component;

	component addresscalculator
	port(
		clk: 									in std_logic;
		inc_i, rst: 						in std_logic;
		addressv_o, address_im: 		out std_logic_vector(9 downto 0);
		address_w1 : 						out std_logic_vector(17 downto 0); -- max is 18 bits long (784*255+783)
		done, rst_temp: 					out std_logic
		);
	end component;

	signal ld_temp_fp, q_w1_fp, ld_mat_fp, rst_temp_fp: std_logic;
	signal q_im_fp : unsigned(7 downto 0);
	signal done_fp: std_logic;
	signal v_o_fp: std_logic_vector(7840 downto 0);
	
	signal inc_i_ac, rst_ac, done_ac, rst_temp_ac: std_logic;
	signal addressv_o_ac, address_im_ac: std_logic_vector(9 downto 0);
	signal address_w1 : std_logic_vector(17 downto 0);
	
	begin
	
	fp : fullprecision 
	port map(CLOCK_50, ld_temp_fp, q_w1_fp, ld_mat_fp, rst_temp_fp, q_im_fp, done_fp, v_o_fp);
	
	ac : addresscalculator
	port map(CLOCK_50, inc_i_ac, rst_ac, addressv_o_ac, address_im_ac, address_w1, done_ac, rst_temp_ac);
	
end behavioural;