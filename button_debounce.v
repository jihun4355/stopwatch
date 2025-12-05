`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/08 13:22:42
// Design Name: 
// Module Name: button_de
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


module button_debounce (
    input  clk,
    input  reset,
    input  i_btn,
    output o_btn
);

    reg [$clog2(100)-1:0] counter_reg;
    reg clk_reg;
    reg [7:0] q_reg, q_next; // 비트 바꿀때 같이 바꿈
    reg  edge_reg;
    wire debouce;

    // clock divider
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0; // 비트 바꿀때 같이 바꿈
            clk_reg     <= 1'b0;
        end else begin
            if (counter_reg == 99) begin
                counter_reg <= 0;
                clk_reg     <= 1'b1;
            end else begin
                counter_reg <= counter_reg + 1;
                clk_reg     <= 1'b0;
            end
        end
    end


    // debouce, shift register
    always @(posedge clk_reg, posedge reset) begin
        if (reset) begin
            q_reg <= 0;
        end else begin
            q_reg <= q_next;

        end
    end
    // seial input, paraller output shife register
    always @(*) begin
        q_next = {i_btn, q_reg[7:1]}; // 비트 바꿀때 같이 바꿈
    end

    // 4input AND
    assign debouce = &q_reg;


    //Q5 output
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            edge_reg <= 1'b0;
        end else begin
            edge_reg <= debouce;
        end
    end

    //edge output 
    assign o_btn = ~edge_reg & debouce;



endmodule
