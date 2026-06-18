`include "UART_Packet.sv"

module TE(uart_if.TEST uif);

UART_Packet tr = new();


initial begin

repeat(2) begin 
    uif.rst_n = 0;            
    repeat (2) @(negedge uif.clk);
    uif.rst_n = 1;
    repeat (2) @(negedge uif.clk);
end

repeat(200) begin 
    
    @(negedge uif.clk)
    
    tr.actual_queue.delete();
    tr.generate_stimulus();
    
    tr.expected_queue.delete();
    tr.golden_model();
   
    wait (uif.tx_busy == 0);
    tr.drive_stim(uif.data_in,uif.parity_en,uif.even_parity);

    uif.tx_start = 1'b1;
    @(negedge uif.clk) //assert tx_start for one cycle
    uif.tx_start = 1'b0;

    @(negedge uif.tx);
    repeat(uif.parity_en ? 11 : 10) begin
    @(negedge uif.clk)
    tr.collect_output(uif.tx);
    end

    @(negedge uif.clk)
    //before checking we need to rearrange the queue of actual output as the design inverted the output
    if (tr.parity_en) tr.actual_queue = {tr.actual_queue[$],tr.actual_queue[2:$-1],tr.actual_queue[1],tr.actual_queue[0]} ;
    else tr.actual_queue = {tr.actual_queue[$],tr.actual_queue[1:$-1],tr.actual_queue[0]} ;
    tr.check_results();
    tr.cg.sample();

end

    $stop;

end


endmodule