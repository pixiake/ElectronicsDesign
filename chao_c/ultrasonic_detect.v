///////////////////////////////////////////////////////////////////////////////////
//功能： 接收外部开始超声检测的触发信号Ultra_start，Ultra_start高电平时开始检测，
//程序产生超声波模块需要的信号，测距完成后，输出有效信号Ultra_valid，同时外部可以从存储器Ultra_data中读取数据.
//超声波输出的高电平脉宽数值Ultra_data，高电平时间=Ultra_data * 0.02 us = Ultra_data * 2 * 10-E8 s 
//根据超声波的性能，最远检测距离为4m，那么实际Ultra_data[19:0] 最大值为20'h927C0, 如果输出超过这个值，就是无效的数据。
//艾曼电子版权所有  http://amfpga.taobao.com
//2011.11.1
//REB 1.1
//////////////////////////////////////////////////////////////////////////////////

module	ultrasonic_detect(
		clk,
		reset_n,
		Ultra_start,
		Ultra_valid,
		Ultra_data,
		Ultra_Trig,
		Ultra_Echo
);

input	clk;			//50MHZ 时钟输入
input	reset_n;
//外部控制接口
input	Ultra_start;	//高电平开始超声波测距
output	Ultra_valid;	//输出高电平时，超声波检测数据输出有效
output	reg [19:0]	Ultra_data;	//超声波输出的高电平脉宽数值，高电平时间=Ultra_data * 0.02 us = Ultra_data * 2 * 10-E8 s 
//ultrasonic interface
output	Ultra_Trig;		//跟超声波模块连接，输出大于10us 的高电平超声波触发信号
input	Ultra_Echo;		//跟超声波模块连接，接收超声波模块的返回高电平信号,
						//程序通过读取高电平脉冲的时间来计算距离
/////////////////////////////////////////////////////////////////////////////////////////////////////
//检测Ultra_start信号的上升沿
/////////////////////////////////////////////////////////////////////////////////////////////////////
reg	Ultra_start_reg1;
reg	Ultra_start_reg2;
wire Ultra_start_rassing;	
always @( posedge clk )
begin
	Ultra_start_reg1	<=	Ultra_start;
	Ultra_start_reg2	<=	Ultra_start_reg1;
end
//检测Ultra_start 信号的上升沿，如果是上升沿，Ultra_start_rassing 输出为高电平，维持一个clk的高电平时间
assign	Ultra_start_rassing	=	Ultra_start_reg1 & (~Ultra_start_reg2);

//////////////////////////////////////////////////////////////////////////////////////////////////////
//检测Ultra_Echo信号的上升沿和下降沿
//////////////////////////////////////////////////////////////////////////////////////////////////////
reg	Ultra_Echo_reg1;
reg Ultra_Echo_reg2;
wire	Ultra_Echo_rassing;
wire	Ultra_Echo_falling;
always @( posedge clk )
begin
	Ultra_Echo_reg1	<=	Ultra_Echo;
	Ultra_Echo_reg2	<=	Ultra_Echo_reg1;
end
//检测Ultra_Echo 信号的上升沿，如果是上升沿，Ultra_Echo_rassing 输出为高电平，维持一个clk的高电平时间
assign	Ultra_Echo_rassing	=	Ultra_Echo_reg1 & (~Ultra_Echo_reg2);
//检测Ultra_Echo 信号的下降沿，如果是下降沿，Ultra_Echo_falling 输出为高电平，维持一个clk的高电平时间
assign	Ultra_Echo_falling	=	Ultra_Echo_reg2 & (~Ultra_Echo_reg1);

/////////////////////////////////////////////////////////////////////////////////////////////////////
//超声波Ultra_Trig信号生成，Ultra_Echo信号脉冲高电平宽度检测
/////////////////////////////////////////////////////////////////////////////////////////////////////
reg	[8:0]	count_10us;
reg	[2:0]	state;
reg	Ultra_Trig;
reg	[19:0]	Ultra_Echo_count;
reg	Ultra_valid;
always @( posedge clk or negedge reset_n )
begin
	if (!reset_n)
		begin
		Ultra_Echo_count	<=	20'h0000;
		state	<=	3'b000;
		Ultra_valid	<=	1'b0;
		count_10us	<=	9'h000;
		end
	else 
	case(state)
		3'b000	:	
		if (Ultra_start_rassing)
		begin
			Ultra_Trig	<=	1'b1;	//超声波开始触发信号
			state	<=	3'b001;
			Ultra_valid	<=	1'b0;	//关闭超声数据有效
		end
		else
			begin
			Ultra_Trig	<=	1'b0;
			state	<=	3'b000;
			end
		3'b001	:	begin
			count_10us	<=	count_10us	+	9'b1;	
			if(	count_10us	>=	9'h1FF)		//保持Ultra_Trig高电平维持时间大于10us
				begin
				count_10us	<=	9'h000;	
				state	<=	3'b011;
				Ultra_Trig	<=	1'b0;	//Ultra_Trig信号已经为此10us以上，将该信号拉低
				end
			else
				state	<=	3'b001;
			end
		3'b011	:
			if( Ultra_Echo_rassing )	//等待超声波 Ultra_Echo 信号上升沿，如果是上升沿，就跳转到下个状态对Ultra_Echo信号的高电平时间进行计数。
				begin
				state	<=	3'b010;
				end
			else
				state	<=	3'b011;
		3'b010	:
			begin
				Ultra_Echo_count[19:0]	<=	Ultra_Echo_count[19:0]	+	20'b1;//对Ultra_Echo信号的高电平时间进行计数。
				if( Ultra_Echo_falling )	//如果是Ultra_Echo信号的下降沿，则停止计数，将计数值保存
					begin
					state	<=	3'b110;
					Ultra_data[19:0]	<=	Ultra_Echo_count[19:0];	//将数据保存到输出寄存器中
					end
			end
		3'b110	:	
			begin
					Ultra_Echo_count[19:0]	<=	20'h0000;	//将计数器清零
					Ultra_valid	<=	1'b1;	//数据稳定后，超声波数据有效信号使能
					state	<=	3'b000;
			end
		default	:	state	<=	3'b000;
		endcase
end

endmodule

