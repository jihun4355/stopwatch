

// `timescale 1ns/1ps
// module watch_dp (
//     input        clk,
//     input        reset,
//     input  [1:0] cursor,        // 0:H10,1:H1,2:M10,3:M1
//     input        inc_pulse,     // +1
//     input        dec_pulse,     // -1
//     input        reset_pulse,   // 초기값 리셋
//     output reg [6:0] msec,      // 0..99
//     output reg [5:0] sec,       // 0..59
//     output reg [5:0] min,       // 0..59
//     output reg [4:0] hour       // 0..23
// );
//     // 초기값(필요 시 수정)
//     localparam [4:0] INIT_H = 5'd12;
//     localparam [5:0] INIT_M = 6'd0;
//     localparam [5:0] INIT_S = 6'd0;

//     // 임시 변수(Verilog-2001 규칙: 블록 시작부에 선언)
//     reg [3:0] h10, h1, m10, m1;

//     // 100Hz 틱(항상 동작) — 기존 tick_gen_100hz 재사용
//     wire tick_100hz, sec_tick, min_tick;
//     tick_gen_100hz U_TICK (
//         .clk(clk), .reset(reset),
//         .i_runstop(1'b1),        // 항상 돌도록
//         .o_tick_100hz(tick_100hz)
//     );

//     // msec 0..99
//     always @(posedge clk or posedge reset) begin
//         if (reset || reset_pulse) msec <= 7'd0;
//         else if (tick_100hz) begin
//             if (msec == 7'd99) msec <= 7'd0;
//             else               msec <= msec + 7'd1;
//         end
//     end
//     assign sec_tick = tick_100hz && (msec == 7'd99);

//     // sec 0..59
//     always @(posedge clk or posedge reset) begin
//         if (reset || reset_pulse) sec <= INIT_S;
//         else if (sec_tick) begin
//             if (sec == 6'd59) sec <= 6'd0;
//             else              sec <= sec + 6'd1;
//         end
//     end
//     assign min_tick = sec_tick && (sec == 6'd59);

//     // min/hour 자연 카운트 + 자리수 편집
//     always @(posedge clk or posedge reset) begin
//         if (reset || reset_pulse) begin
//             min  <= INIT_M;
//             hour <= INIT_H;
//         end else begin
//             // 자연 카운트
//             if (min_tick) begin
//                 if (min == 6'd59) begin
//                     min <= 6'd0;
//                     if (hour == 5'd23) hour <= 5'd0;
//                     else               hour <= hour + 5'd1;
//                 end else begin
//                     min <= min + 6'd1;
//                 end
//             end

//             // 자리수 편집
//             if (inc_pulse | dec_pulse) begin
//                 // 현재 HH:MM을 BCD로 분리
//                 h10 = hour / 10;  h1  = hour % 10;
//                 m10 = min  / 10;  m1  = min  % 10;

//                 if (inc_pulse) begin
//                     case (cursor)
//                       2'd0: h10 = (h10 == 4'd2) ? 4'd0 : (h10 + 4'd1);          // 0..2
//                       2'd1: begin                                               // 0..9 (단 h10=2면 0..3)
//                               h1 = (h1 == 4'd9) ? 4'd0 : (h1 + 4'd1);
//                               if (h10 == 4'd2 && h1 > 4'd3) h1 = 4'd0;
//                            end
//                       2'd2: m10 = (m10 == 4'd5) ? 4'd0 : (m10 + 4'd1);          // 0..5
//                       2'd3: m1  = (m1  == 4'd9) ? 4'd0 : (m1  + 4'd1);          // 0..9
//                     endcase
//                 end

//                 if (dec_pulse) begin
//                     case (cursor)
//                       2'd0: h10 = (h10 == 4'd0) ? 4'd2 : (h10 - 4'd1);          // 2..0
//                       2'd1: begin
//                               if (h1 == 4'd0) h1 = (h10 == 4'd2) ? 4'd3 : 4'd9;  // 0→(3 or 9)
//                               else            h1 = h1 - 4'd1;
//                            end
//                       2'd2: m10 = (m10 == 4'd0) ? 4'd5 : (m10 - 4'd1);          // 5..0
//                       2'd3: m1  = (m1  == 4'd0) ? 4'd9 : (m1  - 4'd1);          // 9..0
//                     endcase
//                 end

//                 // 재조합
//                 hour <= (h10*10 + h1);     // 0..23
//                 min  <= (m10*10 + m1);     // 0..59
//             end
//         end
//     end
// endmodule












// `timescale 1ns/1ps


// module watch_dp #(
//   parameter integer FCOUNT_100HZ = 100_000_000/100,
//   parameter [4:0]  DEF_HOUR = 5'd12,
//   parameter [5:0]  DEF_MIN  = 6'd0,
//   parameter [5:0]  DEF_SEC  = 6'd0,
//   parameter [6:0]  DEF_MSEC = 7'd0
// )(
//   input        clk,
//   input        reset,

//   // 편집 제어
//   input  [1:0] cursor,       // 00:hour, 01:min, 10:sec, 11:msec
//   input        inc_pulse,    // +1
//   input        dec_pulse,    // -1
//   input        reset_pulse,  // 기본값(파라미터)로 복귀

//   // 현재 시간
//   output [6:0] msec,
//   output [5:0] sec,
//   output [5:0] min,
//   output [4:0] hour
// );

//   // 100 Hz tick (항상 동작)
//   wire tick_100hz;
//   tick_gen_100hz U_TICK (
//     .clk(clk),
//     .reset(reset),
//     .i_runstop(1'b1),     // 워치는 항상 run
//     .o_tick_100hz(tick_100hz)
//   );

//   // 자리 선택에 따른 편집 펄스 게이팅
//   wire inc_ms = inc_pulse & (cursor==2'b11);
//   wire dec_ms = dec_pulse & (cursor==2'b11);

//   wire inc_sc = inc_pulse & (cursor==2'b10);
//   wire dec_sc = dec_pulse & (cursor==2'b10);

//   wire inc_mn = inc_pulse & (cursor==2'b01);
//   wire dec_mn = dec_pulse & (cursor==2'b01);

//   wire inc_hr = inc_pulse & (cursor==2'b00);
//   wire dec_hr = dec_pulse & (cursor==2'b00);




// // cursor: 00=hour, 01=min, 10=sec, 11=msec  (매핑은 프로젝트에 맞게!)
// wire [3:0] sel_onehot;
// assign sel_onehot = (cursor==2'b00) ? 4'b1000 :   // hour
//                     (cursor==2'b01) ? 4'b0100 :   // min
//                     (cursor==2'b10) ? 4'b0010 :   // sec
//                                        4'b0001 ;  // msec

// // AND 8개 -> 벡터 AND 2개로 통합
// wire [3:0] inc_vec = {4{inc_pulse}} & sel_onehot;
// wire [3:0] dec_vec = {4{dec_pulse}} & sel_onehot;

// // 각 카운터로 바로 분배 (게이트 블록 사라짐)
// time_counter_ud #(.BIT_WIDTH(7), .TIME_COUNT(100)) U_MSEC (
//   .clk(clk), .reset(reset),
//   .i_tick_up(tick_100hz),
//   .i_up_pulse  (inc_vec[0]),
//   .i_down_pulse(dec_vec[0]),
//   .i_set_default(reset_pulse),
//   .o_time(msec), .o_tick_up(sec_tick)
// );

// time_counter_ud #(.BIT_WIDTH(6), .TIME_COUNT(60)) U_SEC (
//   .clk(clk), .reset(reset),
//   .i_tick_up(sec_tick),
//   .i_up_pulse  (inc_vec[1]),
//   .i_down_pulse(dec_vec[1]),
//   .i_set_default(reset_pulse),
//   .o_time(sec), .o_tick_up(min_tick)
// );

// time_counter_ud #(.BIT_WIDTH(6), .TIME_COUNT(60)) U_MIN (
//   .clk(clk), .reset(reset),
//   .i_tick_up(min_tick),
//   .i_up_pulse  (inc_vec[2]),
//   .i_down_pulse(dec_vec[2]),
//   .i_set_default(reset_pulse),
//   .o_time(min), .o_tick_up(hour_tick)
// );

// time_counter_ud #(.BIT_WIDTH(5), .TIME_COUNT(24)) U_HOUR (
//   .clk(clk), .reset(reset),
//   .i_tick_up(hour_tick),
//   .i_up_pulse  (inc_vec[3]),
//   .i_down_pulse(dec_vec[3]),
//   .i_set_default(reset_pulse),
//   .o_time(hour), .o_tick_up()
// );

// endmodule


// module time_counter_ud #(
//   parameter integer BIT_WIDTH  = 6,
//   parameter integer TIME_COUNT = 60,
//   parameter [BIT_WIDTH-1:0] DEF_VAL = {BIT_WIDTH{1'b0}}
// )(
//   input  clk,
//   input  reset,
//   input  i_tick_up,
//   input  i_up_pulse,
//   input  i_down_pulse,
//   input  i_set_default,
//   output reg [BIT_WIDTH-1:0] o_time,
//   output reg                 o_tick_up   // 자연 tick으로 max→0 될 때만 1클럭
// );
//   localparam [BIT_WIDTH-1:0] MAXV = TIME_COUNT-1;

//   always @(posedge clk or posedge reset) begin
//     if (reset) begin
//       o_time   <= DEF_VAL;
//       o_tick_up<= 1'b0;
//     end else begin
//       o_tick_up <= 1'b0;

//       if (i_set_default) begin
//         o_time <= DEF_VAL;

//       end else if (i_up_pulse) begin
//         o_time <= (o_time==MAXV) ? {BIT_WIDTH{1'b0}} : o_time + 1'b1;

//       end else if (i_down_pulse) begin
//         o_time <= (o_time=={BIT_WIDTH{1'b0}}) ? MAXV : o_time - 1'b1;

//       end else if (i_tick_up) begin
//         if (o_time==MAXV) begin
//           o_time    <= {BIT_WIDTH{1'b0}};
//           o_tick_up <= 1'b1;     // 자연 롤오버 알림(다음 자리로 전파)
//         end else begin
//           o_time <= o_time + 1'b1;
//         end
//       end
//     end
//   end
// endmodule




`timescale 1ns/1ps

module watch_dp #(
  // 100MHz 기준 100Hz 틱(10ms) – 외부 tick_gen_100hz 사용
  parameter [4:0]  DEF_HOUR = 5'd12,
  parameter [5:0]  DEF_MIN  = 6'd0,
  parameter [5:0]  DEF_SEC  = 6'd0,
  parameter [6:0]  DEF_MSEC = 7'd0
)(
  input        clk,
  input        reset,

  // 편집 제어
  input  [1:0] cursor,       // 00:hour, 01:min, 10:sec, 11:msec
  input        inc_pulse,    // +1 (1클럭)
  input        dec_pulse,    // -1 (1클럭)
  input        reset_pulse,  // 기본값으로 복귀(1클럭)

  // 현재 시간
  output [6:0] msec,         // 0..99
  output [5:0] sec,          // 0..59
  output [5:0] min,          // 0..59
  output [4:0] hour          // 0..23
);
  // 100 Hz tick (항상 동작)
  wire tick_100hz;
  tick_gen_100hz U_TICK (
    .clk(clk),
    .reset(reset),
    .i_runstop(1'b1),     // 워치는 항상 run
    .o_tick_100hz(tick_100hz)
  );

  // cursor -> one-hot
  wire [3:0] sel_onehot =
      (cursor==2'b00) ? 4'b1000 :   // hour
      (cursor==2'b01) ? 4'b0100 :   // min
      (cursor==2'b10) ? 4'b0010 :   // sec
                        4'b0001 ;   // msec

  // 벡터 AND로 깔끔하게 게이팅 (AND 뭉치 사라짐)
  wire [3:0] inc_vec = {4{inc_pulse}} & sel_onehot;
  wire [3:0] dec_vec = {4{dec_pulse}} & sel_onehot;

  // 체인 카운터
  wire sec_tick, min_tick, hour_tick;

  time_counter_ud #(.BIT_WIDTH(7), .TIME_COUNT(100), .DEF_VAL(DEF_MSEC)) U_MSEC (
    .clk(clk), .reset(reset),
    .i_tick_up(tick_100hz),
    .i_up_pulse  (inc_vec[0]),
    .i_down_pulse(dec_vec[0]),
    .i_set_default(reset_pulse),
    .o_time(msec), .o_tick_up(sec_tick)
  );

  time_counter_ud #(.BIT_WIDTH(6), .TIME_COUNT(60), .DEF_VAL(DEF_SEC)) U_SEC (
    .clk(clk), .reset(reset),
    .i_tick_up(sec_tick),
    .i_up_pulse  (inc_vec[1]),
    .i_down_pulse(dec_vec[1]),
    .i_set_default(reset_pulse),
    .o_time(sec), .o_tick_up(min_tick)
  );

  time_counter_ud #(.BIT_WIDTH(6), .TIME_COUNT(60), .DEF_VAL(DEF_MIN)) U_MIN (
    .clk(clk), .reset(reset),
    .i_tick_up(min_tick),
    .i_up_pulse  (inc_vec[2]),
    .i_down_pulse(dec_vec[2]),
    .i_set_default(reset_pulse),
    .o_time(min), .o_tick_up(hour_tick)
  );

  time_counter_ud #(.BIT_WIDTH(5), .TIME_COUNT(24), .DEF_VAL(DEF_HOUR)) U_HOUR (
    .clk(clk), .reset(reset),
    .i_tick_up(hour_tick),
    .i_up_pulse  (inc_vec[3]),
    .i_down_pulse(dec_vec[3]),
    .i_set_default(reset_pulse),
    .o_time(hour), .o_tick_up()
  );
endmodule


// ---------- 공용 업/다운 카운터(모듈러 + 자연 롤오버 tick 전파) ----------
module time_counter_ud #(
  parameter integer BIT_WIDTH  = 6,
  parameter integer TIME_COUNT = 60,
  parameter [BIT_WIDTH-1:0] DEF_VAL = {BIT_WIDTH{1'b0}}
)(
  input  clk,
  input  reset,
  input  i_tick_up,       // 자연 증가 입력(다음 자리로 전파될 신호의 원천)
  input  i_up_pulse,      // 수동 +1
  input  i_down_pulse,    // 수동 -1
  input  i_set_default,   // 기본값으로 복귀
  output reg [BIT_WIDTH-1:0] o_time,
  output reg                o_tick_up   // 자연 롤오버 때만 1클럭 HIGH
);
  localparam [BIT_WIDTH-1:0] MAXV = TIME_COUNT-1;
  localparam [BIT_WIDTH-1:0] ZERO = {BIT_WIDTH{1'b0}};

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      o_time    <= DEF_VAL;
      o_tick_up <= 1'b0;
    end else begin
      o_tick_up <= 1'b0;

      if (i_set_default) begin
        o_time <= DEF_VAL;

      end else if (i_up_pulse) begin
        o_time <= (o_time==MAXV) ? ZERO : (o_time + {{(BIT_WIDTH-1){1'b0}},1'b1});

      end else if (i_down_pulse) begin
        o_time <= (o_time==ZERO) ? MAXV : (o_time - {{(BIT_WIDTH-1){1'b0}},1'b1});

      end else if (i_tick_up) begin
        if (o_time==MAXV) begin
          o_time    <= ZERO;
          o_tick_up <= 1'b1;  // 자연 카운트로만 전파
        end else begin
          o_time <= o_time + {{(BIT_WIDTH-1){1'b0}},1'b1};
        end
      end
    end
  end
endmodule
