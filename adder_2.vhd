LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY adder_2 IS
PORT ( X : in std_logic_vector (7 downto 0);
		 Y : in std_logic_vector (7 downto 0);
		 Z : out std_logic_vector (7 downto 0);
		 Cout : out std_logic_vector (1 downto 0));
END adder_2;

ARCHITECTURE gate OF adder_2 IS
signal H :  std_logic_vector (2 downto 0);
signal G :  std_logic_vector (3 downto 0);
signal I :  std_logic_vector (3 downto 0);

Component full_adder
 Port ( A 	: in STD_LOGIC;
		  B 	: in STD_LOGIC;
		  Cin : in STD_LOGIC;
		  S 	: out STD_LOGIC;
		  Cout: out STD_LOGIC);
end component;

BEGIN
FA1:full_adder port map(X(7),not X(6),Y(7),Cout(1),G(3));
FA2:full_adder port map(X(5),not X(4),Y(5),H(2),G(2));
FA3:full_adder port map(X(3),not X(2),Y(3),H(1),G(1));
FA4:full_adder port map(X(1),not X(0),Y(1),H(0),G(0));
FA5:full_adder port map(G(3),not Y(6),H(2),I(3),Z(7));
FA6:full_adder port map(G(2),not Y(4),H(1),I(2),Z(5));
FA7:full_adder port map(G(1),not Y(2),H(0),I(1),Z(3));
FA8:full_adder port map(G(0),not Y(0),'0', I(0),Z(1));
Z(0) <= '0';
Z(6) <= not I(2);  
Z(4) <= not I(1);
Z(2) <= not I(0);
Cout (0) <= not I(3);

END gate; 