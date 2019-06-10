LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

ENTITY multi IS

generic ( radix : integer := 2;
			 index : integer := 1;
			 bandwidth : integer:= 16;
			 digits_number :integer := 2; --how many bits are used to represent a number
			 bits_number: integer :=8---how many number the inputs have
			 );
			
PORT ( X_m : in std_logic_vector (bandwidth-1 downto 0);
		 Y_m : in std_logic_vector (bandwidth-1 downto 0);
		 P_m : out std_logic_vector (bandwidth-1 downto 0));
		 
end multi;
		 
Architecture gate of Multi is 

type XY  is array (bits_number downto 0) of std_logic_vector (index*(bits_number+1)-1 downto 0);
type adj is array (bits_number-1 downto 0) of std_logic_vector (index*(bits_number+1)-1 downto 0);
type VW  is array (bits_number+2 downto 0) of std_logic_vector (indeX*(bits_number+5) downto 0) ;
signal X_in: XY;
signal Y_in: XY;
signal X_adj:adj;
signal Y_adj:adj;
signal V: VW;
signal V_1: VW;
signal V_2: VW;
signal W: VW;

begin
--  initialization and calculation of X and Y

X_in(0) <= (others =>'0');
Y_in(0) <= (others =>'0');

initial: for i in 0 to bits_number-1 generate 

X_adj(i)(index*(bits_number+1)-1 downto index*(bits_number-i))   <=(others => X_m(bandwidth-1-digits_number*i));
X_adj(i)(index*(bits_number-i)-1 downto index*(bits_number-i-1)) <=X_m(bandwidth-2-digits_number*i downto bandwidth-digits_number*(i+1));
X_adj(i)(index*(bits_number-i-1)-1 downto 0)					        <=(others => '0');

				  
Y_adj(i)(index*(bits_number+1)-1 downto index*(bits_number-i))   <=(others => Y_m(bandwidth-1-digits_number*i));
Y_adj(i)(index*(bits_number-i)-1 downto index*(bits_number-i-1)) <=Y_m(bandwidth-2-digits_number*i downto bandwidth-digits_number*(i+1));
Y_adj(i)(index*(bits_number-i-1)-1 downto 0)					        <=(others => '0');


X_in(i+1) <= X_in(i) +X_adj(i);
Y_in(i+1) <= Y_in(i) +Y_adj(i);

end generate;

--calculation of V,W and output P



V(0)(index*(bits_number+5) downto index*(bits_number+2)+1) <= (others =>'0');
V(0)(index*(bits_number+2) downto 0) <= std_logic_vector(signed (y_in(1))*signed(X_m(bandwidth-1 downto bandwidth-digits_number)));
W(0) <= V(0);

--VW initial 

initialVW :for i in 0 to 1 generate
V_1(i+1)(index*(bits_number+5) downto index*(bits_number+2)+1) <= (others =>'0');
V_1(i+1)(index*(bits_number+2) downto 0) <=  std_logic_vector(signed (y_in(i+2))*signed(X_m(bandwidth-digits_number*(i+1)-1 downto bandwidth-digits_number*(i+2))))
														  +std_logic_vector(signed (x_in(i+1))*signed(Y_m(bandwidth-digits_number*(i+1)-1 downto bandwidth-digits_number*(i+2))));
V_2(i+1)(index-1 downto 0) <= (others => '0');
V_2(i+1)(index*(bits_number+5) downto index) <= W(i+1)(index*(bits_number+4) downto 0);
V(i+1) <= V_1(i+1)+V_2(i+1);
W(i+1) <= V(i+1);
end generate initialVW;

recurrenciveVW :for i in 2 to bits_number-2 generate
V_1(i+1)(index*(bits_number+5) downto index*(bits_number+2)+1) <= (others =>'0');
V_1(i+1)(index*(bits_number+2) downto 0) <=  std_logic_vector(signed (y_in(i+2))*signed(X_m(bandwidth-digits_number*(i+1)-1 downto bandwidth-digits_number*(i+2))))
														  +std_logic_vector(signed (x_in(i+1))*signed(Y_m(bandwidth-digits_number*(i+1)-1 downto bandwidth-digits_number*(i+2))));
V_2(i+1)(index-1 downto 0) <= (others => '0');
V_2(i+1)(index*(bits_number+5) downto index) <= W(i+1)(index*(bits_number+4) downto 0);

V(i+1) <=V_1(i+1)+V_2(i+1);
p_m(bandwidth-(i-2)*digits_number-1 downto bandwidth-(i-1)*digits_number) <= V(i+1)(index*(bits_number+5) downto index*(bits_number+4)) + V(i+1)(index*(bits_number+4)-1);
W(i+1)(index*(bits_number+4)-1 downto 0) <= V(i+1)(index*(bits_number+4)-1 downto 0);
W(i+1)(index*(bits_number+5) downto index*(bits_number+4)) <= (others => V(i+1)(index*(bits_number+4)-1));
end generate recurrenciveVW;


lastVW: for i in bits_number-1 to bits_number+1 generate
V(i+1)(index-1 downto 0) <= (others => '0');
V(i+1)(index*(bits_number+5) downto index) <= W(i+1)(index*(bits_number+4) downto 0);
p_m(bandwidth-(i-2)*digits_number-1 downto bandwidth-(i-1)*digits_number) <= V(i+1)(index*(bits_number+5) downto index*(bits_number+4));-- + V(i+1)(index*(bits_number+4)-1);
W(i+1)(index*(bits_number+4)-1 downto 0) <= V(i+1)(index*(bits_number+4)-1 downto 0);
W(i+1)(index*(bits_number+5) downto index*(bits_number+4)) <= (others => V(i+1)(index*(bits_number+4)-1));

end generate lastVW;



end gate;