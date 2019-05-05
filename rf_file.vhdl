library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;	 
use ieee.std_logic_unsigned.all;

entity rf_file is 
	port (rf_a1, rf_a2, rf_a3: in std_logic_vector(2 downto 0); rf_d3: in std_logic_vector(15 downto 0);
		 rf_d1, rf_d2: out std_logic_vector(15 downto 0); rf_write_in, clk: in std_logic);
end entity;

architecture basic of rf_file is

	type regarray is array(7 downto 0) of std_logic_vector(15 downto 0);   -- defining a new type

	signal Memory: regarray := (others => "0000000000000000");

	begin

	rf_d1 <= Memory(conv_integer(rf_a1));
	rf_d2 <= Memory(conv_integer(rf_a2));
	
	Mem_write:
	process (rf_write_in, rf_a3, rf_d3, clk)

		begin

		if(rf_write_in = '1') then
			if(rising_edge(clk)) then
				Memory(conv_integer(rf_a3)) <= rf_d3;
			end if;
		end if;
		
	end process;

end basic;
