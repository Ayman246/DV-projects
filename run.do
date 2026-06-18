vlog interface.sv uart_tx.sv Testbench.sv UART_Packet.sv enum_pkg.sv top.sv +cover -covercells
vsim -voptargs=+acc work.top -cover
coverage save -onexit cov.ucdb
add wave -r *
run -all
coverage report -details -output cov_report.txt