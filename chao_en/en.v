module  en(clk,A,en);

input clk;
input [1:0]A;
output en;

//reg [1:0]mod;
reg [32:0]count;
reg en_buf;

always@(posedge clk)
begin
   if(A == 2'b01)
	begin
   count <= count + 1'b1;
	if(count == 1000000)
	     count <= 0;
	else if(count > 0 && count < 10000)
	     en_buf <= 1;
		 else en_buf <= 0;
	end
end

assign en = en_buf;
endmodule
