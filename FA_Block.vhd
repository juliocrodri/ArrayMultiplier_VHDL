----------------------------------------------------------------------------------
-- Company: CSUN    
-- Engineer: Julio Rodriguez
-- 
-- Create Date: 10/15/2019 10:43:54 AM
-- Design Name: 
-- Module Name: FA_Block - Behavioral
-- Project Name: 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FA_Block is
    Port ( Ai : in STD_LOGIC;
           Xi : in STD_LOGIC;
           Ai_1 : in STD_LOGIC;
           Ci_in : in STD_LOGIC;
           COut : out STD_LOGIC;
           POut : out STD_LOGIC);
end FA_Block;

architecture Behavioral of FA_Block is
Signal Bi:STD_LOGIC;
begin
Bi<=Ai AND Xi; --multiply two single bits
POut<=Ai_1 xor Ci_in xor Bi;
COut<=(Ai_1 and Bi) or (Ai_1 and Ci_in) or (Bi and Ci_in);
end Behavioral;
