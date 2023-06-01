module norm_sfp (reset, clk, sfp_in, norm, sfp_out);

parameter col = 8;
parameter pr = 16;

parameter bw = 8;
parameter bw_psum = 2*bw+4; // bandwidth

input reset;
input clk;
input norm;
wire  [col*bw_psum-1:0] abs;

input signed [col*bw_psum-1:0] sfp_in;  //  [Q0K0, Q0K1, ..., Q0K7] / ....
output [col*bw_psum-1:0] sfp_out;

wire signed [bw_psum-1:0] sfp_in_sign0;
wire signed [bw_psum-1:0] sfp_in_sign1;
wire signed [bw_psum-1:0] sfp_in_sign2;
wire signed [bw_psum-1:0] sfp_in_sign3;
wire signed [bw_psum-1:0] sfp_in_sign4;
wire signed [bw_psum-1:0] sfp_in_sign5;
wire signed [bw_psum-1:0] sfp_in_sign6;
wire signed [bw_psum-1:0] sfp_in_sign7;

reg signed [bw_psum-1:0] sfp_out_sign0;
reg signed [bw_psum-1:0] sfp_out_sign1;
reg signed [bw_psum-1:0] sfp_out_sign2;
reg signed [bw_psum-1:0] sfp_out_sign3;
reg signed [bw_psum-1:0] sfp_out_sign4;
reg signed [bw_psum-1:0] sfp_out_sign5;
reg signed [bw_psum-1:0] sfp_out_sign6;
reg signed [bw_psum-1:0] sfp_out_sign7;

// input diverge
assign sfp_in_sign0 =  sfp_in[bw_psum*1-1 : bw_psum*0];
assign sfp_in_sign1 =  sfp_in[bw_psum*2-1 : bw_psum*1];
assign sfp_in_sign2 =  sfp_in[bw_psum*3-1 : bw_psum*2];
assign sfp_in_sign3 =  sfp_in[bw_psum*4-1 : bw_psum*3];
assign sfp_in_sign4 =  sfp_in[bw_psum*5-1 : bw_psum*4];
assign sfp_in_sign5 =  sfp_in[bw_psum*6-1 : bw_psum*5];
assign sfp_in_sign6 =  sfp_in[bw_psum*7-1 : bw_psum*6];
assign sfp_in_sign7 =  sfp_in[bw_psum*8-1 : bw_psum*7];

// output merge
assign sfp_out[bw_psum*1-1 : bw_psum*0] = sfp_out_sign0;
assign sfp_out[bw_psum*2-1 : bw_psum*1] = sfp_out_sign1;
assign sfp_out[bw_psum*3-1 : bw_psum*2] = sfp_out_sign2;
assign sfp_out[bw_psum*4-1 : bw_psum*3] = sfp_out_sign3;
assign sfp_out[bw_psum*5-1 : bw_psum*4] = sfp_out_sign4;
assign sfp_out[bw_psum*6-1 : bw_psum*5] = sfp_out_sign5;
assign sfp_out[bw_psum*7-1 : bw_psum*6] = sfp_out_sign6;
assign sfp_out[bw_psum*8-1 : bw_psum*7] = sfp_out_sign7;


assign abs[bw_psum*1-1 : bw_psum*0] = (sfp_in[bw_psum*1-1]) ?  (~sfp_in[bw_psum*1-1 : bw_psum*0] + 1)  :  sfp_in[bw_psum*1-1 : bw_psum*0];
assign abs[bw_psum*2-1 : bw_psum*1] = (sfp_in[bw_psum*2-1]) ?  (~sfp_in[bw_psum*2-1 : bw_psum*1] + 1)  :  sfp_in[bw_psum*2-1 : bw_psum*1];
assign abs[bw_psum*3-1 : bw_psum*2] = (sfp_in[bw_psum*3-1]) ?  (~sfp_in[bw_psum*3-1 : bw_psum*2] + 1)  :  sfp_in[bw_psum*3-1 : bw_psum*2];
assign abs[bw_psum*4-1 : bw_psum*3] = (sfp_in[bw_psum*4-1]) ?  (~sfp_in[bw_psum*4-1 : bw_psum*3] + 1)  :  sfp_in[bw_psum*4-1 : bw_psum*3];
assign abs[bw_psum*5-1 : bw_psum*4] = (sfp_in[bw_psum*5-1]) ?  (~sfp_in[bw_psum*5-1 : bw_psum*4] + 1)  :  sfp_in[bw_psum*5-1 : bw_psum*4];
assign abs[bw_psum*6-1 : bw_psum*5] = (sfp_in[bw_psum*6-1]) ?  (~sfp_in[bw_psum*6-1 : bw_psum*5] + 1)  :  sfp_in[bw_psum*6-1 : bw_psum*5];
assign abs[bw_psum*7-1 : bw_psum*6] = (sfp_in[bw_psum*7-1]) ?  (~sfp_in[bw_psum*7-1 : bw_psum*6] + 1)  :  sfp_in[bw_psum*7-1 : bw_psum*6];
assign abs[bw_psum*8-1 : bw_psum*7] = (sfp_in[bw_psum*8-1]) ?  (~sfp_in[bw_psum*8-1 : bw_psum*7] + 1)  :  sfp_in[bw_psum*8-1 : bw_psum*7];



// 24 bits
wire signed [bw_psum+3:0] abs_sum;

assign abs_sum =    {4'b0, abs[bw_psum*1-1 : bw_psum*0]} +
                    {4'b0, abs[bw_psum*2-1 : bw_psum*1]} +
                    {4'b0, abs[bw_psum*3-1 : bw_psum*2]} +
                    {4'b0, abs[bw_psum*4-1 : bw_psum*3]} +
                    {4'b0, abs[bw_psum*5-1 : bw_psum*4]} +
                    {4'b0, abs[bw_psum*6-1 : bw_psum*5]} +
                    {4'b0, abs[bw_psum*7-1 : bw_psum*6]} +
                    {4'b0, abs[bw_psum*8-1 : bw_psum*7]};

wire signed [bw_psum+3-7:0] divider;

assign divider = abs_sum[bw_psum+3:7];



always @(posedge clk) begin
    if (norm) begin
     sfp_out_sign0 <= sfp_in_sign0 / divider;
     sfp_out_sign1 <= sfp_in_sign1 / divider;
     sfp_out_sign2 <= sfp_in_sign2 / divider;
     sfp_out_sign3 <= sfp_in_sign3 / divider;
     sfp_out_sign4 <= sfp_in_sign4 / divider;
     sfp_out_sign5 <= sfp_in_sign5 / divider;
     sfp_out_sign6 <= sfp_in_sign6 / divider;
     sfp_out_sign7 <= sfp_in_sign7 / divider;
    end
end



endmodule
