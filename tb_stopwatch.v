`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/07 15:03:33
// Design Name: 
// Module Name: tb_stopwatch
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_stopwatch();

    reg clk, reset;
    reg [1:0] sw;
    reg         Btn_L, Btn_R, Btn_U, Btn_D;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;
    wire [2:0] led;


    stopwatch dut(
        .sw(sw),
        .clk(clk),
        .reset(reset),
        .Btn_L(Btn_L),
        .Btn_R(Btn_R),
        .Btn_D(Btn_D),
        .Btn_U(Btn_U),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data),
        .led(led)
    );

    always #5 clk = ~clk; //10ns 주기 → 100MHz 클럭

    initial begin
        //초기에는 리셋 상태 → FSM, 카운터 모두 초기화됨
        clk = 0;
        reset = 1;
        Btn_L = 0;
        Btn_R = 0;
        Btn_D = 0;
        Btn_U = 0;
        sw = 0;
        #20;

        reset = 0;

        // STEP 1: 
        Btn_R = 1; #10; Btn_R = 0;
        #10_000_000

        // STEP 2: 
        Btn_R = 1; #10; Btn_R = 0;
        #10_000_000

        // STEP 3: 
        Btn_L = 1; #10; Btn_L = 0;
        #10_000_000

        // STEP 4: 
        Btn_R = 1; #10; Btn_R = 0;
        #10_000_000

        // STEP 5: FND 모드 전환 (sw = 1)
        sw = 1;
        #30_000_000

        // STEP 6: 다시 모드 전환 (sw = 0)
        sw = 0;
        #30_000_000
                
        // 시뮬레이션 정지
        $stop;

    end


endmodule



