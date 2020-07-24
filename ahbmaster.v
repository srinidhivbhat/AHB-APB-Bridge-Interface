module ahbmaster (Hclk, Hresetn,Hresp, Hrdata, Hreadyout, Hwrite, Hreadyin, Htrans, Hwdata, Haddr);
input Hclk, Hresetn, Hreadyout;
reg [2:0] Hburst;
input [1:0] Hresp;
input [31:0] Hrdata;
integer i;
output reg Hwrite, Hreadyin;
output reg [1:0] Htrans;
output reg [31:0] Hwdata, Haddr;

reg [2:0] Hsize;
parameter SEQ=2'b01;
parameter NSEQ=2'b10;
parameter IDLE=3'b000;
parameter INCR4=3'b001;
parameter Wrap4=3'b010;
parameter BYTE= 3'b000;
parameter HWORD=3'b001;

task single_read();
begin
@(posedge Hclk)
begin
#1;
Haddr = 32'h8000_0001;
Hwrite = 0;
Hreadyin = 1;
Htrans = 2'b10;
Hburst =3'b000;
end

@(posedge Hclk)
begin
#1;
//Hreadyin = 0;
Htrans = 2'b00;
end
end
endtask

task single_write();
begin
@(posedge Hclk)
begin 
#1;
Haddr = 32'h8000_1001;
Hwrite = 1;
Hreadyin = 1;
Htrans = 2'b10;
Hburst = 3'b000;
end

@(posedge Hclk)
begin 
#1;
Htrans = 2'b00;
Hwdata = 32'h8000_0111;
//Hreadyin =1;
end
end
endtask

task burst_write();
begin
@(posedge Hclk)
#1
begin 
Hreadyin=1'b1;
Hwrite=1'b1;
Haddr=32'h8000_1000;
Hburst=INCR4;
Hsize=3'b000;
Htrans=NSEQ;
end
case(Hsize)
BYTE: begin
	case(Hburst)
	INCR4 : begin
		wait(Hreadyout)
	        @(posedge Hclk)
		Hwdata={$random}*256;
		Htrans=SEQ;
		Haddr=Haddr+3'd4;
		wait(Hreadyout)
		@(posedge Hclk)
		Hwdata={$random}*256;

		for(i=0;i<2;i=i+1)
		begin
		Htrans=SEQ;
		Haddr=Haddr+3'd4;
		wait(Hreadyout)
		@(posedge Hclk)
		Hwdata={$random}*256;
		end
		Htrans=IDLE;
		end
	Wrap4: begin
		wait(Hreadyout)
	        @(posedge Hclk)
		Hwdata={$random}*256;
		Htrans=SEQ;
		{Haddr[31:2],Haddr[1:0]}={Haddr[31:2],{Haddr[1:0]+1'b1}};
		wait(Hreadyout)
		@(posedge Hclk)
		Hwdata={$random}%256;
		for(i=0;i<2;i=i+1)
		begin
		Htrans=SEQ;
		{Haddr[31:2],Haddr[1:0]}={Haddr[31:2],{Haddr[1:0]+1'b1}};
		wait(Hreadyout)
		@(posedge Hclk)
		Hwdata={$random}%256;
		end
		Htrans=IDLE;
		end
                endcase
		end
HWORD: begin
      case(Hburst)
	INCR4: begin
		wait(Hreadyout)
	        @(posedge Hclk)
		Hwdata={$random}%256;
		Htrans=SEQ;
		Haddr=Haddr+3'd2;
		wait(Hreadyout)
		@(posedge Hclk)
		Hwdata={$random}%256;
		for(i=0;i<2;i=i+1)
		begin
		Htrans=SEQ;
		Haddr=Haddr+3'd2;
		wait(Hreadyout)
		@(posedge Hclk)
		Hwdata={$random}%256;
		end
		Htrans=IDLE;
		end
	Wrap4: begin
		wait(Hreadyout)
	        @(posedge Hclk)
		Hwdata={$random}%256;
		Htrans=SEQ;
		{Haddr[31:2],Haddr[1:0]}={Haddr[31:2],{Haddr[1:0]+1'b1}};
		wait(Hreadyout)
		@(posedge Hclk)
		Hwdata={$random}%256;
		for(i=0;i<2;i=i+1)
		begin
		Htrans=SEQ;
		{Haddr[31:2],Haddr[1:0]}={Haddr[31:2],{Haddr[1:0]+1'b1}};
		wait(Hreadyout)
		@(posedge Hclk)
		Hwdata={$random}%256;
		end
		Htrans=IDLE;
		end
      endcase
end
endcase
end
endtask
endmodule
