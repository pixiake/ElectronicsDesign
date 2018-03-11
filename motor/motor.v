module motor(clk,model_s,in,motor_out,model_o);

input clk;
input [1:0] model_s;
input [5:0] in;
output [9:0] motor_out;
output [1:0]model_o;

reg [9:0] motor_out;
//reg [1:0] model_s;
reg [1:0]model_o;

//reg [3:0] cnt;

always@(posedge clk)
begin

   if(model_s == 2'b10)
	   begin
		      model_o <= 2'b10;
		      if(in == 6'b000001)
		      motor_out <= 10'b0000001010;// ǰ��
				else if(in == 6'b000010)
				motor_out <= 10'b0000000101;// ����
				else if(in == 6'b000011)
				motor_out <= 10'b0000001001;// ��ת
				else if(in == 6'b000100)
				motor_out <= 10'b0000000110;// ��ת
				else if(in == 6'b000101)
				motor_out <= 10'b0010011010;// ��ʽ��תȦ
				else if(in == 6'b000110)
				motor_out <= 10'b0100100101;// ��ʽ��תȦ
				else if(in == 6'b000111)
				motor_out <= 10'b1000001001;// ��ʽ��ת
				else if(in == 6'b001000)
				motor_out <= 10'b1001000110;// ��ʽ��ת�������ƣ�
				else if(in == 6'b001001)
				motor_out <= 10'b0000000000;// ֹͣ
				else if(in == 6'b001010)
				motor_out <= 10'b001000????;// ������
				else if(in == 6'b001011)
				motor_out <= 10'b000100????;// ��
				else motor_out <= 10'b0000000000;
		end
		
		else if(model_s == 2'b01)
		begin
		      model_o <= 2'b01;
		end
		
	   else if (model_s == 2'b11)
		
		begin
		      model_o <= 2'b11;
		end
	
		//else model_o <= 2'b00;

		      
end
endmodule