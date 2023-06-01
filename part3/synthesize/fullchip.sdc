set clock_cycle 1
set io_delay 0.2 

set clock_port1 clk1
set clock_port2 clk2

create_clock -name clk1 -period $clock_cycle [get_ports $clock_port1]
create_clock -name clk2 -period $clock_cycle [get_ports $clock_port2]

#set_multicycle_path -setup 2 -from fifo_top_instance/fifo_instance/rd_ptr_reg[*] -to out_q_reg[*]
#set_multicycle_path -hold  1 -from fifo_top_instance/fifo_instance/rd_ptr_reg[*] -to out_q_reg[*] 

set_input_delay  -clock [get_clocks clk1] -add_delay -max $io_delay [all_inputs]
set_output_delay  -clock [get_clocks clk1] -add_delay -max $io_delay [all_outputs]


set_input_delay  -clock [get_clocks clk2] -add_delay -max $io_delay [all_inputs]
set_output_delay  -clock [get_clocks clk2] -add_delay -max $io_delay [all_outputs]


