module pll0(clk,c0,c1,c2,c3,c4);

input clk;
output c0,c1,c2,c3,c4;

pll	pll_inst (
	.inclk0 ( clk ),
	.c0 ( c0 ),
	.c1 ( c1 ),
	.c2 ( c2 ),
	.c3 ( c3 ),
	.c4 ( c4 )
	);
endmodule
