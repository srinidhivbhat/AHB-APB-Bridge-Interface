module top_tb();
reg Hclk,Hresetn;
wire Hreadyout;
wire Penable_out,Pwrite_out;
wire [2:0]Pselx_out;
wire [31:0] Paddr_out,Pwdata_out;
wire [31:0]Prdata;

wire Hwrite,Hreadyin;
wire [1:0]Htrans;
wire [31:0]Hwdata,Haddr;
wire [1:0]Hresp;
wire [31:0]Paddr,Pwdata,Hrdata;
wire Penable,Pwrite;
wire [2:0]Pselx;
ahbmaster ahb(Hclk, Hresetn,Hresp, Hrdata, Hreadyout, Hwrite, Hreadyin, Htrans, Hwdata, Haddr);
bridgetop bt(.HCLK(Hclk),.HRESET(Hresetn),.PENABLE(Penable),.PWRITE(Pwrite),.PSEL(Pselx),.PADDR(Paddr),.PWDATA(Pwdata_out),.HREADYOUT(Hreadyout),.HWRITE(hwrite),.HREADYIN(Hreadyin),.HWDATA(Hwdata),.HADDR(Haddr),.HTRANS(Htrans));
APB_Interface apb(Penable, Pwrite,Pselx, Paddr, Pwdata, Penable_out, Pwrite_out, Pselx_out, Paddr_out, Pwdata_out,Prdata);

initial 
begin
Hclk=0;
forever #10 Hclk=~Hclk;
end
initial
begin
ahb.single_write;
#200;
end
endmodule