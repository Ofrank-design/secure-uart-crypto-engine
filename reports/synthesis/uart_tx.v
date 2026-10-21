module uart_timing_50000000_9600_1
  (input  clk,
   input  rst,
   output tick);
  reg [25:0] acc;
  wire [31:0] n103_o;
  wire [31:0] n105_o;
  wire n107_o;
  wire [31:0] n108_o;
  wire [31:0] n110_o;
  wire [31:0] n112_o;
  wire [25:0] n113_o;
  wire [31:0] n114_o;
  wire [31:0] n116_o;
  wire [25:0] n117_o;
  wire n120_o;
  wire [25:0] n121_o;
  wire n123_o;
  wire [25:0] n125_o;
  reg [25:0] n129_q;
  reg n130_q;
  assign tick = n130_q;
  /* rtl/uart_timing.vhd:24:12  */
  always @*
    acc = n129_q; // (isignal)
  initial
    acc = 26'b00000000000000000000000000;
  /* rtl/uart_timing.vhd:36:23  */
  assign n103_o = {6'b0, acc};  //  uext
  /* rtl/uart_timing.vhd:36:23  */
  assign n105_o = n103_o + 32'b00000000000000000010010110000000;
  /* rtl/uart_timing.vhd:36:29  */
  assign n107_o = $signed(n105_o) >= $signed(32'b00000010111110101111000010000000);
  /* rtl/uart_timing.vhd:37:29  */
  assign n108_o = {6'b0, acc};  //  uext
  /* rtl/uart_timing.vhd:37:29  */
  assign n110_o = n108_o + 32'b00000000000000000010010110000000;
  /* rtl/uart_timing.vhd:37:35  */
  assign n112_o = n110_o - 32'b00000010111110101111000010000000;
  /* rtl/uart_timing.vhd:37:25  */
  assign n113_o = n112_o[25:0];  // trunc
  /* rtl/uart_timing.vhd:40:29  */
  assign n114_o = {6'b0, acc};  //  uext
  /* rtl/uart_timing.vhd:40:29  */
  assign n116_o = n114_o + 32'b00000000000000000010010110000000;
  /* rtl/uart_timing.vhd:40:25  */
  assign n117_o = n116_o[25:0];  // trunc
  /* rtl/uart_timing.vhd:36:13  */
  assign n120_o = n107_o ? 1'b1 : 1'b0;
  /* rtl/uart_timing.vhd:36:13  */
  assign n121_o = n107_o ? n113_o : n117_o;
  /* rtl/uart_timing.vhd:33:13  */
  assign n123_o = rst ? 1'b0 : n120_o;
  /* rtl/uart_timing.vhd:33:13  */
  assign n125_o = rst ? 26'b00000000000000000000000000 : n121_o;
  /* rtl/uart_timing.vhd:32:9  */
  always @(posedge clk)
    n129_q <= n125_o;
  initial
    n129_q = 26'b00000000000000000000000000;
  /* rtl/uart_timing.vhd:32:9  */
  always @(posedge clk)
    n130_q <= n123_o;
endmodule

module uart_tx
  (input  clk,
   input  rst,
   input  [7:0] data_in,
   input  data_valid,
   output ready,
   output tx,
   output busy,
   output done);
  reg [2:0] state;
  wire tick;
  reg [7:0] shreg;
  reg [2:0] bit_idx;
  wire u_timing_tick;
  wire [2:0] n12_o;
  wire [7:0] n13_o;
  wire n15_o;
  wire n17_o;
  wire [2:0] n19_o;
  wire [2:0] n21_o;
  wire n23_o;
  wire n24_o;
  wire [6:0] n25_o;
  wire [7:0] n27_o;
  wire n29_o;
  wire [2:0] n31_o;
  wire [2:0] n33_o;
  wire [2:0] n34_o;
  wire n35_o;
  wire n36_o;
  wire [7:0] n37_o;
  wire [2:0] n38_o;
  wire n40_o;
  wire n42_o;
  wire [2:0] n44_o;
  wire n46_o;
  wire n49_o;
  wire [2:0] n51_o;
  wire n53_o;
  wire [4:0] n54_o;
  reg n57_o;
  reg n60_o;
  reg [2:0] n62_o;
  reg [7:0] n64_o;
  reg [2:0] n66_o;
  wire n68_o;
  wire n70_o;
  wire [2:0] n73_o;
  wire [7:0] n74_o;
  wire [2:0] n76_o;
  wire n85_o;
  wire n86_o;
  wire n90_o;
  wire n91_o;
  reg [2:0] n93_q;
  reg [7:0] n94_q;
  reg [2:0] n95_q;
  reg n96_q;
  reg n97_q;
  assign ready = n86_o;
  assign tx = n96_q;
  assign busy = n91_o;
  assign done = n97_q;
  /* rtl/uart_tx.vhd:30:12  */
  always @*
    state = n93_q; // (isignal)
  initial
    state = 3'b000;
  /* rtl/uart_tx.vhd:31:12  */
  assign tick = u_timing_tick; // (signal)
  /* rtl/uart_tx.vhd:32:12  */
  always @*
    shreg = n94_q; // (isignal)
  initial
    shreg = 8'b00000000;
  /* rtl/uart_tx.vhd:33:12  */
  always @*
    bit_idx = n95_q; // (isignal)
  initial
    bit_idx = 3'b000;
  /* rtl/uart_tx.vhd:35:5  */
  uart_timing_50000000_9600_1 u_timing (
    .clk(clk),
    .rst(rst),
    .tick(u_timing_tick));
  /* rtl/uart_tx.vhd:51:25  */
  assign n12_o = data_valid ? 3'b001 : state;
  /* rtl/uart_tx.vhd:51:25  */
  assign n13_o = data_valid ? data_in : shreg;
  /* rtl/uart_tx.vhd:49:21  */
  assign n15_o = state == 3'b000;
  /* rtl/uart_tx.vhd:57:25  */
  assign n17_o = tick ? 1'b0 : n96_q;
  /* rtl/uart_tx.vhd:57:25  */
  assign n19_o = tick ? 3'b010 : state;
  /* rtl/uart_tx.vhd:57:25  */
  assign n21_o = tick ? 3'b000 : bit_idx;
  /* rtl/uart_tx.vhd:56:21  */
  assign n23_o = state == 3'b001;
  /* rtl/uart_tx.vhd:65:43  */
  assign n24_o = shreg[0];
  /* rtl/uart_tx.vhd:66:49  */
  assign n25_o = shreg[7:1];
  /* rtl/uart_tx.vhd:66:42  */
  assign n27_o = {1'b0, n25_o};
  /* rtl/uart_tx.vhd:67:40  */
  assign n29_o = bit_idx == 3'b111;
  /* rtl/uart_tx.vhd:70:52  */
  assign n31_o = bit_idx + 3'b001;
  /* rtl/uart_tx.vhd:64:25  */
  assign n33_o = n36_o ? 3'b011 : state;
  /* rtl/uart_tx.vhd:67:29  */
  assign n34_o = n29_o ? bit_idx : n31_o;
  /* rtl/uart_tx.vhd:64:25  */
  assign n35_o = tick ? n24_o : n96_q;
  /* rtl/uart_tx.vhd:64:25  */
  assign n36_o = n29_o & tick;
  /* rtl/uart_tx.vhd:64:25  */
  assign n37_o = tick ? n27_o : shreg;
  /* rtl/uart_tx.vhd:64:25  */
  assign n38_o = tick ? n34_o : bit_idx;
  /* rtl/uart_tx.vhd:63:21  */
  assign n40_o = state == 3'b010;
  /* rtl/uart_tx.vhd:75:25  */
  assign n42_o = tick ? 1'b1 : n96_q;
  /* rtl/uart_tx.vhd:75:25  */
  assign n44_o = tick ? 3'b100 : state;
  /* rtl/uart_tx.vhd:74:21  */
  assign n46_o = state == 3'b011;
  /* rtl/uart_tx.vhd:81:25  */
  assign n49_o = tick ? 1'b1 : 1'b0;
  /* rtl/uart_tx.vhd:81:25  */
  assign n51_o = tick ? 3'b000 : state;
  /* rtl/uart_tx.vhd:80:21  */
  assign n53_o = state == 3'b100;
  assign n54_o = {n53_o, n46_o, n40_o, n23_o, n15_o};
  /* rtl/uart_tx.vhd:48:17  */
  always @*
    case (n54_o)
      5'b10000: n57_o = n96_q;
      5'b01000: n57_o = n42_o;
      5'b00100: n57_o = n35_o;
      5'b00010: n57_o = n17_o;
      5'b00001: n57_o = 1'b1;
      default: n57_o = 1'bX;
    endcase
  /* rtl/uart_tx.vhd:48:17  */
  always @*
    case (n54_o)
      5'b10000: n60_o = n49_o;
      5'b01000: n60_o = 1'b0;
      5'b00100: n60_o = 1'b0;
      5'b00010: n60_o = 1'b0;
      5'b00001: n60_o = 1'b0;
      default: n60_o = 1'bX;
    endcase
  /* rtl/uart_tx.vhd:48:17  */
  always @*
    case (n54_o)
      5'b10000: n62_o = n51_o;
      5'b01000: n62_o = n44_o;
      5'b00100: n62_o = n33_o;
      5'b00010: n62_o = n19_o;
      5'b00001: n62_o = n12_o;
      default: n62_o = 3'bX;
    endcase
  /* rtl/uart_tx.vhd:48:17  */
  always @*
    case (n54_o)
      5'b10000: n64_o = shreg;
      5'b01000: n64_o = shreg;
      5'b00100: n64_o = n37_o;
      5'b00010: n64_o = shreg;
      5'b00001: n64_o = n13_o;
      default: n64_o = 8'bX;
    endcase
  /* rtl/uart_tx.vhd:48:17  */
  always @*
    case (n54_o)
      5'b10000: n66_o = bit_idx;
      5'b01000: n66_o = bit_idx;
      5'b00100: n66_o = n38_o;
      5'b00010: n66_o = n21_o;
      5'b00001: n66_o = bit_idx;
      default: n66_o = 3'bX;
    endcase
  /* rtl/uart_tx.vhd:43:13  */
  assign n68_o = rst ? 1'b1 : n57_o;
  /* rtl/uart_tx.vhd:43:13  */
  assign n70_o = rst ? 1'b0 : n60_o;
  /* rtl/uart_tx.vhd:43:13  */
  assign n73_o = rst ? 3'b000 : n62_o;
  /* rtl/uart_tx.vhd:43:13  */
  assign n74_o = rst ? shreg : n64_o;
  /* rtl/uart_tx.vhd:43:13  */
  assign n76_o = rst ? 3'b000 : n66_o;
  /* rtl/uart_tx.vhd:90:29  */
  assign n85_o = state == 3'b000;
  /* rtl/uart_tx.vhd:90:18  */
  assign n86_o = n85_o ? 1'b1 : 1'b0;
  /* rtl/uart_tx.vhd:91:29  */
  assign n90_o = state == 3'b000;
  /* rtl/uart_tx.vhd:91:18  */
  assign n91_o = n90_o ? 1'b0 : 1'b1;
  /* rtl/uart_tx.vhd:41:9  */
  always @(posedge clk)
    n93_q <= n73_o;
  initial
    n93_q = 3'b000;
  /* rtl/uart_tx.vhd:41:9  */
  always @(posedge clk)
    n94_q <= n74_o;
  initial
    n94_q = 8'b00000000;
  /* rtl/uart_tx.vhd:41:9  */
  always @(posedge clk)
    n95_q <= n76_o;
  initial
    n95_q = 3'b000;
  /* rtl/uart_tx.vhd:41:9  */
  always @(posedge clk)
    n96_q <= n68_o;
  /* rtl/uart_tx.vhd:41:9  */
  always @(posedge clk)
    n97_q <= n70_o;
endmodule

