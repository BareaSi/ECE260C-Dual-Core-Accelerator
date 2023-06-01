// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 

`timescale 1ns/1ps

module fullchip_tb;

parameter total_cycle = 8;   // how many streamed Q vectors will be processed
parameter bw = 8;            // Q & K vector bit precision
parameter bw_psum = 2*bw+4;  // partial sum bit precision
parameter pr = 16;           // how many products added in each dot product 
parameter col = 8;           // how many dot product units are equipped
parameter handshake_cycle = 10; 

integer qk_file ; // file handler
integer qk_scan_file ; // file handler


integer  captured_data;
integer  weight [col*pr-1:0];
`define NULL 0



integer errors;
integer  K1[col-1:0][pr-1:0];
integer  K2[col-1:0][pr-1:0];

integer  Q[total_cycle-1:0][pr-1:0];

integer  result1[total_cycle-1:0][col-1:0];
integer  result2[total_cycle-1:0][col-1:0];

integer  sum1[total_cycle-1:0];
integer  sum2[total_cycle-1:0];

reg signed [bw_psum+3:0] abs_sum1;
reg signed [bw_psum+3-7:0] abs_sum_trunc1;
reg signed [bw_psum+3:0] abs_sum2;
reg signed [bw_psum+3-7:0] abs_sum_trunc2;

reg signed [bw_psum-1:0] chip_sum [total_cycle-1:0];


integer i,j,k,t,p,q,s,u, m;


// signal for core 1
reg reset1 = 1;
reg clk1 = 0;
reg [pr*bw-1:0] mem_in1; 
reg ofifo_rd1 = 0;
wire [18:0] inst1; 
reg div1 = 0;
reg acc1 = 0;
reg qmem_rd1 = 0;
reg qmem_wr1 = 0; 
reg kmem_rd1 = 0; 
reg kmem_wr1 = 0;
reg pmem_rd1 = 0; 
reg pmem_wr1 = 0; 
reg execute1 = 0;
reg load1 = 0;
reg [3:0] qkmem_add1 = 0;
reg [3:0] pmem_add1 = 0;

assign inst1[18] = div1;
assign inst1[17] = acc1;
assign inst1[16] = ofifo_rd1;
assign inst1[15:12] = qkmem_add1;
assign inst1[11:8]  = pmem_add1;
assign inst1[7] = execute1;
assign inst1[6] = load1;
assign inst1[5] = qmem_rd1;
assign inst1[4] = qmem_wr1;
assign inst1[3] = kmem_rd1;
assign inst1[2] = kmem_wr1;
assign inst1[1] = pmem_rd1;
assign inst1[0] = pmem_wr1;

// signal for core 2
reg reset2= 1;
reg clk2 = 0;
reg [pr*bw-1:0] mem_in2; 
reg ofifo_rd2 = 0;
wire [18:0] inst2; 
reg div2 = 0;
reg acc2 = 0;
reg qmem_rd2 = 0;
reg qmem_wr2 = 0; 
reg kmem_rd2 = 0; 
reg kmem_wr2 = 0;
reg pmem_rd2 = 0; 
reg pmem_wr2 = 0; 
reg execute2 = 0;
reg load2 = 0;
reg [3:0] qkmem_add2 = 0;
reg [3:0] pmem_add2 = 0;

assign inst2[18] = div2;
assign inst2[17] = acc2;
assign inst2[16] = ofifo_rd2;
assign inst2[15:12] = qkmem_add2;
assign inst2[11:8]  = pmem_add2;
assign inst2[7] = execute2;
assign inst2[6] = load2;
assign inst2[5] = qmem_rd2;
assign inst2[4] = qmem_wr2;
assign inst2[3] = kmem_rd2;
assign inst2[2] = kmem_wr2;
assign inst2[1] = pmem_rd2;
assign inst2[0] = pmem_wr2;



reg [bw_psum-1:0] temp5b;
reg [bw_psum+3:0] temp_sum;
reg [bw_psum*col-1:0] temp16b;



fullchip #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) fullchip_instance (
      .clk1(clk1),
      .clk2(clk2),
      .mem_in1(mem_in1),
      .mem_in2(mem_in2),
      .inst1(inst1),
      .inst2(inst2),
      .reset1(reset1),
      .reset2(reset2)
);



initial begin 

  $dumpfile("fullchip_tb.vcd");
  $dumpvars(0,fullchip_tb);



///// Q data txt reading /////
errors = 0;
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
          //$display("%d\n", Q[q][j]);
    end
  end
/////////////////////////////////




  for (q=0; q<2; q=q+1) begin
    #0.5 clk1 = 1'b0;       clk2 = 1'b0;   
    #0.5 clk1 = 1'b1;       clk2 = 1'b1;  
  end




///// K data txt reading /////

$display("##### core_one K data txt reading #####");

  for (q=0; q<10; q=q+1) begin
    #0.5 clk1 = 1'b0;   clk2 = 1'b0;   
    #0.5 clk1 = 1'b1;   clk2 = 1'b1; 
  end
  reset1 = 0; reset2 = 0;

  qk_file = $fopen("kdata_core0.txt", "r");

  //// To get rid of first 4 lines in data file ////
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);

  for (q=0; q<col; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
          K1[q][j] = captured_data;
          //$display("##### %d\n", K1[q][j]);
    end
  end

$display("##### core_two K data txt reading #####");
  qk_file = $fopen("kdata_core1.txt", "r");

  //// To get rid of first 4 lines in data file ////
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);

  for (q=0; q<col; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
          K2[q][j] = captured_data;
          //$display("##### %d\n", K2[q][j]);
    end
  end
/////////////////////////////////








/////////////// Estimated result printing /////////////////


$display("##### Estimated core 1 multiplication result #####");

  for (t=0; t<total_cycle; t=t+1) begin
     for (q=0; q<col; q=q+1) begin
       result1[t][q] = 0;
     end

     sum1[t] = 0;
  end

  for (t=0; t<total_cycle; t=t+1) begin
     for (q=0; q<col; q=q+1) begin
         for (k=0; k<pr; k=k+1) begin
            result1[t][q] = result1[t][q] + Q[t][k] * K1[q][k];
         end

         if (result1[t][q] > 0) begin 
             sum1[t] = sum1[t] + result1[t][q];
         end  else begin
             sum1[t] = sum1[t] + result1[t][q] * (-1);
         end

         temp5b = result1[t][q];
         temp16b = {temp16b[139:0], temp5b};
     end

     //$display("%d %d %d %d %d %d %d %d", result1[t][0], result1[t][1], result1[t][2], result1[t][3], result1[t][4], result1[t][5], result1[t][6], result1[t][7]);
     $display("prd @cycle%2d: %40h", t, temp16b);
  end

$display("##### Estimated core 2 multiplication result #####");

  for (t=0; t<total_cycle; t=t+1) begin
     for (q=0; q<col; q=q+1) begin
       result2[t][q] = 0;
     end
     
     sum2[t] = 0;
  end

  for (t=0; t<total_cycle; t=t+1) begin
     for (q=0; q<col; q=q+1) begin
         for (k=0; k<pr; k=k+1) begin
            result2[t][q] = result2[t][q] + Q[t][k] * K2[q][k];
         end

         if (result2[t][q] > 0) begin 
             sum2[t] = sum2[t] + result2[t][q];
         end  else begin
             sum2[t] = sum2[t] + result2[t][q] * (-1);
         end

         temp5b = result2[t][q];
         temp16b = {temp16b[139:0], temp5b};
     end

     //$display("%d %d %d %d %d %d %d %d", result2[t][0], result2[t][1], result2[t][2], result2[t][3], result2[t][4], result2[t][5], result2[t][6], result2[t][7]);
     $display("prd @cycle%2d: %40h", t, temp16b);
  end

//////////////////////////////////////////////



// mange sum 
for (q=0; q<total_cycle; q=q+1) begin
  abs_sum1 =  sum1[q];
  abs_sum_trunc1 = abs_sum1[bw_psum+3:7];
  abs_sum2 =  sum2[q] ;
  abs_sum_trunc2 = abs_sum2[bw_psum+3:7];
  chip_sum[q] = abs_sum1[bw_psum+3:7] + abs_sum2[bw_psum+3:7];
end


///// Qmem writing  /////

$display("##### Qmem writing  #####");

  for (q=0; q<total_cycle; q=q+1) begin

    #0.5 clk1 = 1'b0;  clk2 = 1'b0;  
    qmem_wr1 = 1;  if (q>0) qkmem_add1 = qkmem_add1 + 1; 
    qmem_wr2 = 1;  if (q>0) qkmem_add2 = qkmem_add2 + 1; 

    mem_in1[1*bw-1:0*bw] = Q[q][0];
    mem_in1[2*bw-1:1*bw] = Q[q][1];
    mem_in1[3*bw-1:2*bw] = Q[q][2];
    mem_in1[4*bw-1:3*bw] = Q[q][3];
    mem_in1[5*bw-1:4*bw] = Q[q][4];
    mem_in1[6*bw-1:5*bw] = Q[q][5];
    mem_in1[7*bw-1:6*bw] = Q[q][6];
    mem_in1[8*bw-1:7*bw] = Q[q][7];
    mem_in1[9*bw-1:8*bw] = Q[q][8];
    mem_in1[10*bw-1:9*bw] = Q[q][9];
    mem_in1[11*bw-1:10*bw] = Q[q][10];
    mem_in1[12*bw-1:11*bw] = Q[q][11];
    mem_in1[13*bw-1:12*bw] = Q[q][12];
    mem_in1[14*bw-1:13*bw] = Q[q][13];
    mem_in1[15*bw-1:14*bw] = Q[q][14];
    mem_in1[16*bw-1:15*bw] = Q[q][15];

    mem_in2[1*bw-1:0*bw] = Q[q][0];
    mem_in2[2*bw-1:1*bw] = Q[q][1];
    mem_in2[3*bw-1:2*bw] = Q[q][2];
    mem_in2[4*bw-1:3*bw] = Q[q][3];
    mem_in2[5*bw-1:4*bw] = Q[q][4];
    mem_in2[6*bw-1:5*bw] = Q[q][5];
    mem_in2[7*bw-1:6*bw] = Q[q][6];
    mem_in2[8*bw-1:7*bw] = Q[q][7];
    mem_in2[9*bw-1:8*bw] = Q[q][8];
    mem_in2[10*bw-1:9*bw] = Q[q][9];
    mem_in2[11*bw-1:10*bw] = Q[q][10];
    mem_in2[12*bw-1:11*bw] = Q[q][11];
    mem_in2[13*bw-1:12*bw] = Q[q][12];
    mem_in2[14*bw-1:13*bw] = Q[q][13];
    mem_in2[15*bw-1:14*bw] = Q[q][14];
    mem_in2[16*bw-1:15*bw] = Q[q][15];
    #0.5 clk1 = 1'b1;  clk2 = 1'b1;  

  end

  #0.5 clk1 = 1'b0;   clk2 = 1'b0; 
  qmem_wr1 = 0;      qmem_wr2 = 0; 
  qkmem_add1 = 0;    qkmem_add2 = 0;
  #0.5 clk1 = 1'b1;   clk2 = 1'b1; 
///////////////////////////////////////////





///// Kmem writing  /////

$display("##### Kmem writing #####");

  for (q=0; q<col; q=q+1) begin

    #0.5 clk1 = 1'b0;   clk2 = 1'b0;  
    kmem_wr1 = 1; if (q>0) qkmem_add1 = qkmem_add1 + 1; 
    kmem_wr2 = 1; if (q>0) qkmem_add2 = qkmem_add2 + 1; 

    mem_in1[1*bw-1:0*bw] = K1[q][0];
    mem_in1[2*bw-1:1*bw] = K1[q][1];
    mem_in1[3*bw-1:2*bw] = K1[q][2];
    mem_in1[4*bw-1:3*bw] = K1[q][3];
    mem_in1[5*bw-1:4*bw] = K1[q][4];
    mem_in1[6*bw-1:5*bw] = K1[q][5];
    mem_in1[7*bw-1:6*bw] = K1[q][6];
    mem_in1[8*bw-1:7*bw] = K1[q][7];
    mem_in1[9*bw-1:8*bw] = K1[q][8];
    mem_in1[10*bw-1:9*bw] = K1[q][9];
    mem_in1[11*bw-1:10*bw] = K1[q][10];
    mem_in1[12*bw-1:11*bw] = K1[q][11];
    mem_in1[13*bw-1:12*bw] = K1[q][12];
    mem_in1[14*bw-1:13*bw] = K1[q][13];
    mem_in1[15*bw-1:14*bw] = K1[q][14];
    mem_in1[16*bw-1:15*bw] = K1[q][15];

    mem_in2[1*bw-1:0*bw] = K2[q][0];
    mem_in2[2*bw-1:1*bw] = K2[q][1];
    mem_in2[3*bw-1:2*bw] = K2[q][2];
    mem_in2[4*bw-1:3*bw] = K2[q][3];
    mem_in2[5*bw-1:4*bw] = K2[q][4];
    mem_in2[6*bw-1:5*bw] = K2[q][5];
    mem_in2[7*bw-1:6*bw] = K2[q][6];
    mem_in2[8*bw-1:7*bw] = K2[q][7];
    mem_in2[9*bw-1:8*bw] = K2[q][8];
    mem_in2[10*bw-1:9*bw] = K2[q][9];
    mem_in2[11*bw-1:10*bw] = K2[q][10];
    mem_in2[12*bw-1:11*bw] = K2[q][11];
    mem_in2[13*bw-1:12*bw] = K2[q][12];
    mem_in2[14*bw-1:13*bw] = K2[q][13];
    mem_in2[15*bw-1:14*bw] = K2[q][14];
    mem_in2[16*bw-1:15*bw] = K2[q][15];
    #0.5 clk1 = 1'b1;   clk2 = 1'b1;  

  end

  #0.5 clk1 = 1'b0;  clk2 = 1'b0; 
  kmem_wr1 = 0;      kmem_wr2 = 0;
  qkmem_add1 = 0;    qkmem_add2 = 0;
  #0.5 clk1 = 1'b1;  clk2 = 1'b1; 
///////////////////////////////////////////



  for (q=0; q<2; q=q+1) begin
    #0.5 clk1 = 1'b0;    clk2 = 1'b0; 
    #0.5 clk1 = 1'b1;    clk2 = 1'b1;  
  end




/////  K data loading  /////
$display("##### K data loading to processor #####");

  for (q=0; q<col+1; q=q+1) begin
    #0.5 clk1 = 1'b0;  clk2 = 1'b0;
    load1 = 1;  load2 = 1;
    if (q==1) kmem_rd1 = 1; 
    if (q==1) kmem_rd2 = 1; 
    if (q>1) begin
       qkmem_add1 = qkmem_add1 + 1;
       qkmem_add2 = qkmem_add2 + 1;
    end

    #0.5 clk1 = 1'b1;  clk2 = 1'b1; 
  end

  #0.5 clk1 = 1'b0;  clk2 = 1'b0;  
  kmem_rd1 = 0; qkmem_add1 = 0;
  kmem_rd2 = 0; qkmem_add2 = 0;

  #0.5 clk1 = 1'b1;  clk2 = 1'b1;  

  #0.5 clk1 = 1'b0;  clk2 = 1'b0;  
  load1 = 0;  load2 = 0;
  #0.5 clk1 = 1'b1;  clk2 = 1'b1;  

///////////////////////////////////////////

 for (q=0; q<10; q=q+1) begin
    #0.5 clk1 = 1'b0;    clk2 = 1'b0; 
    #0.5 clk1 = 1'b1;    clk2 = 1'b1; 
 end





///// execution  /////
$display("##### execute #####");

  for (q=0; q<total_cycle; q=q+1) begin
    #0.5 clk1 = 1'b0;   clk2 = 1'b0; 
    execute1 = 1;  execute2 = 1; 
    qmem_rd1 = 1;  qmem_rd2 = 1;

    if (q>0) begin
       qkmem_add1 = qkmem_add1 + 1;
       qkmem_add2 = qkmem_add2 + 1;
    end

    #0.5 clk1 = 1'b1;   clk2 = 1'b1;  
  end

  #0.5 clk1 = 1'b0;     clk2 = 1'b1; 
  qmem_rd1 = 0; qkmem_add1 = 0; execute1 = 0;
  qmem_rd2 = 0; qkmem_add2 = 0; execute2 = 0;
  #0.5 clk1 = 1'b1;     clk2 = 1'b1; 


///////////////////////////////////////////

 for (q=0; q<10; q=q+1) begin
    #0.5 clk1 = 1'b0;    clk2 = 1'b0;  
    #0.5 clk1 = 1'b1;    clk2 = 1'b1;   
 end




////////////// output fifo rd and wb to psum mem ///////////////////

$display("##### move ofifo to pmem #####");

  for (q=0; q<total_cycle; q=q+1) begin
    #0.5 clk1 = 1'b0;  clk2 = 1'b0;  
    ofifo_rd1 = 1;     ofifo_rd2 = 1; 
    pmem_wr1 = 1;      pmem_wr2 = 1; 

    if (q>0) begin
       pmem_add1 = pmem_add1 + 1;
       pmem_add2 = pmem_add2 + 1;
    end

    #0.5 clk1 = 1'b1;  clk2 = 1'b1;
  end

  #0.5 clk1 = 1'b0;  clk2 = 1'b0;  
  pmem_wr1 = 0; pmem_add1 = 0; ofifo_rd1 = 0;
  pmem_wr2 = 0; pmem_add2 = 0; ofifo_rd2 = 0;
  #0.5 clk1 = 1'b1;  clk2 = 1'b1; 

///////////////////////////////////////////


////////////// accumulation ///////////////////

$display("##### accumulation   #####");
  for (q=0; q<total_cycle; q=q+1) begin
    #0.5 clk1 = 1'b0;   clk2 = 1'b0;
    pmem_rd1 = 1; pmem_wr2 = 0;  acc1 = 1; 
    pmem_rd2 = 1; pmem_wr2 = 0;  acc2 = 1; 
    if (q>0) begin
       pmem_add1 = pmem_add1 + 1;
       pmem_add2 = pmem_add2 + 1;
    end
    #0.5 clk1 = 1'b1;   clk2 = 1'b1;
  end 
  #0.5 clk1 = 1'b0;   clk2 = 1'b0;  
  pmem_add1 = 0;      pmem_add2 = 0;
  acc1 = 0;           acc2 = 0;
  #0.5 clk1 = 1'b1;   clk2 = 1'b1;

  #0.5 clk1 = 1'b0;   clk2 = 1'b0;  
  #0.5 clk1 = 1'b1;   clk2 = 1'b1;

  #0.5 clk1 = 1'b0;   clk2 = 1'b0;  
  #0.5 clk1 = 1'b1;   clk2 = 1'b1;

  #0.5 clk1 = 1'b0;   clk2 = 1'b0;  
  #0.5 clk1 = 1'b1;   clk2 = 1'b1;
  #0.5 clk1 = 1'b0;   clk2 = 1'b0;  
  #0.5 clk1 = 1'b1;   clk2 = 1'b1;
  #0.5 clk1 = 1'b0;   clk2 = 1'b0;  
  #0.5 clk1 = 1'b1;   clk2 = 1'b1;
  #0.5 clk1 = 1'b0;   clk2 = 1'b0;  
  #0.5 clk1 = 1'b1;   clk2 = 1'b1;
///////////////////////////////////////////


////////////////// handshake & div ///////////////////
$display("##### handshake & div   #####");

  k = 0;

  for (q=0; q<total_cycle; q=q+1) begin
    #0.5 clk1 = 1'b0;   clk2 = 1'b0;
    pmem_rd1 = 1; pmem_wr2 = 0;  div1 = 1; 
    pmem_rd2 = 1; pmem_wr2 = 0;  div2 = 1; 
    if (q>0) begin
       pmem_add1 = pmem_add1 + 1;
       pmem_add2 = pmem_add2 + 1;
    end
    #0.5 clk1 = 1'b1;   clk2 = 1'b1;

    for (i=0; i <handshake_cycle; i=i+1) begin
      #0.5 clk1 = 1'b0;   clk2 = 1'b0;  
      #0.5 clk1 = 1'b1;   clk2 = 1'b1;
    end

  end 

  #0.5 clk1 = 1'b0;   clk2 = 1'b0;  
  div1 = 0;           div2 = 0; 
  #0.5 clk1 = 1'b1;   clk2 = 1'b1;

///////////////////////////////////////////
$display("the # of errors :  %d", errors);
  #10 $finish;


end

endmodule
