-- Copyright (C) 1991-2013 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;
library altera;
use altera.altera_syn_attributes.all;

library lpm;
use lpm.all;

entity blink_top is
	port
	(
-- {ALTERA_IO_BEGIN} DO NOT REMOVE THIS LINE!

		A : out std_logic;
		B : out std_logic;
		btn0 : in std_logic;
		btn1 : in std_logic;
		btn2 : in std_logic;
		btn3 : in std_logic;
		C : out std_logic;
		clk : in std_logic;
		CT1 : out std_logic;
		CT2 : out std_logic;
		CT3 : out std_logic;
		CT4 : out std_logic;
		D : out std_logic;
		DP : out std_logic;
		E : out std_logic;
		F : out std_logic;
		G : out std_logic;
		hcsr04trig : out std_logic;
		hcsr04echo : in std_logic
-- {ALTERA_IO_END} DO NOT REMOVE THIS LINE!

	);

-- {ALTERA_ATTRIBUTE_BEGIN} DO NOT REMOVE THIS LINE!
-- {ALTERA_ATTRIBUTE_END} DO NOT REMOVE THIS LINE!
end blink_top;

architecture ppl_type of blink_top is
signal cnt : std_logic_vector(22 downto 0);

signal stopwatch_cur : std_logic_vector(15 downto 0);
signal stopwatch_lap0: std_logic_vector(15 downto 0);
signal stopwatch_lap1: std_logic_vector(15 downto 0);
signal stopwatch_lap2: std_logic_vector(15 downto 0);

signal current_time: std_logic_vector(15 downto 0);
signal time_idx: std_logic_vector(1 downto 0);
signal lap_idx: std_logic_vector(1 downto 0);
signal soft_reset: std_logic;

signal paused : std_logic;
signal btn0_clean: std_logic;
signal btn1_clean: std_logic;
signal btn2_clean: std_logic;
signal btn3_clean: std_logic;
signal btn3_clean_prev: std_logic;
signal clk10hz: std_logic;
signal clk97khz: std_logic;

signal btn0_prev : std_logic;
signal btn1_prev : std_logic;
signal btn2_prev : std_logic;
signal btn3_prev : std_logic;

signal led7wires : std_logic_vector(7 downto 0);
signal segid : std_logic_vector(3 downto 0);

signal hcsr04trig_val: std_logic;
signal hcsr04echo_clean: std_logic;
signal hcsr04echo_prev: std_logic;


signal cnt12bit: std_logic_vector(11 downto 0);

signal distance : std_logic_vector(11 downto 0);
signal distance_last : std_logic_vector(15 downto 0);

-- {ALTERA_COMPONENTS_BEGIN} DO NOT REMOVE THIS LINE!
-- {ALTERA_COMPONENTS_END} DO NOT REMOVE THIS LINE!
begin
-- {ALTERA_INSTANTIATION_BEGIN} DO NOT REMOVE THIS LINE!
-- {ALTERA_INSTANTIATION_END} DO NOT REMOVE THIS LINE!

	globalcnt_inst : entity lpm.globalcnt PORT MAP (
			clock	 => clk,
			cout	 => clk10hz,
			q	 => cnt
		);
		
	clk97khz <= cnt(8);
	
	process(clk97khz) is begin
		if (rising_edge(clk97khz)) then
			cnt12bit <= cnt12bit + '1';
			
			if (cnt12bit = "000000000000") then
				hcsr04trig_val <= '1';
			else
				hcsr04trig_val <= '0';
			end if;
			
			if (hcsr04echo_prev = hcsr04echo) then
				hcsr04echo_clean <= hcsr04echo_prev;
			end if;
			hcsr04echo_prev <= hcsr04echo;
			
			if (hcsr04echo_clean = '1') then
				distance <= distance + '1';
			else
				if (not (distance = "000000000000")) then
					distance_last(11 downto 0) <= distance;
				end if;
				distance <= "000000000000";
			end if;
		end if;
	end process;
	
	distance_last(15 downto 12) <= "1111";
	
	hcsr04trig <= hcsr04trig_val;
		
	stopwatch_inst : entity work.stopwatch PORT MAP (
		clk10hz => clk10hz,
		paused  => paused,
		clr	  => btn1_clean or soft_reset,
		d       => stopwatch_cur
	);

	process(clk) is
	begin
		if ( rising_edge(btn0_clean) ) then
			paused <= not paused;
		end if;		
		if ( rising_edge(btn2_clean) ) then
			time_idx <= time_idx + "1";
		end if;
		
		if ( rising_edge(btn3_clean) ) then
			if ( not (stopwatch_cur = 0)) then
				if (lap_idx = "00") then
					stopwatch_lap0 <= stopwatch_cur;
					lap_idx <= "01";
				elsif (lap_idx = "01") then
					stopwatch_lap1 <= stopwatch_cur;
					lap_idx <= "10";				
				elsif (lap_idx = "10") then
					stopwatch_lap2 <= stopwatch_cur;
					lap_idx <= "00";				
				end if;
			end if;
		end if;
		
		soft_reset <= btn3_clean_prev and btn3_clean;
		btn3_clean_prev <= btn3_clean;

	end process;
	
	process (cnt(16)) begin
		if (rising_edge(cnt(16))) then
			btn0_clean <=  (not btn0_prev) and (not btn0);
			btn0_prev <= btn0;
			btn1_clean <=  (not btn1_prev) and (not btn1);
			btn1_prev <= btn1;			
			btn2_clean <=  (not btn2_prev) and (not btn2);
			btn2_prev <= btn2;
			btn3_clean <=  (not btn3_prev) and (not btn3);
			btn3_prev <= btn3;

		end if;
	end process;
		
	with time_idx select current_time <=
		stopwatch_cur  when "00",
		stopwatch_lap0 when "01",
		stopwatch_lap1 when "10",
		distance_last when others;
		
	seg7multi_inst : entity work.seg7multi port map (
		curnum => cnt(17 downto 16),
		data   => current_time,
		segid  => segid,
		seg    => led7wires
	);
	
	CT1 <= segid(0);
	CT2 <= segid(1);
	CT3 <= segid(2);
	CT4 <= segid(3);
	
	A <= led7wires(0);
	B <= led7wires(1);
	C <= led7wires(2);
	D <= led7wires(3);
	E <= led7wires(4);
	F <= led7wires(5);
	G <= led7wires(6);
	DP<= led7wires(7);

end;



