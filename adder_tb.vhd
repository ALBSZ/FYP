LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

ENTITY adder_tb IS
END adder_tb;

ARCHITECTURE behavior OF adder_tb IS

COMPONENT adder_for_all

generic ( radix : integer;
			 bandwidth : integer;
			 digits_number :integer;
			 bits_number: integer
			 );
	 
PORT ( X : in std_logic_vector (bandwidth-1 downto 0);
		 Y : in std_logic_vector (bandwidth-1 downto 0);
		 Z : out std_logic_vector (bandwidth-1 downto 0);
		 Cout : out std_logic_vector (digits_number-1 downto 0));
		 
END COMPONENT;

--Inputs

--Declare two clocks controling inputs
signal clockX : std_logic := '0';
signal clockY : std_logic := '0';

--Declare correctness indicator C;
signal C : std_logic := '1';

--Declare the Parameters set for generic inputs
constant R : integer := 512;
constant D : integer := 10;
constant B : integer := 2;

--Declare the wires connected yo UUT
signal X_i :std_logic_vector(D*B-1 downto 0);
signal Y_i :std_logic_vector(D*B-1 downto 0);
signal Z_i :std_logic_vector(D*B-1 downto 0);
signal Cout_i :std_logic_vector(D-1 downto 0);

--Declare decimal paremeters for autimatically change inputs value
signal X_tmp :integer:=0;
signal Y_tmp :integer:=0;

--Declare decimal paremeter used for checking.
signal X_v : integer;
signal Y_v : integer;
signal Z_actual : integer;
signal Z_correct : integer;


type int_arr is array (B-1 downto 0) of integer;
signal X_n :int_arr;
signal Y_n :int_arr;
signal Z_n :int_arr;
signal Cout_n : integer;

-- Clock period definitions
constant clock_period : time := 20 ns;

BEGIN

-- Instantiate the Unit Under Test (UUT)
uut: adder_for_all

generic map( radix => R,
			 bandwidth => D*B,
			 digits_number => D,
			 bits_number => B
			 )
			
PORT map( X_i,
	  Y_i,
	  Z_i,
	  Cout_i);

--convert inputs and output to decimal number to help find error 
X_n(0) <= to_integer(signed(X_i(D-1 downto 0)));
Xvalue:for i in 1 to B-1 generate 
	X_n(i) <= X_n(i-1) +(R**i)*(to_integer(signed(X_i(D*(i+1)-1 downto i*D))));
end generate;
	X_v <= X_n(B-1);
	
Y_n(0) <= to_integer(signed(Y_i(D-1 downto 0)));
Yvalue:for i in 1 to B-1 generate 
	Y_n(i) <= Y_n(i-1) +(R**i)*(to_integer(signed(Y_i(D*(i+1)-1 downto i*D))));
end generate;
	Y_v <= Y_n(B-1);

Z_n(0) <= to_integer(signed(Z_i(D-1 downto 0)));
Pvalue:for i in 1 to B-1 generate 
	Z_n(i) <= Z_n(i-1) +(R**i)*(to_integer(signed(Z_i(D*(i+1)-1 downto i*D))));
end generate;
	Z_actual <= Z_n(B-1)+(R**B)*(to_integer(signed(Cout_i)));

--compute the correct that module should generate for conparision later
Z_correct <= X_v+Y_v;

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
wait for clock_period*(2**(D*B))/2;
clockX <= '0';
wait for clock_period*(2**(D*B))/2;
end process;

--X and Y increment by 1 every time
process(clockX,clockY) is
begin
    if rising_edge(clockX) then
       Y_tmp <= 0;
       Y_i <= (others => '0');
       X_tmp <= X_tmp+1;
       X_i <= std_logic_vector(to_unsigned(X_tmp, X_i'length));
    end if;
	 
if rising_edge(clockY) then
       Y_tmp <= Y_tmp+1;
       Y_i <= std_logic_vector(to_unsigned(Y_tmp, Y_i'length));
   end if;

end process;

--result checking
C <= '1' when Z_actual = Z_correct else
     '0';


END;
