// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module fullchip (clk1, clk2, mem_in1, mem_in2, inst1, inst2, reset1, reset2, out1, out2);

parameter col = 8;
parameter bw = 8;
parameter bw_psum = 2*bw+4;
parameter pr = 16;

input  clk1; 
input  [pr*bw-1:0] mem_in1; 
input  [18:0] inst1; 
input  reset1;

input  clk2; 
input  [pr*bw-1:0] mem_in2; 
input  [18:0] inst2; 
input  reset2;

output [bw_psum*col-1:0] out1;
output [bw_psum*col-1:0] out2;

wire [bw_psum+3:0] sum_core1;
wire [bw_psum+3:0] sum_core2;

wire req_out_core1;
wire req_out_core2;

wire ack_out_core1;
wire ack_out_core2;


core #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) core_inst1 (
      .reset(reset1), 
      .clk(clk1), 
      .mem_in(mem_in1), 
      .inst(inst1),
      .sum_out(sum_core1),
      .sum_in(sum_core2),
      .req_in(req_out_core2),
      .ack_in(ack_out_core2),
      .req_out(req_out_core1),
      .ack_out(ack_out_core1),
      .out(out1)

);

core #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) core_inst2 (
      .reset(reset2), 
      .clk(clk2), 
      .mem_in(mem_in2), 
      .inst(inst2),
      .sum_out(sum_core2),
      .sum_in(sum_core1),
      .req_in(req_out_core1),
      .ack_in(ack_out_core1),
      .req_out(req_out_core2),
      .ack_out(ack_out_core2),
      .out(out2)
);


endmodule
