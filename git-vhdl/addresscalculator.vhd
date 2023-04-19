library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity addresscalculator is
	port(
	CLOCK_50: in std_logic;
	inc_i, rst: in std_logic;
	addressv_o, address_im: out std_Logic_vector(9 downto 0);
	address_w1 : out std_logic_vector(17 downto 0); -- max is 18 bits long (784*255+783)
	done, rst_temp: out std_logic
	);
end addresscalculator;

architecture behavioural of addresscalculator is
	type state is (init, inci_only, rsti_incj, done_state);
	signal cur_state, next_state : state := init;
	signal rst_i,inc_j, rst_j: std_logic;
	signal  i, j: integer;
	
	begin
	rst_j <= rst;
	rst_temp <= rst_i;
	inc_j <= rst_i;
	address_im <= std_logic_vector(to_unsigned(i,10));
	addressv_o <= std_logic_vector(to_unsigned(i,10));
	address_w1 <= std_logic_vector(to_unsigned(j*784 + i,18));
	
	process(cur_state)
	begin
		if cur_state = init then
			i <= 0;
			j <= 0;
		elsif cur_state = inci_only then
			if inc_i = '1' then
				i <= i+1;
			end if;	
		elsif cur_state = rsti_incj then
			i<=0;
			j<=j+1;
		elsif cur_state = done_state then
			done <= '1';
		end if;
	
	end process;
	
	process(CLOCK_50, cur_state, next_state)
	begin
		if rising_edge(CLOCK_50) then
			if cur_state = init then
				if rst_i = '1' then
					next_state <= rsti_incj;
				else 
					next_state <= inci_only;
				end if;
			elsif cur_state = rsti_incj then
				if rst_i = '0' then
					next_state <= inci_only;
				end if;
				if j = 255 then
					next_state <= done_state;
				end if;
			elsif cur_state = inci_only then
				if rst = '1' then
					next_state <= rsti_incj;
				end if;
			else
				next_state <= done_state;
			end if;
		end if;
	
	end process;
	
	process(CLOCK_50, next_state, rst)
	begin
		if rising_edge(CLOCK_50) then
			cur_state <= next_state;
		end if;
		if rst = '1' then
			cur_state <= init;
		end if;
		if i = 783 or rst = '1' then 
			rst_i <= '1';
		else
			rst_i <= '0';
		end if;
	end process;
		
	
end behavioural;