module key_manager
  (input  clk,
   input  rst,
   input  zeroize,
   input  load,
   input  [127:0] key_in,
   output [127:0] key,
   output key_valid);
  reg [127:0] key_r;
  reg valid_r;
  wire [127:0] n7_o;
  wire n9_o;
  wire [127:0] n11_o;
  wire n13_o;
  wire [127:0] n15_o;
  wire n17_o;
  reg [127:0] n21_q;
  reg n22_q;
  assign key = key_r;
  assign key_valid = valid_r;
  /* rtl/key_manager.vhd:27:12  */
  always @*
    key_r = n21_q; // (isignal)
  initial
    key_r = 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
  /* rtl/key_manager.vhd:28:12  */
  always @*
    valid_r = n22_q; // (isignal)
  initial
    valid_r = 1'b0;
  /* rtl/key_manager.vhd:47:13  */
  assign n7_o = load ? key_in : key_r;
  /* rtl/key_manager.vhd:47:13  */
  assign n9_o = load ? 1'b1 : valid_r;
  /* rtl/key_manager.vhd:44:13  */
  assign n11_o = zeroize ? 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : n7_o;
  /* rtl/key_manager.vhd:44:13  */
  assign n13_o = zeroize ? 1'b0 : n9_o;
  /* rtl/key_manager.vhd:36:13  */
  assign n15_o = rst ? 128'b00000000000000010000001000000011000001000000010100000110000001110000100000001001000010100000101100001100000011010000111000001111 : n11_o;
  /* rtl/key_manager.vhd:36:13  */
  assign n17_o = rst ? 1'b1 : n13_o;
  /* rtl/key_manager.vhd:35:9  */
  always @(posedge clk)
    n21_q <= n15_o;
  initial
    n21_q = 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
  /* rtl/key_manager.vhd:35:9  */
  always @(posedge clk)
    n22_q <= n17_o;
  initial
    n22_q = 1'b0;
endmodule

