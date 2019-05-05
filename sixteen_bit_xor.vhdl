library ieee;
use ieee.std_logic_1164.all;

entity sixteen_bit_xor is
	port(A, B: in std_logic_vector(15 downto 0);
		 S: out std_logic_vector(15 downto 0); 
		 Cout: out std_logic);
end entity sixteen_bit_xor;

architecture struct of sixteen_bit_xor is

	begin
		Cout <= '0';
		S <= A xor B;
		
end architecture struct;