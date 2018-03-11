/********************************��Ȩ����**************************************
**
**-------------------------------------------�ļ���Ϣ----------------------------------------------------------
** �ļ����ƣ�pwm_out.v
**--------------------------------------�޸��ļ��������Ϣ--------------------------------------------------
** �޸��ˣ�
** �޸����ڣ�		
** �汾�ţ�
** �޸����ݣ�
**
*******************************************************************************/

module pwm_right_auto(clk,led);
input clk;

output led;

reg [32:0] count;
reg [9:0] pwm_count;
reg flag;
reg pwm_flag;
always @(posedge clk)
begin
	count=count+1'b1;
	if (count[13:4] < pwm_count)
		pwm_flag=1;
	else
		pwm_flag=0;
	if (count[15] == 1'b1)
		begin
		if (flag == 1'b1)
		begin
			flag= 1'b0;
			/*if (key == 2'b01) 
				pwm_count=(pwm_count+10'b0000000001);
			else if (key == 2'b10)
				pwm_count=(pwm_count-10'b0000000001);
				else pwm_count=pwm_count;*/
				pwm_count = 10'b1111111000;
			end
		end
	else
	flag= 1'b1;
end
assign led=pwm_flag;
endmodule
