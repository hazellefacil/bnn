library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity part of the description.  Describes inputs and outputs

entity reLU is
	generic(
		n : integer := 1; -- could be 128 or 256
		numLen : integer := 10
		);
	port(
		CLOCK_50 : in std_logic;
		Bn_x : in std_logic_vector(n*numLen - 1 downto 0);
		rst : in std_logic;
		Bn_done : in std_logic;
		relu_x : out std_logic_vector(n*numLen - 1 downto 0);
		relu_done : out std_logic
		);
end reLU;

-- Architecture part of the description

architecture behavioural of reLU is

	type state_type is (s_reset, s_clear, s_wait, s_reLU, s_done);

begin

	process(CLOCK_50, rst)
	
		variable state : state_type := s_reset;
		variable count : integer := 0;
		variable Bn_count : std_logic_vector(numLen-1 downto 0);
	
	begin
		
		if rst = '1' then
			state := s_reset;
		elsif rising_edge(CLOCK_50) then
			case state is
				when s_reset =>
				
					count := 0;
					state := s_clear;
					
					relu_done <= '0';
					
				when s_clear =>
				
					relu_x( (count+1)*numLen-1 downto count*numLen ) <= (others => '0');
					
					count := count + 1;
					if count = n then
						state := s_wait;
					else
						state := s_clear;
					end if;
					
					relu_done <= '0';
					
				when s_wait => 
					
					if Bn_done = '1' then
						state := s_reLU;
					else
						state := s_wait;
					end if;
					
					count := 0;
					
					relu_done <= '0';
				
				when s_reLU =>
				
					Bn_count := Bn_x( (count+1)*numLen-1 downto count*numLen );
					
					if Bn_count(numLen-1) = '1' then
						Bn_count := (others => '0');
					end if;
					
					relu_x( (count+1)*numLen-1 downto count*numLen ) <= Bn_count;
					
					count := count + 1;
					if count = n then
						state := s_done;
					else
						state := s_reLU;
					end if;
					
					relu_done <= '0';
					
				when s_done =>
				
					relu_done <= '1';
					state := s_done;
				
				when others =>
				
					state := s_reset;
					
			end case;
		end if;
	
	end process;
	
end behavioural;