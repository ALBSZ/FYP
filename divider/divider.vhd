
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

ENTITY divider IS

generic ( radix : integer := 2;
			 index : integer := 1;
			 bandwidth : integer:= 8;
			 digits_number :integer := 2; --how many bits are used to represent a number
			 bits_number: integer :=4---how many number the inputs have
			 );
			
PORT ( X_d : in std_logic_vector (bandwidth-1 downto 0):= "00000010";
		 D_d : in std_logic_vector (bandwidth-1 downto 0):= "00000100";
		 Q_d : out std_logic_vector (bandwidth-1 downto 0));
		 
end divider;
		 
Architecture gate of divider is 
type Q is array (bits_number+1 downto 0) of std_logic_vector (index*(bits_number+1)-1 downto 0);
type D is array (bits_number downto 0) of std_logic_vector (index*(bits_number+1)-1 downto 0);
type Dadj is array (bits_number-1 downto 0) of std_logic_vector (index*(bits_number+1)-1 downto 0);
type VW  is array (bits_number+3 downto 0) of std_logic_vector (index*(bits_number+5) downto 0) ;
type WS is array (bits_number-1 downto 0) of std_logic_vector (index*(bits_number+2) downto 0) ;
signal D_in: D;
signal D_adj:Dadj;
signal Q_in: Q;
signal Q_adj:D;
signal V: VW;
signal V_1: VW;
signal V_2: VW;
signal V_3: VW;
signal W: VW;
signal W_sub : WS;
signal Q_tmp: std_logic_vector (bandwidth-1 downto 0);

begin
--  initialization and calculation of D

D_in(0) <= (others =>'0');

initial: for i in 0 to bits_number-1 generate 

D_adj(i)(index*(bits_number+1)-1 downto index*(bits_number-i))   <=(others => D_d(bandwidth-1-digits_number*i));
D_adj(i)(index*(bits_number-i)-1 downto index*(bits_number-i-1)) <=D_d(bandwidth-2-digits_number*i downto bandwidth-digits_number*(i+1));
D_adj(i)(index*(bits_number-i-1)-1 downto 0)					        <=(others => '0');

D_in(i+1) <= D_in(i) +D_adj(i);


end generate;

--calculation of V,W and output Q


V(0)(index*(bits_number+5) downto index*(bits_number+1)) <= (others =>X_d(bandwidth-1));
V(0)(index*(bits_number+1)-1 downto index*bits_number) <= X_d(bandwidth-2 downto bandwidth-digits_number);
V(0)(index*bits_number-1 downto 0) <= (others => '0');
W(0) <= V(0);

--VW initial 

initialVW :for i in 0 to 2 generate
V_1(i+1)(index*(bits_number+5) downto index*(bits_number+1)) <= (others =>X_d(bandwidth-1-(i+1)*digits_number));
V_1(i+1)(index*(bits_number+1)-1 downto index*bits_number) <= X_d(bandwidth-digits_number*(i+1)-2 downto bandwidth-digits_number*(i+2));
V_1(i+1)(index*bits_number-1 downto 0) <= (others => '0');

V_2(i+1)(index-1 downto 0) <= (others => '0');
V_2(i+1)(index*(bits_number+5) downto index) <= W(i)(index*(bits_number+4) downto 0);

V(i+1) <= V_1(i+1)+V_2(i+1);
W(i+1) <= V(i+1);
end generate initialVW;

Q_in(0) <= (others => '0');

recurrenciveVW :for i in 3 to bits_number-2 generate
V_1(i+1)(index*(bits_number+5) downto index*(bits_number+1)) <= (others =>X_d(bandwidth-(i+1)*digits_number-1));
V_1(i+1)(index*(bits_number+1)-1 downto index*bits_number) <= X_d(bandwidth-digits_number*(i+1)-2 downto bandwidth-digits_number*(i+2));
V_1(i+1)(index*bits_number-1 downto 0) <= (others => '0');

V_2(i+1)(index-1 downto 0) <= (others => '0');
V_2(i+1)(index*(bits_number+5) downto index) <= W(i)(index*(bits_number+4) downto 0);


V_3(i-2)(index*(bits_number+1) downto 0) <= std_logic_vector(signed (Q_in(0))*signed(D_d(bandwidth-digits_number*(i+1)-1 downto bandwidth-digits_number*(i+2))));
V_3(i-2)(index*(bits_number+5) downto index*(bits_number+1)+1) <= (others => V_3(i-2)(index*(bits_number+2)));

V(i+1) <=std_logic_vector(signed(V_1(i+1))+signed(V_2(i+1))-signed(V_3(i-2)));
Q_tmp(bandwidth-(i-3)*digits_number-1 downto bandwidth-(i-2)*digits_number) <= V(i+1)(index*(bits_number+5) downto index*(bits_number+4)) + V(i+1)(index*(bits_number+4)-1);

W_sub(i-3) <= std_logic_vector(signed(Q_tmp(bandwidth-(i-3)*digits_number-1 downto bandwidth-(i-2)*digits_number))*signed(d_in(i+1)));
W(i+1)(index*(bits_number+5) downto index*5) <= std_logic_vector(signed(V(i+1)(index*(bits_number+5) downto index*5))-signed(W_sub(i-3)(index*bits_number downto 0)));
W(i+1)(index*5-1 downto 0) <= V(i+1)(index*5-1 downto 0);

Q_adj(i-2)(index*(bits_number+1)-1 downto index*(bits_number-i+3))   <=(others => Q_tmp(bandwidth-(i-3)*digits_number-1));
Q_adj(i-2)(index*(bits_number-i+3)-1 downto index*(bits_number-i+2)) <=Q_tmp(bandwidth-(i-3)*digits_number-2 downto bandwidth-(i-2)*digits_number);
Q_adj(i-2)(index*(bits_number-i+2)-1 downto 0)					         <=(others => '0');

Q_in(i-2) <= Q_in(i-1) + Q_adj(i-2);
end generate recurrenciveVW;


lastVW: for i in bits_number-1 to bits_number+2 generate
V(i+1)(index-1 downto 0) <= (others => '0');
V(i+1)(index*(bits_number+5) downto index) <= W(i)(index*(bits_number+4) downto 0);

Q_tmp(bandwidth-(i-3)*digits_number-1 downto bandwidth-(i-2)*digits_number) <= V(i+1)(index*(bits_number+5) downto index*(bits_number+4)) + V(i+1)(index*(bits_number+4)-1);

W_sub(i-3) <= std_logic_vector(signed(Q_tmp(bandwidth-(i-3)*digits_number-1 downto bandwidth-(i-2)*digits_number))*signed(d_in(bits_number)));
W(i+1)(index*(bits_number+5) downto index*5) <= std_logic_vector(signed(V(i+1)(index*(bits_number+5) downto index*5))-signed(W_sub(i-3)(index*bits_number downto 0)));
W(i+1)(index*5-1 downto 0) <= V(i+1)(index*5-1 downto 0);

Q_adj(i-2)(index*(bits_number+1)-1 downto index*(bits_number-i+3))   <=(others => Q_tmp(bandwidth-(i-3)*digits_number-1));
Q_adj(i-2)(index*(bits_number-i+3)-1 downto index*(bits_number-i+2)) <= Q_tmp(bandwidth-(i-3)*digits_number-2 downto bandwidth-(i-2)*digits_number);
Q_adj(i-2)(index*(bits_number-i+2)-1 downto 0)					       <=(others => '0');

Q_in(i-2) <= Q_in(i-1) + Q_adj(i-2);

end generate lastVW;

Q_d <= Q_tmp;

end gate;