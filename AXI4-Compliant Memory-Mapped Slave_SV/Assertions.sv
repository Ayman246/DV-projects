module Assertions (axi_if axiIF);

    assert property (@(posedge axiIF.ACLK) disable iff (!axiIF.ARESETn)
        axiIF.AWVALID |-> !$isunknown(axiIF.AWADDR)
    );

    assert property (@(posedge axiIF.ACLK) disable iff (!axiIF.ARESETn)
        axiIF.WVALID |-> !$isunknown(axiIF.WDATA)
    );

    assert property (@(posedge axiIF.ACLK) disable iff (!axiIF.ARESETn)
        axiIF.WVALID |-> !$isunknown(axiIF.WLAST)
    );

    assert property (@(posedge axiIF.ACLK) disable iff (!axiIF.ARESETn)
        axiIF.BVALID |-> !$isunknown(axiIF.BRESP)
    );

    assert property (@(posedge axiIF.ACLK) disable iff (!axiIF.ARESETn)
        axiIF.ARVALID |-> !$isunknown(axiIF.ARADDR)
    );

    assert property (@(posedge axiIF.ACLK) disable iff (!axiIF.ARESETn)
        axiIF.RVALID |-> !$isunknown(axiIF.RLAST)
    );

    assert property (@(posedge axiIF.ACLK) disable iff (!axiIF.ARESETn)
        axiIF.RVALID |-> !$isunknown(axiIF.RRESP)
    );

    assert property (@(posedge axiIF.ACLK) disable iff (!axiIF.ARESETn)
        axiIF.RVALID |-> !$isunknown(axiIF.RDATA)
    );

endmodule