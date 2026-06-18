vlog interface.sv axi_memory.sv axi4.sv Testbench.sv axiV4_packet.sv top.sv Assertions.sv +cover -covercells
vsim -voptargs=+acc work.top -cover
coverage save -onexit cov.ucdb
add wave -r *
run -all
coverage report -details -output cov_report.txt