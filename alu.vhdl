--IITB-RISC EE224 course project by Mithilesh Vaidya, Rishabh Dahale, Anubhav Agarwal and Mihir Kavishwar
--alu can compute the operations add, NAND, XOR and sets the following flags:
--carry if addition results in carry and zero if result of ALU operation is zero

library ieee;
use ieee.std_logic_1164.all;

entity alu is
	port(A, B: in std_logic_vector(15 downto 0);
		 control: in std_logic_vector(1 downto 0);
		 carry, z, x: out std_logic;
		 out_alu: out std_logic_vector(15 downto 0));
end entity alu;

architecture struct of ALU is

	component sixteen_bit_adder is
		port(A, B: in std_logic_vector(15 downto 0);
		 S: out std_logic_vector(15 downto 0); 
		 Cout: out std_logic);
	end component sixteen_bit_adder;

	component sixteen_bit_nand is
		port(A, B: in std_logic_vector(15 downto 0);
		 S: out std_logic_vector(15 downto 0); 
		 Cout: out std_logic);
	end component sixteen_bit_nand;

	component sixteen_bit_xor is
		port(A, B: in std_logic_vector(15 downto 0);
		 S: out std_logic_vector(15 downto 0); 
		 Cout: out std_logic);
	end component sixteen_bit_xor;

	component Mux_vector is
		port(I0, I1, I2, I3: in std_logic_vector(16 downto 0);
			S: out std_logic_vector(16 downto 0);
			sel0, sel1: in  std_logic);
	end component Mux_vector;

	component zero_check is
		port(A: in std_logic_vector(15 downto 0);
			S: out std_logic);
	end component zero_check;

	--component lsb4 is
	--	port(A: in std_logic_vector(3 downto 0);
	--		S: out std_logic);
	--end component lsb4;

	signal s1, s2, s3, s4 : std_logic_vector(16 downto 0);
	signal s5 : std_logic_vector(15 downto 0);
begin
	add_instance: sixteen_bit_adder
		port map (
		 	A => A, B => B, S => s1(15 downto 0), Cout => s1(16)
		 ); 
	nand_instance: sixteen_bit_nand
		port map (
			A => A, B => B, S => s2(15 downto 0), Cout => s2(16)
		);
	xor_instance: sixteen_bit_xor
		port map (
			A => A, B => B, S => s3(15 downto 0), Cout => s3(16)
		);
	Mux: Mux_vector
		port map (
			I0 => s1, I1 => s2, I2 => s3, I3 => "00000000000000000", sel0 => control(0), 
			sel1 => control(1), S => s4
		);

	s5 <= s4(15 downto 0);
	carry <= s4(16);
	out_alu <= s5;

	zero: zero_check
		port map (
			A => s5, S => z
		);

	--lsb: lsb4
	--	port map (
	--		A => s5(3 downto 0), S => x
	--	);
	x <= not(s5(3) and (not s5(2)) and (not s5(1)) and (not s5(0)));

end architecture struct;