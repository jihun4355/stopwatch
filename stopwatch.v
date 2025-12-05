// `timescale 1ns / 1ps
// //////////////////////////////////////////////////////////////////////


// module stopwatch (
//     input        clk,
//     input        reset,
//     input        Btn_L,    //clear
//     input        Btn_R,    //runstop
//     input Btn_U,
//     input Btn_D,
//     /////////////////////////////////
//     // input  [2:0] sw,
//     input [1:0] sw,
//     // output       led_alarm ,
//     output [3:0] fnd_com,
//     output [7:0] fnd_data,
//     output [2:0] led

// );







//     wire [6:0] sw_msec;   // 0~99 msec
//     wire [5:0] sw_sec;    // 0~59 sec
//     wire [5:0] sw_min;    // 0~59 min
//     wire [4:0] sw_hour;   // 0~23 hour


//     wire [6:0] w_msec;
//     wire [5:0] w_sec;  // 0~59까지의 초
//     wire [5:0] w_min;
//     wire [4:0] w_hour;
 
//     wire b_r, b_l, b_u, b_d;
//     button_debounce DB_R (.clk(clk), .reset(reset), .i_btn(Btn_R), .o_btn(b_r));
//     button_debounce DB_L (.clk(clk), .reset(reset), .i_btn(Btn_L), .o_btn(b_l));
//     button_debounce DB_U (.clk(clk), .reset(reset), .i_btn(Btn_U), .o_btn(b_u));
//     button_debounce DB_D (.clk(clk), .reset(reset), .i_btn(Btn_D), .o_btn(b_d));
//     // Stopwatch CU control (★ 한 쌍만 사용)
//     wire sw_runstop, sw_clear;      // ← 이 이름만 쓰자 (또는 반대로 w_runstop/w_clear로 통일)

//     // Watch edit control
//     wire [1:0] cursor;
//     wire inc_pulse, dec_pulse, w_reset_pulse;
//     wire watch_edit_act; 

//     // --- 모드 & 버튼 게이팅 (추가) ---
//     // 모드(0: Stopwatch, 1: Watch)
//     wire mode = sw[1];

//     // 1) Watch(시계) 쪽 버튼 버스 (move, up, down, reset 순)
//     wire [3:0] watch_btn_p = {b_r, b_u, b_d, b_l};
//     //    mode ? 버튼들 : 0  → ★ RTL_MUX 하나로 표현됨
//     wire [3:0] watch_bus   = mode ? watch_btn_p : 4'b0000;
//     assign {mv_p, up_p, dn_p, rst_p} = watch_bus;

//     // 2) Stopwatch 쪽 버튼 버스 (run, clear 순)
//     wire [1:0] sw_btn_p = {b_r, b_l};
//     //   mode ? 0 : 버튼들  → ★ RTL_MUX 하나로 표현됨
//     wire [1:0] sw_bus   = mode ? 2'b00 : sw_btn_p;
//     assign {run_p, clr_p} = sw_bus;




//     stopwatch_dp U_SW_DP (
//         .clk(clk),
//         .reset(reset),
//         .i_runstop(sw_runstop),
//         .i_clear(sw_clear),
//         .msec(sw_msec),
//         .sec(sw_sec),
//         .min(sw_min),
//         .hour(sw_hour)

//     );

//     stopwatch_cu U_SW_CU (
//         .clk(clk),
//         .reset(reset),
//         .i_runstop(run_p),
//         .i_clear  (clr_p),
//         .o_runstop(sw_runstop),
//         .o_clear(sw_clear)

//     );




//     watch_cu U_W_CU (
//         .clk(clk), .reset(reset),
//         .btn_move_p (mv_p),
//         .btn_up_p   (up_p),
//         .btn_down_p (dn_p),
//         .btn_reset_p(rst_p),
//         .cursor(cursor),
//         .inc_pulse(inc_pulse),
//         .dec_pulse(dec_pulse),
//         .reset_pulse(w_reset_pulse),
//         .edit_activity(watch_edit_act)
//     );



//     watch_dp U_W_DP (
//     .clk(clk), .reset(reset),
//     .cursor(cursor),
//     .inc_pulse(inc_pulse),
//     .dec_pulse(dec_pulse),
//     .reset_pulse(w_reset_pulse),
//     .msec(w_msec), .sec(w_sec), .min(w_min), .hour(w_hour)
//     );

//     // (3) 시간 버스 MUX (mode 재선언 금지!)
//     wire [23:0] time_sw  = {sw_hour, sw_min, sw_sec, sw_msec};
//     wire [23:0] time_w   = { w_hour,  w_min,  w_sec,  w_msec};
//     wire [23:0] time_sel = mode ? time_w : time_sw;





//     fnd_controller U_FND_CNTL (
//         .clk(clk),
//         .reset(reset),
//         .i_time(time_sel),    // ← 반드시 MUX 결과
//         .fnd_com(fnd_com),
//         .fnd_data(fnd_data),
//         .sw(sw[0])                                         // FND 표시 모드 1비트만
//     );


//     assign led[0] = sw[1];            // 시계 항상 켜짐
//     assign led[1] = sw_runstop;       // 스톱워치 run 상태
//     assign led[2] = watch_edit_act;   // 시계 시간 변경 모드




// endmodule









`timescale 1ns / 1ps
module stopwatch (
    input        clk,
    input        reset,
    input        Btn_L,        // clear
    input        Btn_R,        // run/stop
    input        Btn_U,        // watch: up
    input        Btn_D,        // watch: down
    input  [1:0] sw,           // sw[1]=mode(0:SW,1:Watch), sw[0]=FND 페이지
    output [3:0] fnd_com,
    output [7:0] fnd_data,
    output [2:0] led
);
    //============================================================
    // 1) 버튼 디바운스
    //============================================================
    wire b_r, b_l, b_u, b_d;
    button_debounce DB_R (.clk(clk), .reset(reset), .i_btn(Btn_R), .o_btn(b_r));
    button_debounce DB_L (.clk(clk), .reset(reset), .i_btn(Btn_L), .o_btn(b_l));
    button_debounce DB_U (.clk(clk), .reset(reset), .i_btn(Btn_U), .o_btn(b_u));
    button_debounce DB_D (.clk(clk), .reset(reset), .i_btn(Btn_D), .o_btn(b_d));

    //============================================================
    // 2) 모드 & 버튼 게이팅 (MUX를 벡터로 깔끔 처리)
    //   - mode=0: 스톱워치, mode=1: 워치
    //============================================================
    wire mode = sw[1];

    // Watch 쪽: {move, up, down, reset}
    wire [3:0] watch_btn_p = {b_r, b_u, b_d, b_l};
    wire [3:0] watch_bus   = mode ? watch_btn_p : 4'b0000;
    wire mv_p, up_p, dn_p, rst_p;
    assign {mv_p, up_p, dn_p, rst_p} = watch_bus;

    // Stopwatch 쪽: {run, clear}
    wire [1:0] sw_btn_p = {b_r, b_l};
    wire [1:0] sw_bus   = mode ? 2'b00 : sw_btn_p;
    wire run_p, clr_p;
    assign {run_p, clr_p} = sw_bus;

    //============================================================
    // 3) Stopwatch 데이터패스 & 컨트롤
    //============================================================
    wire [6:0] sw_msec;
    wire [5:0] sw_sec, sw_min;
    wire [4:0] sw_hour;
    wire       sw_runstop, sw_clear;

    stopwatch_dp U_SW_DP (
        .clk(clk),
        .reset(reset),
        .i_runstop(sw_runstop),
        .i_clear(sw_clear),
        .msec(sw_msec),
        .sec (sw_sec),
        .min (sw_min),
        .hour(sw_hour)
    );

    stopwatch_cu U_SW_CU (
        .clk(clk),
        .reset(reset),
        .i_runstop(run_p),
        .i_clear  (clr_p),
        .o_runstop(sw_runstop),
        .o_clear  (sw_clear)
    );

    //============================================================
    // 4) Watch(시계) 데이터패스 & 컨트롤
    //============================================================
    wire [1:0] cursor;
    wire       inc_pulse, dec_pulse, w_reset_pulse;
    wire       watch_edit_act;

    watch_cu U_W_CU (
        .clk(clk), .reset(reset),
        .btn_move_p (mv_p),
        .btn_up_p   (up_p),
        .btn_down_p (dn_p),
        .btn_reset_p(rst_p),
        .cursor(cursor),
        .inc_pulse(inc_pulse),
        .dec_pulse(dec_pulse),
        .reset_pulse(w_reset_pulse),
        .edit_activity(watch_edit_act)
    );

    wire [6:0] w_msec;
    wire [5:0] w_sec, w_min;
    wire [4:0] w_hour;

    watch_dp U_W_DP (
        .clk(clk), .reset(reset),
        .cursor(cursor),
        .inc_pulse(inc_pulse),
        .dec_pulse(dec_pulse),
        .reset_pulse(w_reset_pulse),
        .msec(w_msec), .sec(w_sec), .min(w_min), .hour(w_hour)
    );

    //============================================================
    // 5) 시간 버스 단일 MUX → FND
    //============================================================
    wire [23:0] time_sw  = {sw_hour, sw_min, sw_sec, sw_msec};
    wire [23:0] time_w   = { w_hour,  w_min,  w_sec,  w_msec};
    wire [23:0] time_sel = mode ? time_w : time_sw;

    fnd_controller U_FND (
        .clk(clk),
        .reset(reset),
        .i_time(time_sel),
        .i_runstop(1'b0),       // fnd 내부에 입력 존재하지만 사용 안 함 → 0 연결
        .i_clear  (1'b0),
        .sw(sw[0]),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );

    //============================================================
    // 6) LED 인디케이터
    //   led[0] : 현재 모드(1=Watch, 0=Stopwatch)
    //   led[1] : 스톱워치 run 상태 표시
    //   led[2] : 워치 편집 활동(최근 0.1s 하이라이트)
    //============================================================
    assign led[0] = mode;
    assign led[1] = sw_runstop;
    assign led[2] = watch_edit_act;

endmodule

