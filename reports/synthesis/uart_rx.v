module uart_timing_50000000_9600_16
  (input  clk,
   input  rst,
   output tick);
  reg [25:0] acc;
  wire [31:0] n162_o;
  wire [31:0] n164_o;
  wire n166_o;
  wire [31:0] n167_o;
  wire [31:0] n169_o;
  wire [31:0] n171_o;
  wire [25:0] n172_o;
  wire [31:0] n173_o;
  wire [31:0] n175_o;
  wire [25:0] n176_o;
  wire n179_o;
  wire [25:0] n180_o;
  wire n182_o;
  wire [25:0] n184_o;
  reg [25:0] n188_q;
  reg n189_q;
  assign tick = n189_q;
  /* rtl/uart_timing.vhd:24:12  */
  always @*
    acc = n188_q; // (isignal)
  initial
    acc = 26'b00000000000000000000000000;
  /* rtl/uart_timing.vhd:36:23  */
  assign n162_o = {6'b0, acc};  //  uext
  /* rtl/uart_timing.vhd:36:23  */
  assign n164_o = n162_o + 32'b00000000000000100101100000000000;
  /* rtl/uart_timing.vhd:36:29  */
  assign n166_o = $signed(n164_o) >= $signed(32'b00000010111110101111000010000000);
  /* rtl/uart_timing.vhd:37:29  */
  assign n167_o = {6'b0, acc};  //  uext
  /* rtl/uart_timing.vhd:37:29  */
  assign n169_o = n167_o + 32'b00000000000000100101100000000000;
  /* rtl/uart_timing.vhd:37:35  */
  assign n171_o = n169_o - 32'b00000010111110101111000010000000;
  /* rtl/uart_timing.vhd:37:25  */
  assign n172_o = n171_o[25:0];  // trunc
  /* rtl/uart_timing.vhd:40:29  */
  assign n173_o = {6'b0, acc};  //  uext
  /* rtl/uart_timing.vhd:40:29  */
  assign n175_o = n173_o + 32'b00000000000000100101100000000000;
  /* rtl/uart_timing.vhd:40:25  */
  assign n176_o = n175_o[25:0];  // trunc
  /* rtl/uart_timing.vhd:36:13  */
  assign n179_o = n166_o ? 1'b1 : 1'b0;
  /* rtl/uart_timing.vhd:36:13  */
  assign n180_o = n166_o ? n172_o : n176_o;
  /* rtl/uart_timing.vhd:33:13  */
  assign n182_o = rst ? 1'b0 : n179_o;
  /* rtl/uart_timing.vhd:33:13  */
  assign n184_o = rst ? 26'b00000000000000000000000000 : n180_o;
  /* rtl/uart_timing.vhd:32:9  */
  always @(posedge clk)
    n188_q <= n184_o;
  initial
    n188_q = 26'b00000000000000000000000000;
  /* rtl/uart_timing.vhd:32:9  */
  always @(posedge clk)
    n189_q <= n182_o;
endmodule

module uart_rx
  (input  clk,
   input  rst,
   input  rx,
   output [7:0] data_out,
   output data_valid,
   output busy,
   output framing_err);
  reg [2:0] state;
  reg [1:0] sync;
  wire rx_s;
  wire tick;
  reg [3:0] tcnt;
  reg [2:0] bit_idx;
  reg [7:0] shreg;
  wire n9_o;
  wire u_timing_tick;
  wire n14_o;
  wire [1:0] n15_o;
  wire n16_o;
  wire [2:0] n18_o;
  wire [3:0] n20_o;
  wire n22_o;
  wire n24_o;
  wire n25_o;
  wire [2:0] n28_o;
  wire [3:0] n30_o;
  wire [2:0] n32_o;
  wire [3:0] n34_o;
  wire [2:0] n35_o;
  wire [3:0] n36_o;
  wire n37_o;
  wire n38_o;
  wire [3:0] n39_o;
  wire n40_o;
  wire n42_o;
  wire n44_o;
  wire [6:0] n45_o;
  wire [7:0] n46_o;
  wire n48_o;
  wire [2:0] n50_o;
  wire [2:0] n52_o;
  wire [2:0] n53_o;
  wire [3:0] n55_o;
  wire n56_o;
  wire [3:0] n58_o;
  wire [2:0] n59_o;
  wire [7:0] n60_o;
  wire n61_o;
  wire [3:0] n62_o;
  wire n63_o;
  wire n64_o;
  wire n66_o;
  wire n68_o;
  wire [7:0] n69_o;
  wire n72_o;
  wire n75_o;
  wire [2:0] n78_o;
  wire [3:0] n80_o;
  wire n81_o;
  wire n83_o;
  wire n85_o;
  wire [2:0] n86_o;
  wire [3:0] n87_o;
  wire n88_o;
  wire n90_o;
  wire n92_o;
  wire n93_o;
  wire [3:0] n94_o;
  wire n96_o;
  wire [2:0] n98_o;
  wire n100_o;
  wire [4:0] n101_o;
  reg [7:0] n103_o;
  reg n106_o;
  reg n109_o;
  reg [2:0] n111_o;
  reg [3:0] n113_o;
  reg [2:0] n115_o;
  reg [7:0] n117_o;
  wire [7:0] n119_o;
  wire n121_o;
  wire n124_o;
  wire [2:0] n127_o;
  wire [1:0] n129_o;
  wire [3:0] n131_o;
  wire [2:0] n133_o;
  wire [7:0] n134_o;
  wire n146_o;
  wire n147_o;
  reg [2:0] n149_q;
  reg [1:0] n150_q;
  reg [3:0] n151_q;
  reg [2:0] n152_q;
  reg [7:0] n153_q;
  reg [7:0] n154_q;
  reg n155_q;
  reg n156_q;
  assign data_out = n154_q;
  assign data_valid = n155_q;
  assign busy = n147_o;
  assign framing_err = n156_q;
  /* rtl/uart_rx.vhd:27:12  */
  always @*
    state = n149_q; // (isignal)
  initial
    state = 3'b000;
  /* rtl/uart_rx.vhd:29:12  */
  always @*
    sync = n150_q; // (isignal)
  initial
    sync = 2'b11;
  /* rtl/uart_rx.vhd:32:12  */
  assign rx_s = n9_o; // (signal)
  /* rtl/uart_rx.vhd:34:12  */
  assign tick = u_timing_tick; // (signal)
  /* rtl/uart_rx.vhd:35:12  */
  always @*
    tcnt = n151_q; // (isignal)
  initial
    tcnt = 4'b0000;
  /* rtl/uart_rx.vhd:36:12  */
  always @*
    bit_idx = n152_q; // (isignal)
  initial
    bit_idx = 3'b000;
  /* rtl/uart_rx.vhd:37:12  */
  always @*
    shreg = n153_q; // (isignal)
  initial
    shreg = 8'b00000000;
  /* rtl/uart_rx.vhd:39:17  */
  assign n9_o = sync[1];
  /* rtl/uart_rx.vhd:41:5  */
  uart_timing_50000000_9600_16 u_timing (
    .clk(clk),
    .rst(rst),
    .tick(u_timing_tick));
  /* rtl/uart_rx.vhd:48:32  */
  assign n14_o = sync[0];
  /* rtl/uart_rx.vhd:48:36  */
  assign n15_o = {n14_o, rx};
  /* rtl/uart_rx.vhd:61:33  */
  assign n16_o = ~rx_s;
  /* rtl/uart_rx.vhd:61:25  */
  assign n18_o = n16_o ? 3'b001 : state;
  /* rtl/uart_rx.vhd:61:25  */
  assign n20_o = n16_o ? 4'b0000 : tcnt;
  /* rtl/uart_rx.vhd:60:21  */
  assign n22_o = state == 3'b000;
  /* rtl/uart_rx.vhd:68:37  */
  assign n24_o = tcnt == 4'b0110;
  /* rtl/uart_rx.vhd:69:41  */
  assign n25_o = ~rx_s;
  /* rtl/uart_rx.vhd:69:33  */
  assign n28_o = n25_o ? 3'b010 : 3'b000;
  /* rtl/uart_rx.vhd:69:33  */
  assign n30_o = n25_o ? 4'b0000 : tcnt;
  /* rtl/uart_rx.vhd:67:25  */
  assign n32_o = n40_o ? 3'b000 : bit_idx;
  /* rtl/uart_rx.vhd:77:46  */
  assign n34_o = tcnt + 4'b0001;
  /* rtl/uart_rx.vhd:67:25  */
  assign n35_o = n38_o ? n28_o : state;
  /* rtl/uart_rx.vhd:68:29  */
  assign n36_o = n24_o ? n30_o : n34_o;
  /* rtl/uart_rx.vhd:68:29  */
  assign n37_o = n25_o & n24_o;
  /* rtl/uart_rx.vhd:67:25  */
  assign n38_o = n24_o & tick;
  /* rtl/uart_rx.vhd:67:25  */
  assign n39_o = tick ? n36_o : tcnt;
  /* rtl/uart_rx.vhd:67:25  */
  assign n40_o = n37_o & tick;
  /* rtl/uart_rx.vhd:66:21  */
  assign n42_o = state == 3'b001;
  /* rtl/uart_rx.vhd:83:37  */
  assign n44_o = tcnt == 4'b1111;
  /* rtl/uart_rx.vhd:85:54  */
  assign n45_o = shreg[7:1];
  /* rtl/uart_rx.vhd:85:47  */
  assign n46_o = {rx_s, n45_o};
  /* rtl/uart_rx.vhd:86:44  */
  assign n48_o = bit_idx == 3'b111;
  /* rtl/uart_rx.vhd:89:56  */
  assign n50_o = bit_idx + 3'b001;
  /* rtl/uart_rx.vhd:82:25  */
  assign n52_o = n61_o ? 3'b011 : state;
  /* rtl/uart_rx.vhd:86:33  */
  assign n53_o = n48_o ? bit_idx : n50_o;
  /* rtl/uart_rx.vhd:92:46  */
  assign n55_o = tcnt + 4'b0001;
  /* rtl/uart_rx.vhd:83:29  */
  assign n56_o = n48_o & n44_o;
  /* rtl/uart_rx.vhd:83:29  */
  assign n58_o = n44_o ? 4'b0000 : n55_o;
  /* rtl/uart_rx.vhd:82:25  */
  assign n59_o = n63_o ? n53_o : bit_idx;
  /* rtl/uart_rx.vhd:82:25  */
  assign n60_o = n64_o ? n46_o : shreg;
  /* rtl/uart_rx.vhd:82:25  */
  assign n61_o = n56_o & tick;
  /* rtl/uart_rx.vhd:82:25  */
  assign n62_o = tick ? n58_o : tcnt;
  /* rtl/uart_rx.vhd:82:25  */
  assign n63_o = n44_o & tick;
  /* rtl/uart_rx.vhd:82:25  */
  assign n64_o = n44_o & tick;
  /* rtl/uart_rx.vhd:81:21  */
  assign n66_o = state == 3'b010;
  /* rtl/uart_rx.vhd:98:37  */
  assign n68_o = tcnt == 4'b1111;
  /* rtl/uart_rx.vhd:97:25  */
  assign n69_o = n88_o ? shreg : n154_q;
  /* rtl/uart_rx.vhd:99:33  */
  assign n72_o = rx_s ? 1'b1 : 1'b0;
  /* rtl/uart_rx.vhd:99:33  */
  assign n75_o = rx_s ? 1'b0 : 1'b1;
  /* rtl/uart_rx.vhd:99:33  */
  assign n78_o = rx_s ? 3'b000 : 3'b100;
  /* rtl/uart_rx.vhd:108:46  */
  assign n80_o = tcnt + 4'b0001;
  /* rtl/uart_rx.vhd:98:29  */
  assign n81_o = rx_s & n68_o;
  /* rtl/uart_rx.vhd:98:29  */
  assign n83_o = n68_o ? n72_o : 1'b0;
  /* rtl/uart_rx.vhd:98:29  */
  assign n85_o = n68_o ? n75_o : 1'b0;
  /* rtl/uart_rx.vhd:97:25  */
  assign n86_o = n93_o ? n78_o : state;
  /* rtl/uart_rx.vhd:98:29  */
  assign n87_o = n68_o ? tcnt : n80_o;
  /* rtl/uart_rx.vhd:97:25  */
  assign n88_o = n81_o & tick;
  /* rtl/uart_rx.vhd:97:25  */
  assign n90_o = tick ? n83_o : 1'b0;
  /* rtl/uart_rx.vhd:97:25  */
  assign n92_o = tick ? n85_o : 1'b0;
  /* rtl/uart_rx.vhd:97:25  */
  assign n93_o = n68_o & tick;
  /* rtl/uart_rx.vhd:97:25  */
  assign n94_o = tick ? n87_o : tcnt;
  /* rtl/uart_rx.vhd:96:21  */
  assign n96_o = state == 3'b011;
  /* rtl/uart_rx.vhd:113:25  */
  assign n98_o = rx_s ? 3'b000 : state;
  /* rtl/uart_rx.vhd:112:21  */
  assign n100_o = state == 3'b100;
  assign n101_o = {n100_o, n96_o, n66_o, n42_o, n22_o};
  /* rtl/uart_rx.vhd:59:17  */
  always @*
    case (n101_o)
      5'b10000: n103_o = n154_q;
      5'b01000: n103_o = n69_o;
      5'b00100: n103_o = n154_q;
      5'b00010: n103_o = n154_q;
      5'b00001: n103_o = n154_q;
      default: n103_o = 8'bX;
    endcase
  /* rtl/uart_rx.vhd:59:17  */
  always @*
    case (n101_o)
      5'b10000: n106_o = 1'b0;
      5'b01000: n106_o = n90_o;
      5'b00100: n106_o = 1'b0;
      5'b00010: n106_o = 1'b0;
      5'b00001: n106_o = 1'b0;
      default: n106_o = 1'bX;
    endcase
  /* rtl/uart_rx.vhd:59:17  */
  always @*
    case (n101_o)
      5'b10000: n109_o = 1'b0;
      5'b01000: n109_o = n92_o;
      5'b00100: n109_o = 1'b0;
      5'b00010: n109_o = 1'b0;
      5'b00001: n109_o = 1'b0;
      default: n109_o = 1'bX;
    endcase
  /* rtl/uart_rx.vhd:59:17  */
  always @*
    case (n101_o)
      5'b10000: n111_o = n98_o;
      5'b01000: n111_o = n86_o;
      5'b00100: n111_o = n52_o;
      5'b00010: n111_o = n35_o;
      5'b00001: n111_o = n18_o;
      default: n111_o = 3'bX;
    endcase
  /* rtl/uart_rx.vhd:59:17  */
  always @*
    case (n101_o)
      5'b10000: n113_o = tcnt;
      5'b01000: n113_o = n94_o;
      5'b00100: n113_o = n62_o;
      5'b00010: n113_o = n39_o;
      5'b00001: n113_o = n20_o;
      default: n113_o = 4'bX;
    endcase
  /* rtl/uart_rx.vhd:59:17  */
  always @*
    case (n101_o)
      5'b10000: n115_o = bit_idx;
      5'b01000: n115_o = bit_idx;
      5'b00100: n115_o = n59_o;
      5'b00010: n115_o = n32_o;
      5'b00001: n115_o = bit_idx;
      default: n115_o = 3'bX;
    endcase
  /* rtl/uart_rx.vhd:59:17  */
  always @*
    case (n101_o)
      5'b10000: n117_o = shreg;
      5'b01000: n117_o = shreg;
      5'b00100: n117_o = n60_o;
      5'b00010: n117_o = shreg;
      5'b00001: n117_o = shreg;
      default: n117_o = 8'bX;
    endcase
  /* rtl/uart_rx.vhd:52:13  */
  assign n119_o = rst ? 8'b00000000 : n103_o;
  /* rtl/uart_rx.vhd:52:13  */
  assign n121_o = rst ? 1'b0 : n106_o;
  /* rtl/uart_rx.vhd:52:13  */
  assign n124_o = rst ? 1'b0 : n109_o;
  /* rtl/uart_rx.vhd:52:13  */
  assign n127_o = rst ? 3'b000 : n111_o;
  /* rtl/uart_rx.vhd:52:13  */
  assign n129_o = rst ? 2'b11 : n15_o;
  /* rtl/uart_rx.vhd:52:13  */
  assign n131_o = rst ? 4'b0000 : n113_o;
  /* rtl/uart_rx.vhd:52:13  */
  assign n133_o = rst ? 3'b000 : n115_o;
  /* rtl/uart_rx.vhd:52:13  */
  assign n134_o = rst ? shreg : n117_o;
  /* rtl/uart_rx.vhd:121:28  */
  assign n146_o = state == 3'b000;
  /* rtl/uart_rx.vhd:121:17  */
  assign n147_o = n146_o ? 1'b0 : 1'b1;
  /* rtl/uart_rx.vhd:47:9  */
  always @(posedge clk)
    n149_q <= n127_o;
  initial
    n149_q = 3'b000;
  /* rtl/uart_rx.vhd:47:9  */
  always @(posedge clk)
    n150_q <= n129_o;
  initial
    n150_q = 2'b11;
  /* rtl/uart_rx.vhd:47:9  */
  always @(posedge clk)
    n151_q <= n131_o;
  initial
    n151_q = 4'b0000;
  /* rtl/uart_rx.vhd:47:9  */
  always @(posedge clk)
    n152_q <= n133_o;
  initial
    n152_q = 3'b000;
  /* rtl/uart_rx.vhd:47:9  */
  always @(posedge clk)
    n153_q <= n134_o;
  initial
    n153_q = 8'b00000000;
  /* rtl/uart_rx.vhd:47:9  */
  always @(posedge clk)
    n154_q <= n119_o;
  /* rtl/uart_rx.vhd:47:9  */
  always @(posedge clk)
    n155_q <= n121_o;
  /* rtl/uart_rx.vhd:47:9  */
  always @(posedge clk)
    n156_q <= n124_o;
endmodule

