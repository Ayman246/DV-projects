`include "interface.sv"
`include "uart_tx.sv"
`include "Testbench.sv"


module top();

    bit clk;

initial begin
forever begin
    #5 clk = ~clk; //100 MHZ clk
end
end

uart_if uif (clk);
uart_tx dut (uif.DUT);
TE test (uif.TEST);

endmodule