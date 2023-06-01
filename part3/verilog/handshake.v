
// ready: !o_empty from sfp_row 


module handshake(reset, clk, ready, ack, req);

input reset;
input clk;
input ready;
input ack;
output req;


parameter SIZE = 2;

parameter IDLE = 2'b00; 
parameter READY = 2'b01; // pause for a few cycle for preparing data
parameter SENT_WAIT = 2'b10;

reg [1:0] counter;


reg   [SIZE-1:0]    state;  // current state
wire  [SIZE-1:0]    next_state   ;


assign next_state = fsm_function(state, ready, ack, counter);

assign req = (state == SENT_WAIT);

function [SIZE-1:0] fsm_function;
    input [SIZE-1:0] state;
    input ready;
    input ack;
    input [1:0] counter;
    case (state)
     IDLE: if (ready) begin
                fsm_function = READY;
            end else 
                fsm_function = IDLE;
     READY: if (counter == 2'b11) begin  
                fsm_function = SENT_WAIT;
            end else
                fsm_function = READY;
     SENT_WAIT: if (ack) begin
                fsm_function = IDLE;
            end else 
                fsm_function = SENT_WAIT;
     default : fsm_function = IDLE;
    endcase
endfunction



always @ (posedge clk)
    begin
    if (reset) begin
        state <=  IDLE;
        counter <= 0;
    end else begin
        state <=  next_state;
        if (state == READY) begin
            counter <= counter + 1;
        end else begin
            counter <= 0;
        end
    end
end

endmodule