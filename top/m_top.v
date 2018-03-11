module  m_select(m_s,motor_a,motor_b,pwm_a1,pwm_a2,pwm_b1,pwm_b2,led_a,led_b,mo_out,pwm_out1,pwm_out2,led_out);


input [1:0]m_s;
input [3:0]motor_a,motor_b;
input pwm_a1;
input pwm_a2;
input pwm_b1;
input pwm_b2;
input led_a,led_b;

output [3:0]mo_out;
output pwm_out1;
output pwm_out2;
output led_out;

reg [3:0]mo_out;   
reg pwm_out1;
reg pwm_out2;
reg led_out;

always@(m_s or motor_a or motor_b or pwm_a1 or pwm_a2 or pwm_b1 or pwm_b2 or led_a or led_b)

case(m_s)
   2'b10: begin
	       mo_out[3:0] = motor_a[3:0];
		    pwm_out1 =  pwm_a1;
			 pwm_out2 =  pwm_a2;
		    led_out = led_a;
			 end                     //人工控制
	2'b01: begin
	       mo_out[3:0] = motor_b[3:0];
		    pwm_out1 =  pwm_b1;
			 pwm_out2 =  pwm_b2;
		    led_out = led_b;
			 end	                   //自动控制
   2'b01: begin
	       mo_out[3:0] = 4'b0;
		    pwm_out1 =  0;
			 pwm_out2 =  0;
		    led_out = 1;
			 end	    
  default: 	begin
	       mo_out[3:0] = 4'b0;
		    pwm_out1 =  0;
			 pwm_out2 =  0;
		    led_out = 1;
			 end		 
  endcase
endmodule