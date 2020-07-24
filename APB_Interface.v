module APB_Interface(Penable, Pwrite, Pselx, Paddr, Pwdata, Penable_out, Pwrite_out, Pselx_out, Paddr_out, Pwdata_out,Prdata);

input Penable, Pwrite;
input [2:0] Pselx;
input [31:0] Paddr, Pwdata;
output Penable_out, Pwrite_out;
output [2:0] Pselx_out;
output [31:0] Paddr_out, Pwdata_out; 
output reg [31:0] Prdata;
assign Penable_out = Penable;
assign Pwrite_out = Pwrite;
assign Pselx_out = Pselx;
assign Paddr_out = Paddr;
assign Pwdata_out = Pwdata;

always @(*)
begin
	if(Pwrite == 0 && Penable == 1)
		Prdata = $random;
	else
		Prdata = 0;
end

endmodule
