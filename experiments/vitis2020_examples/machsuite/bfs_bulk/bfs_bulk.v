// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2020.2 (64-bit)
// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// ==============================================================

`timescale 1 ns / 1 ps

module bfs_top_add_64ns_64ns_64_3_1_Adder_0(clk, reset, ce, a, b, s);

// ---- input/output ports list here ----
input   clk;
input   reset;
input   ce;
input  [64 - 1 : 0] a;
input  [64 - 1 : 0] b;
output [64 - 1 : 0] s;

// wire for the primary inputs
wire [64 - 1 : 0] ain_s0 = a;
wire [64 - 1 : 0] bin_s0 = b;

// This AddSub module have totally 3 stages. For each stage the adder's width are:
// 21 22 21

// Stage 1 logic
wire [21 - 1 : 0]    fas_s1;
wire                 facout_s1;
reg  [43 - 1 : 0]    ain_s1;
reg  [43 - 1 : 0]    bin_s1;
reg  [21 - 1 : 0]    sum_s1;
reg                  carry_s1;
bfs_top_add_64ns_64ns_64_3_1_Adder_0_comb_adder #(
    .N    ( 21 )
) u1 (
    .a    ( ain_s0[21 - 1 : 0] ),
    .b    ( bin_s0[21 - 1 : 0] ),
    .cin  ( 1'b0 ),
    .s    ( fas_s1 ),
    .cout ( facout_s1 )
);

always @ (posedge clk) begin
    if (ce) begin
        sum_s1   <= fas_s1;
        carry_s1 <= facout_s1;
    end
end

always @ (posedge clk) begin
    if (ce) begin
        ain_s1 <= ain_s0[64 - 1 : 21];
    end
end

always @ (posedge clk) begin
    if (ce) begin
        bin_s1 <= bin_s0[64 - 1 : 21];
    end
end

// Stage 2 logic
wire [22 - 1 : 0]    fas_s2;
wire                 facout_s2;
reg  [21 - 1 : 0]    ain_s2;
reg  [21 - 1 : 0]    bin_s2;
reg  [43 - 1 : 0]    sum_s2;
reg                  carry_s2;
bfs_top_add_64ns_64ns_64_3_1_Adder_0_comb_adder #(
    .N    ( 22 )
) u2 (
    .a    ( ain_s1[22 - 1 : 0] ),
    .b    ( bin_s1[22 - 1 : 0] ),
    .cin  ( carry_s1 ),
    .s    ( fas_s2 ),
    .cout ( facout_s2 )
);

always @ (posedge clk) begin
    if (ce) begin
        sum_s2   <= {fas_s2, sum_s1};
        carry_s2 <= facout_s2;
    end
end

always @ (posedge clk) begin
    if (ce) begin
        ain_s2 <= ain_s1[43 - 1 : 22];
    end
end

always @ (posedge clk) begin
    if (ce) begin
        bin_s2 <= bin_s1[43 - 1 : 22];
    end
end

// Stage 3 logic
wire [21 - 1 : 0]    fas_s3;
wire                 facout_s3;
bfs_top_add_64ns_64ns_64_3_1_Adder_0_comb_adder #(
    .N    ( 21 )
) u3 (
    .a    ( ain_s2[21 - 1 : 0] ),
    .b    ( bin_s2[21 - 1 : 0] ),
    .cin  ( carry_s2 ),
    .s    ( fas_s3 ),
    .cout ( facout_s3 )
);

assign s = {fas_s3, sum_s2};

endmodule

// small adder
module bfs_top_add_64ns_64ns_64_3_1_Adder_0_comb_adder 
#(parameter
    N = 32
)(
    input  [N-1 : 0]  a,
    input  [N-1 : 0]  b,
    input  wire           cin,
    output [N-1 : 0]  s,
    output wire           cout
);
assign {cout, s} = a + b + cin;

endmodule

`timescale 1 ns / 1 ps
module bfs_top_add_64ns_64ns_64_3_1(
    clk,
    reset,
    ce,
    din0,
    din1,
    dout);

parameter ID = 32'd1;
parameter NUM_STAGE = 32'd1;
parameter din0_WIDTH = 32'd1;
parameter din1_WIDTH = 32'd1;
parameter dout_WIDTH = 32'd1;
input clk;
input reset;
input ce;
input[din0_WIDTH - 1:0] din0;
input[din1_WIDTH - 1:0] din1;
output[dout_WIDTH - 1:0] dout;



bfs_top_add_64ns_64ns_64_3_1_Adder_0 bfs_top_add_64ns_64ns_64_3_1_Adder_0_U(
    .clk( clk ),
    .reset( reset ),
    .ce( ce ),
    .a( din0 ),
    .b( din1 ),
    .s( dout ));

endmodule

// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2020.2 (64-bit)
// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// ==============================================================

`timescale 1 ns / 1 ps

module bfs_top_add_8ns_8ns_8_2_1_Adder_1(clk, reset, ce, a, b, s);

// ---- input/output ports list here ----
input   clk;
input   reset;
input   ce;
input  [8 - 1 : 0] a;
input  [8 - 1 : 0] b;
output [8 - 1 : 0] s;

// wire for the primary inputs
wire [8 - 1 : 0] ain_s0 = a;
wire [8 - 1 : 0] bin_s0 = b;

// This AddSub module have totally 2 stages. For each stage the adder's width are:
// 4 4

// Stage 1 logic
wire [4 - 1 : 0]     fas_s1;
wire                 facout_s1;
reg  [4 - 1 : 0]     ain_s1;
reg  [4 - 1 : 0]     bin_s1;
reg  [4 - 1 : 0]     sum_s1;
reg                  carry_s1;
bfs_top_add_8ns_8ns_8_2_1_Adder_1_comb_adder #(
    .N    ( 4 )
) u1 (
    .a    ( ain_s0[4 - 1 : 0] ),
    .b    ( bin_s0[4 - 1 : 0] ),
    .cin  ( 1'b0 ),
    .s    ( fas_s1 ),
    .cout ( facout_s1 )
);

always @ (posedge clk) begin
    if (ce) begin
        sum_s1   <= fas_s1;
        carry_s1 <= facout_s1;
    end
end

always @ (posedge clk) begin
    if (ce) begin
        ain_s1 <= ain_s0[8 - 1 : 4];
    end
end

always @ (posedge clk) begin
    if (ce) begin
        bin_s1 <= bin_s0[8 - 1 : 4];
    end
end

// Stage 2 logic
wire [4 - 1 : 0]     fas_s2;
wire                 facout_s2;
bfs_top_add_8ns_8ns_8_2_1_Adder_1_comb_adder #(
    .N    ( 4 )
) u2 (
    .a    ( ain_s1[4 - 1 : 0] ),
    .b    ( bin_s1[4 - 1 : 0] ),
    .cin  ( carry_s1 ),
    .s    ( fas_s2 ),
    .cout ( facout_s2 )
);

assign s = {fas_s2, sum_s1};

endmodule

// small adder
module bfs_top_add_8ns_8ns_8_2_1_Adder_1_comb_adder 
#(parameter
    N = 32
)(
    input  [N-1 : 0]  a,
    input  [N-1 : 0]  b,
    input  wire           cin,
    output [N-1 : 0]  s,
    output wire           cout
);
assign {cout, s} = a + b + cin;

endmodule

`timescale 1 ns / 1 ps
module bfs_top_add_8ns_8ns_8_2_1(
    clk,
    reset,
    ce,
    din0,
    din1,
    dout);

parameter ID = 32'd1;
parameter NUM_STAGE = 32'd1;
parameter din0_WIDTH = 32'd1;
parameter din1_WIDTH = 32'd1;
parameter dout_WIDTH = 32'd1;
input clk;
input reset;
input ce;
input[din0_WIDTH - 1:0] din0;
input[din1_WIDTH - 1:0] din1;
output[dout_WIDTH - 1:0] dout;



bfs_top_add_8ns_8ns_8_2_1_Adder_1 bfs_top_add_8ns_8ns_8_2_1_Adder_1_U(
    .clk( clk ),
    .reset( reset ),
    .ce( ce ),
    .a( din0 ),
    .b( din1 ),
    .s( dout ));

endmodule

// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2020.2 (64-bit)
// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// ==============================================================

`timescale 1 ns / 1 ps

module bfs_top_add_9ns_9ns_9_2_1_Adder_2(clk, reset, ce, a, b, s);

// ---- input/output ports list here ----
input   clk;
input   reset;
input   ce;
input  [9 - 1 : 0] a;
input  [9 - 1 : 0] b;
output [9 - 1 : 0] s;

// wire for the primary inputs
wire [9 - 1 : 0] ain_s0 = a;
wire [9 - 1 : 0] bin_s0 = b;

// This AddSub module have totally 2 stages. For each stage the adder's width are:
// 4 5

// Stage 1 logic
wire [4 - 1 : 0]     fas_s1;
wire                 facout_s1;
reg  [5 - 1 : 0]     ain_s1;
reg  [5 - 1 : 0]     bin_s1;
reg  [4 - 1 : 0]     sum_s1;
reg                  carry_s1;
bfs_top_add_9ns_9ns_9_2_1_Adder_2_comb_adder #(
    .N    ( 4 )
) u1 (
    .a    ( ain_s0[4 - 1 : 0] ),
    .b    ( bin_s0[4 - 1 : 0] ),
    .cin  ( 1'b0 ),
    .s    ( fas_s1 ),
    .cout ( facout_s1 )
);

always @ (posedge clk) begin
    if (ce) begin
        sum_s1   <= fas_s1;
        carry_s1 <= facout_s1;
    end
end

always @ (posedge clk) begin
    if (ce) begin
        ain_s1 <= ain_s0[9 - 1 : 4];
    end
end

always @ (posedge clk) begin
    if (ce) begin
        bin_s1 <= bin_s0[9 - 1 : 4];
    end
end

// Stage 2 logic
wire [5 - 1 : 0]     fas_s2;
wire                 facout_s2;
bfs_top_add_9ns_9ns_9_2_1_Adder_2_comb_adder #(
    .N    ( 5 )
) u2 (
    .a    ( ain_s1[5 - 1 : 0] ),
    .b    ( bin_s1[5 - 1 : 0] ),
    .cin  ( carry_s1 ),
    .s    ( fas_s2 ),
    .cout ( facout_s2 )
);

assign s = {fas_s2, sum_s1};

endmodule

// small adder
module bfs_top_add_9ns_9ns_9_2_1_Adder_2_comb_adder 
#(parameter
    N = 32
)(
    input  [N-1 : 0]  a,
    input  [N-1 : 0]  b,
    input  wire           cin,
    output [N-1 : 0]  s,
    output wire           cout
);
assign {cout, s} = a + b + cin;

endmodule

`timescale 1 ns / 1 ps
module bfs_top_add_9ns_9ns_9_2_1(
    clk,
    reset,
    ce,
    din0,
    din1,
    dout);

parameter ID = 32'd1;
parameter NUM_STAGE = 32'd1;
parameter din0_WIDTH = 32'd1;
parameter din1_WIDTH = 32'd1;
parameter dout_WIDTH = 32'd1;
input clk;
input reset;
input ce;
input[din0_WIDTH - 1:0] din0;
input[din1_WIDTH - 1:0] din1;
output[dout_WIDTH - 1:0] dout;



bfs_top_add_9ns_9ns_9_2_1_Adder_2 bfs_top_add_9ns_9ns_9_2_1_Adder_2_U(
    .clk( clk ),
    .reset( reset ),
    .ce( ce ),
    .a( din0 ),
    .b( din1 ),
    .s( dout ));

endmodule

// ==============================================================
// RTL generated by Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2020.2 (64-bit)
// Version: 2020.2
// Copyright (C) Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// 
// ===========================================================

`timescale 1 ns / 1 ps 

(* CORE_GENERATION_INFO="bfs_top_bfs_top,hls_ip_2020_2,{HLS_INPUT_TYPE=cxx,HLS_INPUT_FLOAT=0,HLS_INPUT_FIXED=0,HLS_INPUT_PART=xc7z020-clg484-1,HLS_INPUT_CLOCK=2.000000,HLS_INPUT_ARCH=others,HLS_SYN_CLOCK=2.776000,HLS_SYN_LAT=-1,HLS_SYN_TPT=none,HLS_SYN_MEM=0,HLS_SYN_DSP=0,HLS_SYN_FF=2040,HLS_SYN_LUT=636,HLS_VERSION=2020_2}" *)

module bfs_top (
        ap_clk,
        ap_rst,
        ap_start,
        ap_done,
        ap_idle,
        ap_ready,
        nodes_address0,
        nodes_ce0,
        nodes_q0,
        edges_address0,
        edges_ce0,
        edges_q0,
        starting_node,
        level_address0,
        level_ce0,
        level_we0,
        level_d0,
        level_q0,
        level_counts_address0,
        level_counts_ce0,
        level_counts_we0,
        level_counts_d0
);

parameter    ap_ST_fsm_state1 = 26'd1;
parameter    ap_ST_fsm_state2 = 26'd2;
parameter    ap_ST_fsm_state3 = 26'd4;
parameter    ap_ST_fsm_state4 = 26'd8;
parameter    ap_ST_fsm_state5 = 26'd16;
parameter    ap_ST_fsm_state6 = 26'd32;
parameter    ap_ST_fsm_state7 = 26'd64;
parameter    ap_ST_fsm_state8 = 26'd128;
parameter    ap_ST_fsm_state9 = 26'd256;
parameter    ap_ST_fsm_state10 = 26'd512;
parameter    ap_ST_fsm_state11 = 26'd1024;
parameter    ap_ST_fsm_state12 = 26'd2048;
parameter    ap_ST_fsm_state13 = 26'd4096;
parameter    ap_ST_fsm_state14 = 26'd8192;
parameter    ap_ST_fsm_state15 = 26'd16384;
parameter    ap_ST_fsm_state16 = 26'd32768;
parameter    ap_ST_fsm_state17 = 26'd65536;
parameter    ap_ST_fsm_pp0_stage0 = 26'd131072;
parameter    ap_ST_fsm_pp0_stage1 = 26'd262144;
parameter    ap_ST_fsm_pp0_stage2 = 26'd524288;
parameter    ap_ST_fsm_pp0_stage3 = 26'd1048576;
parameter    ap_ST_fsm_pp0_stage4 = 26'd2097152;
parameter    ap_ST_fsm_pp0_stage5 = 26'd4194304;
parameter    ap_ST_fsm_state30 = 26'd8388608;
parameter    ap_ST_fsm_state31 = 26'd16777216;
parameter    ap_ST_fsm_state32 = 26'd33554432;

input   ap_clk;
input   ap_rst;
input   ap_start;
output   ap_done;
output   ap_idle;
output   ap_ready;
output  [7:0] nodes_address0;
output   nodes_ce0;
input  [127:0] nodes_q0;
output  [11:0] edges_address0;
output   edges_ce0;
input  [63:0] edges_q0;
input  [63:0] starting_node;
output  [7:0] level_address0;
output   level_ce0;
output   level_we0;
output  [7:0] level_d0;
input  [7:0] level_q0;
output  [3:0] level_counts_address0;
output   level_counts_ce0;
output   level_counts_we0;
output  [63:0] level_counts_d0;

reg ap_done;
reg ap_idle;
reg ap_ready;
reg nodes_ce0;
reg edges_ce0;
reg[7:0] level_address0;
reg level_ce0;
reg level_we0;
reg[7:0] level_d0;
reg[3:0] level_counts_address0;
reg level_counts_ce0;
reg level_counts_we0;
reg[63:0] level_counts_d0;

(* fsm_encoding = "none" *) reg   [25:0] ap_CS_fsm;
wire    ap_CS_fsm_state1;
reg   [63:0] e_1_reg_194;
reg   [63:0] cnt_1_reg_205;
reg   [7:0] reg_244;
wire    ap_CS_fsm_state10;
wire    ap_CS_fsm_pp0_stage1;
reg    ap_enable_reg_pp0_iter1;
wire    ap_block_state19_pp0_stage1_iter0;
wire    ap_block_state25_pp0_stage1_iter1;
wire    ap_block_pp0_stage1_11001;
reg   [0:0] icmp_ln195_1_reg_417;
reg   [0:0] icmp_ln195_1_reg_417_pp0_iter1_reg;
wire    ap_CS_fsm_state3;
wire   [7:0] grp_fu_258_p2;
reg   [7:0] empty_reg_357;
wire    ap_CS_fsm_state4;
wire   [63:0] grp_fu_248_p2;
reg   [63:0] add_ln188_reg_362;
wire    ap_CS_fsm_state5;
wire   [0:0] icmp_ln191_fu_270_p2;
reg   [0:0] icmp_ln191_reg_368;
wire    ap_CS_fsm_state6;
wire   [8:0] grp_fu_264_p2;
reg   [8:0] n_1_reg_372;
wire    ap_CS_fsm_state7;
wire   [63:0] zext_ln191_fu_276_p1;
reg   [63:0] zext_ln191_reg_377;
wire   [0:0] icmp_ln192_fu_289_p2;
reg   [0:0] icmp_ln192_reg_392;
wire    ap_CS_fsm_state11;
wire    ap_CS_fsm_state12;
wire   [63:0] tmp_begin_fu_295_p1;
reg   [63:0] tmp_begin_reg_401;
wire    ap_CS_fsm_state15;
reg   [63:0] tmp_end_reg_407;
wire   [0:0] icmp_ln195_fu_309_p2;
reg   [0:0] icmp_ln195_reg_413;
wire    ap_CS_fsm_state16;
wire   [0:0] icmp_ln195_1_fu_313_p2;
wire    ap_CS_fsm_pp0_stage0;
wire    ap_block_state18_pp0_stage0_iter0;
wire    ap_block_state24_pp0_stage0_iter1;
wire    ap_block_pp0_stage0_11001;
reg   [7:0] level_addr_2_reg_426;
wire    ap_CS_fsm_pp0_stage3;
wire    ap_block_state21_pp0_stage3_iter0;
wire    ap_block_state27_pp0_stage3_iter1;
wire    ap_block_pp0_stage3_11001;
wire   [63:0] grp_fu_318_p2;
reg   [63:0] e_2_reg_431;
wire    ap_CS_fsm_pp0_stage5;
reg    ap_enable_reg_pp0_iter0;
wire    ap_block_state23_pp0_stage5_iter0;
wire    ap_block_state29_pp0_stage5_iter1;
wire    ap_block_pp0_stage5_11001;
wire   [0:0] icmp_ln199_fu_324_p2;
reg   [0:0] icmp_ln199_reg_436;
wire    ap_CS_fsm_pp0_stage2;
wire    ap_block_state20_pp0_stage2_iter0;
wire    ap_block_state26_pp0_stage2_iter1;
wire    ap_block_pp0_stage2_11001;
wire   [63:0] grp_fu_330_p2;
reg   [63:0] cnt_4_reg_440;
wire    ap_CS_fsm_pp0_stage4;
wire    ap_block_state22_pp0_stage4_iter0;
wire    ap_block_state28_pp0_stage4_iter1;
wire    ap_block_pp0_stage4_11001;
wire    ap_CS_fsm_state17;
wire    ap_block_pp0_stage5_subdone;
reg    ap_condition_pp0_flush_enable;
wire    ap_block_pp0_stage2_subdone;
reg   [63:0] horizon_reg_156;
wire    ap_CS_fsm_state2;
wire    ap_CS_fsm_state32;
wire   [0:0] icmp_ln206_fu_336_p2;
reg   [8:0] n_reg_168;
wire    ap_CS_fsm_state31;
reg   [63:0] cnt_reg_180;
reg   [63:0] ap_phi_mux_e_1_phi_fu_197_p4;
wire    ap_block_pp0_stage0;
reg   [63:0] ap_phi_mux_cnt_2_phi_fu_220_p4;
reg   [63:0] ap_phi_reg_pp0_iter1_cnt_2_reg_216;
wire   [63:0] ap_phi_reg_pp0_iter0_cnt_2_reg_216;
reg   [63:0] cnt_3_reg_228;
wire    ap_CS_fsm_state30;
wire    ap_block_pp0_stage3;
wire    ap_CS_fsm_state8;
wire    ap_CS_fsm_state9;
wire    ap_block_pp0_stage4;
wire    ap_CS_fsm_state13;
wire    ap_CS_fsm_state14;
wire   [7:0] grp_fu_258_p0;
wire  signed [31:0] sext_ln192_fu_281_p1;
wire   [63:0] zext_ln192_fu_285_p1;
wire    ap_block_pp0_stage2;
reg   [25:0] ap_NS_fsm;
wire    ap_block_pp0_stage0_subdone;
wire    ap_block_pp0_stage1_subdone;
wire    ap_block_pp0_stage3_subdone;
wire    ap_block_pp0_stage4_subdone;
reg    ap_idle_pp0;
wire    ap_enable_pp0;
wire    ap_ce_reg;

// power-on initialization
initial begin
#0 ap_CS_fsm = 26'd1;
#0 ap_enable_reg_pp0_iter1 = 1'b0;
#0 ap_enable_reg_pp0_iter0 = 1'b0;
end

bfs_top_add_64ns_64ns_64_3_1 #(
    .ID( 1 ),
    .NUM_STAGE( 3 ),
    .din0_WIDTH( 64 ),
    .din1_WIDTH( 64 ),
    .dout_WIDTH( 64 ))
add_64ns_64ns_64_3_1_U1(
    .clk(ap_clk),
    .reset(ap_rst),
    .din0(horizon_reg_156),
    .din1(64'd1),
    .ce(1'b1),
    .dout(grp_fu_248_p2)
);

bfs_top_add_8ns_8ns_8_2_1 #(
    .ID( 1 ),
    .NUM_STAGE( 2 ),
    .din0_WIDTH( 8 ),
    .din1_WIDTH( 8 ),
    .dout_WIDTH( 8 ))
add_8ns_8ns_8_2_1_U2(
    .clk(ap_clk),
    .reset(ap_rst),
    .din0(grp_fu_258_p0),
    .din1(8'd1),
    .ce(1'b1),
    .dout(grp_fu_258_p2)
);

bfs_top_add_9ns_9ns_9_2_1 #(
    .ID( 1 ),
    .NUM_STAGE( 2 ),
    .din0_WIDTH( 9 ),
    .din1_WIDTH( 9 ),
    .dout_WIDTH( 9 ))
add_9ns_9ns_9_2_1_U3(
    .clk(ap_clk),
    .reset(ap_rst),
    .din0(n_reg_168),
    .din1(9'd1),
    .ce(1'b1),
    .dout(grp_fu_264_p2)
);

bfs_top_add_64ns_64ns_64_3_1 #(
    .ID( 1 ),
    .NUM_STAGE( 3 ),
    .din0_WIDTH( 64 ),
    .din1_WIDTH( 64 ),
    .dout_WIDTH( 64 ))
add_64ns_64ns_64_3_1_U4(
    .clk(ap_clk),
    .reset(ap_rst),
    .din0(e_1_reg_194),
    .din1(64'd1),
    .ce(1'b1),
    .dout(grp_fu_318_p2)
);

bfs_top_add_64ns_64ns_64_3_1 #(
    .ID( 1 ),
    .NUM_STAGE( 3 ),
    .din0_WIDTH( 64 ),
    .din1_WIDTH( 64 ),
    .dout_WIDTH( 64 ))
add_64ns_64ns_64_3_1_U5(
    .clk(ap_clk),
    .reset(ap_rst),
    .din0(cnt_1_reg_205),
    .din1(64'd1),
    .ce(1'b1),
    .dout(grp_fu_330_p2)
);

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_CS_fsm <= ap_ST_fsm_state1;
    end else begin
        ap_CS_fsm <= ap_NS_fsm;
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter0 <= 1'b0;
    end else begin
        if ((1'b1 == ap_condition_pp0_flush_enable)) begin
            ap_enable_reg_pp0_iter0 <= 1'b0;
        end else if (((1'b1 == ap_CS_fsm_state17) & (icmp_ln195_reg_413 == 1'd1))) begin
            ap_enable_reg_pp0_iter0 <= 1'b1;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst == 1'b1) begin
        ap_enable_reg_pp0_iter1 <= 1'b0;
    end else begin
        if ((((1'b0 == ap_block_pp0_stage2_subdone) & (ap_enable_reg_pp0_iter0 == 1'b0) & (1'b1 == ap_CS_fsm_pp0_stage2)) | ((1'b0 == ap_block_pp0_stage5_subdone) & (1'b1 == ap_CS_fsm_pp0_stage5)))) begin
            ap_enable_reg_pp0_iter1 <= ap_enable_reg_pp0_iter0;
        end else if (((1'b1 == ap_CS_fsm_state17) & (icmp_ln195_reg_413 == 1'd1))) begin
            ap_enable_reg_pp0_iter1 <= 1'b0;
        end
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage3_11001) & (ap_enable_reg_pp0_iter1 == 1'b1) & (icmp_ln199_reg_436 == 1'd0) & (1'b1 == ap_CS_fsm_pp0_stage3) & (icmp_ln195_1_reg_417_pp0_iter1_reg == 1'd0))) begin
        ap_phi_reg_pp0_iter1_cnt_2_reg_216 <= cnt_1_reg_205;
    end else if (((1'b0 == ap_block_pp0_stage5_11001) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage5))) begin
        ap_phi_reg_pp0_iter1_cnt_2_reg_216 <= ap_phi_reg_pp0_iter0_cnt_2_reg_216;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b1 == ap_CS_fsm_state17) & (icmp_ln195_reg_413 == 1'd1))) begin
        cnt_1_reg_205 <= cnt_reg_180;
    end else if (((1'b0 == ap_block_pp0_stage5_11001) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage5) & (icmp_ln195_1_reg_417_pp0_iter1_reg == 1'd0))) begin
        cnt_1_reg_205 <= ap_phi_mux_cnt_2_phi_fu_220_p4;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state30)) begin
        cnt_3_reg_228 <= cnt_1_reg_205;
    end else if ((((1'b1 == ap_CS_fsm_state17) & (icmp_ln195_reg_413 == 1'd0)) | ((1'b1 == ap_CS_fsm_state12) & (icmp_ln192_reg_392 == 1'd0)))) begin
        cnt_3_reg_228 <= cnt_reg_180;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state31)) begin
        cnt_reg_180 <= cnt_3_reg_228;
    end else if ((1'b1 == ap_CS_fsm_state5)) begin
        cnt_reg_180 <= 64'd0;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b1 == ap_CS_fsm_state17) & (icmp_ln195_reg_413 == 1'd1))) begin
        e_1_reg_194 <= tmp_begin_reg_401;
    end else if (((1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0) & (icmp_ln195_1_reg_417 == 1'd0))) begin
        e_1_reg_194 <= e_2_reg_431;
    end
end

always @ (posedge ap_clk) begin
    if (((icmp_ln206_fu_336_p2 == 1'd0) & (1'b1 == ap_CS_fsm_state32))) begin
        horizon_reg_156 <= add_ln188_reg_362;
    end else if ((1'b1 == ap_CS_fsm_state2)) begin
        horizon_reg_156 <= 64'd0;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state31)) begin
        n_reg_168 <= n_1_reg_372;
    end else if ((1'b1 == ap_CS_fsm_state5)) begin
        n_reg_168 <= 9'd0;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state5)) begin
        add_ln188_reg_362 <= grp_fu_248_p2;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage4_11001) & (icmp_ln199_reg_436 == 1'd1) & (1'b1 == ap_CS_fsm_pp0_stage4) & (icmp_ln195_1_reg_417_pp0_iter1_reg == 1'd0))) begin
        cnt_4_reg_440 <= grp_fu_330_p2;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage5_11001) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage5) & (icmp_ln195_1_reg_417 == 1'd0))) begin
        e_2_reg_431 <= grp_fu_318_p2;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state4)) begin
        empty_reg_357 <= grp_fu_258_p2;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state6)) begin
        icmp_ln191_reg_368 <= icmp_ln191_fu_270_p2;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state11)) begin
        icmp_ln192_reg_392 <= icmp_ln192_fu_289_p2;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage0_11001) & (1'b1 == ap_CS_fsm_pp0_stage0))) begin
        icmp_ln195_1_reg_417 <= icmp_ln195_1_fu_313_p2;
        icmp_ln195_1_reg_417_pp0_iter1_reg <= icmp_ln195_1_reg_417;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state16)) begin
        icmp_ln195_reg_413 <= icmp_ln195_fu_309_p2;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage2_11001) & (1'b1 == ap_CS_fsm_pp0_stage2) & (icmp_ln195_1_reg_417_pp0_iter1_reg == 1'd0))) begin
        icmp_ln199_reg_436 <= icmp_ln199_fu_324_p2;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b0 == ap_block_pp0_stage3_11001) & (1'b1 == ap_CS_fsm_pp0_stage3) & (icmp_ln195_1_reg_417 == 1'd0))) begin
        level_addr_2_reg_426 <= edges_q0;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state7)) begin
        n_1_reg_372 <= grp_fu_264_p2;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b1 == ap_CS_fsm_state10) | ((1'b0 == ap_block_pp0_stage1_11001) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage1) & (icmp_ln195_1_reg_417_pp0_iter1_reg == 1'd0)))) begin
        reg_244 <= level_q0;
    end
end

always @ (posedge ap_clk) begin
    if ((1'b1 == ap_CS_fsm_state15)) begin
        tmp_begin_reg_401 <= tmp_begin_fu_295_p1;
        tmp_end_reg_407 <= {{nodes_q0[127:64]}};
    end
end

always @ (posedge ap_clk) begin
    if (((1'b1 == ap_CS_fsm_state7) & (icmp_ln191_reg_368 == 1'd0))) begin
        zext_ln191_reg_377[8 : 0] <= zext_ln191_fu_276_p1[8 : 0];
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage5_subdone) & (1'b1 == ap_CS_fsm_pp0_stage5) & (icmp_ln195_1_reg_417 == 1'd1))) begin
        ap_condition_pp0_flush_enable = 1'b1;
    end else begin
        ap_condition_pp0_flush_enable = 1'b0;
    end
end

always @ (*) begin
    if (((icmp_ln206_fu_336_p2 == 1'd1) & (1'b1 == ap_CS_fsm_state32))) begin
        ap_done = 1'b1;
    end else begin
        ap_done = 1'b0;
    end
end

always @ (*) begin
    if (((ap_start == 1'b0) & (1'b1 == ap_CS_fsm_state1))) begin
        ap_idle = 1'b1;
    end else begin
        ap_idle = 1'b0;
    end
end

always @ (*) begin
    if (((ap_enable_reg_pp0_iter1 == 1'b0) & (ap_enable_reg_pp0_iter0 == 1'b0))) begin
        ap_idle_pp0 = 1'b1;
    end else begin
        ap_idle_pp0 = 1'b0;
    end
end

always @ (*) begin
    if (((icmp_ln199_reg_436 == 1'd1) & (icmp_ln195_1_reg_417_pp0_iter1_reg == 1'd0))) begin
        ap_phi_mux_cnt_2_phi_fu_220_p4 = cnt_4_reg_440;
    end else begin
        ap_phi_mux_cnt_2_phi_fu_220_p4 = ap_phi_reg_pp0_iter1_cnt_2_reg_216;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage0) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0) & (icmp_ln195_1_reg_417 == 1'd0))) begin
        ap_phi_mux_e_1_phi_fu_197_p4 = e_2_reg_431;
    end else begin
        ap_phi_mux_e_1_phi_fu_197_p4 = e_1_reg_194;
    end
end

always @ (*) begin
    if (((icmp_ln206_fu_336_p2 == 1'd1) & (1'b1 == ap_CS_fsm_state32))) begin
        ap_ready = 1'b1;
    end else begin
        ap_ready = 1'b0;
    end
end

always @ (*) begin
    if ((((1'b0 == ap_block_pp0_stage1_11001) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage1)) | ((1'b0 == ap_block_pp0_stage2_11001) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage2)) | ((1'b0 == ap_block_pp0_stage3_11001) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage3)) | ((1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0)))) begin
        edges_ce0 = 1'b1;
    end else begin
        edges_ce0 = 1'b0;
    end
end

always @ (*) begin
    if ((((1'b0 == ap_block_pp0_stage4) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage4)) | ((1'b0 == ap_block_pp0_stage3) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage3)))) begin
        level_address0 = level_addr_2_reg_426;
    end else if ((1'b1 == ap_CS_fsm_state7)) begin
        level_address0 = zext_ln191_fu_276_p1;
    end else if ((1'b1 == ap_CS_fsm_state1)) begin
        level_address0 = starting_node;
    end else begin
        level_address0 = 'bx;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state10) | (1'b1 == ap_CS_fsm_state9) | (1'b1 == ap_CS_fsm_state8) | (1'b1 == ap_CS_fsm_state2) | (1'b1 == ap_CS_fsm_state7) | ((1'b0 == ap_block_pp0_stage1_11001) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage1)) | ((ap_start == 1'b1) & (1'b1 == ap_CS_fsm_state1)) | ((1'b0 == ap_block_pp0_stage4_11001) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage4)) | ((1'b0 == ap_block_pp0_stage4_11001) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage4)) | ((1'b0 == ap_block_pp0_stage5_11001) & (ap_enable_reg_pp0_iter0 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage5)) | ((1'b0 == ap_block_pp0_stage3_11001) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage3)) | ((1'b0 == ap_block_pp0_stage0_11001) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage0)))) begin
        level_ce0 = 1'b1;
    end else begin
        level_ce0 = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state7)) begin
        level_counts_address0 = add_ln188_reg_362;
    end else if ((1'b1 == ap_CS_fsm_state1)) begin
        level_counts_address0 = 64'd0;
    end else begin
        level_counts_address0 = 'bx;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state32) | (1'b1 == ap_CS_fsm_state2) | (1'b1 == ap_CS_fsm_state7) | ((ap_start == 1'b1) & (1'b1 == ap_CS_fsm_state1)))) begin
        level_counts_ce0 = 1'b1;
    end else begin
        level_counts_ce0 = 1'b0;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state7)) begin
        level_counts_d0 = cnt_reg_180;
    end else if ((1'b1 == ap_CS_fsm_state1)) begin
        level_counts_d0 = 64'd1;
    end else begin
        level_counts_d0 = 'bx;
    end
end

always @ (*) begin
    if ((((ap_start == 1'b1) & (1'b1 == ap_CS_fsm_state1)) | ((1'b1 == ap_CS_fsm_state7) & (icmp_ln191_reg_368 == 1'd1)))) begin
        level_counts_we0 = 1'b1;
    end else begin
        level_counts_we0 = 1'b0;
    end
end

always @ (*) begin
    if (((1'b0 == ap_block_pp0_stage3) & (ap_enable_reg_pp0_iter1 == 1'b1) & (1'b1 == ap_CS_fsm_pp0_stage3))) begin
        level_d0 = empty_reg_357;
    end else if ((1'b1 == ap_CS_fsm_state1)) begin
        level_d0 = 8'd0;
    end else begin
        level_d0 = 'bx;
    end
end

always @ (*) begin
    if ((((ap_start == 1'b1) & (1'b1 == ap_CS_fsm_state1)) | ((1'b0 == ap_block_pp0_stage3_11001) & (ap_enable_reg_pp0_iter1 == 1'b1) & (icmp_ln199_reg_436 == 1'd1) & (1'b1 == ap_CS_fsm_pp0_stage3) & (icmp_ln195_1_reg_417_pp0_iter1_reg == 1'd0)))) begin
        level_we0 = 1'b1;
    end else begin
        level_we0 = 1'b0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state14) | (1'b1 == ap_CS_fsm_state13) | (1'b1 == ap_CS_fsm_state15) | (1'b1 == ap_CS_fsm_state12))) begin
        nodes_ce0 = 1'b1;
    end else begin
        nodes_ce0 = 1'b0;
    end
end

always @ (*) begin
    case (ap_CS_fsm)
        ap_ST_fsm_state1 : begin
            if (((ap_start == 1'b1) & (1'b1 == ap_CS_fsm_state1))) begin
                ap_NS_fsm = ap_ST_fsm_state2;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state1;
            end
        end
        ap_ST_fsm_state2 : begin
            ap_NS_fsm = ap_ST_fsm_state3;
        end
        ap_ST_fsm_state3 : begin
            ap_NS_fsm = ap_ST_fsm_state4;
        end
        ap_ST_fsm_state4 : begin
            ap_NS_fsm = ap_ST_fsm_state5;
        end
        ap_ST_fsm_state5 : begin
            ap_NS_fsm = ap_ST_fsm_state6;
        end
        ap_ST_fsm_state6 : begin
            ap_NS_fsm = ap_ST_fsm_state7;
        end
        ap_ST_fsm_state7 : begin
            if (((1'b1 == ap_CS_fsm_state7) & (icmp_ln191_reg_368 == 1'd1))) begin
                ap_NS_fsm = ap_ST_fsm_state32;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state8;
            end
        end
        ap_ST_fsm_state8 : begin
            ap_NS_fsm = ap_ST_fsm_state9;
        end
        ap_ST_fsm_state9 : begin
            ap_NS_fsm = ap_ST_fsm_state10;
        end
        ap_ST_fsm_state10 : begin
            ap_NS_fsm = ap_ST_fsm_state11;
        end
        ap_ST_fsm_state11 : begin
            ap_NS_fsm = ap_ST_fsm_state12;
        end
        ap_ST_fsm_state12 : begin
            if (((1'b1 == ap_CS_fsm_state12) & (icmp_ln192_reg_392 == 1'd0))) begin
                ap_NS_fsm = ap_ST_fsm_state31;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state13;
            end
        end
        ap_ST_fsm_state13 : begin
            ap_NS_fsm = ap_ST_fsm_state14;
        end
        ap_ST_fsm_state14 : begin
            ap_NS_fsm = ap_ST_fsm_state15;
        end
        ap_ST_fsm_state15 : begin
            ap_NS_fsm = ap_ST_fsm_state16;
        end
        ap_ST_fsm_state16 : begin
            ap_NS_fsm = ap_ST_fsm_state17;
        end
        ap_ST_fsm_state17 : begin
            if (((1'b1 == ap_CS_fsm_state17) & (icmp_ln195_reg_413 == 1'd1))) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state31;
            end
        end
        ap_ST_fsm_pp0_stage0 : begin
            if ((1'b0 == ap_block_pp0_stage0_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage1;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end
        end
        ap_ST_fsm_pp0_stage1 : begin
            if ((1'b0 == ap_block_pp0_stage1_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage2;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage1;
            end
        end
        ap_ST_fsm_pp0_stage2 : begin
            if ((~((1'b0 == ap_block_pp0_stage2_subdone) & (ap_enable_reg_pp0_iter1 == 1'b1) & (ap_enable_reg_pp0_iter0 == 1'b0) & (1'b1 == ap_CS_fsm_pp0_stage2)) & (1'b0 == ap_block_pp0_stage2_subdone))) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage3;
            end else if (((1'b0 == ap_block_pp0_stage2_subdone) & (ap_enable_reg_pp0_iter1 == 1'b1) & (ap_enable_reg_pp0_iter0 == 1'b0) & (1'b1 == ap_CS_fsm_pp0_stage2))) begin
                ap_NS_fsm = ap_ST_fsm_state30;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage2;
            end
        end
        ap_ST_fsm_pp0_stage3 : begin
            if ((1'b0 == ap_block_pp0_stage3_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage4;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage3;
            end
        end
        ap_ST_fsm_pp0_stage4 : begin
            if ((1'b0 == ap_block_pp0_stage4_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage5;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage4;
            end
        end
        ap_ST_fsm_pp0_stage5 : begin
            if ((1'b0 == ap_block_pp0_stage5_subdone)) begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage0;
            end else begin
                ap_NS_fsm = ap_ST_fsm_pp0_stage5;
            end
        end
        ap_ST_fsm_state30 : begin
            ap_NS_fsm = ap_ST_fsm_state31;
        end
        ap_ST_fsm_state31 : begin
            ap_NS_fsm = ap_ST_fsm_state6;
        end
        ap_ST_fsm_state32 : begin
            if (((icmp_ln206_fu_336_p2 == 1'd1) & (1'b1 == ap_CS_fsm_state32))) begin
                ap_NS_fsm = ap_ST_fsm_state1;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state3;
            end
        end
        default : begin
            ap_NS_fsm = 'bx;
        end
    endcase
end

assign ap_CS_fsm_pp0_stage0 = ap_CS_fsm[32'd17];

assign ap_CS_fsm_pp0_stage1 = ap_CS_fsm[32'd18];

assign ap_CS_fsm_pp0_stage2 = ap_CS_fsm[32'd19];

assign ap_CS_fsm_pp0_stage3 = ap_CS_fsm[32'd20];

assign ap_CS_fsm_pp0_stage4 = ap_CS_fsm[32'd21];

assign ap_CS_fsm_pp0_stage5 = ap_CS_fsm[32'd22];

assign ap_CS_fsm_state1 = ap_CS_fsm[32'd0];

assign ap_CS_fsm_state10 = ap_CS_fsm[32'd9];

assign ap_CS_fsm_state11 = ap_CS_fsm[32'd10];

assign ap_CS_fsm_state12 = ap_CS_fsm[32'd11];

assign ap_CS_fsm_state13 = ap_CS_fsm[32'd12];

assign ap_CS_fsm_state14 = ap_CS_fsm[32'd13];

assign ap_CS_fsm_state15 = ap_CS_fsm[32'd14];

assign ap_CS_fsm_state16 = ap_CS_fsm[32'd15];

assign ap_CS_fsm_state17 = ap_CS_fsm[32'd16];

assign ap_CS_fsm_state2 = ap_CS_fsm[32'd1];

assign ap_CS_fsm_state3 = ap_CS_fsm[32'd2];

assign ap_CS_fsm_state30 = ap_CS_fsm[32'd23];

assign ap_CS_fsm_state31 = ap_CS_fsm[32'd24];

assign ap_CS_fsm_state32 = ap_CS_fsm[32'd25];

assign ap_CS_fsm_state4 = ap_CS_fsm[32'd3];

assign ap_CS_fsm_state5 = ap_CS_fsm[32'd4];

assign ap_CS_fsm_state6 = ap_CS_fsm[32'd5];

assign ap_CS_fsm_state7 = ap_CS_fsm[32'd6];

assign ap_CS_fsm_state8 = ap_CS_fsm[32'd7];

assign ap_CS_fsm_state9 = ap_CS_fsm[32'd8];

assign ap_block_pp0_stage0 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage0_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage1_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage1_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage2 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage2_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage2_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage3 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage3_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage3_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage4 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage4_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage4_subdone = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage5_11001 = ~(1'b1 == 1'b1);

assign ap_block_pp0_stage5_subdone = ~(1'b1 == 1'b1);

assign ap_block_state18_pp0_stage0_iter0 = ~(1'b1 == 1'b1);

assign ap_block_state19_pp0_stage1_iter0 = ~(1'b1 == 1'b1);

assign ap_block_state20_pp0_stage2_iter0 = ~(1'b1 == 1'b1);

assign ap_block_state21_pp0_stage3_iter0 = ~(1'b1 == 1'b1);

assign ap_block_state22_pp0_stage4_iter0 = ~(1'b1 == 1'b1);

assign ap_block_state23_pp0_stage5_iter0 = ~(1'b1 == 1'b1);

assign ap_block_state24_pp0_stage0_iter1 = ~(1'b1 == 1'b1);

assign ap_block_state25_pp0_stage1_iter1 = ~(1'b1 == 1'b1);

assign ap_block_state26_pp0_stage2_iter1 = ~(1'b1 == 1'b1);

assign ap_block_state27_pp0_stage3_iter1 = ~(1'b1 == 1'b1);

assign ap_block_state28_pp0_stage4_iter1 = ~(1'b1 == 1'b1);

assign ap_block_state29_pp0_stage5_iter1 = ~(1'b1 == 1'b1);

assign ap_enable_pp0 = (ap_idle_pp0 ^ 1'b1);

assign ap_phi_reg_pp0_iter0_cnt_2_reg_216 = 'bx;

assign edges_address0 = ap_phi_mux_e_1_phi_fu_197_p4;

assign grp_fu_258_p0 = horizon_reg_156[7:0];

assign icmp_ln191_fu_270_p2 = ((n_reg_168 == 9'd256) ? 1'b1 : 1'b0);

assign icmp_ln192_fu_289_p2 = ((zext_ln192_fu_285_p1 == horizon_reg_156) ? 1'b1 : 1'b0);

assign icmp_ln195_1_fu_313_p2 = ((ap_phi_mux_e_1_phi_fu_197_p4 == tmp_end_reg_407) ? 1'b1 : 1'b0);

assign icmp_ln195_fu_309_p2 = ((tmp_begin_reg_401 < tmp_end_reg_407) ? 1'b1 : 1'b0);

assign icmp_ln199_fu_324_p2 = ((reg_244 == 8'd127) ? 1'b1 : 1'b0);

assign icmp_ln206_fu_336_p2 = ((cnt_reg_180 == 64'd0) ? 1'b1 : 1'b0);

assign nodes_address0 = zext_ln191_reg_377;

assign sext_ln192_fu_281_p1 = $signed(reg_244);

assign tmp_begin_fu_295_p1 = nodes_q0[63:0];

assign zext_ln191_fu_276_p1 = n_reg_168;

assign zext_ln192_fu_285_p1 = $unsigned(sext_ln192_fu_281_p1);

always @ (posedge ap_clk) begin
    zext_ln191_reg_377[63:9] <= 55'b0000000000000000000000000000000000000000000000000000000;
end

endmodule //bfs_top
