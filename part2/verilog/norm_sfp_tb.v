`timescale 1ns/1ps

module norm_sfp_tb;


parameter total_cycle = 16;   // how many streamed Q vectors will be processed
parameter bw = 8;            // Q & K vector bit precision
parameter bw_psum = 2*bw+4;  // partial sum bit precision
parameter pr = 16;           // how many products added in each dot product 
parameter col = 8;           // how many dot product units are equipped

integer qk_file ; // file handler
integer qk_scan_file ; // file handler


integer  captured_data;
integer  weight [col*pr-1:0];
`define NULL 0


integer  K[col-1:0][pr-1:0];
integer  Q[total_cycle-1:0][pr-1:0];
integer  result[total_cycle-1:0][col-1:0];
integer  sum[total_cycle-1:0];


reg signed [bw_psum+3:0] abs_sum;
reg signed [bw_psum+3-7:0] abs_sum_trunc;

reg signed [bw_psum+3:0] sum_for_norm [total_cycle-1:0];
reg signed [bw_psum-1:0] one_norm;
reg signed [bw_psum*col-1:0] one_cycle_norm;
reg signed [bw_psum*col-1:0] all_normed_result[total_cycle-1:0];

reg signed [bw_psum-1:0] temp_result;


reg [bw_psum*col-1:0] sfp_in_prepared [total_cycle-1:0];



integer i,j,k,t,p,q,s,u, m;

integer error;


reg reset = 1;
reg clk = 0;
reg norm = 0;
reg [col*bw_psum-1:0] sfp_in;
wire [col*bw_psum-1:0] sfp_out;


reg [bw_psum-1:0] temp5b;
reg [bw_psum+3:0] temp_sum;
reg [bw_psum*col-1:0] temp16b;




norm_sfp #(.col(col), .pr(pr), .bw(bw), .bw_psum(bw_psum)) norm_inst (
    .reset(reset),
    .clk(clk),
    .sfp_in(sfp_in),
    .norm(norm),
    .sfp_out(sfp_out)
);




initial begin 

  $dumpfile("norm_sfp_tb.vcd");
  $dumpvars(0,norm_sfp_tb);

///// Q data txt reading /////

$display("##### Q data txt reading #####");


  qk_file = $fopen("qdata.txt", "r");

  //// To get rid of first 3 lines in data file ////
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);


  for (q=0; q<total_cycle; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
          Q[q][j] = captured_data;
          //$display("%d\n", K[q][j]);
    end
  end
/////////////////////////////////

  for (q=0; q<2; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
  end


///// K data txt reading /////

$display("##### K data txt reading #####");

  for (q=0; q<10; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
  end
  reset = 0;

  qk_file = $fopen("kdata.txt", "r");

  //// To get rid of first 4 lines in data file ////
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);




  for (q=0; q<col; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
          K[q][j] = captured_data;
          //$display("##### %d\n", K[q][j]);
    end
  end
/////////////////////////////////




/////////////// Estimated column result printing /////////////////
//$display("##### Estimated column result #####");

  for (t=0; t<total_cycle; t=t+1) begin
     for (q=0; q<col; q=q+1) begin
       result[t][q] = 0;
     end
  end

  for (t=0; t<total_cycle; t=t+1) begin
     for (q=0; q<col; q=q+1) begin
         for (k=0; k<pr; k=k+1) begin
            result[t][q] = result[t][q] + Q[t][k] * K[q][k];
         end

         temp5b = result[t][q];
         temp16b = {temp16b[139:0], temp5b};
     end

     //$display("%d %d %d %d %d %d %d %d", result[t][0], result[t][1], result[t][2], result[t][3], result[t][4], result[t][5], result[t][6], result[t][7]);
     //$display("prd @cycle%2d: %40h", t, temp16b);
     sfp_in_prepared[t] = temp16b;
  end
//////////////////////////////////////////////


/////////////// Estimated abs(sum) result printing /////////////////



$display("##### Estimated sum_abs, and norm result result #####");

  for (t=0; t<total_cycle; t=t+1) begin
     sum_for_norm[t] = 0;
  end

  for (t=0; t<total_cycle; t=t+1) begin
    for (q=0; q<col; q=q+1) begin
        if (result[t][q] > 0) begin 
            sum_for_norm[t] = sum_for_norm[t] + result[t][q];
        end  else begin
            sum_for_norm[t] = sum_for_norm[t] + result[t][q] * (-1);
        end
    end 

    for (q=0; q<col; q=q+1) begin
        temp_result = result[t][q];
        abs_sum = sum_for_norm[t];
        abs_sum_trunc = abs_sum[23:7];

        // norm_result[t][q] = temp_result / abs_sum_trunc; 
        one_norm = temp_result / abs_sum_trunc;
        one_cycle_norm = {one_cycle_norm[139:0], one_norm};
    end

    all_normed_result[t] = one_cycle_norm;

    $display("sum_abs @cycle%2d: %d", t, sum_for_norm[t]);
    $display("   norm result @cycle%2d: %40h", t, one_cycle_norm);

  end
//////////////////////////////////////////////



$display("##### Actual result #####");
  error = 0;
  for (t=0; t<total_cycle; t=t+1) begin
     sfp_in = sfp_in_prepared[t]; norm = 1;
     #0.5 clk = 1'b0;   
     #0.5 clk = 1'b1;

    if (t>0) begin
     if (sfp_out == all_normed_result[t-1]) begin
      $display("norm reuslt @cycle%2d: %40h matches", t-1, sfp_out);
     end else begin
      error=error+1;
      $display("norm reuslt @cycle%2d: %40h %40h doesn't match", t-1, sfp_out, all_normed_result[t-1]);
     end
    end
  end

  #0.5 clk = 1'b0;   
  #0.5 clk = 1'b1;

  if (sfp_out == all_normed_result[total_cycle-1]) begin
      $display("norm reuslt @cycle%2d: %40h matches", total_cycle-1, sfp_out);
     end else begin
      error=error+1;
      $display("norm reuslt @cycle%2d: %40h %40h doesn't match", total_cycle-1, sfp_out, all_normed_result[total_cycle-1]);
     end
  $display("total # of errors: %d", error);

  norm = 0;
  #0.5 clk = 1'b0;   
  #0.5 clk = 1'b1;
  
end


endmodule