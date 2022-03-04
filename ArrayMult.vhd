----------------------------------------------------------------------------------
-- Company: CSUN
-- Engineer: Julio Rodriguez
-- 
-- Create Date: 10/15/2019 11:06:59 AM
-- Design Name: 
-- Module Name: ArrayMult - Behavioral
-- Project Name: Array Multiplier
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity ArrayMult is
    generic ( size: integer :=5);
    Port ( A_in : in STD_LOGIC_VECTOR (size-1 downto 0);
           X_in : in STD_LOGIC_VECTOR (size-1 downto 0);
           Prod: out STD_LOGIC_VECTOR(2*size-1  downto 0));
end ArrayMult;

architecture Behavioral of ArrayMult is
------------------------------components-----------------------------------
component FA_Block is
    Port ( Ai : in STD_LOGIC;
           Xi : in STD_LOGIC;
           Ai_1 : in STD_LOGIC;
           Ci_in : in STD_LOGIC;
           COut : out STD_LOGIC;
           POut : out STD_LOGIC);
end component;
---------------------------------Signals-------------------------------------
type Bridge is Array (size downto 0) of STD_LOGIC_VECTOR(size-1 downto 0);
signal COut_Array: Bridge;
signal ProdBit_Array:Bridge; 
signal LSB_portion : std_logic_vector(size-1 downto 0);


-------------------------------Port Map & Generate----------------------------
begin
genRow: for j in 0 to size generate
   genBlock:for k in 0 to size-1 generate
        LSBROW0:if(j=0 and k=0) generate
        Row0_Block:FA_Block port map(
                        Ai=>A_in(k),
                        Ai_1=>'0',
                        Ci_in=>'0',
                        Xi=>X_in(0),
                        COut=>COut_Array(j)(k),
                        POut=>LSB_portion(j));
        end generate LSBROW0;
        Row_0: if (j=0 and k<size-1 and k>0) generate 
            --generate the first Row where C_in =0         
            Row0_Block:FA_Block port map(
                Ai=>A_in(k),
                --Ai_1=>A_in(k+1),--changed top row input 
                Ai_1=>'0',
                Ci_in=>'0',
                Xi=>X_in(0),
                COut=>COut_Array(j)(k),
                POut=>ProdBit_Array(j)(k));
            end generate Row_0;
            --MSB of first row has Ai_1 of 0
            Row_0End: if (j=0 and k=size-1) generate 
                        Row0_Block:FA_Block port map(
                            Ai=>A_in(k),
                            Ai_1=>'0',
                            Ci_in=>'0',
                            Xi=>X_in(0),
                            COut=>COut_Array(j)(k),
                            POut=>ProdBit_Array(j)(k));
                        end generate Row_0End;
            Row_jLSB: if(j>0 and j<size and k=0) generate
                                LSBBlock:FA_Block port map(
                                    Ai=>A_in(k), 
                                    Xi=>X_in(j),
                                    Ai_1=>ProdBit_Array(j-1)(k+1),
                                    Ci_in=>COut_Array(j-1)(k),
                                    COut=>COut_Array(j)(k),
                                    POut=>LSB_portion(j));
                end generate Row_jLSB;
            
            Row_j: if(j>0 and j<size and k<size-1 and k>0) generate
                Rowj_Block:FA_Block port map(
                    Ai=>A_in(k), 
                    Xi=>X_in(j),
                    Ai_1=>ProdBit_Array(j-1)(k+1),
                    Ci_in=>COut_Array(j-1)(k),
                    COut=>COut_Array(j)(k),
                    POut=>ProdBit_Array(j)(k));
        end generate Row_j;

        Row_jMSB: if(j>0 and j<size and k=size-1) generate
            Rowj_Block:FA_Block port map(
                Ai=>A_in(k), 
                Xi=>X_in(j),
                Ai_1=>'0',
                Ci_in=>COut_Array(j-1)(k),
                COut=>COut_Array(j)(k),
                POut=>ProdBit_Array(j)(k));
        end generate Row_jMSB;
        --generate the last row
        --Outputs Upper half of final product bits
        --make it a regular full adder by applying the same input to A and X
        Row_end0: if (j=size and k=0) generate
                    --generate the last row
                    --Outputs Upper half of final product bits
                    
                    RowEnd_0Block:FA_Block port map(
                        Ai=>COut_Array(j-1)(k), 
                        Xi=>COut_Array(j-1)(k),
                        Ai_1=>ProdBit_Array(j-1)(k+1),
                        Ci_in=>'0',
                        COut=>COut_Array(j)(k),
                        POut=>ProdBit_Array(j)(k));
            end generate Row_end0;
            
        Row_end: if (j=size and k<size-2 and k>0) generate

                
                RowEnd_Block:FA_Block port map(
                    Ai=>COut_Array(j-1)(k), 
                    Xi=>COut_Array(j-1)(k),
                    Ai_1=>ProdBit_Array(j-1)(k+1),
                    Ci_in=>COut_Array(j)(k-1),
                    COut=>COut_Array(j)(k),
                    POut=>ProdBit_Array(j)(k));
        end generate Row_end;
        
        RowEnd_MSB: if (j=size and k=size-2) generate --
            Final_Block: FA_Block port map(
                    Ai=>COut_Array(j-1)(k), 
                    Xi=>COut_Array(j-1)(k),
                    Ai_1=>ProdBit_Array(j-1)(k+1),
                    Ci_in=>COut_Array(j)(k-1),
                    COut=>ProdBit_Array(j)(k+1),
                    POut=>ProdBit_Array(j)(k));
        end generate RowEnd_MSB;
        
    end generate genBlock;
 end generate genRow;
 --Attempted to concatenate the LSB of each row 
 --since 2D concatenation is not defined , shifted bit by bit into a temporary vector
--BitConcat:process (clk)
--variable i: integer:=size-1;
--begin
--    if(rising_edge(clk))then
--    if(i>=0)then
--    LSB_portion<=LSB_portion(size-2 downto 0) & ProdBit_Array(i)(0);
--    i:=i-1;
--    else
--    LSB_portion<=LSB_portion;
--    end if;
--    end if;
--end process BitConcat; 
Prod<=ProdBit_Array(size)(size-1 downto 0) & LSB_portion;

--Checked output lines with RTL analysis. the correct bits are outputted ot correct location on BUS with this statement
--Prod<=ProdBit_Array(size)(size-1 downto 0) &ProdBit_Array(4)(0)&ProdBit_Array(3)(0)&ProdBit_Array(2)(0)&ProdBit_Array(1)(0)&ProdBit_Array(0)(0);

end Behavioral;
