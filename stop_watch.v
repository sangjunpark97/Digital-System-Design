module stop_watch(
	key,
	EN,
	clk,
	hex0,
	hex1,
	hex2,
	hex3,
	hex4,
	hex5
);

input		[1:0]	key;
input			clk,EN;

output	 	[6:0]	hex0,hex1,hex2,hex3,hex4,hex5;

wire EN_5M, EN_100MS, EN_10MS, EN_1S, EN_1MIN, EN_10MIN, EN_10S;
wire 	[18:0]	O_5M;
wire	[3:0]		O_100MS, O_10MS,O_1S, O_1MIN;
wire	[2:0]		O_10S, O_10MIN;
wire				start,reset,start_key;

assign reset = EN? key[0] : 1'b1;
assign start_key = EN? key[1]  : 1'b1;


T_FF 	
Start_0(
	.iRSTn(reset),
	.iCLK(start_key),
	.iDATA(1'b1),
	.oDATA(start)
);

COUNTER_LAB // 0.001초 단위 카운터
#(.n(19),.k(500000))
COUNTER_5M(
	.iCLK(clk),
	.iEN(start),
	.iRSTn(reset),
	.oEN(EN_5M),
	.oCNT(O_5M)
);

COUNTER_LAB// 0.01초 단위 카운터
#(.n(4),.k(10))
COUNTER_10MS(
	.iCLK(clk),
	.iEN(EN_5M),
	.iRSTn(reset),
	.oEN(EN_10MS),
	.oCNT(O_10MS)
);

COUNTER_LAB// 0.1초 단위 카운터
#(.n(4),.k(10))
COUNTER_100MS(
	.iCLK(clk),
	.iEN(EN_10MS),
	.iRSTn(reset),
	.oEN(EN_100MS),
	.oCNT(O_100MS)
);

COUNTER_LAB// 1초 단위 카운터
#(.n(4),.k(10))
COUNTER_1S(
	.iCLK(clk),
	.iEN(EN_100MS),
	.iRSTn(reset),
	.oEN(EN_1S),
	.oCNT(O_1S)
);

COUNTER_LAB// 10초 단위 카운터
#(.n(3),.k(6))
COUNTER_10S(
	.iCLK(clk),
	.iEN(EN_1S),
	.iRSTn(reset),
	.oEN(EN_10S),
	.oCNT(O_10S)
);

COUNTER_LAB 1분 단위 카운터
#(.n(4),.k(10))
COUNTER_1M(
	.iCLK(clk),
	.iEN(EN_10S),
	.iRSTn(reset),
	.oEN(EN_1MIN),
	.oCNT(O_1MIN)
);

COUNTER_LAB 10분 단위 카운터
#(.n(3),.k(6))
COUNTER_10M(
	.iCLK(clk),
	.iEN(EN_1MIN),
	.iRSTn(reset),
	.oEN(EN_10MIN),
	.oCNT(O_10MIN)
);

Segment_Decoder
Hex0(
	.iDATA(O_10MS),
	.oDATA(hex0)
);

Segment_Decoder
Hex1(
	.iDATA(O_100MS),
	.oDATA(hex1)
);

Segment_Decoder
Hex2(
	.iDATA(O_1S),
	.oDATA(hex2)
);

Segment_Decoder
Hex3(
	.iDATA(O_10S),
	.oDATA(hex3)
);

Segment_Decoder
Hex4(
	.iDATA(O_1MIN),
	.oDATA(hex4)
);

Segment_Decoder
Hex5(
	.iDATA(O_10MIN),
	.oDATA(hex5)
);


endmodule
