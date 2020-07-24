module ahbslave(HCLK, HRESET,HWRITE,HREADYIN,HTRANS,HWDATA,HADDR,PIPED0,PIPED1,PIPEA0,PIPEA1,VALID,TEMP_SEL, HWRITEREG);

///you have not taken HWRITEREG signals
output reg HWRITEREG;

input HCLK,HRESET,HWRITE,HREADYIN;
input [1:0] HTRANS;
input[31:0]HWDATA,HADDR;
output VALID;
output [2:0] TEMP_SEL;
output reg[31:0] PIPED0,PIPED1,PIPEA0,PIPEA1;
parameter SEQ=2'b01;
parameter NSEQ=2'b10;

//---- logic wrong assign VALID =(((HADDR>=(32'h8000_0000))&&HADDR<=(32'hBFFF_FFFF))&&(HTRANS==((SEQ)||(NSEQ)))&&(HREADYIN==1));
assign VALID =(HADDR>=32'h8000_0000 && HADDR<= 32'h8FFF_FFFF && HTRANS == SEQ || HTRANS == NSEQ && (HREADYIN==1) );

assign TEMP_SEL[0]=(HADDR>=32'h8000_0000)&&(HADDR<=32'h8400_0000);
assign TEMP_SEL[1]=(HADDR>32'h8400_0000)&&(HADDR<=32'h8800_00000);
assign TEMP_SEL[2]=(HADDR>32'h8800_0000)&&(HADDR<=32'h8C00_00000);

always @(posedge HCLK)
begin 
 if(HRESET==1)
begin
  PIPEA0<=32'h0;
  PIPEA1<=32'h0;
  PIPED0<=32'h0;
  PIPED1<=32'h0;
  HWRITEREG <= 0;
end
else
 begin
 PIPEA0<=HADDR;
 PIPEA1<=PIPEA0;
 PIPED0<=HWDATA;
 PIPED1<=PIPED0;
 HWRITEREG <= HWRITE;
 end
end

endmodule
