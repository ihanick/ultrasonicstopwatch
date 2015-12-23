library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity stopwatch is
	port (
		clk10hz : in std_logic;
		paused  : in std_logic;
		clr	  : in std_logic;
		d       : out std_logic_vector(15 downto 0)		
	);
end stopwatch;


architecture stopwatch_impl of stopwatch is
signal dseconds: std_logic_vector(3 downto 0);
signal seconds_0: std_logic_vector(3 downto 0);
signal seconds_1: std_logic_vector(3 downto 0);
signal minutes_0: std_logic_vector(3 downto 0);
begin

	d(3 downto 0) <= dseconds;
	d(7 downto 4) <= seconds_0;
	d(11 downto 8) <= seconds_1;
	d(15 downto 12) <= minutes_0;
	
	process(clk10hz) is
	begin
		if (rising_edge(clk10hz)) then

			if (clr = '1') then
				dseconds <= "0000";
				seconds_0 <= "0000";
				seconds_1 <= "0000";
				minutes_0 <= "0000";
			end if;

			if (paused = '0') then					
				dseconds <= dseconds + "1";
				if (dseconds >= std_logic_vector(to_unsigned(9, dseconds'length)) ) then
					dseconds <= "0000";
					seconds_0 <= seconds_0 + "1";
					if (seconds_0 >= std_logic_vector(to_unsigned(9, seconds_0'length)) ) then
						seconds_0 <= "0000";
						seconds_1 <= seconds_1 + "1";
						if (seconds_1 >= std_logic_vector(to_unsigned(5, seconds_1'length))) then
							seconds_1 <= "0000";
							minutes_0 <= minutes_0 + "1";
							if (minutes_0 >= std_logic_vector(to_unsigned(9, minutes_0'length)) ) then
								minutes_0 <= "0000";
							end if;
						end if;
					end if;
				end if;
			end if;
		end if;	
	end process;
end;