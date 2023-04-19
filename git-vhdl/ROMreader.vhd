library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- Entity part of the description.  Describes inputs and outputs

entity ROMreader is -- visualize first for weight matrix reading
	generic(
		n : integer := 256; -- could be 128 or 256
		data_size : integer := 8;
		address_size : integer := 8
		);
	port(
		CLOCK_50 : in std_logic;
		nex : in std_logic;
		rst : in std_logic;
		q_in : in std_logic_vector(data_size - 1 downto 0);
		q_out : out std_logic_vector(data_size - 1 downto 0);
		ready : out std_logic;
		address : out std_logic_vector(address_size - 1 downto 0)
		);
end ROMreader;

-- Architecture part of the description

architecture behavioural of ROMreader is

	type state_type is (s_reset, s_wait, s_buff1, s_buff2, s_ready, s_done);

begin

	q_out <= q_in;

	process(CLOCK_50, rst)
		
		variable state : state_type := s_reset;
		variable count : integer := 0;
		
	begin
	
		if rst = '1' then
		
			state := s_reset;
			count := 0;
		
		elsif rising_edge(CLOCK_50) then
		
			case state is
			
				when s_reset =>
					count := 0;
					state := s_wait;
					ready <= '0';
				
				when s_wait =>
					if nex = '1' then
						address <= std_logic_vector(to_unsigned(count, address'length));
					end if;
					ready <= '0';
					state := s_buff1;
				
				when s_buff1 =>
					state := s_buff2;
				
				when s_buff2 =>
					state := s_ready;
				
				when s_ready =>
					ready <= '1';
					count := count + 1;
					if count = n then
						state := s_done;
					else
						state := s_wait;
					end if;
				
				when s_done =>
					ready <= '0';
					state := s_done;
				
				when others =>
					state := s_reset;
			
			end case;
		
		end if;
	
	end process;
	
end behavioural;