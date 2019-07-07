
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

ENTITY divider_tb IS
END divider_tb;

ARCHITECTURE behavior OF divider_tb IS

COMPONENT divider

generic ( radix : integer := 2;
			 index : integer := 1;
			 bandwidth : integer:= 8;
			 digits_number :integer := 2; --how many bits are used to represent a number
			 bits_number: integer :=4---how many number the inputs have
			 );
			
PORT ( X_d : in std_logic_vector (bandwidth-1 downto 0);
		 D_d : in std_logic_vector (bandwidth-1 downto 0);
		 Q_d : out std_logic_vector (bandwidth-1 downto 0));
		 
END COMPONENT;

--Declare two clocks controling inputs
signal clockX : std_logic := '0';
signal clockY : std_logic := '0';

--Declare correctness indicator C;
signal C : std_logic := '1';


--Declare the Parameters set for generic inputs
constant R : integer := 2;
constant D : integer := 2;
constant B : integer := 4;

--Declare the wires connected yo UUT
signal X :std_logic_vector(D*B-1 downto 0);
signal Y :std_logic_vector(D*B-1 downto 0);
signal P :std_logic_vector(D*B-1 downto 0);

--Declare decimal paremeters for autimatically change inputs value
signal X_tmp :integer :=2;
signal Y_tmp :integer;

--Declare decimal paremeter used for checking.
signal X_v : integer;
signal Y_v : integer :=1;
signal P_actual : integer;
signal X_actual: integer;
type int_arr is array (B-1 downto 0) of integer;
signal X_n :int_arr;
signal Y_n :int_arr;
signal P_n :int_arr;

-- Clock period definitions
constant clock_period : time := 20 ns;

BEGIN

-- Instantiate the Unit Under Test (UUT)
uut: divider

generic map( radix => R,
			 index => D-1,
			 bandwidth => D*B,
			 digits_number => D,
			 bits_number => B
			 )
			
PORT map( X,
	  Y,
	  P);

--convert inputs and output to decimal number to help find error 
X_n(0) <= to_integer(signed(X(D-1 downto 0)));
Xvalue:for i in 1 to B-1 generate 
	X_n(i) <= X_n(i-1) +(R**i)*(to_integer(signed(X(D*(i+1)-1 downto i*D))));
end generate;
	X_v <= X_n(B-2)*(R**B);
	
Y_n(0) <= to_integer(signed(Y(D-1 downto 0)));
Yvalue:for i in 1 to B-1 generate 
	Y_n(i) <= Y_n(i-1) +(R**i)*(to_integer(signed(Y(D*(i+1)-1 downto i*D))));
end generate;
	Y_v <= Y_n(B-2);

P_n(0) <= to_integer(signed(P(D-1 downto 0)));
Pvalue:for i in 1 to B-1 generate 
	P_n(i) <= P_n(i-1) +(R**i)*(to_integer(signed(P(D*(i+1)-1 downto i*D))));
end generate;
	P_actual <= P_n(B-1);

--compute the correct that module should generate for conparision later
X_actual <= P_actual*Y_v;


-- Clock process definitions, for every Xclock cycle, all posinle value of Y will be tested
clockY_process :process
begin
clockY <= '0';
wait for clock_period/2;
clockY <= '1';
wait for clock_period/2;
end process;

clockX_process :process
begin
clockX <= '1';
wait for clock_period*(2**(D*B-1))/2;
clockX <= '0';
wait for clock_period*(2**(D*B-1))/2;
end process;

--X and Y increment by 1 every time
process(clockX,clockY) is
begin
    if rising_edge(clockX) then
       	Y_tmp <= X_tmp;
	Y <= std_logic_vector(to_unsigned(Y_tmp, Y'length));
	if (X_tmp < 2**(D*B-1))then
       		X_tmp <= X_tmp+1;		
	end if;
       X <= std_logic_vector(to_unsigned(X_tmp, X'length));
    end if;
	 
if rising_edge(clockY) then
       Y_tmp <= Y_tmp+1;
       Y <= std_logic_vector(to_unsigned(Y_tmp, Y'length));
   end if;

--result checking
if ((X /= X_actual) and (abs(X_v) < abs(Y_v))) then 
	C <= '0';
else 
	C <= '1';
end if ;
end process;


END;