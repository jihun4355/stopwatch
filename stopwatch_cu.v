


`timescale 1ns / 1ps


module stopwatch_cu (
    input clk,
    input reset,
    input i_clear,
    input i_runstop,
    output o_clear,
    output o_runstop
);
    

    // 1.상태 정의 (State Definition)
    parameter STOP = 2'b00, RUN = 2'b01, CLEAR = 2'b10;


    // 2. 출력 레지스터와 다음 상태값 저장 변수
        // c_state	현재 상태
        // n_state	다음 상태 (조합 논리로 계산됨)
        // runstop_reg	출력 값으로 사용할 저장용 레지스터
        // runstop_next	조합 논리에서 계산된 다음 출력 값
        // clear_reg, clear_next	위와 같은 역할 (clear 신호용)
    reg [1:0] c_state, n_state;
    reg runstop_reg, runstop_next;
    reg clear_reg, clear_next;


    // 3. 상태 레지스터 블록 (State Register Logic)
        // 클럭 상승 에지 또는 리셋 신호에서 동작합니다.


        // 리셋되면 상태를 STOP으로 초기화하고, 출력들도 모두 0으로 초기화
        // 리셋이 아니면, 클럭 상승 시점에 다음 상태(n_state)로 전이하고,
        // 출력 레지스터도 다음 값(_next)로 업데이트
    assign o_runstop = runstop_reg;
    assign o_clear = clear_reg;
    // 리셋 처리
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            c_state <= STOP;
            runstop_reg <= 1'b0;
            clear_reg <= 1'b0;
        end else begin
            c_state <= n_state;
            runstop_reg <= runstop_next;
            clear_reg <= clear_next;
        end
    end
    // always @(*) -> 
    // 클럭 없이 입력 변화에 따라 바로 n_state, runstop_next, clear_next 값을 계산

    always @(*) begin
        n_state = c_state; // default: 없는 이유 기본값을 초기화 해서
        runstop_next = runstop_reg;
        clear_next = clear_reg;
        case (c_state)
            // runstop_next = 0	스톱워치 멈춘 상태니까 작동 금지
            // clear_next = 0	클리어 신호도 없음
            // i_runstop == 1	버튼 누르면 RUN 상태로 전이
            // i_clear == 1	클리어 버튼 누르면 CLEAR 상태로 전이
            STOP: begin
                runstop_next = 1'b0;
                clear_next = 1'b0;

                if (i_runstop) begin
                    n_state = RUN;
                end else if (i_clear) begin
                    n_state = CLEAR;
                end
            end 
            // runstop_next = 1	작동 중인 상태이므로 동작 신호 HIGH
            // i_runstop == 1	다시 버튼 누르면 STOP 상태로 전환
            // i_clear는 무시됨	RUN 중에는 clear 입력 무시
            RUN : begin
                runstop_next = 1'b1;
                if (i_runstop) begin
                    n_state = STOP;
                end
            end
            // clear_next = 1	클리어 신호 HIGH (이 클럭에만 1임 = 1클럭 펄스)
            // 다음 상태는 항상 STOP	초기화 후 바로 멈춘 상태로 돌아감
            CLEAR: begin
                clear_next = 1'b1;
                n_state = STOP;
            end
        endcase

    end
 

endmodule















