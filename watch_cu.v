

`timescale 1ns/1ps
module watch_cu (
    input        clk,
    input        reset,        // 동기 리셋 권장
    input        btn_move_p,   // 디바운스된 1클럭 펄스
    input        btn_up_p,     // +
    input        btn_down_p,   // -
    input        btn_reset_p,  // 기본값으로 리셋
    output reg [1:0] cursor,   // 00:hour, 01:min, 10:sec, 11:msec
    output            inc_pulse,
    output            dec_pulse,
    output            reset_pulse,
    output            edit_activity
);
    // 펄스는 그대로 DP로 전달
    assign inc_pulse   = btn_up_p;
    assign dec_pulse   = btn_down_p;
    assign reset_pulse = btn_reset_p;

    // 커서 이동: 0→1→2→3→0
    always @(posedge clk) begin
        if (reset)      cursor <= 2'd0;
        else if (btn_move_p)
                        cursor <= cursor + 2'd1;
    end

    // 편집 활동 LED 스트레치(약 0.1s @100MHz)
    localparam integer STRETCH = 10_000_000;
    localparam integer CW = $clog2(STRETCH+1);

    reg [CW-1:0] act_cnt = {CW{1'b0}};
    reg          act     = 1'b0;
    assign edit_activity = act;

    wire any_evt = btn_move_p | btn_up_p | btn_down_p | btn_reset_p;

    always @(posedge clk) begin
        if (reset) begin
            act_cnt <= {CW{1'b0}};
            act     <= 1'b0;
        end else if (any_evt) begin
            act_cnt <= STRETCH[CW-1:0];
            act     <= 1'b1;
        end else if (act_cnt != 0) begin
            act_cnt <= act_cnt - 1'b1;
            act     <= 1'b1;
        end else begin
            act     <= 1'b0;
        end
    end
endmodule
