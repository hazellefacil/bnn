library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- Entity part of the description.  Describes inputs and outputs

entity mean is
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
end mean;

-- Architecture part of the description

architecture behavioural of mean is

	type state_type is (s_reset, s_wait, s_add, s_divide, s_done);
	
	signal state_o : state_type;
	signal count_o, vob_count_o, temp_o, log2_n_o : integer;
	signal temp2_o : std_logic_vector((2*numLen)-1 downto 0);

begin

	process(CLOCK_50, rst)
		
		variable state : state_type := s_reset;
		variable count : integer := 0;
		variable vob_count : integer := 0;
		variable temp : integer := 0;
		variable temp2 : std_logic_vector((2*numLen)-1 downto 0);
		variable log2_n : integer;
		
	begin
	
		log2_n := integer(floor(log2(real(n))));
		
		state_o <= state;
		count_o <= count;
		vob_count_o <= vob_count;
		temp_o <= temp;
		log2_n_o <= log2_n;
		temp2_o <= temp2;
		
		if rst = '1' then
			state := s_reset;
		elsif rising_edge(CLOCK_50) then
			case state is
				when s_reset =>
					
					mean <= (others => '0');
					-- temp := (others => '0');		
					temp := 0;
					count := 0;
					
					mean_done <= '0';
					state := s_wait;
					
				when s_wait => 
					
					if start = '1' then
						state := s_add;
					else
						state := s_wait;
					end if;
					
					mean_done <= '0';
				
				when s_add =>
				
					-- vob_count := vob( (count+1)*numLen-2 downto count*numLen );
					vob_count := to_integer(unsigned(vob( (count+1)*numLen-2 downto count*numLen )));
					
					if vob((count+1)*numLen-1) = '1' then
						temp := temp - vob_count;
					else
						temp := temp + vob_count;
					end if;
					
					count := count + 1;
					if count = n then
						state := s_divide;
					else
						state := s_add;
					end if;
					
					mean_done <= '0';
					
				when s_divide =>
					
					if temp < 0 then
						temp := -temp;
						temp2 := std_logic_vector(to_unsigned(temp, temp2'length));
						mean <= '1' & std_logic_vector(to_unsigned(to_integer(shift_right(unsigned(temp2), log2_n + 1)), mean'length - 1));
					else
						temp2 := std_logic_vector(to_unsigned(temp, temp2'length));
						mean <= '0' & std_logic_vector(to_unsigned(to_integer(shift_right(unsigned(temp2), log2_n + 1)), mean'length - 1));
					end if;
					
					state := s_done;
					
				when s_done =>
				
					mean_done <= '1';
					state := s_done;
				
				when others =>
				
					state := s_reset;
					
			end case;
		end if;
	
	end process;
	
end behavioural;