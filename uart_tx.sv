module uart_tx (uart_if.DUT uif);

    // State machine states
    localparam IDLE   = 3'd0,
               START  = 3'd1,
               DATA   = 3'd2,
               PARITY = 3'd3,
               STOP   = 3'd4;

    reg [2:0] state;
    reg [3:0] bit_cnt;
    reg [7:0] shift_reg;
    reg       parity_bit;

    always @(posedge uif.clk or negedge uif.rst_n) begin
        if (!uif.rst_n) begin
            state     <= IDLE;
            uif.tx        <= 1'b1;  // idle is high
            uif.tx_busy   <= 1'b0;
            shift_reg <= 8'd0;
            bit_cnt   <= 4'd0;
            parity_bit <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    uif.tx <= 1'b1;
                    uif.tx_busy <= 1'b0;
                    if (uif.tx_start) begin
                        shift_reg <= uif.data_in;
                        bit_cnt <= 4'd0;
                        parity_bit <= (uif.even_parity) ? (^uif.data_in) : ~(^uif.data_in);
                        uif.tx_busy <= 1'b1;
                        state <= START;
                    end
                end

                START: begin
                    uif.tx <= 1'b0; // start bit
                    state <= DATA;
                end

                DATA: begin
                    uif.tx <= shift_reg[7];             //FIX_ME::convert to 0 to fix
                    shift_reg <= shift_reg << 1;    //FIX_ME::convert to >> to fix  
                    bit_cnt <= bit_cnt + 1;  
                    if (bit_cnt == 4'd7) begin
                        if (uif.parity_en)
                            state <= PARITY;
                        else
                            state <= STOP;
                    end
                end

                PARITY: begin
                    uif.tx <= parity_bit;
                    state <= STOP;
                end

                STOP: begin
                    uif.tx <= 1'b1; // stop bit (always 1)
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule