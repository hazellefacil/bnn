library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fullprecision is
	port(
	CLOCK_50: in std_logic;
	ld_temp, q_w1, ld_mat, rst_temp: in std_logic;
	q_im: in unsigned(7 downto 0);
	done: out std_logic;
	v_o: out std_logic_vector(7840 downto 0) -- 784 10 bit unsigned numbers
	);
end fullprecision;

architecture behavioural of fullprecision is
	type state is (init, calculate, save_row, save_temp,done_state);
	signal cur_state,next_state : state := init;
	signal temp: unsigned(9 downto 0);
	signal curRow : integer := 0;
begin
	
	process(CLOCK_50,cur_state,next_state)
	begin
		if rising_edge(CLOCK_50) then
			if (cur_state = init) then
				next_state <= calculate;
			elsif (cur_state = calculate) then
				if (ld_temp = '1') then
					next_state <= save_row;
				elsif(ld_mat='1') then
					next_state <= save_temp;
				end if;
			elsif (cur_state = save_temp) then
				next_state <= calculate;
			elsif (cur_state = save_row) then
				if (curRow = 784) then
					next_state <=done_state;
				else
					next_state <= calculate;
				end if;
			elsif (cur_state =done_state) then
				next_state <=done_state;
			end if;
		end if;
	end process;

	process(CLOCK_50, cur_state)
	begin
		if rising_edge(CLOCK_50) then	
			if cur_state = init then
				curRow <= 0;
				done <= '0';
				temp <= "0000000000";
			elsif cur_state = calculate then
				if q_w1 = '0' then
					temp <= temp+q_im;
				else
					temp <= temp+q_im;
				end if;
			elsif cur_state = save_row then
				v_o(((curRow+1)*10-1) downto curRow*10) <= (7 downto temp'length => '0') & std_logic_vector(temp);
				curRow <= curRow + 1;
				temp <= "0000000000";
			elsif cur_state =done_state then
				done <= '1';
			end if;
		end if;
	end process;

	process(CLOCK_50, next_state,rst_temp)
	begin
		if rising_edge(CLOCK_50) then
			cur_state <= next_state;
		end if;
		if rst_temp = '1' then
			cur_state <= init;
		end if;
	end process;
					
		
end behavioural;