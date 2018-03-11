module disp(clk,ina,inb,inc,ind,ena,enb,enc,en,mo,pwm_s,led_s);

input clk;
input ena,enb,enc,en;
input [19:0]ina,inb,inc,ind;
output [3:0]mo;
output [1:0]pwm_s;
output led_s;

reg [3:0]mo;
reg [19:0]ina_buf,inb_buf,inc_buf,ind_buf;
reg [1:0] pwm_s;
reg led_s;

always@(posedge clk)
begin
if(ena == 1)
  begin
    ina_buf <= ina ;
  end
end

always@(posedge clk)
begin
if(enb == 1)
  begin
    inb_buf <= inb ;
  end
end

always@(posedge clk)
begin
if(enc == 1)
  begin
    inc_buf <= inc ;
  end
end

always@(posedge clk)
begin
if(en == 1)
  begin
    ind_buf <= ind ;
  end
end


always @ (posedge clk)
begin
     
	   if(ina_buf < 90000)
	   begin
	   mo <= 4'b0101;
		pwm_s <= 2'b01;
		end
		else if(inb_buf < 90000)
		begin
		mo <= 4'b1010;
		pwm_s <= 2'b01;
		end
		else if(inc_buf < 90000)
		begin
		mo <= 4'b0110;
		pwm_s <= 2'b10;
		end
		else if(ind_buf < 90000)
      begin
		mo <= 4'b1001;
		pwm_s <= 2'b11;
      end
		else 
		begin
		mo <= 4'b0000;
		pwm_s <= 2'b00;
      led_s <= 1'b0;
		end
end



endmodule
