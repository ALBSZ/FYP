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
			
PORT ( X_m_i : in std_logic_vector (bandwidth-1 downto 0);
		 Y_m_i: in std_logic_vector (bandwidth-1 downto 0);
		 clk : in std_logic;
		 P_m_i : out std_logic_vector (bandwidth-1 downto 0));
		 
end toplevel;

---------------------------------------------------------------------------------------------------
-- architecture ---------------------------------------------------------------------------------

ARCHITECTURE gate OF toplevel IS

signal X_m_t : std_logic_vector (bandwidth-1 downto 0);
signal Y_m_t : std_logic_vector (bandwidth-1 downto 0); 
signal P_m_t : std_logic_vector (digits_number-1 downto 0);

component multi
generic ( radix : integer := 2;
			 index : integer := 1;
			 bandwidth : integer:= 16;
			 digits_number :integer := 2;
			 bits_number: integer :=8
			 );
			
PORT ( X_m : in std_logic_vector (bandwidth-1 downto 0);
		 Y_m : in std_logic_vector (bandwidth-1 downto 0);
		 P_m : out std_logic_vector (bandwidth-1 downto 0));
end component;

begin
	test: multi
generic map( radix  => 2,
			 index  => 1,
			 bandwidth => 16,
			 digits_number  => 2, 
			 bits_number =>8
			 )
	 
	PORT map ( X_m => X_m_t,
				  Y_m => Y_m_t,
				  P_m => P_m_i);
process(clk)
begin
   if rising_edge(clk) then
		X_m_t <= X_m_i;
		Y_m_t <= Y_m_i;
	end if;
end process;				  

end gate;
