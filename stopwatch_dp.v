`timescale 1ns / 1ps

module stopwatch_dp (
    input        clk,
    input        reset,
    input        i_runstop,
    input        i_clear,

    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
);
    wire w_tick_100hz, w_sec_tick, w_min_tick, w_hour_tick;




    time_counter #(
        .BIT_WIDTH (7),
        .TIME_COUNT(100)
    ) U_MSEC_COUNTER (
        .clk(clk),
        .reset(reset),
        .i_tick(w_tick_100hz),
        .i_clear(i_clear),
        .o_time(msec),
        .o_tick(w_sec_tick)
    );


    time_counter #(
        .BIT_WIDTH (6),
        .TIME_COUNT(60)
    ) U_SEC_COUNTER (
        .clk(clk),
        .reset(reset),
        .i_tick(w_sec_tick),
        .i_clear(i_clear),
        .o_time(sec),
        .o_tick(w_min_tick)
    );


    time_counter #(
        .BIT_WIDTH (6),
        .TIME_COUNT(60)
    ) U_min_COUNTER (
        .clk(clk),
        .reset(reset),
        .i_tick(w_min_tick),
        .i_clear(i_clear),
        .o_time(min),
        .o_tick(w_hour_tick)
    );


    time_counter #(
        .BIT_WIDTH (6),
        .TIME_COUNT(60)
    ) U_hour_COUNTER (
        .clk(clk),
        .reset(reset),
        .i_tick(w_hour_tick),
        .i_clear(i_clear),
        .o_time(hour),
        .o_tick()
    );


    tick_gen_100hz U_TICK_GEN_100HZ (
        .clk(clk),
        .reset(reset),
        .i_runstop(i_runstop),
        .o_tick_100hz(w_tick_100hz)
    );
endmodule




// BIT_WIDTH: 출력 카운트 값(o_time)의 비트 수
// TIME_COUNT: 몇 번 틱을 셀 건지 (ex. 100이면 0~99까지 카운트)
module time_counter #(
    parameter BIT_WIDTH  = 7,
    parameter TIME_COUNT = 100
)(
    input clk,
    input reset,
    input i_tick,
    input i_clear,
    output [BIT_WIDTH-1:0] o_time,
    output o_tick
);
    // $clog2()는 TIME_COUNT 값을 표현하기 위해 필요한 최소 비트 수입니다.
    // 예: TIME_COUNT=100이면 ceil(log2(100)) = 7 → 7비트
    reg [$clog2(TIME_COUNT)-1:0] count_reg, count_next;
    reg tick_reg, tick_next;
    // 카운터 값과 tick 신호를 외부로 전달합니다.
    assign o_time = count_reg;
    assign o_tick = tick_reg;
    // 클럭 상승 or 리셋 시에 레지스터 업데이트
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count_reg <= 0;
            tick_reg  <= 1'b0;
        end else begin
            count_reg <= count_next;
            tick_reg  <= tick_next;
        end 
    end
    // 조합 논리(always @(*))에서는 *_next 값을 준비만 합니다.

    always @(*) begin
        count_next = count_reg; //기본적으로 변화 없음으로 초기화 (이거 없으면 latch 생김)
        tick_next  = 1'b0;
        // i_tick == 1 & 카운트 끝	count = 0, tick_next = 1
        // i_tick == 1 & 아직 진행 중	count + 1, tick_next = 0
        // i_tick == 0	아무 변화 없음 (tick도 LOW)
        if (i_tick) begin
            if (count_reg == TIME_COUNT - 1) begin
                count_next = 0;
                tick_next  = 1'b1;
            end else begin
                count_next = count_reg + 1;
                tick_next  = 1'b0;
            end
        end
        // i_clear 신호가 1이면 강제로 카운터를 0으로 초기화합니다.
        // tick_next는 그대로 0이라서 tick 출력은 발생하지 않습니다.
        // 이건 보통 사용자가 STOP 상태에서 clear 버튼을 누르면 0으로 만드는 용도입니다.
        if (i_clear == 1'b1) begin
            count_next = 0;
        end

    end
    
endmodule



module tick_gen_100hz #(
    parameter FCOUNT = 100_000_000 / 100  // 클럭이 1_000_000번 들어오면,
                                        //1번 펄스를 발생시키는 구조입니다.
) (
    input  clk,
    input  reset,

    input  i_runstop,
    output o_tick_100hz
);
    // r_counter: 0부터 FCOUNT-1까지 카운트 → 1,000,000번
    // r_tick: 1클럭만 HIGH 되는 펄스 값 저장용 레지스터
    reg [$clog2(FCOUNT)-1:0] r_counter;
    reg r_tick;

    // r_tick은 내부 레지스터입니다.
    // 이 값이 1클럭 동안 HIGH가 되면, o_tick_100hz도 HIGH가 됩니다.
    // 즉, 이게 펄스 출력 역할을 하죠
    assign o_tick_100hz = r_tick;
    // 클럭의 상승 에지 또는 비동기 리셋 시 동작합니다.
    always @(posedge clk or posedge reset) begin
        // reset = 1이면:
        // r_counter: 0으로 초기화
        // r_tick: 0으로 초기화
        if (reset) begin
            r_counter <= 0;
            r_tick    <= 1'b0;
        end else begin
            // 외부 FSM(stopwatch_cu)의 o_runstop에서 연결됩니다.
            // 즉, 사용자가 "START" 버튼을 누른 상태를 의미합니다.
            if (i_runstop == 1'b1) begin    
                // FCOUNT = 1_000_000 (100MHz / 100Hz)
                // 0부터 999_999까지 셉니다 → 딱 100만 클럭이 지나면
                // 카운터를 리셋하고, r_tick을 1로 만들어서 1펄스 발생
                if (r_counter == FCOUNT - 1) begin
                    r_counter <= 0;
                    r_tick    <= 1'b1;
                // 계속 클럭을 셉니다 (r_counter += 1)
                // 펄스는 이때 발생하면 안 되므로 r_tick = 0
                end else begin
                    r_counter <= r_counter + 1;
                    r_tick    <= 1'b0;
                end 
            // 스톱워치가 멈춰있는 상태이므로,
            // 카운터는 증가도 초기화도 하지 않고 그대로 유지
            // r_tick은 0 또는 유지인데, 어차피 1클럭만 HIGH이기 때문에 펄스 발생 안 함
            end else begin
                r_counter <= r_counter;
                
            end
        end
    
    end
endmodule


