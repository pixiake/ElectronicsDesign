module com(clk,a,b);

input clk;
input [9:0] a;
output [1:0] b;

reg [9:0] a_buf;
reg [1:0] b;
always@(posedge clk)
begin
    a_buf <= a;
end

always@(posedge clk)
begin
   if(a_buf == 10'b1111111000)
	   begin
		    b <= 2'b10; 
		end
		else if(a_buf == 10'b0000000111)
		begin
		    b <= 2'b01; 
		end
		//else b<= 2'b00;
end
endmodule