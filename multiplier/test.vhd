
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY TB_multi IS
END TB_multi;

ARCHITECTURE behavior OF TB_multi IS

-- Component Declaration for the Unit Under Test (UUT)

component multi
generic ( radix : integer := 2;
			 index : integer := 1;
			 bandwidth : integer:= 8;
			 digits_number :integer := 2;
			 bits_number: integer :=4
			 );
			
PORT ( X_m : in std_logic_vector (bandwidth-1 downto 0);
		 Y_m : in std_logic_vector (bandwidth-1 downto 0);
		 P_m : out std_logic_vector (bandwidth-1 downto 0));
end component;

--Inputs
signal clock : std_logic := '0';
signal X : std_logic_vector (7 downto 0) := "00000000";
signal Y : std_logic_vector (7 downto 0) := "00000000";
signal P : std_logic_vector (7 downto 0) := "00000000";
signal X_v : integer;
signal Y_v : integer;
signal P_actual : integer;
signal P_correct :integer;

--Outputs
signal counter : std_logic_vector(3 downto 0);

-- Clock period definitions
constant clock_period : time := 20 ns;

BEGIN

-- Instantiate the Unit Under Test (UUT)
uut: multi generic map( radix  => 2,
			 index  => 1,
			 bandwidth => 8,
			 digits_number  => 2, 
			 bits_number => 4
			 )
	 
	PORT map ( X_m => X,
				  Y_m => Y,
				  P_m => P);
X_v <= (8*(to_integer(signed(X(7 downto 6))))+ 4*(to_integer(signed(X(5 downto 4))))+2*(to_integer(signed(X(3 downto 2))))+to_integer(signed(X(1 downto 0))));
Y_v <= (8*(to_integer(signed(Y(7 downto 6))))+ 4*(to_integer(signed(Y(5 downto 4))))+2*(to_integer(signed(Y(3 downto 2))))+to_integer(signed(Y(1 downto 0))));
P_actual <= (8*(to_integer(signed(P(7 downto 6))))+ 4*(to_integer(signed(P(5 downto 4))))+2*(to_integer(signed(P(3 downto 2))))+to_integer(signed(P(1 downto 0))))*16;
P_correct <= X_v*Y_v;
-- Clock process definitions
clock_process :process
begin
clock <= '0';
wait for clock_period/2;
clock <= '1';
wait for clock_period/2;
end process;

-- Stimulus process
stim_proc: process
begin
-- hold reset state for 100 ns.
wait for 20 ns;
X <= "00010000";
Y <= "00010000";
wait for 20 ns;
X <= "00010000";
Y <= "01000000";
wait for 20 ns;
X <= "00010000";
Y <= "01010000";
wait for 20 ns;
X <= "00010000";
Y <= "01110000";

wait for 20 ns;
X <= "01000000";
Y <= "00000100";
wait for 20 ns;
X <= "01000000";
Y <= "00010000";
wait for 20 ns;
X <= "01000000";
Y <= "00010100";
wait for 20 ns;
X <= "01000000";
Y <= "00011100";


wait for 20 ns;
X <= "01000000";
Y <= "01000000";
wait for 20 ns;
X <= "01000000";
Y <= "01000100";
wait for 20 ns;
X <= "01000000";
Y <= "01001100";
wait for 20 ns;
X <= "01000000";
Y <= "01010000";
wait for 20 ns;
X <= "01000000";
Y <= "01010100";
wait for 20 ns;
X <= "01000000";
Y <= "01010100";
wait for 20 ns;
X <= "01000000";
Y <= "01011100";
wait for 20 ns;
X <= "01000000";
Y <= "01110000";
wait for 20 ns;
X <= "01000000";
Y <= "01110100";
wait for 20 ns;
X <= "01000000";
Y <= "01111100";

wait;
end process;

END;