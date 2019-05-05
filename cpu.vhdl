--IITB-RISC EE224 course project by Mithilesh Vaidya, Rishabh Dahale, Anubhav Agarwal and Mihir kKvishwar
--The main driving unit
--State transitions and control signals are decided according to the FSM state transition diagram. Refer to the docs

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu is
	port (clk, rst: in std_logic; final_out: out std_logic_vector(15 downto 0));
end entity cpu;

architecture main of cpu is

	component alu is
	port (a, b: in std_logic_vector(15 downto 0);
		  control : in std_logic_vector(1 downto 0);
		  carry, z, x: out std_logic;
		  out_alu: out std_logic_vector(15 downto 0));
	end component alu;

	component rf_file is
	port (rf_a1, rf_a2, rf_a3: in std_logic_vector(2 downto 0);
		  rf_d3: in std_logic_vector(15 downto 0);
		  rf_d1, rf_d2: out std_logic_vector(15 downto 0);
		  rf_write_in, clk: in std_logic);
	end component rf_file;

	component memory_unit is
	port (address,Mem_datain: in std_logic_vector(15 downto 0); 
		  clk,write_signal: in std_logic;
		  Mem_dataout: out std_logic_vector(15 downto 0));
	end component memory_unit;

	component sign_extend_10 is
	port (inp: in std_logic_vector(5 downto 0); 
		   extended: out std_logic_vector(15 downto 0));
	end component sign_extend_10;

	component sign_extend_7 is
	port (inp: in std_logic_vector(8 downto 0); 
		   extended: out std_logic_vector(15 downto 0));
	end component sign_extend_7;

	--No component for left shift. Do it on the go
	
	type FSMState is (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, 
		S17, S18, S19, S20, S21, S22, S23, S24, S25, S26, S27, S28, S29);
	signal fsm_state: FSMState;
	signal instr_reg, instr_pointer: std_logic_vector(15 downto 0);
	signal mem_A, mem_Din, MEM_DOUT, ALU_A, ALU_B, ALU_O, RF_D1, RF_D2, RF_D3, SIGN_EXTENDER_10_OUTPUT, SIGN_EXTENDER_7_OUTPUT : std_logic_vector(15 downto 0);
	signal MEM_WRITE_BAR_ENABLE, ALU_C, ALU_Z, ALU_X, C_FLAG, Z_FLAG, RF_WRITE_IN : std_logic;
	signal RF_A1, RF_A2, RF_A3 : std_logic_vector(2 downto 0);
	signal T1, T2, T3, T4, T5 : std_logic_vector(15 downto 0);
	signal ALU_CONTROL : std_logic_vector(1 downto 0);
	signal SIGN_EXTERNDER_10_INPUT : std_logic_vector(5 downto 0);
	signal SIGN_EXTERNDER_7_INPUT : std_logic_vector(8 downto 0);

	
	begin

		Memory : memory_unit port map (
			mem_A, mem_Din, clk, MEM_WRITE_BAR_ENABLE, MEM_DOUT
		);
		
		Arithmetic_Logical_Unit : alu port map (
			ALU_A, ALU_B, ALU_CONTROL, ALU_C, ALU_Z, ALU_X, ALU_O
		);

		Register_file : rf_file port map (
			RF_A1, RF_A2, RF_A3, RF_D3, RF_D1, RF_D2, RF_WRITE_IN, clk
		);

		SE10 : sign_extend_10 port map (
			SIGN_EXTERNDER_10_INPUT, SIGN_EXTENDER_10_OUTPUT
		);

		SE7 : sign_extend_7 port map (
			SIGN_EXTERNDER_7_INPUT, SIGN_EXTENDER_7_OUTPUT
		);

		-- ALU_CONTROL "00" Adder, "01" NAND of all, "10" XOR
		-- 

		process(clk, fsm_state)

		variable next_fsm_state_var : FSMState;
		--variable RF_WRITE_IN_var : std_logic;
		--next_fsm_state_var := fsm_state;
		variable next_IP, temp_T1, temp_T2, temp_T3, temp_T4, temp_T5, instr_reg_var : std_logic_vector(15 downto 0);
		--next_IP := instr_pointer;
		variable TZ_TEMP, TC_TEMP : std_logic;

		begin
		
		next_fsm_state_var :=  fsm_state;
		next_IP := instr_pointer;
		temp_T4 := T4;
		temp_T1 := T1;
		temp_T2 := T2;
		temp_T3 := T3;
		temp_T5 := T5;
		TZ_TEMP := Z_FLAG;
		TC_TEMP := C_FLAG;
		instr_reg_var := instr_reg;

		--MEM_WRITE_BAR_ENABLE_var := MEM_WRITE_BAR_ENABLE;
		--RF_WRITE_IN_var := RF_WRITE_IN;

		case( fsm_state ) is
			
				when S0 =>
					MEM_WRITE_BAR_ENABLE<='1';
					RF_WRITE_IN <= '0';
					MEM_A <= instr_pointer;
					instr_reg_var := MEM_DOUT;
					case (instr_reg(15 downto 12)) is
						when "0000" =>
							next_fsm_state_var := S1;
						when "0001" =>
							next_fsm_state_var := S4;
						when "0010" =>
							next_fsm_state_var := S1;
						when "0011" =>
							next_fsm_state_var := S8;
						when "0100" =>
							next_fsm_state_var := S1;
						when "0101" =>
							next_fsm_state_var := S1;
						when "0110" =>
							next_fsm_state_var := S15;
						when "0111" =>
							next_fsm_state_var := S15;
						when "1100" =>
							next_fsm_state_var := S22;
						when "1000" =>
							next_fsm_state_var := S26;
						when "1001" =>
							next_fsm_state_var := S26;
						when others =>
							null;
					end case;
				
				when S1 =>
					MEM_WRITE_BAR_ENABLE<='1';
					RF_WRITE_IN <= '0';
					RF_A1 <= instr_reg(11 downto 9);
					RF_A2 <= instr_reg(8 downto 6);
					temp_T1:=RF_D1; temp_T2:=RF_D2;
					
					case (instr_reg(15 downto 12)) is
						when "0000" =>
							next_fsm_state_var := S2;
						when "0010" =>
							next_fsm_state_var := S6;
						when "0100" =>
							next_fsm_state_var := S10;
						when "0101" =>
							next_fsm_state_var := S13;
						when others =>
							null;
					end case;

				when S2 =>
					MEM_WRITE_BAR_ENABLE<='1';
					ALU_A <= T1; ALU_B <= T2;
					ALU_CONTROL <= "00";
					RF_WRITE_IN <= '1';
					
					--if (instr_reg(1 downto 0)="00") then
					--	TC_TEMP :=ALU_C; TZ_TEMP := ALU_Z;
					--elsif (instr_reg(1 downto 0)="10") then
					--	if (C_FLAG='1') then
					--		TC_TEMP :=ALU_C; TZ_TEMP := ALU_Z;
					--	else
					--		TC_TEMP :=C_FLAG; TZ_TEMP := Z_FLAG;
					--	end if;
					--elsif (instr_reg(1 downto 0)="01") then
					--	if (Z_FLAG='1') then
					--		TC_TEMP :=ALU_C; TZ_TEMP := ALU_Z;
					--	else
					--		TC_TEMP :=C_FLAG; TZ_TEMP := Z_FLAG;
					--	end if;
					--end if;
					--if (instr_reg(1 downto 0)="00") then =>
					temp_T3 := ALU_O;
					--elsif (instr_reg(1 downto 0) = "10" and C_FLAG='1') then
					--	T1 <= ALU_O; C_FLAG <=ALU_C; Z_FLAG <= ALU_Z;
					--elsif (instr_reg(1 downto 0)="01" and Z_FLAG='1') then
					--	T1 <= ALU_O; C_FLAG <=ALU_C; Z_FLAG <= ALU_Z;
					--end if;

					case (instr_reg(15 downto 12)) is
						when "0000" =>
							next_fsm_state_var := S3;
						when "0001" =>
							next_fsm_state_var := S5;
						when others =>
							null;
					end case;

				when S3 =>
					MEM_WRITE_BAR_ENABLE<='1';

					if (instr_pointer(15 downto 12)="0000" or instr_pointer(15 downto 12)="0001") then
						if (instr_reg(1 downto 0)="00") then
							RF_WRITE_IN <= '1';
							RF_D3<=T3; RF_A3<=instr_reg(5 downto 3) ; TC_TEMP := ALU_C; TZ_TEMP := ALU_Z;
							--RF_WRITE_IN <= '1';
						elsif (instr_reg(1 downto 0) = "10" and C_FLAG='1') then
							RF_WRITE_IN <= '1';
							RF_D3<=T3; RF_A3<=instr_reg(5 downto 3) ; TC_TEMP := ALU_C; TZ_TEMP := ALU_Z;
							--RF_WRITE_IN_var := '0';
						elsif (instr_reg(1 downto 0)="01" and Z_FLAG='1') then
							RF_WRITE_IN <= '1';
							RF_D3<=T3; RF_A3<=instr_reg(5 downto 3) ; TC_TEMP := ALU_C; TZ_TEMP := ALU_Z;
							--RF_WRITE_IN_var := '0';
						end if;
					elsif (instr_pointer(15 downto 12)="0010") then
						if (instr_reg(1 downto 0)="00") then
							RF_WRITE_IN <= '1';
							RF_D3<=T3; RF_A3<=instr_reg(5 downto 3) ; TZ_TEMP := ALU_Z;
							--RF_WRITE_IN <= '1';
						elsif (instr_reg(1 downto 0) = "10" and C_FLAG='1') then
							RF_WRITE_IN <= '1';
							RF_D3<=T3; RF_A3<=instr_reg(5 downto 3) ; TZ_TEMP := ALU_Z;
							--RF_WRITE_IN_var := '0';
						elsif (instr_reg(1 downto 0)="01" and Z_FLAG='1') then
							RF_WRITE_IN <= '1';
							RF_D3<=T3; RF_A3<=instr_reg(5 downto 3) ; TZ_TEMP := ALU_Z;
							--RF_WRITE_IN_var := '0';
						end if;

					end if;
					--RF_WRITE_IN <= '0';
					--RF_D3<=T1; instr_reg(5 downto 3)<=RF_A3;
					next_fsm_state_var := S7;

				when S4 =>
					RF_WRITE_IN <= '0';
					MEM_WRITE_BAR_ENABLE<='1';
					RF_A1 <= instr_reg(11 downto 9); temp_T1 := RF_D1;
					SIGN_EXTERNDER_10_INPUT<= instr_reg(5 downto 0);
					temp_T2 := SIGN_EXTENDER_10_OUTPUT;

					next_fsm_state_var := S2;

				when S5 =>
					MEM_WRITE_BAR_ENABLE<='1';
					RF_WRITE_IN <= '1';
					RF_D3 <= T3; RF_A3<=instr_reg(8 downto 6);
					TZ_TEMP := ALU_Z; TC_TEMP := ALU_C;
					--C_FLAG <= TC_TEMP; Z_FLAG <= TZ_TEMP;
					--if (instr_reg(1 downto 0)="00") then
					--	RF_WRITE_IN <= '1';
					--	RF_D3<=T3; RF_A3<=instr_reg(5 downto 3) ; TC_TEMP := ALU_C; TZ_TEMP := ALU_Z;
					--	--RF_WRITE_IN <= '1';
					--elsif (instr_reg(1 downto 0) = "10" and C_FLAG='1') then
					--	RF_WRITE_IN <= '1';
					--	RF_D3<=T3; RF_A3<=instr_reg(5 downto 3) ; TC_TEMP := ALU_C; TZ_TEMP := ALU_Z;
					--	--RF_WRITE_IN_var := '0';
					--elsif (instr_reg(1 downto 0)="01" and Z_FLAG='1') then
					--	RF_WRITE_IN <= '1';
					--	RF_D3<=T3; RF_A3<=instr_reg(5 downto 3) ; TC_TEMP := ALU_C; TZ_TEMP := ALU_Z;
					--	--RF_WRITE_IN_var := '0';
					--end if;
					--RF_WRITE_IN_var := '0';
					next_fsm_state_var := S7;
				
				when S6 =>
					RF_WRITE_IN <= '0';
					MEM_WRITE_BAR_ENABLE<='1';
					ALU_A <= T1; ALU_B <= T2;
					ALU_CONTROL <= "01";
					temp_T3:=ALU_O; -- TZ_TEMP<=ALU_Z;

					--if (instr_reg(1 downto 0)="00") then
					--	TC_TEMP :=C_FLAG; TZ_TEMP := ALU_Z;
					--elsif (instr_reg(1 downto 0)="10") then
					--	if (C_FLAG='1') then
					--		TC_TEMP :=C_FLAG; TZ_TEMP := ALU_Z;
					--	else
					--		TC_TEMP :=C_FLAG; TZ_TEMP := Z_FLAG;
					--	end if;
					--elsif (instr_reg(1 downto 0)="01") then
					--	if (Z_FLAG='1') then
					--		TC_TEMP :=C_FLAG; TZ_TEMP := ALU_Z;
					--	else
					--		TC_TEMP :=C_FLAG; TZ_TEMP := Z_FLAG;
					--	end if;
					--end if;

					next_fsm_state_var:= S3;

				when S7 =>
					RF_WRITE_IN <= '0';
					MEM_WRITE_BAR_ENABLE<='1';
					ALU_A <= instr_pointer;
					ALU_B <= x"0001";
					ALU_CONTROL<="00";
					next_IP := ALU_O;

					next_fsm_state_var := S0;

				when S8 =>
					RF_WRITE_IN <= '0';
					MEM_WRITE_BAR_ENABLE<='1';
					temp_T1(15 downto 7) := instr_reg(8 downto 0);
					temp_T1(6 downto 0) := "0000000";

					next_fsm_state_var:=S9;

				when S9 =>
					MEM_WRITE_BAR_ENABLE<='1';
					RF_WRITE_IN <= '1';
					RF_D3<=T1;
					RF_A3<=instr_reg(11 downto 9);
					--RF_WRITE_IN_var := '0';

					next_fsm_state_var := S7;

				when S10 =>
					RF_WRITE_IN <= '0';
					MEM_WRITE_BAR_ENABLE<='1';
					ALU_A<=T2;
					SIGN_EXTERNDER_10_INPUT<= instr_reg(5 downto 0);
					ALU_B <= SIGN_EXTENDER_10_OUTPUT;
					ALU_CONTROL<="00";
					temp_T1:= ALU_O;
					TZ_TEMP:=ALU_Z;

					next_fsm_state_var := S11;

				when S11 =>
					RF_WRITE_IN <= '0';
					MEM_WRITE_BAR_ENABLE<='1';
					--MEM_WRITE_BAR_ENABLE <= '0';
					MEM_A <= T1;
					temp_T2 := MEM_DOUT;

					next_fsm_state_var:= S12;

				when S12 =>
					MEM_WRITE_BAR_ENABLE<='1';
					RF_WRITE_IN <= '1';
					RF_D3<=T2;
					RF_A3<=instr_reg(11 downto 9);
					--RF_WRITE_IN_var := '0';

					next_fsm_state_var := S7;

				when S13 =>
					RF_WRITE_IN <= '0';
					MEM_WRITE_BAR_ENABLE<='1';
					ALU_A<=T2;
					SIGN_EXTERNDER_10_INPUT<=instr_reg(5 downto 0);
					ALU_B <= SIGN_EXTENDER_10_OUTPUT;
					ALU_CONTROL<="00";
					temp_T3:=ALU_O;

					next_fsm_state_var := S14;

				when S14 =>
					RF_WRITE_IN <= '0';
					MEM_WRITE_BAR_ENABLE<='0';
					MEM_A <= T3;
					MEM_DIN <= T1;
					--MEM_WRITE_BAR_ENABLE_var := '1';

					next_fsm_state_var := S7;

				when S15 =>
					RF_WRITE_IN <= '0';
					MEM_WRITE_BAR_ENABLE<='1';
					RF_A1<=instr_reg(11 downto 9);
					temp_T1 := RF_D1;
					temp_T2 := x"0000";

					next_fsm_state_var := S16;

				when S16 =>
					RF_WRITE_IN <= '0';
					MEM_WRITE_BAR_ENABLE<='1';
					ALU_A <= T1;
					ALU_B <= T2;
					ALU_CONTROL <= "00";
					temp_T3 := ALU_O;

					if (instr_reg(15 downto 12)="0110") then
						next_fsm_state_var:=S17;
					elsif (instr_reg(15 downto 12)="0111") then
						next_fsm_state_var:=S20;
					end if;
					--next_fsm_state_var:=S17;

				when S17 =>
					RF_WRITE_IN <= '0';
					MEM_WRITE_BAR_ENABLE<='1';
					MEM_A <= T3;
					temp_T4 := MEM_DOUT;

					next_fsm_state_var := S18;

				when S18 =>
					--temp_T3 := T3;
					MEM_WRITE_BAR_ENABLE<='1';
					RF_WRITE_IN <= '1';
					RF_A3 <= T2(2 downto 0);
					RF_D3 <= T4;
					temp_T5 := T2;
					--RF_WRITE_IN_var := '0';

					next_fsm_state_var:=S19;

				when S19 =>
					RF_WRITE_IN <= '0';
					MEM_WRITE_BAR_ENABLE<='1';
					ALU_B <= x"0001";
					ALU_A<=T5;
					ALU_CONTROL<="00";
					temp_T2:=ALU_O;

					if (ALU_X='0') then
						next_fsm_state_var := S7;
					elsif (ALU_X='1') then
						next_fsm_state_var := S16;
					end if;

				when S20 =>
					RF_WRITE_IN <= '0';
					MEM_WRITE_BAR_ENABLE<='1';
					RF_A2<=T2(2 downto 0);
					temp_T4:=RF_D2;

					next_fsm_state_var := S21;

				when S21 =>
					RF_WRITE_IN <= '0';
					MEM_WRITE_BAR_ENABLE<='0';
					MEM_A<=T3;
					MEM_DIN<=T4;
					temp_T5 := T2;
					--MEM_WRITE_BAR_ENABLE_var:='1';

					next_fsm_state_var:=S19;

				when S22 =>
					RF_WRITE_IN <= '0';
					MEM_WRITE_BAR_ENABLE<='1';
					ALU_A<=instr_pointer;
					SIGN_EXTERNDER_10_INPUT<=instr_reg(5 downto 0);
					ALU_B<=SIGN_EXTENDER_10_OUTPUT;
					ALU_CONTROL <= "00";
					temp_T4:=ALU_O;

					next_fsm_state_var:=S23;

				when S23 =>
					RF_WRITE_IN <= '0';
					MEM_WRITE_BAR_ENABLE<='1';
					RF_A1<=instr_reg(11 downto 9);
					RF_A2<=instr_reg(8 downto 6);
					temp_T1:=RF_D1;
					temp_T2:=RF_D2;

					next_fsm_state_var:=S24;

				when S24 =>
					RF_WRITE_IN <= '0';
					MEM_WRITE_BAR_ENABLE<='1';
					ALU_A<=T1;
					ALU_B<=T2;
					ALU_CONTROL<="10";
					temp_T3:=ALU_O;

					if (ALU_Z='0') then
						next_fsm_state_var:=S7;
					elsif (ALU_Z='1') then
						next_fsm_state_var:=S25;
					end if;

				when S25 =>
					RF_WRITE_IN <= '0';
					MEM_WRITE_BAR_ENABLE<='1';
					--temp_T4 := instr_pointer;
					next_IP := T4;
					next_fsm_state_var :=S0;

				when S26 =>
					MEM_WRITE_BAR_ENABLE<='1';
					RF_WRITE_IN <= '1';
					RF_A3 <= instr_reg(11 downto 9);
					RF_D3 <= instr_pointer;
					--RF_WRITE_IN_var := '0';

					if (instr_reg(15 downto 12)="1000") then
						next_fsm_state_var := S27;
					elsif (instr_reg(15 downto 12)="1001") then
						next_fsm_state_var := S29;
					end if;

				when S27 =>
					RF_WRITE_IN <= '0';
					MEM_WRITE_BAR_ENABLE<='1';
					ALU_A <= instr_pointer;
					SIGN_EXTERNDER_7_INPUT <= instr_reg(8 downto 0);
					ALU_B <= SIGN_EXTENDER_7_OUTPUT;
					ALU_CONTROL <= "00";
					temp_T1:=ALU_O;

					next_fsm_state_var:=S28;

				when S28 =>
					RF_WRITE_IN <= '0';
					MEM_WRITE_BAR_ENABLE<='1';
					next_IP:=T1;

					next_fsm_state_var :=S0;

				when S29 =>
					RF_WRITE_IN <= '0';
					MEM_WRITE_BAR_ENABLE<='1';
					RF_A1<=instr_reg(8 downto 6);
					temp_T1 := RF_D1;
					next_fsm_state_var:=S28;

				when others =>
					null;
			end case ;

			T1 <= temp_T1; T2 <= temp_T2; T3 <= temp_T3; T4 <= temp_T4; T5 <= temp_T5;
			instr_reg <= instr_reg_var;
			C_FLAG <= TC_TEMP; Z_FLAG <= TZ_TEMP;
			--RF_WRITE_IN <= RF_WRITE_IN_var;
			--MEM_WRITE_BAR_ENABLE <= MEM_WRITE_BAR_ENABLE_var;

			if(rising_edge(clk)) then
				--T1 <= temp_T1; T2 <= temp_T2; T3 <= temp_T3; T4 <= temp_T4;
				--instr_reg <= instr_reg_var;
				if (rst = '1') then
					instr_pointer <= x"0000";
					fsm_state <= S0;
--					MEM_WRITE_BAR_ENABLE <= '1';
					--RF_WRITE_IN_var := '0';
					--MEM_WRITE_BAR_ENABLE <= '1';
					--RF_WRITE_IN <= '0';
					--T1 <= x"0000";
					--T2 <= x"0000";
					--T3 <= x"0000";
					--T4 <= x"0000";
					--instr_reg <= x"0000";
				else
					fsm_state <= next_fsm_state_var;
					instr_pointer <= next_IP;
					--instr_reg <= instr_reg_var;
					--T1 <= temp_T1; T2 <= temp_T2; T3 <= temp_T3; T4 <= temp_T4;
					--instr_reg <= instr_reg_var;
					--RF_WRITE_IN <= RF_WRITE_IN_var;
					--MEM_WRITE_BAR_ENABLE <= MEM_WRITE_BAR_ENABLE_var;
					
				end if;
			end if;

			--T1 <= temp_T1; T2 <= temp_T2; T3 <= temp_T3; T4 <= temp_T4;
			--instr_reg <= instr_reg_var;
			--RF_WRITE_IN <= RF_WRITE_IN_var;
			--MEM_WRITE_BAR_ENABLE <= MEM_WRITE_BAR_ENABLE_var;

			--RF_WRITE_IN <= RF_WRITE_IN_var;
			--MEM_WRITE_BAR_ENABLE <= MEM_WRITE_BAR_ENABLE_var;

		end process;


end main;
