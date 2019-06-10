LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.math_real.all;

ENTITY toplevel IS

generic ( radix : integer := 2;
			 index : integer := 1;
			 bandwidth : integer:= 16;
			 digits_number :integer := 2; --how many bits are used to represent a number
			 bits_number: integer :=8---how many number the inputs have
			 );
			
PORT ( X_d_i : in std_logic_vector (bandwidth-1 downto 0);
		 D_d_i: in std_logic_vector (bandwidth-1 downto 0);
		 clk : in std_logic;
		 Q_d_i : out std_logic_vector (bandwidth-1 downto 0));
		 
end toplevel;

---------------------------------------------------------------------------------------------------
-- architecture ---------------------------------------------------------------------------------

ARCHITECTURE gate OF toplevel IS

signal X_d_t : std_logic_vector (bandwidth-1 downto 0);
signal D_d_t : std_logic_vector (bandwidth-1 downto 0); 
signal Q_d_t : std_logic_vector (digits_number-1 downto 0);

component divider
generic ( radix : integer := 2;
			 index : integer := 1;
			 bandwidth : integer:= 16;
			 digits_number :integer := 2;
			 bits_number: integer :=8
			 );
			
PORT ( X_d : in std_logic_vector (bandwidth-1 downto 0);
		 D_d : in std_logic_vector (bandwidth-1 downto 0);
		 Q_d : out std_logic_vector (bandwidth-1 downto 0));
end component;

begin
	test: divider
generic map( radix  => 2,
			 index  => 1,
			 bandwidth => 16,
			 digits_number  => 2, 
			 bits_number =>8
			 )
	 
	PORT map ( X_d => X_d_t,
				  D_d => D_d_t,
				  Q_d => Q_d_i);
process(clk)
begin
   if rising_edge(clk) then
		X_d_t <= X_d_i;
		D_d_t <= D_d_i;
	end if;
end process;				  

end gate;
