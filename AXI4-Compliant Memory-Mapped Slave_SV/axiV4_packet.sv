class axiV4_packet;

    parameter ADDR_WIDTH_AXI = 16;
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 10;   // For 1024 locations
    parameter DEPTH = 1024;

    logic                       mem_en;
    logic                       mem_we;
    rand logic   [ADDR_WIDTH-1:0]    mem_addr;
    rand logic   [DATA_WIDTH-1:0]    mem_wdata;
    rand logic [ADDR_WIDTH_AXI-1:0]    AWADDR;
    logic   [DATA_WIDTH-1:0]    mem_rdata;
    logic   [DATA_WIDTH-1:0]    exp_rdata;
    logic   [DATA_WIDTH-1:0] memory [0:DEPTH-1];
    logic [DATA_WIDTH-1:0] expected_out [$];
    logic [DATA_WIDTH-1:0] actual_out [$];
    logic [DATA_WIDTH-1:0] wdata_q [$];
    rand logic   [7:0]               AWLEN;
    logic   [2:0]               AWSIZE = 2;
    rand logic   [DATA_WIDTH-1:0]    WDATA;
    logic [1:0] BRESP_dut; 
    logic [1:0] BRESP;
    logic [1:0] RRESP_dut; 
    logic [1:0] RRESP;

    constraint mem_address_c {soft mem_addr inside {[1:DEPTH-1]} ; } 
    constraint mem_wdata_c { mem_wdata < {DATA_WIDTH{1'b1}};  } 
    constraint AWADDR_c {AWADDR < 2 **  (ADDR_WIDTH+2) ;}
    constraint WDATA_c { WDATA  < {DATA_WIDTH{1'b1}}; } 




function void generate_stimulus();
        assert (this.randomize()) 
        else  $fatal;   
endfunction

function void mem_golden_model();
//verify memory operation first 

    //write operation 
    if (mem_en && mem_we)
        memory[mem_addr] = mem_wdata;
    //read operation
    else if (mem_en && ~mem_we)
        exp_rdata = memory[mem_addr];

endfunction

task drive_stim(output logic [ADDR_WIDTH-1:0] mem_addr_dut,output logic [DATA_WIDTH-1:0] mem_wdata_dut);
    mem_addr_dut  = mem_addr ;
    mem_wdata_dut = mem_wdata ;
endtask

task collect_output(input logic [DATA_WIDTH-1:0] data);
    actual_out.push_back(data);
endtask

task mem_check_results ();
    if (exp_rdata !== mem_rdata) begin
        $display("error : exp_rdata : %b , mem_rdata : %b , time :%t",exp_rdata,mem_rdata,$time);
        $stop;
    end
endtask

task axi_golden_model();
    //write operation
    AWADDR = this.AWADDR;
    WDATA = this.WDATA;
    wdata_q.push_back(WDATA);
    BRESP = (AWADDR < 2**(ADDR_WIDTH+2)) ? 2'b00 : 2'b10 ;
//***************************************************//
    //read operation
    AWADDR = this.AWADDR; //read from the same write address to check that both operations work using one test
    expected_out = wdata_q;
    RRESP = (AWADDR <  2**(ADDR_WIDTH+2)) ? 2'b00 : 2'b10 ;
endtask

task axi_check_results ();
        $display("**AWLEN is %d",AWLEN);
        $display("**expected_queue is %p",expected_out);
        $display("**actual queue is %p",actual_out);
        $display( "***************************************");
    if (expected_out !== actual_out) begin
        $display("error, expected_queue is %p,actual queue is %p",expected_out,actual_out);
        //$stop;
        //Bug in DUT in read operation 
    end
    if(BRESP_dut !== BRESP )
    $display("**error in BRESP : BRESP_dut = %b  , BRESP = %b",BRESP_dut,BRESP);
    if(RRESP_dut !== RRESP )
    $display("**error in RRESP : RRESP_dut = %b  , RRESP = %b",RRESP_dut,RRESP);
endtask



//////////////////////////////////////////
//    ******** COVERAGE **********     //
//////////////////////////////////////////
covergroup mem_cg;
mem_addr_cp : coverpoint mem_addr ;
mem_wdata_cp : coverpoint mem_wdata;
mem_cross_cp : cross mem_addr_cp, mem_wdata_cp;
endgroup

covergroup axi_cg;
AWADDR_cp : coverpoint AWADDR;
WDATA_cp : coverpoint WDATA ;
axi_cp : cross AWADDR_cp, WDATA_cp;
endgroup




function new();
// initalize the memory array 
    foreach(memory[i])
    memory[i] = 0;
    mem_cg = new();
    axi_cg = new();

endfunction

endclass