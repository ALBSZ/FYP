LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

ENTITY multi_tb IS
END multi_tb;

ARCHITECTURE behavior OF multi_tb IS

-- Component Declaration for the Unit Under Test (UUT)

COMPONENT multi

generic ( radix : integer;
			 index : integer;
			 bandwidth : integer;
			 digits_number :integer; --how many bits are used to represent a number
			 bits_number: integer---how many number the inputs have
			 );
			
PORT ( X_m : in std_logic_vector (bandwidth-1 downto 0);
		 Y_m : in std_logic_vector (bandwidth-1 downto 0);
		 P_m : out std_logic_vector (bandwidth-1 downto 0));
		 
END COMPONENT;

--Inputs
signal clockX : std_logic := '0';
signal clockY : std_logic := '0';

signal C : std_logic := '1';

constant R : integer := 8;
constant D : integer := 4;
constant B : integer := 4;

signal X :std_logic_vector(D*B-1 downto 0);
signal Y :std_logic_vector(D*B-1 downto 0);
signal P :std_logic_vector(D*B-1 downto 0);

signal X_increment :std_logic_vector(D*B-1 downto 0);
signal Y_increment :std_logic_vector(D*B-1 downto 0);

signal X_tmp :integer;
signal Y_tmp :integer;

signal X_v : integer;
signal Y_v : integer;
signal P_actual : integer;
signal P_correct : integer;
signal P_C_output : integer;


type int_arr is array (B-1 downto 0) of integer;
signal X_n :int_arr;
signal Y_n :int_arr;
signal P_n :int_arr;

-- Clock period definitions
constant clock_period : time := 20 ns;

BEGIN

-- Instantiate the Unit Under Test (UUT)
uut: multi

generic map( radix => R,
			 index => D-1,
			 bandwidth => D*B,
			 digits_number => D,
			 bits_number => B
			 )
			
PORT map( X_m =>X,
		 Y_m =>Y,
		 P_m =>P);

X_increment(D*B-1 downto D*B/2+1) <= (others => '0');
X_increment(D*B/2) <= '1';
X_increment(D*B/2-1 downto 0) <= (others => '0');

Y_increment(0) <= '1';
Y_increment(D*B-1 downto 1) <= (others => '0');


X_n(0) <= to_integer(signed(X(D-1 downto 0)));
Xvalue:for i in 1 to B-1 generate 
	X_n(i) <= X_n(i-1) +(R**i)*(to_integer(signed(X(D*(i+1)-1 downto i*D))));
end generate;
	X_v <= X_n(B-1);
	
Y_n(0) <= to_integer(signed(Y(D-1 downto 0)));
Yvalue:for i in 1 to B-1 generate 
	Y_n(i) <= Y_n(i-1) +(R**i)*(to_integer(signed(Y(D*(i+1)-1 downto i*D))));
end generate;
	Y_v <= Y_n(B-1);

P_n(0) <= to_integer(signed(P(D-1 downto 0)));
Pvalue:for i in 1 to B-1 generate 
	P_n(i) <= P_n(i-1) +(R**i)*(to_integer(signed(P(D*(i+1)-1 downto i*D))));
end generate;
	P_actual <= P_n(B-1)*(R**B);

P_correct <= X_v*Y_v;
P_c_output <= (P_correct+R**(B-1))/(R**B);	

-- Clock process definitions
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
wait for clock_period*(2**(D*B-2))/2;
clockX <= '0';
wait for clock_period*(2**(D*B-2))/2;
end process;

process(clockX,clockY) is
begin
    if rising_edge(clockX) then
       Y_tmp <= 0;
       Y <= (others => '0');
       X_tmp <= X_tmp+R**B;
       X <= std_logic_vector(to_unsigned(X_tmp, X'length));
    end if;
	 
if rising_edge(clockY) then
       Y_tmp <= Y_tmp+1;
       Y <= std_logic_vector(to_unsigned(Y_tmp, Y'length));
   end if;
	 
	 if ((X_v >0) and (Y_v >0) and(P_c_output /= P_n(B-1))) then 
		C <= '0';
	 else 
		C <= '1';
	 end if;
end process;



END;