module uart_timing
  (input  clk,
   input  rst,
   output tick);
  reg [25:0] acc;
  wire [31:0] n5_o;
  wire [31:0] n7_o;
  wire n9_o;
  wire [31:0] n10_o;
  wire [31:0] n12_o;
  wire [31:0] n14_o;
  wire [25:0] n15_o;
  wire [31:0] n16_o;
  wire [31:0] n18_o;
  wire [25:0] n19_o;
  wire n22_o;
  wire [25:0] n23_o;
  wire n25_o;
  wire [25:0] n27_o;
  reg [25:0] n31_q;
  reg n32_q;
  assign tick = n32_q;
  /* rtl/uart_timing.vhd:24:12  */
  always @*
    acc = n31_q; // (isignal)
  initial
    acc = 26'b00000000000000000000000000;
  /* rtl/uart_timing.vhd:36:23  */
  assign n5_o = {6'b0, acc};  //  uext
  /* rtl/uart_timing.vhd:36:23  */
  assign n7_o = n5_o + 32'b00000000000000100101100000000000;
  /* rtl/uart_timing.vhd:36:29  */
  assign n9_o = $signed(n7_o) >= $signed(32'b00000010111110101111000010000000);
  /* rtl/uart_timing.vhd:37:29  */
  assign n10_o = {6'b0, acc};  //  uext
  /* rtl/uart_timing.vhd:37:29  */
  assign n12_o = n10_o + 32'b00000000000000100101100000000000;
  /* rtl/uart_timing.vhd:37:35  */
  assign n14_o = n12_o - 32'b00000010111110101111000010000000;
  /* rtl/uart_timing.vhd:37:25  */
  assign n15_o = n14_o[25:0];  // trunc
  /* rtl/uart_timing.vhd:40:29  */
  assign n16_o = {6'b0, acc};  //  uext
  /* rtl/uart_timing.vhd:40:29  */
  assign n18_o = n16_o + 32'b00000000000000100101100000000000;
  /* rtl/uart_timing.vhd:40:25  */
  assign n19_o = n18_o[25:0];  // trunc
  /* rtl/uart_timing.vhd:36:13  */
  assign n22_o = n9_o ? 1'b1 : 1'b0;
  /* rtl/uart_timing.vhd:36:13  */
  assign n23_o = n9_o ? n15_o : n19_o;
  /* rtl/uart_timing.vhd:33:13  */
  assign n25_o = rst ? 1'b0 : n22_o;
  /* rtl/uart_timing.vhd:33:13  */
  assign n27_o = rst ? 26'b00000000000000000000000000 : n23_o;
  /* rtl/uart_timing.vhd:32:9  */
  always @(posedge clk)
    n31_q <= n27_o;
  initial
    n31_q = 26'b00000000000000000000000000;
  /* rtl/uart_timing.vhd:32:9  */
  always @(posedge clk)
    n32_q <= n25_o;
endmodule

