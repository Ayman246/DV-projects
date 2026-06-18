import enum_e::*;

class UART_Packet;

    rand parity_e parity_mode;
    rand logic [7:0] data_in;

    logic parity_en;
    logic even_parity;
    logic parity_bit;

    logic expected_queue[$];
    logic actual_queue[$];

    constraint ones_default_c{
        data_in dist {8'hff:/10,8'h00:/10,[8'h01:8'hfe]:/80};
    }
    constraint parity_valid_c {
        parity_mode inside {EVEN_PARITY, ODD_PARITY, NO_PARITY};
    }

task calc_parity();
  case (parity_mode)
    EVEN_PARITY: begin parity_en = 1'b1;    even_parity = 1'b1;  end
    ODD_PARITY : begin parity_en = 1'b1;    even_parity = 1'b0;  end
    NO_PARITY  : begin parity_en = 1'b0;    even_parity = 1'b0;  end
  endcase
  parity_bit = parity_en ? ((even_parity) ? ~(^data_in) : ^data_in) : 0;
endtask

task generate_stimulus();
    assert(this.randomize())
    else $stop;
endtask

task golden_model();
    calc_parity();
    expected_queue.push_back(0); //start bit
    for(int i = 0 ; i < 8 ; i++)
    expected_queue.push_back(data_in[i]); //data bits
    if (parity_en) expected_queue.push_back(parity_bit); //optional parity bit
    expected_queue.push_back(1); //stop bit
        
endtask

task drive_stim(
    output logic [7:0] data_in_,
    output logic parity_en_,
    output logic even_parity_);

     calc_parity();
     data_in_ = data_in;
     parity_en_ = parity_en;
     even_parity_ = ~even_parity; //Parity bit is inverted in design

endtask

task collect_output(input logic tx_);
        actual_queue.push_front(tx_);

endtask

task check_results();
    if (expected_queue.size() !== actual_queue.size()) begin
            $display("size mismatch!");
            print();
            $stop;
            end
    else begin
    foreach(expected_queue[i])
     if (expected_queue[i] !== actual_queue[i]) begin
            $display("UART mismatch!");
            print();
            $stop;
            end
        else begin 
            $display("UART success!");
             print();
        end
    end
    
endtask

task print();
    $display("data in= %b , parity en = %b , parity bit = %b , expected tx = %p , actual tx = %p",data_in,parity_en,parity_bit,expected_queue,actual_queue);
    $display("******************************************************************************");
endtask

//////////////////////////////////////////
//    ******** COVERAGE **********     //
//////////////////////////////////////////
covergroup cg;
data_in_cp : coverpoint data_in {
    bins a = {[0:63]};
    bins b = {[64:127]};
    bins c = {[128:191]};
    bins d = {[192:255]};
    bins e = {8'hff};
    bins f = {8'h00};
}
parity_mode_cp : coverpoint parity_mode;
cross_cp : cross data_in_cp, parity_mode_cp;

endgroup

function new();
    cg = new();
endfunction


endclass