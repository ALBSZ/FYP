
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY TB_multi IS
END TB_multi;

ARCHITECTURE behavior OF TB_multi IS

-- Component Declaration for the Unit Under Test (UUT)

component multi
generic ( radix : integer;
			 index : integer;
			 bandwidth : integer;
			 digits_number :integer;
			 bits_number: integer 
			 			 );
			
PORT ( X_m : in std_logic_vector (bandwidth-1 downto 0);
		 Y_m : in std_logic_vector (bandwidth-1 downto 0);
		 P_m : out std_logic_vector (bandwidth-1 downto 0));
end component;

--Inputs
signal clockX : std_logic := '0';
signal clockY : std_logic := '0';

constant R :integer := 2;
constant D :integer := 2;
constant B :integer := 4;
signal C : std_logic := '1';
signal X : std_logic_vector (B*D-1 downto 0) := (others => '0');
signal Y : std_logic_vector (B*D-1 downto 0) := (others => '0');
signal P : std_logic_vector (B*D-1 downto 0) := (others => '0');

type int_array is array (B-1 downto 0) of integer;
signal X_n : int_array;
signal Y_n : int_array;
signal P_n : int_array;

signal X_tmp : std_logic_vector (B*D-1 downto 0) := (others => '0');
signal Y_tmp : std_logic_vector (B*D-1 downto 0) := (others => '0');
signal X_increment : std_logic_vector (B*D-1 downto 0);
signal Y_increment : std_logic_vector (B*D-1 downto 0);


signal X_v : integer;
signal Y_v : integer;
signal P_actual : integer;
signal P_correct :integer;
signal P_C_output :integer;

--Outputs
signal counter : std_logic_vector(3 downto 0);

-- Clock period definitions
constant clock_period : time := 20 ns;

BEGIN


X_increment(D*B-1 downto D*B/2+1) <= (others => '0');
X_increment(D*B/2) <= '1';
X_increment(D*B/2-1 downto 0) <= (others => '0');

Y_increment(0) <='1';
Y_increment(D*B-1 downto 1) <=(others => '0');

-- Instantiate the Unit Under Test (UUT)
uut: multi generic map( radix  => R,
			 index  => D-1,
			 bandwidth => D*B,
			 digits_number  => D, 
			 bits_number => B
			 )
	 
	PORT map ( X_m => X,
				  Y_m => Y,
				  P_m => P);
X_n(0) <= to_integer(signed(X(D-1 downto 0)));
Xadd : for i in 1 to B-1 generate 
  X_n(i) <= X_n(i-1)  + (2**i)*(to_integer(signed(X((i+1)*D-1 downto i*D))));
end generate;
  X_v <= X_n(B-1);

Y_n(0) <= to_integer(signed(Y(D-1 downto 0)));
Yadd : for i in 1 to B-1 generate 
  Y_n(i) <= Y_n(i-1)  + (2**i)*(to_integer(signed(Y((i+1)*D-1 downto i*D))));
end generate;
  Y_v <= Y_n(B-1);
  
P_n(0) <= to_integer(signed(P(D-1 downto 0)));
Padd : for i in 1 to B-1 generate 
  P_n(i) <= P_n(i-1)  + (2**i)*(to_integer(signed(P((i+1)*D-1 downto i*D))));
end generate;
  P_actual <= P_n(B-1)*(R**B);

P_correct <= X_v*Y_v;
P_C_output <= (P_correct+ R**(B-1))/(R**B);

-- Clock process definitions
clockX_process :process
begin
clockX <= '0';
wait for clock_period*(2**(D*B-1))/2;
clockX <= '1';
wait for clock_period*(2**(D*B-1))/2;
end process;

-- Clock process definitions
clockY_process :process
begin
clockY <= '0';
wait for clock_period/2;
clockY <= '1';
wait for clock_period/2;
end process;

process(clockX,clockY) is
begin
if rising_edge(clockX) then
  X <= X_tmp+X_increment;
  X_tmp <= X;
  Y <= (others =>'0');
end if;

if rising_edge(clockY) then
  Y <= Y_tmp+Y_increment;
  Y_tmp <= Y;
end if; 

if ((X_v>0) and (Y_V >0) and (P_correct >=(R**B)) and(P_C_output /= P_n(B-1)))   then 
  C <= '0';
else 
  C <= '1';
end if;

end process;


END;