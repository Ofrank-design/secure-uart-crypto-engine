## timing_constraints.xdc  -- TEMPLATE, NOT VERIFIED AGAINST ANY BOARD.
## The FPGA part, board and pin numbers are still unknown. Fill in every <...> before use.
## Syntax is Xilinx/Vivado XDC; Quartus (SDC) and others need the equivalent commands.

## Primary clock: 50 MHz, 20 ns
create_clock -period 20.000 -name sys_clk [get_ports clk]

## Pins (REPLACE): 
# set_property -dict { PACKAGE_PIN <pin> IOSTANDARD <std> } [get_ports clk]
# set_property -dict { PACKAGE_PIN <pin> IOSTANDARD <std> } [get_ports uart_rx_pin]
# set_property -dict { PACKAGE_PIN <pin> IOSTANDARD <std> } [get_ports uart_tx_pin]
# set_property -dict { PACKAGE_PIN <pin> IOSTANDARD <std> } [get_ports rst_in]

## uart_rx_pin and rst_in are asynchronous inputs, each passing through a 2-flop synchroniser.
## Cut the pin-to-first-flop path only (not the whole design) once the real timing report is reviewed:
# set_false_path -from [get_ports uart_rx_pin] -to [get_cells -hier -filter {NAME =~ *sync_reg*}]
# set_false_path -from [get_ports rst_in]      -to [get_cells -hier -filter {NAME =~ *rst_s_reg*}]
## The synchroniser flops carry ASYNC_REG (see rtl/uart_rx.vhd); add the same attribute to rst_s in the top
## if the tool does not infer it.

## Slow outputs (UART TX at 9600 baud) need no I/O delay constraint beyond the board's requirements.
## Status/NV-store/key ports (zeroize, key_load, key_in, ctr_*, seq_*) must be wired to real logic
## or constrained as appropriate; leaving them unconnected changes the security behaviour.
