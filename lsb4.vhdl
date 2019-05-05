library ieee;
use ieee.std_logic_1164.all;

entity lsb4 is
	port(A: in std_logic_vector(3 downto 0);
			S: out std_logic);
end entity lsb4;

architecture struct of lsb4 is

	begin
		S <= not(A(3) and (not A(2)) and (not A(1)) and (not A(0)));
		
end architecture struct;