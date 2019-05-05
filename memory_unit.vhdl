--IITB-RISC EE224 course project by Mithilesh Vaidya, Rishabh Dahale, Anubhav Agarwal and Mihir Kavishwar
--Memory is asynchronous read and so there is no read signal
--It gives 16-bit data in one clock cycle
--The preloaded memory computes the instructions given in the documentation

library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;	 
use ieee.std_logic_unsigned.all;

entity memory_unit is 
	port (address, Mem_datain: in std_logic_vector(15 downto 0); clk, write_signal: in std_logic; Mem_dataout: out std_logic_vector(15 downto 0));
end entity;

architecture Form of memory_unit is

	type regarray is array(65535 downto 0) of std_logic_vector(15 downto 0);   -- defining a new type

	signal Memory: regarray := (
	0 => x"3001", 1 => x"60aa", 2 => x"0038", 3 => x"03fa", 4 => x"0079", 5 => x"5f9f", 6 => x"13fb", 7 => x"2038",
	8 => x"233a", 9 => x"2079", 10 => x"4f9f", 11 => x"c9c2", 12 => x"abcd", 13 => x"8e02", 14 => x"1234", 15 => x"91c0",
	128 => x"ffff", 129 => x"0002", 130 => x"0000", 131 => x"0000", 132 => x"0001", 133 => x"0000",
	others => x"0000"
	);
	-- you can use the above mentioned way to initialise the memory with the instructions and the data as required to test your processor
	begin

	Mem_dataout <= Memory(conv_integer(address));
	
	Mem_write:

	process (write_signal, Mem_datain, address, clk)
		begin
		if(write_signal = '0') then
			if(rising_edge(clk)) then
				Memory(conv_integer(address)) <= Mem_datain;
			end if;
		end if;
	end process;

end Form;