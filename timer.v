module Timer(
 	Oalarm,
	key,
	sw,
	EN,
	clk,
	led,
	hex0,
	hex1,
	hex2,
	hex3,
	hex4,
	hex5
);

input	[2:0]	key; // reset, preset 등 clock 통제용 key
input 	[9:0]	sw; //preset data 입력
input		clk,EN;

output	[6:0]	hex0,hex1,hex2,hex3,hex4,hex5;
output	[9:0]	led;
output  		Oalarm; //0까지 카운트 되면 1출력

wire EN_5M, EN_100MS, EN_10MS, EN_1S, EN_1MIN, EN_10MIN, EN_10S;
wire Z_100MS, Z_10MS, Z_1S, Z_1MIN, Z_10MIN, Z_10S;
wire 	[18:0]	O_5M;
wire	[3:0]	O_100MS, O_10MS,O_1S, O_1MIN;
wire	[2:0]	O_10S, O_10MIN; //카운터 출력값
wire		preset1,preset2,preset3,preset4;
wire		start,reset,preset,start_key;
wire	[2:0]	preset_data;
wire	[3:0]	preset_data9;

assign preset2 = (sw[9:8] == 2'b01) ? preset : 1'b1;
assign preset3 = (sw[9:8] == 2'b10) ? preset : 1'b1;
assign preset4 = (sw[9:8] == 2'b11) ? preset : 1'b1;
assign preset1 = (sw[9:8] == 2'b00) ? preset : 1'b1;  //sw[9:8] 로 시,분,초 중 preset 할 항목을 select


assign reset = EN? key[0] : 1'b1;
assign preset = EN? key[1] : 1'b1;
assign start_key = EN? key[2] : 1'b1;
assign preset_data = (sw[9:8] == 2'b01 || sw[9:8] == 2'b11) ? ((sw[2:0] > 3'd5 )? 3'd5 : sw[2:0] ) : sw[2:0];
//0~5범위 preset data: 10분단위, 10초단위
assign preset_data9 = (sw[9:8] == 2'b00 || sw[9:8] == 2'b10) ? ((sw[3:0] > 4'd9 )? 3'd9 : sw[3:0] ) : sw[3:0];
//0~9범위 preset data: 1분단위, 1초단위
reg     Oalarm;

T_FF	
Start(
	.iRSTn(reset),
	.iCLK(start_key),
	.iDATA(1'b1),
	.oDATA(start)
);

COUNTER_LAB
#(.n(19),.k(500000))
COUNTER_5M(
	.iCLK(clk),
	.iEN(start),
	.iRSTn(reset),
	.oEN(EN_5M),
	.oCNT(O_5M)
);

RCOUNTER_LAB// 역카운터
#(.n(4),.k(10))
COUNTER_10MS(
	.iCLK(clk),
	.iEN(EN_5M),
	.iRSTn(reset),
	.iZERO(Z_100MS),
	.oZERO(Z_10MS),
	.oEN(EN_10MS),
	.oCNT(O_10MS)
);

RCOUNTER_LAB
#(.n(4),.k(10))
COUNTER_100MS(
	.iCLK(clk),
	.iEN(EN_10MS),
	.iRSTn(reset),
	.iZERO(Z_1S),
	.oZERO(Z_100MS),
	.oEN(EN_100MS),
	.oCNT(O_100MS)
);

RCOUNTER_PRESET
#(.n(4),.k(10))
COUNTER_1S(
	.iCLK(clk),
	.iEN(EN_100MS),
	.iRSTn(reset),
	.iPRSTn(preset1),
	.iDATA_Preset(preset_data9),
	.iZERO(Z_10S),
	.oZERO(Z_1S),
	.oEN(EN_1S),
	.oCNT(O_1S)
);

RCOUNTER_PRESET
#(.n(3),.k(6))
COUNTER_10S(
	.iCLK(clk),
	.iEN(EN_1S),
	.iRSTn(reset),
	.iPRSTn(preset2),
	.iDATA_Preset(preset_data),
	.iZERO(Z_1MIN),
	.oZERO(Z_10S),
	.oEN(EN_10S),
	.oCNT(O_10S)
);

RCOUNTER_PRESET
#(.n(4),.k(10))
COUNTER_1M(
	.iCLK(clk),
	.iEN(EN_10S),
	.iRSTn(reset),
	.iPRSTn(preset3),
	.iDATA_Preset(preset_data9),
	.iZERO(Z_10MIN),
	.oZERO(Z_1MIN),
	.oEN(EN_1MIN),
	.oCNT(O_1MIN)
);


always@(negedge O_10MS[0])
begin
if({O_10MIN,O_1MIN,O_10S,O_1S,O_100MS,O_10MS}=={21'b0,1'b1})
begin 
Oalarm<=1'b1; 
end
else begin 
Oalarm<=1'b0; 
end
end
 

RCOUNTER_PRESET
#(.n(3),.k(6))
COUNTER_10M(
	.iCLK(clk),
	.iEN(EN_1MIN),
	.iRSTn(reset),
	.iPRSTn(preset4),
	.iDATA_Preset(preset_data),
	.iZERO(1'b1),
	.oZERO(Z_10MIN),
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