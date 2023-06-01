module handshake_tb;


reg reset;
reg clk;
reg ready;
reg ack;
wire req;


handshake handshake_init (
    .reset(reset), 
    .clk(clk), 
    .ready(ready), 
    .ack(ack), 
    .req(req)
);


initial begin 

  $dumpfile("handshake_tb.vcd");
  $dumpvars(0,handshake_tb);

  #0.5 clk = 1'b0;
  reset = 1;  ready = 0; ack = 0;
  #0.5 clk = 1'b1;

  #0.5 clk = 1'b0; // idle
  reset = 0;  
  #0.5 clk = 1'b1;

  #0.5 clk = 1'b0;
  ready = 1;
  #0.5 clk = 1'b1;

  #0.5 clk = 1'b0; // READY
  #0.5 clk = 1'b1;

    #0.5 clk = 1'b0;
    #0.5 clk = 1'b1;

    #0.5 clk = 1'b0;
    #0.5 clk = 1'b1;

    #0.5 clk = 1'b0; // ns: SENT_WAIT , counter == 1'b11, req = 1;
    #0.5 clk = 1'b1;

    #0.5 clk = 1'b0; // SENT_WAIT , counter == 1'b00, 
    #0.5 clk = 1'b1;

    #0.5 clk = 1'b0;
    ack = 1;
    #0.5 clk = 1'b1;

    #0.5 clk = 1'b0;
    #0.5 clk = 1'b1;
end

endmodule