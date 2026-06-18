/* 
bugs :

    *in memory 
        1- reset operation in memory design is reversed
        2- read opreation reads from (address) - 1 not address

    *in axi 
        1- boundry check does not work correctly all the time 
        2- RDATA reads from memory one cycle earlier so the output latency is two cycles after mem_en is asserted


**I have to fix the reset in memory design file to complete the process.
*/
`include "axiV4_packet.sv"
module testbench#(   
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH_AXI = 16,
    parameter ADDR_WIDTH = 10,    // For 1024 locations
    parameter DEPTH = 1024)(axi_if.TE axiIF);

axiV4_packet tr = new();

logic                       mem_en;
logic                       mem_we;
logic   [ADDR_WIDTH-1:0]    mem_addr;
logic   [DATA_WIDTH-1:0]    mem_wdata;
logic   [DATA_WIDTH-1:0]    mem_rdata;

axi4_memory #(.DATA_WIDTH(DATA_WIDTH),.ADDR_WIDTH(ADDR_WIDTH),.DEPTH(DEPTH)) memory_dut (
    axiIF.ACLK,axiIF.ARESETn,mem_en,mem_we,mem_addr,mem_wdata,mem_rdata);

task reset_n();
    repeat (2) begin // need to be fixed later 
    axiIF.ARESETn = 0;
    @(negedge axiIF.ACLK); 
    axiIF.ARESETn = 1;
    @(negedge axiIF.ACLK);
    end
endtask

initial begin
    reset_n();
    $display ("reset operation is reversed in dut ");
    
 for(int i = 1 ; i < 50000 ; i++ ) begin
    @(negedge axiIF.ACLK);
    tr.generate_stimulus();
    tr.mem_cg.sample();
    //write 
    mem_write_op();

    //read
    mem_read_op();

    //print 
    $display("mem_addr: %b : mem_rdata: %b, exp_rdata: %b",mem_addr,mem_rdata,tr.exp_rdata);

    //axiIF.ARESETn = 1;
 end

 //try to drive addr = 0
    @(negedge axiIF.ACLK);
    tr.mem_address_c.constraint_mode(0);
    tr.mem_addr.rand_mode(0);
    tr.mem_addr = 10'd0;
    tr.mem_cg.sample();
    
    //write 
    mem_write_op();

    //read
    mem_read_op();

    //print 
    $display("corner case 1 : mem_addr: %b : mem_rdata: %b, exp_rdata: %b",mem_addr,mem_rdata,tr.exp_rdata);

//try to drive an addr > 10bits
    @(negedge axiIF.ACLK);
    tr.mem_address_c.constraint_mode(0);
    tr.randomize() with {mem_addr > DEPTH-1;};

    //write 
    mem_write_op();

    //read
    mem_read_op();
    
    //print 
    $display("corner case 2 : mem_addr: %b : mem_rdata: %b, exp_rdata: %b",mem_addr,mem_rdata,tr.exp_rdata);

 $display("****************************");
 $display("mem  test is done");
 $display("****************************");
 

//********************************//
//system verification
//*******************************//

//only one beat test
  for(int i = 1 ; i < 50000 ; i++ ) begin
    tr.wdata_q.delete();
    tr.expected_out.delete();
    tr.actual_out.delete();

    tr.AWLEN.rand_mode(0);
    tr.AWLEN = 0 ;
    axiIF.AWLEN = tr.AWLEN;
    //write operation
    axi_write_op(tr.AWLEN);

    @(negedge axiIF.ACLK);
    mem_en = 1'b0;
    tr.mem_en = mem_en;

    @(negedge axiIF.ACLK);
    mem_en = 1'b1;
    tr.mem_en = mem_en;   

    //reset_n(); 
    
    //read operation
    axi_read_op(tr.AWLEN); 


    reset_n();

 end
 $display("****************************");
 $display("one beat test is done");
 $display("****************************");

//randomized no. of beats test
for(int i = 1 ; i < 5000 ; i++ ) begin
    tr.wdata_q.delete();
    tr.expected_out.delete();
    tr.actual_out.delete();

    tr.AWLEN.rand_mode(1);
    tr.generate_stimulus();
    tr.axi_cg.sample();

    //write operation
    axi_write_op(tr.AWLEN);

    //reset_n();
    axiIF.WDATA = 0;
    
    //read operation
    axi_read_op(tr.AWLEN);

    reset_n();
end

$display("**********************");
$display("multi beats Verification is Done");
$display("**********************");

//  test Addresses which may exceed 4095
  for(int i = 1 ; i < 52000 ; i++ ) begin
    tr.wdata_q.delete();
    tr.expected_out.delete();
    tr.actual_out.delete();
    tr.AWADDR_c.constraint_mode(0);
    tr.AWLEN.rand_mode(0);
    tr.AWLEN = 0 ;
    axiIF.AWLEN = tr.AWLEN;
    //write operation
    axi_write_op(tr.AWLEN);

    @(negedge axiIF.ACLK);
    mem_en = 1'b0;
    tr.mem_en = mem_en;

    @(negedge axiIF.ACLK);
    mem_en = 1'b1;
    tr.mem_en = mem_en;   

    //reset_n(); 
    
    //read operation
    axi_read_op(tr.AWLEN); 


    reset_n();
    

 end

$display("**********************");
$display("System Verification is Done");
$display("**********************");

$stop;
end

task mem_write_op();
    //write 
    {mem_en,mem_we} = {1'b1,1'b1};
    @(negedge axiIF.ACLK);
    tr.mem_en = mem_en;
    tr.mem_we = mem_we;
    @(negedge axiIF.ACLK);
    tr.drive_stim(mem_addr,mem_wdata);
    @(negedge axiIF.ACLK);
    tr.mem_golden_model();
endtask

task mem_read_op();
    //read
    @(negedge axiIF.ACLK);
    {mem_en,mem_we} = {1'b1,1'b0};
    mem_addr = tr.mem_addr == 10'd0 ? (tr.mem_addr) : (tr.mem_addr + 1); // need to be fixed in memory file 
    @(negedge axiIF.ACLK);
    tr.mem_en = mem_en;
    tr.mem_we = mem_we;
    @(negedge axiIF.ACLK);
    tr.mem_rdata = mem_rdata;
    tr.mem_golden_model();
    @(negedge axiIF.ACLK);
    if(mem_addr)
    tr.mem_check_results();
endtask

task axi_write_op (input logic [7:0] AWLEN);
    //write operation
        axiIF.AWSIZE = 2;
        //write address phase
        @(negedge axiIF.ACLK);
        tr.AWLEN.rand_mode(0);
        tr.generate_stimulus();
        tr.axi_cg.sample();
        axiIF.AWLEN  = AWLEN;
        @(negedge axiIF.ACLK);
        axiIF.AWADDR = (tr.AWADDR / (1 << axiIF.AWSIZE)) * (1 << axiIF.AWSIZE);
        axiIF.AWVALID = 1;
        wait (axiIF.AWREADY == 1);
        @(negedge axiIF.ACLK);
        axiIF.AWVALID = 0;
        
        //write data phase
        for(int i = 0; i < AWLEN+1 ; i++) begin
        tr.AWADDR.rand_mode(0);
        tr.generate_stimulus();
        tr.axi_cg.sample();
        @(negedge axiIF.ACLK);
        axiIF.WDATA = tr.WDATA ;
        //tr.collect_output(axiIF.WDATA); 
        tr.axi_golden_model();
        axiIF.WVALID = 1;
        axiIF.WLAST = (i == AWLEN && axiIF.WVALID == 1);
        wait (axiIF.WREADY == 1);
        @(negedge axiIF.ACLK);
        axiIF.WVALID = 0;
        axiIF.WLAST = 0;
        end
        tr.AWADDR.rand_mode(1);

        //write response phase
        @(negedge axiIF.ACLK);
        axiIF.BREADY = 1'b1;
        wait (axiIF.BVALID == 1);
        tr.BRESP_dut = axiIF.BRESP;
        @(negedge axiIF.ACLK);
        axiIF.BREADY = 1'b0;
        
endtask
 
task axi_read_op(input logic [7:0] ARLEN);
     //read operation
        axiIF.ARSIZE = axiIF.AWSIZE;
        //read address phase 
        @(negedge axiIF.ACLK);
        axiIF.ARLEN = ARLEN;
        axiIF.ARADDR = ( (tr.AWADDR) / (1 << axiIF.ARSIZE)) * (1 << axiIF.ARSIZE ) + 4 ; //fix the internal memory (read op)
        axiIF.ARVALID = 1;
        wait (axiIF.ARREADY == 1); 
        @(negedge axiIF.ACLK);
        axiIF.ARVALID = 0;

        //read data phase
        for(int i = 0; i < ARLEN+1 ; i++) begin
        axiIF.RREADY = 1;
        wait (axiIF.RVALID == 1);
        @(negedge axiIF.ACLK);
        @(posedge axiIF.ACLK);
        #2ns;
        tr.collect_output(axiIF.RDATA);
        @(negedge axiIF.ACLK);
        end
        if (ARLEN == 0)
        $display("ADDR = %h, DATA = %h", axiIF.AWADDR, axiIF.RDATA);
        tr.RRESP_dut = axiIF.RRESP;
        tr.axi_check_results();
        tr.AWLEN.rand_mode(1);
        @(negedge axiIF.ACLK);
        axiIF.RREADY = 0;
        
endtask

endmodule

