library ieee;

use ieee.std_logic_1164.all;

entity seg7multi is
	port
	(
		curnum : in std_logic_vector(1 downto 0);
		data   : in std_logic_vector(15 downto 0);
		segid  : out std_logic_vector(3 downto 0);
		seg : out std_logic_vector(7 downto 0)
	);
end seg7multi;
	
	
architecture seg7multi_impl of seg7multi is
signal is1 : std_logic;
signal is2 : std_logic;
signal is3 : std_logic;
signal is4 : std_logic;

signal dgt : std_logic_vector(3 downto 0);
signal seg_code : std_logic_vector(6 downto 0);

begin
	with curnum select dgt <=
		data(15 downto 12) when "00", -- minutes_0
		data(11 downto 8)  when "01",	-- seconds_1
		data(7  downto 4)  when "10",	-- seconds_0
		data(3  downto 0)  when others;  -- 0.1 seconds
		
	with curnum select segid <=
		"0001" when "00",
		"0010" when "01",
		"0100" when "10",
		"1000" when others;
		
	seg7_inst : entity work.seg7 port map (num => dgt, code => seg_code);
	
	seg(6 downto 0) <= not seg_code;
	seg(7) <= not ((not curnum(0) and not curnum(1) and data(4) ) ); -- LSB of seconds_0
end;