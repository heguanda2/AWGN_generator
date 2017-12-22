// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.2 (win64) Build 1909853 Thu Jun 15 18:39:09 MDT 2017
// Date        : Fri Dec 22 10:17:04 2017
// Host        : Lab-PC running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode synth_stub
//               C:/Users/Lab/Desktop/Gengchen_stuff/super_gaus_noise/super_gaus_noise.srcs/sources_1/ip/super_mult/super_mult_stub.v
// Design      : super_mult
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx690tffg1761-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "mult_gen_v12_0_12,Vivado 2017.2" *)
module super_mult(CLK, A, B, P)
/* synthesis syn_black_box black_box_pad_pin="CLK,A[24:0],B[24:0],P[24:0]" */;
  input CLK;
  input [24:0]A;
  input [24:0]B;
  output [24:0]P;
endmodule
