module top #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH_AXI= 16,
    parameter ADDR_WIDTH = 10,    // For 1024 locations
    parameter DEPTH = 1024
)
();

bit clk;
always #5 clk=~clk;

//project modules instances
axi_if #(
     ADDR_WIDTH_AXI,   
     DATA_WIDTH) axiIF(clk); 

axi4 #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH_AXI),
    .MEMORY_DEPTH(DEPTH) ) DUT (axiIF);

testbench #(   
     DATA_WIDTH,
     ADDR_WIDTH_AXI,
     ADDR_WIDTH, 
     DEPTH) TE (axiIF);

Assertions assertions (axiIF);

endmodule