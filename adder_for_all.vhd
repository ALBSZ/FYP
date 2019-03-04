--This design is an onlinehigher radix redundant (bigger than or equal to 4) number adder which allows paramiterized radix and bandwith.
--Value range of each bit is set to be -(r/2+1) to r/2  represented by 2's complement for easy implementation ( umsymetrical set but dont know whether a good seting or not).
--Also, "when... else" statement was used, allowing quartus buiding part of circuit. So there is potentail of optimization.
--The output with base-16,8,4 has been tested in ModelSim by manually picking random inputs. Output correctness needs further investigated.
--Only full adder was used as component in this disigned.(more hierarchy disign is in progress).
--no clock signal is assigned but quartus compilation keeps showing warning because of this....(do we need it?)

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.math_real.all;

--top entity declaration----------------------------------------------------------------------
ENTITY adder_for_all IS


generic ( radix : integer := 512;
			 bandwidth : integer:= 50;
			 digits_number :integer := 10;
			 bits_number: integer :=5
			 );
	 
PORT ( X : in std_logic_vector (bandwidth-1 downto 0);
		 Y : in std_logic_vector (bandwidth-1 downto 0);
		 Z : out std_logic_vector (bandwidth-1 downto 0);
		 Cout : out std_logic_vector (digits_number-1 downto 0));

END adder_for_all;

---------------------------------------------------------------------------------------------------
-- architecture ---------------------------------------------------------------------------------

ARCHITECTURE gate OF adder_for_all IS

--internal signal declaration ------------------------------------------------------------
signal sum_initial :  std_logic_vector (bandwidth-1 downto 0);
signal sum_adjusted :  std_logic_vector (bandwidth-1 downto 0);
signal cout_bits :  std_logic_vector (bandwidth-1 downto 0);
signal internal_cin_1 :std_logic_vector ((digits_number+1)*bits_number-1 downto 0);
signal internal_cin_2 :std_logic_vector ((digits_number+1)*(bits_number-1)-1 downto 0);

-----------------------------------------------------------------------------------------------------
--component assignment for full_adder-------------------------------------------------------------

Component full_adder
 Port ( A 	: in STD_LOGIC;
		  B 	: in STD_LOGIC;
		  Cin : in STD_LOGIC;
		  S 	: out STD_LOGIC;
		  Cout: out STD_LOGIC);
end component;

------------------------------------------------------------------------------------------------------------------------------------
--architecture main body---------------------------------------------------------------------------------
BEGIN

--toplevel parallel addition of each bit and adjustment when bit value exceeds assigned range--------------------------
top_adders: for i in 0 to bits_number-1 generate

-- basic 2's complement addition for each bits
	internal_cin_1((digits_number+1)*i) <= '0';
	
	bitsadders :for j in 0 to digits_number-1 generate
		bits: full_adder port map (A => X(digits_number*i+j), B => Y(digits_number*i+j), Cin => internal_cin_1((digits_number+1)*i+j), S => sum_initial(digits_number*i+j), Cout => internal_cin_1((digits_number+1)*i+j+1));
	end generate;
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
--bit values adjustment-----------------------------------------------------------------------------------------------------------------------------------------------
	sum_adjusted(digits_number*(i+1)-1) <= not sum_initial(digits_number*(i+1)-1) when ((X(digits_number*(i+1)-1) xnor Y(digits_number*(i+1)-1)) and (X(digits_number*(i+1)-1) xor sum_initial(digits_number*(i+1)-1))) = '1' else
														not sum_initial(digits_number*(i+1)-1) when (sum_initial(digits_number*(i+1)-1) xor sum_initial(digits_number*(i+1)-2)) = '1' else
														sum_initial(digits_number*(i+1)-1);
	adjustment_1 :for j in 0 to digits_number-2 generate 
		adj_1:sum_adjusted(digits_number*i+j) <= sum_initial(digits_number*i+j);
	end generate;
		
											  
	cout_bits(digits_number*i) <='1' when ((X(digits_number*(i+1)-1) xnor Y(digits_number*(i+1)-1)) and (X(digits_number*(i+1)-1) xor sum_initial(digits_number*(i+1)-1))) = '1'else 
										  '1' when (sum_initial(digits_number*(i+1)-1) xor sum_initial(digits_number*(i+1)-2)) ='1' else
										  '0';
											  
	adjustment_2: for j in 1 to digits_number-1 generate
		adj_2: cout_bits(digits_number*i+j) <=X(digits_number*(i+1)-1)when ((X(digits_number*(i+1)-1) xnor Y(digits_number*(i+1)-1)) and (X(digits_number*(i+1)-1) xor sum_initial(digits_number*(i+1)-1))) = '1' else 	
														  sum_initial(digits_number*(i+1)-1) when (sum_initial(digits_number*(i+1)-1) xor sum_initial(digits_number*(i+1)-2)) = '1' else
														  '0';
	end generate;
	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
end generate;

--bottom addition for increments and decrements 
bottom_adders: for i in 0 to bits_number-2 generate

	internal_cin_2((digits_number+1)*i) <= '0';
	bitsadders :for j in 0 to digits_number-1 generate
		bits: full_adder port map (A => sum_adjusted(digits_number*(i+1)+j), B => cout_bits(digits_number*i+j),Cin => internal_cin_2((digits_number+1)*i+j), S => Z(digits_number*(i+1)+j), Cout => internal_cin_2((digits_number+1)*i+j+1));
	end generate;
end generate;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--passing values to outputs--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	F1:for i in 0 to digits_number-1 generate
		Z(i) <= sum_adjusted(i);
	end generate;

	F2:for i in 0 to digits_number-1 generate 
		Cout (i) <= cout_bits(bandwidth-digits_number+i);
	end generate;

END gate; 