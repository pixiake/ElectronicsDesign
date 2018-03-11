///////////////////////////////////////////////////////////////////////////////////
//���ܣ� �����ⲿ��ʼ�������Ĵ����ź�Ultra_start��Ultra_start�ߵ�ƽʱ��ʼ��⣬
//�������������ģ����Ҫ���źţ������ɺ������Ч�ź�Ultra_valid��ͬʱ�ⲿ���ԴӴ洢��Ultra_data�ж�ȡ����.
//����������ĸߵ�ƽ������ֵUltra_data���ߵ�ƽʱ��=Ultra_data * 0.02 us = Ultra_data * 2 * 10-E8 s 
//���ݳ����������ܣ���Զ������Ϊ4m����ôʵ��Ultra_data[19:0] ���ֵΪ20'h927C0, �������������ֵ��������Ч�����ݡ�
//�������Ӱ�Ȩ����  http://amfpga.taobao.com
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

input	clk;			//50MHZ ʱ������
input	reset_n;
//�ⲿ���ƽӿ�
input	Ultra_start;	//�ߵ�ƽ��ʼ���������
output	Ultra_valid;	//����ߵ�ƽʱ��������������������Ч
output	reg [19:0]	Ultra_data;	//����������ĸߵ�ƽ������ֵ���ߵ�ƽʱ��=Ultra_data * 0.02 us = Ultra_data * 2 * 10-E8 s 
//ultrasonic interface
output	Ultra_Trig;		//��������ģ�����ӣ��������10us �ĸߵ�ƽ�����������ź�
input	Ultra_Echo;		//��������ģ�����ӣ����ճ�����ģ��ķ��ظߵ�ƽ�ź�,
						//����ͨ����ȡ�ߵ�ƽ�����ʱ�����������
/////////////////////////////////////////////////////////////////////////////////////////////////////
//���Ultra_start�źŵ�������
/////////////////////////////////////////////////////////////////////////////////////////////////////
reg	Ultra_start_reg1;
reg	Ultra_start_reg2;
wire Ultra_start_rassing;	
always @( posedge clk )
begin
	Ultra_start_reg1	<=	Ultra_start;
	Ultra_start_reg2	<=	Ultra_start_reg1;
end
//���Ultra_start �źŵ������أ�����������أ�Ultra_start_rassing ���Ϊ�ߵ�ƽ��ά��һ��clk�ĸߵ�ƽʱ��
assign	Ultra_start_rassing	=	Ultra_start_reg1 & (~Ultra_start_reg2);

//////////////////////////////////////////////////////////////////////////////////////////////////////
//���Ultra_Echo�źŵ������غ��½���
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
//���Ultra_Echo �źŵ������أ�����������أ�Ultra_Echo_rassing ���Ϊ�ߵ�ƽ��ά��һ��clk�ĸߵ�ƽʱ��
assign	Ultra_Echo_rassing	=	Ultra_Echo_reg1 & (~Ultra_Echo_reg2);
//���Ultra_Echo �źŵ��½��أ�������½��أ�Ultra_Echo_falling ���Ϊ�ߵ�ƽ��ά��һ��clk�ĸߵ�ƽʱ��
assign	Ultra_Echo_falling	=	Ultra_Echo_reg2 & (~Ultra_Echo_reg1);

/////////////////////////////////////////////////////////////////////////////////////////////////////
//������Ultra_Trig�ź����ɣ�Ultra_Echo�ź�����ߵ�ƽ��ȼ��
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
			Ultra_Trig	<=	1'b1;	//��������ʼ�����ź�
			state	<=	3'b001;
			Ultra_valid	<=	1'b0;	//�رճ���������Ч
		end
		else
			begin
			Ultra_Trig	<=	1'b0;
			state	<=	3'b000;
			end
		3'b001	:	begin
			count_10us	<=	count_10us	+	9'b1;	
			if(	count_10us	>=	9'h1FF)		//����Ultra_Trig�ߵ�ƽά��ʱ�����10us
				begin
				count_10us	<=	9'h000;	
				state	<=	3'b011;
				Ultra_Trig	<=	1'b0;	//Ultra_Trig�ź��Ѿ�Ϊ��10us���ϣ������ź�����
				end
			else
				state	<=	3'b001;
			end
		3'b011	:
			if( Ultra_Echo_rassing )	//�ȴ������� Ultra_Echo �ź������أ�����������أ�����ת���¸�״̬��Ultra_Echo�źŵĸߵ�ƽʱ����м�����
				begin
				state	<=	3'b010;
				end
			else
				state	<=	3'b011;
		3'b010	:
			begin
				Ultra_Echo_count[19:0]	<=	Ultra_Echo_count[19:0]	+	20'b1;//��Ultra_Echo�źŵĸߵ�ƽʱ����м�����
				if( Ultra_Echo_falling )	//�����Ultra_Echo�źŵ��½��أ���ֹͣ������������ֵ����
					begin
					state	<=	3'b110;
					Ultra_data[19:0]	<=	Ultra_Echo_count[19:0];	//�����ݱ��浽����Ĵ�����
					end
			end
		3'b110	:	
			begin
					Ultra_Echo_count[19:0]	<=	20'h0000;	//������������
					Ultra_valid	<=	1'b1;	//�����ȶ��󣬳�����������Ч�ź�ʹ��
					state	<=	3'b000;
			end
		default	:	state	<=	3'b000;
		endcase
end

endmodule

