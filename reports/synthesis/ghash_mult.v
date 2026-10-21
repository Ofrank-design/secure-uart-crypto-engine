module ghash_mult
  (input  clk,
   input  rst,
   input  start,
   input  [127:0] a,
   input  [127:0] h,
   output busy,
   output done,
   output [127:0] p);
  reg [127:0] x;
  reg [127:0] v;
  reg [127:0] z;
  reg [6:0] cnt;
  reg busy_r;
  wire n13_o;
  wire [127:0] n14_o;
  wire [127:0] n15_o;
  wire [127:0] n17_o;
  wire [6:0] n19_o;
  wire n21_o;
  wire n22_o;
  wire [127:0] n23_o;
  wire [127:0] n24_o;
  wire [126:0] n25_o;
  wire [127:0] n27_o;
  wire n28_o;
  wire [7:0] n29_o;
  wire [7:0] n31_o;
  wire [7:0] n32_o;
  wire [7:0] n33_o;
  wire [119:0] n34_o;
  wire [126:0] n35_o;
  wire [127:0] n37_o;
  wire [127:0] n38_o;
  wire [31:0] n39_o;
  wire n41_o;
  wire [31:0] n42_o;
  wire [31:0] n44_o;
  wire [6:0] n45_o;
  wire n48_o;
  wire [127:0] n49_o;
  wire [6:0] n50_o;
  wire n52_o;
  wire n54_o;
  wire [127:0] n55_o;
  wire [127:0] n56_o;
  wire [127:0] n57_o;
  wire [127:0] n58_o;
  wire [6:0] n59_o;
  wire n60_o;
  wire n65_o;
  wire [127:0] n67_o;
  wire [127:0] n68_o;
  wire [127:0] n69_o;
  wire [127:0] n70_o;
  wire [6:0] n72_o;
  wire n74_o;
  reg [127:0] n89_q;
  reg [127:0] n90_q;
  reg [127:0] n91_q;
  reg [6:0] n92_q;
  reg n93_q;
  reg n94_q;
  reg [127:0] n95_q;
  assign busy = busy_r;
  assign done = n94_q;
  assign p = n95_q;
  /* rtl/ghash_mult.vhd:21:12  */
  always @*
    x = n89_q; // (isignal)
  initial
    x = 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
  /* rtl/ghash_mult.vhd:21:15  */
  always @*
    v = n90_q; // (isignal)
  initial
    v = 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
  /* rtl/ghash_mult.vhd:21:18  */
  always @*
    z = n91_q; // (isignal)
  initial
    z = 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
  /* rtl/ghash_mult.vhd:22:12  */
  always @*
    cnt = n92_q; // (isignal)
  initial
    cnt = 7'b0000000;
  /* rtl/ghash_mult.vhd:23:12  */
  always @*
    busy_r = n93_q; // (isignal)
  initial
    busy_r = 1'b0;
  /* rtl/ghash_mult.vhd:35:26  */
  assign n13_o = ~busy_r;
  /* rtl/ghash_mult.vhd:36:17  */
  assign n14_o = start ? a : x;
  /* rtl/ghash_mult.vhd:36:17  */
  assign n15_o = start ? h : v;
  /* rtl/ghash_mult.vhd:36:17  */
  assign n17_o = start ? 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : z;
  /* rtl/ghash_mult.vhd:36:17  */
  assign n19_o = start ? 7'b0000000 : cnt;
  /* rtl/ghash_mult.vhd:36:17  */
  assign n21_o = start ? 1'b1 : busy_r;
  /* rtl/ghash_mult.vhd:45:21  */
  assign n22_o = x[127];
  /* rtl/ghash_mult.vhd:45:47  */
  assign n23_o = z ^ v;
  /* rtl/ghash_mult.vhd:45:17  */
  assign n24_o = n22_o ? n23_o : z;
  /* rtl/ghash_mult.vhd:46:30  */
  assign n25_o = v[127:1];
  /* rtl/ghash_mult.vhd:46:27  */
  assign n27_o = {1'b0, n25_o};
  /* rtl/ghash_mult.vhd:47:21  */
  assign n28_o = v[0];
  /* rtl/ghash_mult.vhd:47:60  */
  assign n29_o = n27_o[127:120];
  /* rtl/ghash_mult.vhd:47:77  */
  assign n31_o = n29_o ^ 8'b11100001;
  assign n32_o = n27_o[127:120];
  /* rtl/ghash_mult.vhd:47:17  */
  assign n33_o = n28_o ? n31_o : n32_o;
  assign n34_o = n27_o[119:0];
  /* rtl/ghash_mult.vhd:48:23  */
  assign n35_o = x[126:0];
  /* rtl/ghash_mult.vhd:48:38  */
  assign n37_o = {n35_o, 1'b0};
  assign n38_o = {n33_o, n34_o};
  /* rtl/ghash_mult.vhd:51:24  */
  assign n39_o = {25'b0, cnt};  //  uext
  /* rtl/ghash_mult.vhd:51:24  */
  assign n41_o = n39_o == 32'b00000000000000000000000001111111;
  /* rtl/ghash_mult.vhd:56:32  */
  assign n42_o = {25'b0, cnt};  //  uext
  /* rtl/ghash_mult.vhd:56:32  */
  assign n44_o = n42_o + 32'b00000000000000000000000000000001;
  /* rtl/ghash_mult.vhd:56:28  */
  assign n45_o = n44_o[6:0];  // trunc
  /* rtl/ghash_mult.vhd:51:17  */
  assign n48_o = n41_o ? 1'b1 : 1'b0;
  /* rtl/ghash_mult.vhd:51:17  */
  assign n49_o = n41_o ? n24_o : n95_q;
  /* rtl/ghash_mult.vhd:51:17  */
  assign n50_o = n41_o ? cnt : n45_o;
  /* rtl/ghash_mult.vhd:51:17  */
  assign n52_o = n41_o ? 1'b0 : busy_r;
  /* rtl/ghash_mult.vhd:35:13  */
  assign n54_o = n13_o ? 1'b0 : n48_o;
  /* rtl/ghash_mult.vhd:35:13  */
  assign n55_o = n13_o ? n95_q : n49_o;
  /* rtl/ghash_mult.vhd:35:13  */
  assign n56_o = n13_o ? n14_o : n37_o;
  /* rtl/ghash_mult.vhd:35:13  */
  assign n57_o = n13_o ? n15_o : n38_o;
  /* rtl/ghash_mult.vhd:35:13  */
  assign n58_o = n13_o ? n17_o : n24_o;
  /* rtl/ghash_mult.vhd:35:13  */
  assign n59_o = n13_o ? n19_o : n50_o;
  /* rtl/ghash_mult.vhd:35:13  */
  assign n60_o = n13_o ? n21_o : n52_o;
  /* rtl/ghash_mult.vhd:32:13  */
  assign n65_o = rst ? 1'b0 : n54_o;
  /* rtl/ghash_mult.vhd:32:13  */
  assign n67_o = rst ? n95_q : n55_o;
  /* rtl/ghash_mult.vhd:32:13  */
  assign n68_o = rst ? x : n56_o;
  /* rtl/ghash_mult.vhd:32:13  */
  assign n69_o = rst ? v : n57_o;
  /* rtl/ghash_mult.vhd:32:13  */
  assign n70_o = rst ? z : n58_o;
  /* rtl/ghash_mult.vhd:32:13  */
  assign n72_o = rst ? 7'b0000000 : n59_o;
  /* rtl/ghash_mult.vhd:32:13  */
  assign n74_o = rst ? 1'b0 : n60_o;
  /* rtl/ghash_mult.vhd:30:9  */
  always @(posedge clk)
    n89_q <= n68_o;
  initial
    n89_q = 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
  /* rtl/ghash_mult.vhd:30:9  */
  always @(posedge clk)
    n90_q <= n69_o;
  initial
    n90_q = 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
  /* rtl/ghash_mult.vhd:30:9  */
  always @(posedge clk)
    n91_q <= n70_o;
  initial
    n91_q = 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
  /* rtl/ghash_mult.vhd:30:9  */
  always @(posedge clk)
    n92_q <= n72_o;
  initial
    n92_q = 7'b0000000;
  /* rtl/ghash_mult.vhd:30:9  */
  always @(posedge clk)
    n93_q <= n74_o;
  initial
    n93_q = 1'b0;
  /* rtl/ghash_mult.vhd:30:9  */
  always @(posedge clk)
    n94_q <= n65_o;
  /* rtl/ghash_mult.vhd:30:9  */
  always @(posedge clk)
    n95_q <= n67_o;
endmodule

