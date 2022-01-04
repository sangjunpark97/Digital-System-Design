module controller(
	key,
	state
);

input		key;

output	[3:0]	state;

reg		[3:0]	current_state, next_state;

parameter	[3:0]	A = 3'b000 , B = 3'b001, C =3'b010; //A: clock mode B: timer mode C: stop_watch mode

always @(posedge key)
begin
	current_state <= next_state; // key를 누르면 저장되어있는 다음 상태가 현재상태로 대입된다
end

always@* // 현재상태가 A일때 key 누르면 B가, 현재상태가 B일때 key 누르면 C가, 현재상태가 C일때 key 누르면 A가 다음 상태에 저장 
begin
	case(current_state)
		A : next_state = B;
		B : next_state = C;
		C : next_state = A;
		default : next_state = A;
	endcase
end

assign state = current_state;

endmodule