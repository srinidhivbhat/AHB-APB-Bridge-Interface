module fsmcontroller(HCLK,HRESETn,VALID,HWDATA0,HWDATA1,HADDR0,HADDR1,TEMP,PENABLE,PWRITE,HREADOUT,PSEL,PADDR,PWDATA,HWRITE,HWRITEREG);

input VALID,HCLK;
input HWRITE,HRESETn,HWRITEREG;
/////////////---------  vector is not declared reg nex_state,state;
reg [2:0] nex_state, state;
input[31:0]HWDATA0,HWDATA1,HADDR0,HADDR1;
input[2:0]TEMP;
output reg PENABLE,HREADOUT,PWRITE;
output reg[2:0] PSEL;
output reg[31:0]PADDR,PWDATA;
reg hreadyout_temp, pwrite_temp, penable_temp;
reg [31:0] hrdata_temp, paddr_temp, pwdata_temp;
reg [2:0] pselx_temp;

parameter ST_IDLE = 3'b111;
parameter ST_READ = 3'b101;
parameter ST_WWAIT = 3'b010;
parameter ST_WRITE = 3'b001;
parameter ST_WENABLE = 3'b100;
parameter ST_WRITEP = 3'b110;
parameter ST_WENABLEP = 3'b011;
parameter ST_RENABLE = 3'b000;

always@(posedge HCLK)
begin
if(HRESETn)
state<=ST_IDLE;
else
state<=nex_state;
end

always@(state,VALID,HWRITE,HWRITEREG)
begin
nex_state=ST_IDLE;
case(state)
ST_IDLE:begin
	if(VALID==1 & HWRITE==1)
	nex_state=ST_WWAIT;
	else if(VALID==1 & HWRITE==0)
	nex_state=ST_READ;
	else
	nex_state=ST_IDLE;
	end
ST_WWAIT:begin
	if(VALID==1)
	nex_state=ST_WRITEP;
	else
	nex_state=ST_WRITE;
	end
ST_WRITEP:begin
	if(VALID==1)
	nex_state=ST_WENABLEP;
	else
	nex_state=ST_WENABLE;
	end
ST_WRITE:begin
	if(VALID==0)
	nex_state=ST_WENABLE;
	else
	nex_state=ST_WENABLEP;
	end
ST_WENABLEP:begin
	if(VALID==1 & HWRITEREG==1)
	nex_state=ST_WRITEP;
	else if(VALID==0 & HWRITEREG==1)
	nex_state=ST_WRITE;
	else 
	nex_state=ST_READ;
	end
ST_WENABLE:begin
	if(VALID==1 & HWRITE==0)
	nex_state=ST_READ;
	else if(VALID==1 & HWRITE==1)
	nex_state=ST_WWAIT;
	else
	nex_state=ST_IDLE;
	end
ST_READ:begin
	if(VALID==1 & HWRITE==0)
	nex_state<=ST_READ;
	else if(VALID==1 & HWRITE==1)
	nex_state=ST_WWAIT;
	else
	nex_state=ST_IDLE;
	end
ST_RENABLE: begin
	if(VALID==1 &HWRITE==0)
	nex_state=ST_READ;
	else if(VALID==1 & HWRITE==1)
	nex_state=ST_WWAIT;
	else
	nex_state=ST_IDLE;
	end 
endcase
end

always@(*)
begin
{hreadyout_temp, penable_temp, pwrite_temp,  pselx_temp, paddr_temp, pwdata_temp, hrdata_temp} = 0;
 case(state)
ST_IDLE: begin
	hreadyout_temp = 1;
	//pwrite_temp = 1;
	penable_temp=0;
	pselx_temp=0;
	end
ST_READ: begin
	paddr_temp = HADDR0;
	pselx_temp = TEMP;
	hreadyout_temp = 0;
	end
ST_WWAIT: begin
	hreadyout_temp = 1;
	end	
ST_WRITE: begin 
	paddr_temp = HADDR0;
	pselx_temp = TEMP;	
	pwrite_temp = 1;
	penable_temp = 1;
	hreadyout_temp = 1;
	pwdata_temp = HWDATA0;  //first piplined data
	end
ST_WENABLE: begin
	penable_temp = 1;
	pwrite_temp = 1;  //signal not included
	pwdata_temp = HWDATA0;
	paddr_temp = HADDR1;
	pselx_temp = TEMP;
	hreadyout_temp = 1;
	end
ST_WRITEP: begin
	paddr_temp = HADDR0;
	pselx_temp = TEMP;
	pwrite_temp = 1;
	penable_temp = 1;
	pwdata_temp = HWDATA0;
	hreadyout_temp = 1;
	end
ST_WENABLEP: begin 
	hreadyout_temp = 1;
	pwrite_temp = 1;
	penable_temp = 1;
	pwdata_temp = HWDATA0;
	paddr_temp = HADDR1;
	pselx_temp = TEMP;
	end
ST_RENABLE: begin
	penable_temp = 1;
	paddr_temp = HADDR1;
	pselx_temp = TEMP;
	hreadyout_temp = 1;
	end
endcase
end

always@(posedge HCLK)
begin
if (HRESETn)
{PENABLE,PWRITE,PSEL,PADDR,PWDATA,HREADOUT} = 0;
else
PENABLE <= penable_temp;
PWRITE <= pwrite_temp;
PSEL <= pselx_temp;
PADDR <= paddr_temp;
PWDATA <= pwdata_temp;
HREADOUT <= hreadyout_temp;
end
endmodule



