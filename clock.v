module clock(
	KEY,
	sw,
	EN,
	clk,
	led,
	oEN,
	hex0,
	hex1,
	hex2,
	hex3,
	hex4,
	hex5,
 	key,
 	alarm);
	
input  	[1:0] 	KEY; //alarm설정용 KEY
input  	[1:0] 	key; // reset, preset 등 clock 통제용 key
input 	[9:0]	sw; //preset data 입력
input		clk,EN;

output	[6:0]	hex0,hex1,hex2,hex3,hex4,hex5;
output	[9:0]	led;
output		oEN;
output  	 	alarm; //설정한 시간이 되면 1출력


wire EN_5M, EN_50M, EN_100MS, EN_1S, EN_10S, EN_1MIN, EN_10MIN, EN_1H, EN_3s;
wire	[25:0]	 	O_50M;
wire 	[22:0]	 	O_5M;
wire	[3:0]		O_100MS, O_1S, O_1MIN;
wire	[2:0]		O_10S, O_10MIN;
wire	[4:0]		O_1H;
wire	[3:0]		hour;
wire	[1:0]		O_3s;
wire 	[4:0]  		alarm_1H;
wire   	[2:0]  		alarm_10MIN;
wire  	[3:0]  		alarm_1MIN;
wire			preset1,preset2,preset3;
wire			reset, preset;


reg alarm;
assign preset1 = (sw[9:8] == 2'b01) ? preset : 1'b1; 
assign preset2 = (sw[9:8] == 2'b10) ? preset : 1'b1;
assign preset3 = (sw[9:8] == 2'b11) ? preset : 1'b1; //sw[9:8] 로 시,분,초 중 preset 할 항목을 select

assign reset = EN? KEY[0]: 1'b1; //enable 신호가 입력될 때 reset=KEY[0]
assign preset = EN? KEY[1]: 1'b1; //enable 신호가 입력될 때 preset=KEY[1]

assign led[8:1] = 8'b00000000;
assign oEN = EN_1H;



D_REG
#(.WL(3))
U0
(.iRSTn(key[0]),.iCLK(key[1]),.iEN(1'b1),.iDATA(O_1MIN),.oDATA(alarm_1MIN));
D_REG
#(.WL(2))
U1
(.iRSTn(key[0]),.iCLK(key[1]),.iEN(1'b1),.iDATA(O_10MIN),.oDATA(alarm_10MIN));
D_REG
#(.WL(4))
U3
(.iRSTn(KEY[0]),.iCLK(key[1]),.iEN(1'b1),.iDATA(hour),.oDATA(alarm_1H));
//key[1] 입력시 입력 시점의 시 분 초가 알람 설정값으로 저장된다.
              

COUNTER_LAB
#(.n(23),.k(5000000))]
COUNTER_5M(
	.iCLK(clk),
	.iEN(1'b1),
	.iRSTn(reset),
	.oEN(EN_5M),
	.oCNT(O_5M)
);

COUNTER_LAB
#(.n(4),.k(10))
COUNTER_100MS(
	.iCLK(clk),
	.iEN(EN_5M),
	.iRSTn(reset),
	.oEN(EN_100MS),
	.oCNT(O_100MS)
);

COUNTER_LAB
#(.n(4),.k(10))
COUNTER_1S(
	.iCLK(clk),
	.iEN(EN_100MS),
	.iRSTn(reset),
	.oEN(EN_1S),
	.oCNT(O_1S)
);

COUNTER_LAB
#(.n(3),.k(6))
COUNTER_10S(
	.iCLK(clk),
	.iEN(EN_1S),
	.iRSTn(reset),
	.oEN(EN_10S),
	.oCNT(O_10S)
);

COUNTER_PRESET
#(.n(4),.k(10))
COUNTER_1M(
	.iCLK(clk),
	.iEN(EN_10S),
	.iRSTn(reset),
	.iPRSTn(preset1),
	.iDATA_Preset(sw[3:0]),
	.oEN(EN_1MIN),
	.oCNT(O_1MIN)
);

COUNTER_PRESET
#(.n(3),.k(6))
COUNTER_10M(
	.iCLK(clk),
	.iEN(EN_1MIN),
	.iRSTn(reset),
	.iPRSTn(preset2),
	.iDATA_Preset(sw[2:0]),
	.oEN(EN_10MIN),
	.oCNT(O_10MIN)
);

COUNTER_PRESET
#(.n(5),.k(24))
COUNTER_1H(
	.iCLK(clk),
	.iEN(EN_10MIN),
	.iRSTn(reset),
	.iPRSTn(preset3),
	.iDATA_Preset(sw[4:0]),
	.oEN(EN_1H),
	.oCNT(O_1H)
);


AM_PM
am_pm_1(
	.iDATA(O_1H),
	.oDATA(hour),
	.oLED(led[9])
);

Segment_Decoder
Hex0(
	.iDATA(O_100MS),
	.oDATA(hex0)
);

Segment_Decoder
Hex1(
	.iDATA(O_1S),
	.oDATA(hex1)
);

Segment_Decoder
Hex2(
	.iDATA(O_10S),
	.oDATA(hex2)
);

Segment_Decoder
Hex3(
	.iDATA(O_1MIN),
	.oDATA(hex3)
);

Segment_Decoder
Hex4(
	.iDATA(O_10MIN),
	.oDATA(hex4)
);

Segment_Decoder
Hex5(
	.iDATA(hour),
	.oDATA(hex5)
);
always@*
begin

if((~(alarm_1H==5'b00000)|~(alarm_10MIN==3'b000)|~(alarm_1MIN==4'b0000))&((O_1MIN==alarm_1MIN)&(O_10MIN==alarm_10MIN)&(O_1H==alarm_1H)))
begin
alarm <= 1'b1;
end
else
begin
alarm <= 1'b0;
end
//알람 설정값과 현재 시간이 같으면 alarm으로 1출력
end
endmodule
