library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity part of the description.  Describes inputs and outputs

entity Bn is
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
end Bn;

-- Architecture part of the description

architecture behavioural of Bn is

	type state_type is (s_reset, s_wait, s_Bn, s_done);
	signal state_o : state_type;
	
begin

	process(CLOCK_50, rst)
	
		variable state : state_type := s_reset;
		variable count, temp, gamma_int, beta_int : integer := 0;
	
	begin
	
		if rst = '1' then
		
			state := s_reset;
			count := 0;
			Bn <= (others => '0');
		
		elsif rising_edge(CLOCK_50) then
		
			case state is
			
				when s_reset =>
				
					count := 0;
					state := s_wait;
					Bn_done <= '0';
				
				when s_wait =>
				
					if start = '1' then
						state := s_Bn;
					else
						state := s_wait;
					end if;
					Bn_done <= '0';
					
				when s_Bn =>
				
					if g = '1' and b = '1' then -- gamma and beta are valid inputs
					
						temp := to_integer(unsigned(x_norm( (count+1)*numLen-2 downto count*numLen )));
						gamma_int := to_integer(unsigned(gamma(numLen - 2 downto 0)));
						beta_int := to_integer(unsigned(beta(numLen - 2 downto 0)));
						if x_norm( (count+1)*numLen-1 ) = '1' then
							temp := -temp;
						end if;
						if gamma(numLen - 1) = '1' then
							gamma_int := -gamma_int;
						end if;
						if beta(numLen - 1) = '1' then
							beta_int := -beta_int;
						end if;
						
						temp := gamma_int*temp + beta_int;
						if temp < 0 then
							temp := -temp;
							Bn( (count+1)*numLen-1 downto count*numLen ) <= '1' & std_logic_vector(to_unsigned(temp, numLen - 1));
						else
							Bn( (count+1)*numLen-1 downto count*numLen ) <= '0' & std_logic_vector(to_unsigned(temp, numLen - 1));
						end if;
						
						count := count + 1;
						
						if count = n then
							state := s_done;
						else
							state := s_Bn;
						end if;
						
					else
						state := s_Bn;
					end if;
					Bn_done <= '0';
				
				when s_done =>
				
					Bn_done <= '1';
					state := s_done;
				
				when others =>
					
					state := s_reset;
			
			end case;
		
		state_o <= state;
		
		end if;
	
	end process;
	
end behavioural;