-- INP 2018/2019
-- Project 1
-- Karel Hanák (xhanak34)

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity ledc8x8 is
port (

	SMCLK : in std_logic;
	RESET: in std_logic;
	ROW : out std_logic_vector(0 to 7);
	LED : out std_logic_vector(0 to 7)

);
end ledc8x8;

architecture main of ledc8x8 is

	signal rows : std_logic_vector(0 to 7) := "10000000";
	signal leds : std_logic_vector(0 to 7) := "11111111";
	signal tick : std_logic := '0';
	signal counter : std_logic_vector(0 to 7) := "00000000";
	signal delay : std_logic_vector(0 to 12) := "0000000000000";
	signal current_state : std_logic_vector(0 to 1) := "00";
	
begin

	process(SMCLK, RESET)
	begin
		if(RESET = '1') then
			counter <= "00000000";
		elsif (rising_edge(SMCLK)) then
			counter <= counter + 1;
		end if;
	end process;
	
	process(counter, SMCLK, RESET)
	begin
		if (RESET = '1') then
			tick <= '0';
		elsif (rising_edge(SMCLK)) then
			if (counter = "11111111") then	-- one tick at 256, reduced for custom CE
				tick <= '1';
			else 
				tick <= '0';
			end if;
		end if;
	end process;
	
	process(tick, SMCLK, RESET)
	begin
		if (RESET = '1') then
			rows <= "10000000";
			current_state <= "00";
		elsif (rising_edge(SMCLK) and tick = '1') then
			case (rows) is				-- rotates rows
				when "10000000" =>
					rows <= "01000000";
				when "01000000" =>
					rows <= "00100000";
				when "00100000" =>
					rows <= "00010000";
				when "00010000" =>
					rows <= "00001000";
				when "00001000" =>
					rows <= "00000100";
				when "00000100" =>
					rows <= "00000010";
				when "00000010" =>
					rows <= "00000001";
				when "00000001" =>
					rows <= "10000000";
				when others =>
					null;
			end case;
			if (delay = "1110000000111") then 	-- approximate delay in miliseconds
				current_state <= current_state + 1; 	-- change state after reaching the delay
				delay <= "0000000000000";
			else
				delay <= delay + 1;
			end if;
		end if;
	end process;
	
	process(current_state, rows)
	begin
		if (current_state = "00") then
			case (rows) is				-- first letter at 0 to 250ms
				when "10000000" =>
					leds <= "11011101";
				when "01000000" =>
					leds <= "11011011";
				when "00100000" =>
					leds <= "11010111";
				when "00010000" =>
					leds <= "11001111";
				when "00001000" =>
					leds <= "11010111";
				when "00000100" =>
					leds <= "11011011";
				when "00000010" =>
					leds <= "11011101";
				when "00000001" =>
					leds <= "11111111";
				when others =>
					leds <= "11111111";
			end case;
		elsif (current_state = "10") then
			case (rows)  is			-- second letter at 500 to 750 ms
				when "10000000" =>
					leds <= "11011011";
				when "01000000" =>
					leds <= "11011011";
				when "00100000" =>
					leds <= "11011011";
				when "00010000" =>
					leds <= "11000011";
				when "00001000" =>
					leds <= "11011011";
				when "00000100" =>
					leds <= "11011011";
				when "00000010" =>
					leds <= "11011011";
				when "00000001" =>
					leds <= "11111111";
				when others =>
					leds <= "11111111";
			end case;
		else 
			leds <= "11111111";
		end if;
	end process;
	ROW <= rows;
	LED <= leds;
end main;
