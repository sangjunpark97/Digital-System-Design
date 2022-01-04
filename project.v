module project(
	KEY, 
	SW,
	CLOCK_50,
	LEDR,
	HEX0,
	HEX1,
	HEX2,
	HEX3,
	HEX4,
	HEX5,
	GPIO_0,
	GPIO_1

);
parameter I=4; //soc보드 기준 외부에서 받는 input parameter 
parameter O=1; //soc보드 기준 외부에서 받는 output parameter
input	[1:0]	 KEY; //KEY[1]: clock모듈 preset KEY[0]: clock모듈 reset, GPIO핀 입출력 값 reset 
input 	[9:0]	 SW; //SW[9:8]: clock모듈에서 시 분 초 중 preset 할 항목을 select, SW[4:0]: clock 모듈 preset data
input		 CLOCK_50;
input      [I-1:0]      GPIO_0; //soc보드 기준 input
output    [O-1:0]    GPIO_1; //soc보드 기준 output 

output	[6:0]	HEX0,HEX1,HEX2,HEX3,HEX4,HEX5; // HEX5: 시단위 HEX4: 10분단위 HEX3: 1분단위 HEX2: 10초단위 HEX1: 1초단위 HEX0: 0.1초단위
output	[9:0]	LEDR;




wire			clock_En,timer_En, stop_watch_en,oEN;
wire		[3:0]  	state;
wire		[6:0]	c_HEX0,c_HEX1,c_HEX2,c_HEX3,c_HEX4,c_HEX5; //clock 모듈 출력 data 저장
wire		[6:0]	t_HEX0,t_HEX1,t_HEX2,t_HEX3,t_HEX4,t_HEX5; //timer 모듈 출력 data 저장
wire		[6:0]	s_HEX0,s_HEX1,s_HEX2,s_HEX3,s_HEX4,s_HEX5; //stop_watch 모듈 출력 data 저장

wire 	 	[I-1:0] 	gpio_0_tmp; //아두이노에서 soc보드로 입력되는 값을 저장
wire 	 	[O-1:0] 	gpio_1_tmp; //timer alarm
wire 	 	[0:0] 	gpio_1_1_tmp; //clock alarm
assign clock_En = state == 3'b000 ?	1'b1:1'b0;
assign timer_En = state == 3'b001 ?	1'b1:1'b0;
assign stop_watch_en = state == 3'b010 ? 1'b1 : 1'b0;
//controller 모듈에서 지정한 state에 맞게 clock,timer,stop_watch가 작동할 수 있도록 각각 enable 신호 설정

D_REG#(.WL(I))
D_gpio_0(.iRSTn(KEY[0]),.iCLK(CLOCK_50),.iDATA(GPIO_0[I-1:0]),.iEN(1'b1),.oDATA(gpio_0_tmp[I-1:0]));
D_REG#(.WL(O))
D_gpio_1(.iRSTn(KEY[0]),.iCLK(CLOCK_50),.iDATA(gpio_1_1_tmp[0]|gpio_1_tmp[O-1:0]),.iEN(1'b1),.oDATA(GPIO_1[O-1:0]));
//soc보드와 아두이노의 입출력 사이에 클럭을 맞추기 위함
		 
Controller
control(
	.key(~gpio_0_tmp[3]),
	.state(state)
); //gpio_0_tmp로 state변경

clock
clock_0( 
	.KEY(~gpio_0_tmp[1:0]),
	.sw(SW),
	.EN(clock_En),
	.clk(CLOCK_50),
	.oEN(oEN),
	.led(LEDR[9:0]),
	.hex0(c_HEX0),
	.hex1(c_HEX1),
	.hex2(c_HEX2),
	.hex3(c_HEX3),
	.hex4(c_HEX4),
	.hex5(c_HEX5)
	,.alarm(gpio_1_tmp[0:0]),.key(KEY[1:0]))
;

Timer
timer_0(.Oalarm(gpio_1_1_tmp[0:0]),
	.key(~gpio_0_tmp[2:0]),
	.sw(SW),
	.EN(timer_En),
	.clk(CLOCK_50),
	.hex0(t_HEX0),
	.hex1(t_HEX1),
	.hex2(t_HEX2),
	.hex3(t_HEX3),
	.hex4(t_HEX4),
	.hex5(t_HEX5)
);
stop_watch
stop_watch0(
	.key(~gpio_0_tmp[1:0]),
	.sw(SW[1:0]),
	.EN(stop_watch_en),
	.clk(CLOCK_50),
	.hex0(s_HEX0),
	.hex1(s_HEX1),
	.hex2(s_HEX2),
	.hex3(s_HEX3),
	.hex4(s_HEX4),
	.hex5(s_HEX5)
);


assign HEX0 = state==3'b000 ? c_HEX0:
					state == 3'b001 ?	t_HEX0:
				  state == 3'b010 ?  s_HEX0:7'b1000111;
				  
				 
				  
assign HEX1 = state==3'b000 ? c_HEX1:
					state == 3'b001 ?	t_HEX1:
				  state == 3'b010 ?  s_HEX1:7'b1000111;
				  
assign HEX2 =  state==3'b000 ? c_HEX2:
					state == 3'b001 ?	t_HEX2:
				  state == 3'b010 ?  s_HEX2:7'b1000111;
				 
				  
assign HEX3 =  state==3'b000 ? c_HEX3:
					state == 3'b001 ?	t_HEX3:
				  state == 3'b010 ?  s_HEX3:7'b1000111;
				  
				 
assign HEX4 = state==3'b000 ? c_HEX4:
					state == 3'b001 ?	t_HEX4:
				  state == 3'b010 ?  s_HEX4:7'b1000111;
				 
				  
assign HEX5 = state==3'b000 ? c_HEX5:
					state == 3'b001 ?	t_HEX5:
				  state == 3'b010 ?  s_HEX5:7'b1000111;
				 
				 

						 
//지정한 state에 맞는 mode의 출력값이 soc보드로 출력될 수 있도록 설정

endmodule
