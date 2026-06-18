interface axi_if #(
    parameter ADDR_WIDTH = 16,
    parameter DATA_WIDTH = 32
)(input bit ACLK);


    bit                       ARESETn;

    // Write address channel
    logic   [ADDR_WIDTH-1:0]    AWADDR;
    logic   [7:0]               AWLEN;
    logic   [2:0]               AWSIZE = 2;
    logic                       AWVALID;
    logic                       AWREADY;

    // Write data channel
    logic   [DATA_WIDTH-1:0]    WDATA;
    logic                       WVALID;
    logic                       WLAST;
    logic                       WREADY;

    // Write response channel
    logic  [1:0]                BRESP;
    logic                       BVALID;
    logic                       BREADY;

    // Read address channel
    logic   [ADDR_WIDTH-1:0]    ARADDR;
    logic   [7:0]               ARLEN;
    logic   [2:0]               ARSIZE = 2;
    logic                       ARVALID;
    logic                       ARREADY;

    // Read data channel
    logic  [DATA_WIDTH-1:0]     RDATA;
    logic  [1:0]                RRESP;
    logic                       RVALID;
    logic                       RLAST;
    logic                       RREADY;

modport DUT (
    input ACLK,ARESETn,AWADDR,AWLEN,AWVALID,WDATA,WVALID,WLAST,BREADY,ARADDR,ARLEN,ARSIZE,ARVALID,RREADY,AWSIZE,
    output AWREADY,WREADY,BRESP,BVALID,ARREADY,RDATA,RRESP,RVALID,RLAST
);

modport TE (
    output ARESETn,AWADDR,AWLEN,AWVALID,WDATA,WVALID,WLAST,BREADY,ARADDR,ARLEN,ARSIZE,ARVALID,RREADY,AWSIZE,
    input ACLK,AWREADY,WREADY,BRESP,BVALID,ARREADY,RDATA,RRESP,RVALID,RLAST
);




endinterface