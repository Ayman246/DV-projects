interface uart_if (input bit clk);

    bit rst_n;
    logic tx_start;
    logic [7:0] data_in;
    logic parity_en;
    logic even_parity;
    logic tx;
    logic tx_busy;


    modport TEST (
    output rst_n,tx_start,data_in,parity_en,even_parity,   
    input tx,tx_busy,clk
    );

    modport DUT (
    input rst_n,tx_start,data_in,parity_en,even_parity,clk,   
    output tx,tx_busy
    );


endinterface