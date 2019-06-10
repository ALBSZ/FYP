LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity CA is 

generic( digits_width: integer);

PORT ( X : in std_logic_vector (digits_width-1 downto 0);
		 Y : in std_logic_vector (digits_width-1 downto 0);
		 cin : in std_logic;
		 Z : out std_logic_vector (digits_width-1 downto 0);
		 Cout : out std_logic);
		 
end CA;

architecture gate of CA is 
	signal internal_cin : std_logic_vector (digits_width downto 0);
	
	Component FA
	 Port ( A 	: in STD_LOGIC;
			  B 	: in STD_LOGIC;
			  Cin : in STD_LOGIC;
			  S 	: out STD_LOGIC;
			  Cout: out STD_LOGIC);
	end component;

	begin
		internal_cin(0) <= cin;
		Adder: for i in 0 to digits_width-1 generate 
			A: FA port map (A => X(i), B => Y(i), Cin => internal_cin(i), S => Z(i), Cout => internal_cin(i+1));
		end generate;
			
		Cout <= internal_cin(digits_width);
		
	
end gate;