reg go;
reg complete;
reg fsm1_next_state ;
reg fsm2_next_state ; 
reg complete ;
reg fsm1_state;
reg fsm2_state;


//abstracted FSM1
always @(posedge clk) begin
  case( fsm1_state )
    START_SUB : begin
      go              <= 1'b1;
      fsm1_next_state <= WAIT_SUB;
    end
    WAIT_SUB: begin
      if (complete == 1'b1) begin
        go              <= 1'b0;
        fsm1_next_state <= COMPLETED_SUB;
      end
      else begin
        go              <= 1'b1;         //Might not be required to hold high in Synch design
        fsm1_next_state <= WAIT_SUB;     // Holds state
      end
    end
    default: begin
      go              <= 1'b0;
      fsm1_next_state <= fsm1_state;
    end
  endcase
end

//fsm2
always @(posedge clk) begin
  case( fsm2_state )
    WAITING : begin
      complete        <= 1'b0;
      if (go ==1'b1) begin
        fsm2_next_state <= DOSOMETHING;
      end
      else begin
        fsm2_next_state <= WAITING;
      end 
    end
    DOSOMETHING : begin
      complete        <= 1'b1;
      fsm2_next_state <= WAITING;
      // if an async system wait until go is deasserted
      // rather than pulse complete for 1 cycle
    end
  endcase
end