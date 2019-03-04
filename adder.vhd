--This is an online radix-2 adder based on  reference book <digital arithmetic>
--Correctness checked.
--bandwidth can be changed now.
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.math_real.all;


ENTITY adder IS

generic ( radix : integer := 2;
			 bandwidth : integer:= 16;
			 bits_number :integer := 8
			 );

--constant bits_number_per_digit : integer := integer(ceil(log2(real(radix))))+1;-- 2
--constant bits_number: integer := bandwidth/bits_number_per_digit;--4		 
PORT ( X : in std_logic_vector (bandwidth-1 downto 0);
		 Y : in std_logic_vector (bandwidth-1 downto 0);
		 Z : out std_logic_vector (bandwidth-1 downto 0);
		 Cout : out std_logic_vector (1 downto 0));

END adder;

ARCHITECTURE gate OF adder IS
signal H :  std_logic_vector (bits_number downto 0);
signal G :  std_logic_vector (bits_number-1 downto 0);
signal I :  std_logic_vector (bits_number-1 downto 0);
signal J :  std_logic_vector (bits_number-1 downto 0);
signal K :  std_logic_vector (bits_number-1 downto 0);

Component full_adder
 Port ( A 	: in STD_LOGIC;
		  B 	: in STD_LOGIC;
		  Cin : in STD_LOGIC;
		  S 	: out STD_LOGIC;
		  Cout: out STD_LOGIC);
end component;


BEGIN

H(0) <= '0';

top_adders: for i in 0 to bits_number-1 generate
  J(i) <= not X(2*i);
  top: full_adder port map (A => X(2*i+1), B => J(i), Cin => Y(2*i+1), S =>G(i) , Cout => H(i+1));
end generate;

bottom_adders: for j in 0 to bits_number-1 generate
	K(j) <= not Y(2*j);
	bottom: full_adder port map (A => G(j), B => K(j), Cin => H(j), S =>Z(2*j+1) , Cout => I(j));
end generate;

Z(0) <= '0';

inverters: for k in 0 to bits_number-2 generate

Z(2*K+2) <= not I(k);

end generate;


Cout (0) <= not I(bits_number-1);
Cout (1) <= H(bits_number);


END gate; 