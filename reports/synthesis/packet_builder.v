module packet_builder
  (input  clk,
   input  rst,
   input  start,
   input  [7:0] resp_type,
   input  [15:0] resp_seq,
   input  [95:0] resp_nonce,
   input  [8:0] resp_len,
   input  resp_has_tag,
   input  resp_is_err,
   input  [7:0] resp_code,
   input  [127:0] resp_tag,
   input  [7:0] pay_data,
   input  full,
   output busy,
   output done,
   output [3:0] pay_blk,
   output [3:0] pay_byte,
   output wr_en,
   output [7:0] wr_data);
  reg state;
  reg [1:0] phase;
  reg [7:0] l_type;
  reg [7:0] l_code;
  reg [15:0] l_seq;
  reg [95:0] l_nonce;
  reg [8:0] l_len;
  reg [127:0] l_tag;
  reg l_has_tag;
  reg l_is_err;
  reg [4:0] ri;
  reg [8:0] pay_idx;
  reg [3:0] p_blk;
  reg [3:0] p_byte;
  reg [3:0] tag_j;
  wire n23_o;
  wire n24_o;
  wire n28_o;
  wire n29_o;
  wire n30_o;
  wire n31_o;
  wire [15:0] n37_o;
  wire n39_o;
  wire n41_o;
  wire n43_o;
  wire [7:0] n44_o;
  wire n46_o;
  wire [7:0] n47_o;
  wire n49_o;
  wire [6:0] n64_o;
  wire [6:0] n66_o;
  wire n71_o;
  wire n72_o;
  wire n73_o;
  wire [7:0] n74_o;
  wire n76_o;
  wire [7:0] n77_o;
  wire [6:0] n78_o;
  reg [7:0] n81_o;
  wire n83_o;
  wire [7:0] n84_o;
  wire n86_o;
  wire [6:0] n97_o;
  wire [6:0] n99_o;
  wire n103_o;
  wire [2:0] n104_o;
  reg [7:0] n106_o;
  wire n113_o;
  wire [1:0] n115_o;
  wire [7:0] n116_o;
  wire [7:0] n117_o;
  wire [15:0] n118_o;
  wire [95:0] n119_o;
  wire [8:0] n120_o;
  wire [127:0] n121_o;
  wire n122_o;
  wire n123_o;
  wire [4:0] n125_o;
  wire [8:0] n127_o;
  wire [3:0] n129_o;
  wire [3:0] n131_o;
  wire [3:0] n133_o;
  wire n135_o;
  wire n136_o;
  wire [31:0] n137_o;
  wire n139_o;
  wire [31:0] n140_o;
  wire n142_o;
  wire n148_o;
  wire n150_o;
  wire [1:0] n152_o;
  wire n154_o;
  wire n155_o;
  wire [1:0] n157_o;
  wire [31:0] n158_o;
  wire [31:0] n160_o;
  wire [4:0] n161_o;
  wire n163_o;
  wire n164_o;
  wire [1:0] n165_o;
  wire [4:0] n166_o;
  wire n168_o;
  wire [31:0] n169_o;
  wire [31:0] n171_o;
  wire [31:0] n172_o;
  wire n173_o;
  wire n179_o;
  wire n181_o;
  wire [1:0] n183_o;
  wire [31:0] n184_o;
  wire [31:0] n186_o;
  wire [8:0] n187_o;
  wire [31:0] n188_o;
  wire n190_o;
  wire [31:0] n191_o;
  wire [31:0] n193_o;
  wire [3:0] n194_o;
  wire [31:0] n195_o;
  wire [31:0] n197_o;
  wire [3:0] n198_o;
  wire [3:0] n199_o;
  wire [3:0] n201_o;
  wire n203_o;
  wire n204_o;
  wire n205_o;
  wire [8:0] n206_o;
  wire [3:0] n207_o;
  wire [3:0] n208_o;
  wire n210_o;
  wire [31:0] n211_o;
  wire n213_o;
  wire [31:0] n217_o;
  wire [31:0] n219_o;
  wire [3:0] n220_o;
  wire n223_o;
  wire n225_o;
  wire [3:0] n226_o;
  wire n228_o;
  wire [2:0] n229_o;
  reg n231_o;
  reg n233_o;
  reg [1:0] n235_o;
  reg [4:0] n237_o;
  reg [8:0] n239_o;
  reg [3:0] n241_o;
  reg [3:0] n243_o;
  reg [3:0] n245_o;
  wire n247_o;
  wire n248_o;
  wire [1:0] n249_o;
  wire [4:0] n250_o;
  wire [8:0] n251_o;
  wire [3:0] n252_o;
  wire [3:0] n253_o;
  wire [3:0] n254_o;
  wire n256_o;
  wire [1:0] n257_o;
  reg n260_o;
  reg n262_o;
  reg [1:0] n264_o;
  reg [7:0] n266_o;
  reg [7:0] n268_o;
  reg [15:0] n270_o;
  reg [95:0] n272_o;
  reg [8:0] n274_o;
  reg [127:0] n276_o;
  reg n278_o;
  reg n280_o;
  reg [4:0] n282_o;
  reg [8:0] n284_o;
  reg [3:0] n286_o;
  reg [3:0] n288_o;
  reg [3:0] n290_o;
  wire n292_o;
  wire n295_o;
  wire [1:0] n297_o;
  wire [7:0] n298_o;
  wire [7:0] n299_o;
  wire [15:0] n300_o;
  wire [95:0] n301_o;
  wire [8:0] n302_o;
  wire [127:0] n303_o;
  wire n304_o;
  wire n305_o;
  wire [4:0] n307_o;
  wire [8:0] n308_o;
  wire [3:0] n309_o;
  wire [3:0] n310_o;
  wire [3:0] n311_o;
  reg n329_q;
  reg [1:0] n330_q;
  reg [7:0] n331_q;
  reg [7:0] n332_q;
  reg [15:0] n333_q;
  reg [95:0] n334_q;
  reg [8:0] n335_q;
  reg [127:0] n336_q;
  reg n337_q;
  reg n338_q;
  reg [4:0] n339_q;
  reg [8:0] n340_q;
  reg [3:0] n341_q;
  reg [3:0] n342_q;
  reg [3:0] n343_q;
  reg n344_q;
  wire [7:0] n345_o;
  wire [7:0] n346_o;
  wire [7:0] n347_o;
  wire [7:0] n348_o;
  wire [7:0] n349_o;
  wire [7:0] n350_o;
  wire [7:0] n351_o;
  wire [7:0] n352_o;
  wire [7:0] n353_o;
  wire [7:0] n354_o;
  wire [7:0] n355_o;
  wire [7:0] n356_o;
  wire [3:0] n357_o;
  wire [1:0] n358_o;
  reg [7:0] n359_o;
  wire [1:0] n360_o;
  reg [7:0] n361_o;
  wire [1:0] n362_o;
  reg [7:0] n363_o;
  wire n364_o;
  wire [7:0] n365_o;
  wire n366_o;
  wire [7:0] n367_o;
  wire [7:0] n368_o;
  wire [7:0] n369_o;
  wire [7:0] n370_o;
  wire [7:0] n371_o;
  wire [7:0] n372_o;
  wire [7:0] n373_o;
  wire [7:0] n374_o;
  wire [7:0] n375_o;
  wire [7:0] n376_o;
  wire [7:0] n377_o;
  wire [7:0] n378_o;
  wire [7:0] n379_o;
  wire [7:0] n380_o;
  wire [7:0] n381_o;
  wire [7:0] n382_o;
  wire [7:0] n383_o;
  wire [3:0] n384_o;
  wire [1:0] n385_o;
  reg [7:0] n386_o;
  wire [1:0] n387_o;
  reg [7:0] n388_o;
  wire [1:0] n389_o;
  reg [7:0] n390_o;
  wire [1:0] n391_o;
  reg [7:0] n392_o;
  wire [1:0] n393_o;
  reg [7:0] n394_o;
  assign busy = n24_o;
  assign done = n344_q;
  assign pay_blk = p_blk;
  assign pay_byte = p_byte;
  assign wr_en = n31_o;
  assign wr_data = n106_o;
  /* rtl/packet_builder.vhd:49:12  */
  always @*
    state = n329_q; // (isignal)
  initial
    state = 1'b0;
  /* rtl/packet_builder.vhd:50:12  */
  always @*
    phase = n330_q; // (isignal)
  initial
    phase = 2'b00;
  /* rtl/packet_builder.vhd:52:12  */
  always @*
    l_type = n331_q; // (isignal)
  initial
    l_type = 8'b00000000;
  /* rtl/packet_builder.vhd:52:20  */
  always @*
    l_code = n332_q; // (isignal)
  initial
    l_code = 8'b00000000;
  /* rtl/packet_builder.vhd:53:12  */
  always @*
    l_seq = n333_q; // (isignal)
  initial
    l_seq = 16'b0000000000000000;
  /* rtl/packet_builder.vhd:54:12  */
  always @*
    l_nonce = n334_q; // (isignal)
  initial
    l_nonce = 96'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
  /* rtl/packet_builder.vhd:55:12  */
  always @*
    l_len = n335_q; // (isignal)
  initial
    l_len = 9'b000000000;
  /* rtl/packet_builder.vhd:56:12  */
  always @*
    l_tag = n336_q; // (isignal)
  initial
    l_tag = 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
  /* rtl/packet_builder.vhd:57:12  */
  always @*
    l_has_tag = n337_q; // (isignal)
  initial
    l_has_tag = 1'b0;
  /* rtl/packet_builder.vhd:57:23  */
  always @*
    l_is_err = n338_q; // (isignal)
  initial
    l_is_err = 1'b0;
  /* rtl/packet_builder.vhd:59:12  */
  always @*
    ri = n339_q; // (isignal)
  initial
    ri = 5'b00000;
  /* rtl/packet_builder.vhd:60:12  */
  always @*
    pay_idx = n340_q; // (isignal)
  initial
    pay_idx = 9'b000000000;
  /* rtl/packet_builder.vhd:61:12  */
  always @*
    p_blk = n341_q; // (isignal)
  initial
    p_blk = 4'b0000;
  /* rtl/packet_builder.vhd:62:12  */
  always @*
    p_byte = n342_q; // (isignal)
  initial
    p_byte = 4'b0000;
  /* rtl/packet_builder.vhd:62:20  */
  always @*
    tag_j = n343_q; // (isignal)
  initial
    tag_j = 4'b0000;
  /* rtl/packet_builder.vhd:64:32  */
  assign n23_o = state == 1'b0;
  /* rtl/packet_builder.vhd:64:21  */
  assign n24_o = n23_o ? 1'b0 : 1'b1;
  /* rtl/packet_builder.vhd:65:32  */
  assign n28_o = state == 1'b1;
  /* rtl/packet_builder.vhd:65:48  */
  assign n29_o = ~full;
  /* rtl/packet_builder.vhd:65:39  */
  assign n30_o = n29_o & n28_o;
  /* rtl/packet_builder.vhd:65:21  */
  assign n31_o = n30_o ? 1'b1 : 1'b0;
  /* rtl/packet_builder.vhd:74:31  */
  assign n37_o = {7'b0, l_len};  //  uext
  /* rtl/packet_builder.vhd:78:21  */
  assign n39_o = ri == 5'b00000;
  /* rtl/packet_builder.vhd:79:21  */
  assign n41_o = ri == 5'b00001;
  /* rtl/packet_builder.vhd:80:21  */
  assign n43_o = ri == 5'b00010;
  /* rtl/packet_builder.vhd:81:47  */
  assign n44_o = l_seq[15:8];
  /* rtl/packet_builder.vhd:81:21  */
  assign n46_o = ri == 5'b00011;
  /* rtl/packet_builder.vhd:82:47  */
  assign n47_o = l_seq[7:0];
  /* rtl/packet_builder.vhd:82:21  */
  assign n49_o = ri == 5'b00100;
  /* rtl/packet_builder.vhd:83:49  */
  assign n64_o = {2'b0, ri};  //  uext
  /* rtl/packet_builder.vhd:83:49  */
  assign n66_o = 7'b0010000 - n64_o;
  /* rtl/packet_builder.vhd:83:21  */
  assign n71_o = $unsigned(ri) >= $unsigned(5'b00101);
  /* rtl/packet_builder.vhd:83:21  */
  assign n72_o = $unsigned(ri) <= $unsigned(5'b10000);
  /* rtl/packet_builder.vhd:83:21  */
  assign n73_o = n71_o & n72_o;
  /* rtl/packet_builder.vhd:84:43  */
  assign n74_o = n37_o[15:8];
  /* rtl/packet_builder.vhd:84:21  */
  assign n76_o = ri == 5'b10001;
  /* rtl/packet_builder.vhd:85:43  */
  assign n77_o = n37_o[7:0];
  assign n78_o = {n76_o, n73_o, n49_o, n46_o, n43_o, n41_o, n39_o};
  /* rtl/packet_builder.vhd:77:17  */
  always @*
    case (n78_o)
      7'b1000000: n81_o = n74_o;
      7'b0100000: n81_o = n367_o;
      7'b0010000: n81_o = n47_o;
      7'b0001000: n81_o = n44_o;
      7'b0000100: n81_o = l_type;
      7'b0000010: n81_o = 8'b00000001;
      7'b0000001: n81_o = 8'b10100101;
      default: n81_o = n77_o;
    endcase
  /* rtl/packet_builder.vhd:76:13  */
  assign n83_o = phase == 2'b00;
  /* rtl/packet_builder.vhd:88:17  */
  assign n84_o = l_is_err ? l_code : pay_data;
  /* rtl/packet_builder.vhd:87:13  */
  assign n86_o = phase == 2'b01;
  /* rtl/packet_builder.vhd:90:27  */
  assign n97_o = {3'b0, tag_j};  //  uext
  /* rtl/packet_builder.vhd:90:27  */
  assign n99_o = 7'b0001111 - n97_o;
  /* rtl/packet_builder.vhd:89:13  */
  assign n103_o = phase == 2'b10;
  assign n104_o = {n103_o, n86_o, n83_o};
  /* rtl/packet_builder.vhd:75:9  */
  always @*
    case (n104_o)
      3'b100: n106_o = n394_o;
      3'b010: n106_o = n84_o;
      3'b001: n106_o = n81_o;
      default: n106_o = 8'bX;
    endcase
  /* rtl/packet_builder.vhd:111:25  */
  assign n113_o = start ? 1'b1 : state;
  /* rtl/packet_builder.vhd:111:25  */
  assign n115_o = start ? 2'b00 : phase;
  /* rtl/packet_builder.vhd:111:25  */
  assign n116_o = start ? resp_type : l_type;
  /* rtl/packet_builder.vhd:111:25  */
  assign n117_o = start ? resp_code : l_code;
  /* rtl/packet_builder.vhd:111:25  */
  assign n118_o = start ? resp_seq : l_seq;
  /* rtl/packet_builder.vhd:111:25  */
  assign n119_o = start ? resp_nonce : l_nonce;
  /* rtl/packet_builder.vhd:111:25  */
  assign n120_o = start ? resp_len : l_len;
  /* rtl/packet_builder.vhd:111:25  */
  assign n121_o = start ? resp_tag : l_tag;
  /* rtl/packet_builder.vhd:111:25  */
  assign n122_o = start ? resp_has_tag : l_has_tag;
  /* rtl/packet_builder.vhd:111:25  */
  assign n123_o = start ? resp_is_err : l_is_err;
  /* rtl/packet_builder.vhd:111:25  */
  assign n125_o = start ? 5'b00000 : ri;
  /* rtl/packet_builder.vhd:111:25  */
  assign n127_o = start ? 9'b000000000 : pay_idx;
  /* rtl/packet_builder.vhd:111:25  */
  assign n129_o = start ? 4'b0000 : p_blk;
  /* rtl/packet_builder.vhd:111:25  */
  assign n131_o = start ? 4'b0000 : p_byte;
  /* rtl/packet_builder.vhd:111:25  */
  assign n133_o = start ? 4'b0000 : tag_j;
  /* rtl/packet_builder.vhd:110:21  */
  assign n135_o = state == 1'b0;
  /* rtl/packet_builder.vhd:130:33  */
  assign n136_o = ~full;
  /* rtl/packet_builder.vhd:133:43  */
  assign n137_o = {27'b0, ri};  //  uext
  /* rtl/packet_builder.vhd:133:43  */
  assign n139_o = n137_o == 32'b00000000000000000000000000010010;
  /* rtl/packet_builder.vhd:134:50  */
  assign n140_o = {23'b0, l_len};  //  uext
  /* rtl/packet_builder.vhd:134:50  */
  assign n142_o = $signed(n140_o) > $signed(32'b00000000000000000000000000000000);
  /* rtl/packet_builder.vhd:136:41  */
  assign n148_o = l_has_tag ? 1'b0 : 1'b1;
  /* rtl/packet_builder.vhd:136:41  */
  assign n150_o = l_has_tag ? state : 1'b0;
  /* rtl/packet_builder.vhd:136:41  */
  assign n152_o = l_has_tag ? 2'b10 : phase;
  /* rtl/packet_builder.vhd:134:41  */
  assign n154_o = n142_o ? 1'b0 : n148_o;
  /* rtl/packet_builder.vhd:134:41  */
  assign n155_o = n142_o ? state : n150_o;
  /* rtl/packet_builder.vhd:134:41  */
  assign n157_o = n142_o ? 2'b01 : n152_o;
  /* rtl/packet_builder.vhd:142:50  */
  assign n158_o = {27'b0, ri};  //  uext
  /* rtl/packet_builder.vhd:142:50  */
  assign n160_o = n158_o + 32'b00000000000000000000000000000001;
  /* rtl/packet_builder.vhd:142:47  */
  assign n161_o = n160_o[4:0];  // trunc
  /* rtl/packet_builder.vhd:133:37  */
  assign n163_o = n139_o ? n154_o : 1'b0;
  /* rtl/packet_builder.vhd:133:37  */
  assign n164_o = n139_o ? n155_o : state;
  /* rtl/packet_builder.vhd:133:37  */
  assign n165_o = n139_o ? n157_o : phase;
  /* rtl/packet_builder.vhd:133:37  */
  assign n166_o = n139_o ? ri : n161_o;
  /* rtl/packet_builder.vhd:132:33  */
  assign n168_o = phase == 2'b00;
  /* rtl/packet_builder.vhd:145:48  */
  assign n169_o = {23'b0, pay_idx};  //  uext
  /* rtl/packet_builder.vhd:145:48  */
  assign n171_o = n169_o + 32'b00000000000000000000000000000001;
  /* rtl/packet_builder.vhd:145:52  */
  assign n172_o = {23'b0, l_len};  //  uext
  /* rtl/packet_builder.vhd:145:52  */
  assign n173_o = n171_o == n172_o;
  /* rtl/packet_builder.vhd:146:41  */
  assign n179_o = l_has_tag ? 1'b0 : 1'b1;
  /* rtl/packet_builder.vhd:146:41  */
  assign n181_o = l_has_tag ? state : 1'b0;
  /* rtl/packet_builder.vhd:145:37  */
  assign n183_o = n205_o ? 2'b10 : phase;
  /* rtl/packet_builder.vhd:148:60  */
  assign n184_o = {23'b0, pay_idx};  //  uext
  /* rtl/packet_builder.vhd:148:60  */
  assign n186_o = n184_o + 32'b00000000000000000000000000000001;
  /* rtl/packet_builder.vhd:148:52  */
  assign n187_o = n186_o[8:0];  // trunc
  /* rtl/packet_builder.vhd:149:51  */
  assign n188_o = {28'b0, p_byte};  //  uext
  /* rtl/packet_builder.vhd:149:51  */
  assign n190_o = n188_o == 32'b00000000000000000000000000001111;
  /* rtl/packet_builder.vhd:150:73  */
  assign n191_o = {28'b0, p_blk};  //  uext
  /* rtl/packet_builder.vhd:150:73  */
  assign n193_o = n191_o + 32'b00000000000000000000000000000001;
  /* rtl/packet_builder.vhd:150:67  */
  assign n194_o = n193_o[3:0];  // trunc
  /* rtl/packet_builder.vhd:152:62  */
  assign n195_o = {28'b0, p_byte};  //  uext
  /* rtl/packet_builder.vhd:152:62  */
  assign n197_o = n195_o + 32'b00000000000000000000000000000001;
  /* rtl/packet_builder.vhd:152:55  */
  assign n198_o = n197_o[3:0];  // trunc
  /* rtl/packet_builder.vhd:149:41  */
  assign n199_o = n190_o ? n194_o : p_blk;
  /* rtl/packet_builder.vhd:149:41  */
  assign n201_o = n190_o ? 4'b0000 : n198_o;
  /* rtl/packet_builder.vhd:145:37  */
  assign n203_o = n173_o ? n179_o : 1'b0;
  /* rtl/packet_builder.vhd:145:37  */
  assign n204_o = n173_o ? n181_o : state;
  /* rtl/packet_builder.vhd:145:37  */
  assign n205_o = l_has_tag & n173_o;
  /* rtl/packet_builder.vhd:145:37  */
  assign n206_o = n173_o ? pay_idx : n187_o;
  /* rtl/packet_builder.vhd:145:37  */
  assign n207_o = n173_o ? p_blk : n199_o;
  /* rtl/packet_builder.vhd:145:37  */
  assign n208_o = n173_o ? p_byte : n201_o;
  /* rtl/packet_builder.vhd:144:33  */
  assign n210_o = phase == 2'b01;
  /* rtl/packet_builder.vhd:156:46  */
  assign n211_o = {28'b0, tag_j};  //  uext
  /* rtl/packet_builder.vhd:156:46  */
  assign n213_o = n211_o == 32'b00000000000000000000000000001111;
  /* rtl/packet_builder.vhd:156:84  */
  assign n217_o = {28'b0, tag_j};  //  uext
  /* rtl/packet_builder.vhd:156:84  */
  assign n219_o = n217_o + 32'b00000000000000000000000000000001;
  /* rtl/packet_builder.vhd:156:78  */
  assign n220_o = n219_o[3:0];  // trunc
  /* rtl/packet_builder.vhd:156:37  */
  assign n223_o = n213_o ? 1'b1 : 1'b0;
  /* rtl/packet_builder.vhd:156:37  */
  assign n225_o = n213_o ? 1'b0 : state;
  /* rtl/packet_builder.vhd:156:37  */
  assign n226_o = n213_o ? tag_j : n220_o;
  /* rtl/packet_builder.vhd:155:33  */
  assign n228_o = phase == 2'b10;
  assign n229_o = {n228_o, n210_o, n168_o};
  /* rtl/packet_builder.vhd:131:29  */
  always @*
    case (n229_o)
      3'b100: n231_o = n223_o;
      3'b010: n231_o = n203_o;
      3'b001: n231_o = n163_o;
      default: n231_o = 1'bX;
    endcase
  /* rtl/packet_builder.vhd:131:29  */
  always @*
    case (n229_o)
      3'b100: n233_o = n225_o;
      3'b010: n233_o = n204_o;
      3'b001: n233_o = n164_o;
      default: n233_o = 1'bX;
    endcase
  /* rtl/packet_builder.vhd:131:29  */
  always @*
    case (n229_o)
      3'b100: n235_o = phase;
      3'b010: n235_o = n183_o;
      3'b001: n235_o = n165_o;
      default: n235_o = 2'bX;
    endcase
  /* rtl/packet_builder.vhd:131:29  */
  always @*
    case (n229_o)
      3'b100: n237_o = ri;
      3'b010: n237_o = ri;
      3'b001: n237_o = n166_o;
      default: n237_o = 5'bX;
    endcase
  /* rtl/packet_builder.vhd:131:29  */
  always @*
    case (n229_o)
      3'b100: n239_o = pay_idx;
      3'b010: n239_o = n206_o;
      3'b001: n239_o = pay_idx;
      default: n239_o = 9'bX;
    endcase
  /* rtl/packet_builder.vhd:131:29  */
  always @*
    case (n229_o)
      3'b100: n241_o = p_blk;
      3'b010: n241_o = n207_o;
      3'b001: n241_o = p_blk;
      default: n241_o = 4'bX;
    endcase
  /* rtl/packet_builder.vhd:131:29  */
  always @*
    case (n229_o)
      3'b100: n243_o = p_byte;
      3'b010: n243_o = n208_o;
      3'b001: n243_o = p_byte;
      default: n243_o = 4'bX;
    endcase
  /* rtl/packet_builder.vhd:131:29  */
  always @*
    case (n229_o)
      3'b100: n245_o = n226_o;
      3'b010: n245_o = tag_j;
      3'b001: n245_o = tag_j;
      default: n245_o = 4'bX;
    endcase
  /* rtl/packet_builder.vhd:130:25  */
  assign n247_o = n136_o ? n231_o : 1'b0;
  /* rtl/packet_builder.vhd:130:25  */
  assign n248_o = n136_o ? n233_o : state;
  /* rtl/packet_builder.vhd:130:25  */
  assign n249_o = n136_o ? n235_o : phase;
  /* rtl/packet_builder.vhd:130:25  */
  assign n250_o = n136_o ? n237_o : ri;
  /* rtl/packet_builder.vhd:130:25  */
  assign n251_o = n136_o ? n239_o : pay_idx;
  /* rtl/packet_builder.vhd:130:25  */
  assign n252_o = n136_o ? n241_o : p_blk;
  /* rtl/packet_builder.vhd:130:25  */
  assign n253_o = n136_o ? n243_o : p_byte;
  /* rtl/packet_builder.vhd:130:25  */
  assign n254_o = n136_o ? n245_o : tag_j;
  /* rtl/packet_builder.vhd:129:21  */
  assign n256_o = state == 1'b1;
  assign n257_o = {n256_o, n135_o};
  /* rtl/packet_builder.vhd:109:17  */
  always @*
    case (n257_o)
      2'b10: n260_o = n247_o;
      2'b01: n260_o = 1'b0;
      default: n260_o = 1'bX;
    endcase
  /* rtl/packet_builder.vhd:109:17  */
  always @*
    case (n257_o)
      2'b10: n262_o = n248_o;
      2'b01: n262_o = n113_o;
      default: n262_o = 1'bX;
    endcase
  /* rtl/packet_builder.vhd:109:17  */
  always @*
    case (n257_o)
      2'b10: n264_o = n249_o;
      2'b01: n264_o = n115_o;
      default: n264_o = 2'bX;
    endcase
  /* rtl/packet_builder.vhd:109:17  */
  always @*
    case (n257_o)
      2'b10: n266_o = l_type;
      2'b01: n266_o = n116_o;
      default: n266_o = 8'bX;
    endcase
  /* rtl/packet_builder.vhd:109:17  */
  always @*
    case (n257_o)
      2'b10: n268_o = l_code;
      2'b01: n268_o = n117_o;
      default: n268_o = 8'bX;
    endcase
  /* rtl/packet_builder.vhd:109:17  */
  always @*
    case (n257_o)
      2'b10: n270_o = l_seq;
      2'b01: n270_o = n118_o;
      default: n270_o = 16'bX;
    endcase
  /* rtl/packet_builder.vhd:109:17  */
  always @*
    case (n257_o)
      2'b10: n272_o = l_nonce;
      2'b01: n272_o = n119_o;
      default: n272_o = 96'bX;
    endcase
  /* rtl/packet_builder.vhd:109:17  */
  always @*
    case (n257_o)
      2'b10: n274_o = l_len;
      2'b01: n274_o = n120_o;
      default: n274_o = 9'bX;
    endcase
  /* rtl/packet_builder.vhd:109:17  */
  always @*
    case (n257_o)
      2'b10: n276_o = l_tag;
      2'b01: n276_o = n121_o;
      default: n276_o = 128'bX;
    endcase
  /* rtl/packet_builder.vhd:109:17  */
  always @*
    case (n257_o)
      2'b10: n278_o = l_has_tag;
      2'b01: n278_o = n122_o;
      default: n278_o = 1'bX;
    endcase
  /* rtl/packet_builder.vhd:109:17  */
  always @*
    case (n257_o)
      2'b10: n280_o = l_is_err;
      2'b01: n280_o = n123_o;
      default: n280_o = 1'bX;
    endcase
  /* rtl/packet_builder.vhd:109:17  */
  always @*
    case (n257_o)
      2'b10: n282_o = n250_o;
      2'b01: n282_o = n125_o;
      default: n282_o = 5'bX;
    endcase
  /* rtl/packet_builder.vhd:109:17  */
  always @*
    case (n257_o)
      2'b10: n284_o = n251_o;
      2'b01: n284_o = n127_o;
      default: n284_o = 9'bX;
    endcase
  /* rtl/packet_builder.vhd:109:17  */
  always @*
    case (n257_o)
      2'b10: n286_o = n252_o;
      2'b01: n286_o = n129_o;
      default: n286_o = 4'bX;
    endcase
  /* rtl/packet_builder.vhd:109:17  */
  always @*
    case (n257_o)
      2'b10: n288_o = n253_o;
      2'b01: n288_o = n131_o;
      default: n288_o = 4'bX;
    endcase
  /* rtl/packet_builder.vhd:109:17  */
  always @*
    case (n257_o)
      2'b10: n290_o = n254_o;
      2'b01: n290_o = n133_o;
      default: n290_o = 4'bX;
    endcase
  /* rtl/packet_builder.vhd:104:13  */
  assign n292_o = rst ? 1'b0 : n260_o;
  /* rtl/packet_builder.vhd:104:13  */
  assign n295_o = rst ? 1'b0 : n262_o;
  /* rtl/packet_builder.vhd:104:13  */
  assign n297_o = rst ? 2'b00 : n264_o;
  /* rtl/packet_builder.vhd:104:13  */
  assign n298_o = rst ? l_type : n266_o;
  /* rtl/packet_builder.vhd:104:13  */
  assign n299_o = rst ? l_code : n268_o;
  /* rtl/packet_builder.vhd:104:13  */
  assign n300_o = rst ? l_seq : n270_o;
  /* rtl/packet_builder.vhd:104:13  */
  assign n301_o = rst ? l_nonce : n272_o;
  /* rtl/packet_builder.vhd:104:13  */
  assign n302_o = rst ? l_len : n274_o;
  /* rtl/packet_builder.vhd:104:13  */
  assign n303_o = rst ? l_tag : n276_o;
  /* rtl/packet_builder.vhd:104:13  */
  assign n304_o = rst ? l_has_tag : n278_o;
  /* rtl/packet_builder.vhd:104:13  */
  assign n305_o = rst ? l_is_err : n280_o;
  /* rtl/packet_builder.vhd:104:13  */
  assign n307_o = rst ? 5'b00000 : n282_o;
  /* rtl/packet_builder.vhd:104:13  */
  assign n308_o = rst ? pay_idx : n284_o;
  /* rtl/packet_builder.vhd:104:13  */
  assign n309_o = rst ? p_blk : n286_o;
  /* rtl/packet_builder.vhd:104:13  */
  assign n310_o = rst ? p_byte : n288_o;
  /* rtl/packet_builder.vhd:104:13  */
  assign n311_o = rst ? tag_j : n290_o;
  /* rtl/packet_builder.vhd:102:9  */
  always @(posedge clk)
    n329_q <= n295_o;
  initial
    n329_q = 1'b0;
  /* rtl/packet_builder.vhd:102:9  */
  always @(posedge clk)
    n330_q <= n297_o;
  initial
    n330_q = 2'b00;
  /* rtl/packet_builder.vhd:102:9  */
  always @(posedge clk)
    n331_q <= n298_o;
  initial
    n331_q = 8'b00000000;
  /* rtl/packet_builder.vhd:102:9  */
  always @(posedge clk)
    n332_q <= n299_o;
  initial
    n332_q = 8'b00000000;
  /* rtl/packet_builder.vhd:102:9  */
  always @(posedge clk)
    n333_q <= n300_o;
  initial
    n333_q = 16'b0000000000000000;
  /* rtl/packet_builder.vhd:102:9  */
  always @(posedge clk)
    n334_q <= n301_o;
  initial
    n334_q = 96'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
  /* rtl/packet_builder.vhd:102:9  */
  always @(posedge clk)
    n335_q <= n302_o;
  initial
    n335_q = 9'b000000000;
  /* rtl/packet_builder.vhd:102:9  */
  always @(posedge clk)
    n336_q <= n303_o;
  initial
    n336_q = 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
  /* rtl/packet_builder.vhd:102:9  */
  always @(posedge clk)
    n337_q <= n304_o;
  initial
    n337_q = 1'b0;
  /* rtl/packet_builder.vhd:102:9  */
  always @(posedge clk)
    n338_q <= n305_o;
  initial
    n338_q = 1'b0;
  /* rtl/packet_builder.vhd:102:9  */
  always @(posedge clk)
    n339_q <= n307_o;
  initial
    n339_q = 5'b00000;
  /* rtl/packet_builder.vhd:102:9  */
  always @(posedge clk)
    n340_q <= n308_o;
  initial
    n340_q = 9'b000000000;
  /* rtl/packet_builder.vhd:102:9  */
  always @(posedge clk)
    n341_q <= n309_o;
  initial
    n341_q = 4'b0000;
  /* rtl/packet_builder.vhd:102:9  */
  always @(posedge clk)
    n342_q <= n310_o;
  initial
    n342_q = 4'b0000;
  /* rtl/packet_builder.vhd:102:9  */
  always @(posedge clk)
    n343_q <= n311_o;
  initial
    n343_q = 4'b0000;
  /* rtl/packet_builder.vhd:102:9  */
  always @(posedge clk)
    n344_q <= n292_o;
  /* rtl/packet_builder.vhd:40:9  */
  assign n345_o = l_nonce[7:0];
  /* rtl/packet_builder.vhd:39:9  */
  assign n346_o = l_nonce[15:8];
  /* rtl/packet_builder.vhd:36:9  */
  assign n347_o = l_nonce[23:16];
  /* rtl/packet_builder.vhd:35:9  */
  assign n348_o = l_nonce[31:24];
  /* rtl/packet_builder.vhd:24:9  */
  assign n349_o = l_nonce[39:32];
  /* rtl/packet_builder.vhd:23:9  */
  assign n350_o = l_nonce[47:40];
  assign n351_o = l_nonce[55:48];
  assign n352_o = l_nonce[63:56];
  /* rtl/packet_builder.vhd:96:19  */
  assign n353_o = l_nonce[71:64];
  /* rtl/packet_builder.vhd:96:19  */
  assign n354_o = l_nonce[79:72];
  /* rtl/packet_builder.vhd:96:19  */
  assign n355_o = l_nonce[87:80];
  /* rtl/packet_builder.vhd:96:19  */
  assign n356_o = l_nonce[95:88];
  /* rtl/packet_builder.vhd:83:49  */
  assign n357_o = n66_o[3:0];  // trunc
  /* rtl/packet_builder.vhd:83:49  */
  assign n358_o = n357_o[1:0];
  /* rtl/packet_builder.vhd:83:49  */
  always @*
    case (n358_o)
      2'b00: n359_o = n345_o;
      2'b01: n359_o = n346_o;
      2'b10: n359_o = n347_o;
      2'b11: n359_o = n348_o;
    endcase
  /* rtl/packet_builder.vhd:83:49  */
  assign n360_o = n357_o[1:0];
  /* rtl/packet_builder.vhd:83:49  */
  always @*
    case (n360_o)
      2'b00: n361_o = n349_o;
      2'b01: n361_o = n350_o;
      2'b10: n361_o = n351_o;
      2'b11: n361_o = n352_o;
    endcase
  /* rtl/packet_builder.vhd:83:49  */
  assign n362_o = n357_o[1:0];
  /* rtl/packet_builder.vhd:83:49  */
  always @*
    case (n362_o)
      2'b00: n363_o = n353_o;
      2'b01: n363_o = n354_o;
      2'b10: n363_o = n355_o;
      2'b11: n363_o = n356_o;
    endcase
  /* rtl/packet_builder.vhd:90:59  */
  assign n364_o = n357_o[2];
  /* rtl/packet_builder.vhd:83:49  */
  assign n365_o = n364_o ? n361_o : n359_o;
  /* rtl/packet_builder.vhd:90:59  */
  assign n366_o = n357_o[3];
  /* rtl/packet_builder.vhd:83:49  */
  assign n367_o = n366_o ? n363_o : n365_o;
  /* rtl/packet_builder.vhd:83:49  */
  assign n368_o = l_tag[7:0];
  /* rtl/packet_builder.vhd:83:49  */
  assign n369_o = l_tag[15:8];
  assign n370_o = l_tag[23:16];
  /* rtl/packet_builder.vhd:90:36  */
  assign n371_o = l_tag[31:24];
  assign n372_o = l_tag[39:32];
  /* rtl/packet_builder.vhd:90:36  */
  assign n373_o = l_tag[47:40];
  /* rtl/packet_builder.vhd:83:78  */
  assign n374_o = l_tag[55:48];
  assign n375_o = l_tag[63:56];
  /* rtl/packet_builder.vhd:83:82  */
  assign n376_o = l_tag[71:64];
  assign n377_o = l_tag[79:72];
  /* rtl/packet_builder.vhd:83:88  */
  assign n378_o = l_tag[87:80];
  assign n379_o = l_tag[95:88];
  /* rtl/packet_builder.vhd:83:88  */
  assign n380_o = l_tag[103:96];
  /* rtl/packet_builder.vhd:83:53  */
  assign n381_o = l_tag[111:104];
  assign n382_o = l_tag[119:112];
  /* rtl/packet_builder.vhd:83:57  */
  assign n383_o = l_tag[127:120];
  /* rtl/packet_builder.vhd:90:27  */
  assign n384_o = n99_o[3:0];  // trunc
  /* rtl/packet_builder.vhd:90:27  */
  assign n385_o = n384_o[1:0];
  /* rtl/packet_builder.vhd:90:27  */
  always @*
    case (n385_o)
      2'b00: n386_o = n368_o;
      2'b01: n386_o = n369_o;
      2'b10: n386_o = n370_o;
      2'b11: n386_o = n371_o;
    endcase
  /* rtl/packet_builder.vhd:90:27  */
  assign n387_o = n384_o[1:0];
  /* rtl/packet_builder.vhd:90:27  */
  always @*
    case (n387_o)
      2'b00: n388_o = n372_o;
      2'b01: n388_o = n373_o;
      2'b10: n388_o = n374_o;
      2'b11: n388_o = n375_o;
    endcase
  /* rtl/packet_builder.vhd:90:27  */
  assign n389_o = n384_o[1:0];
  /* rtl/packet_builder.vhd:90:27  */
  always @*
    case (n389_o)
      2'b00: n390_o = n376_o;
      2'b01: n390_o = n377_o;
      2'b10: n390_o = n378_o;
      2'b11: n390_o = n379_o;
    endcase
  /* rtl/packet_builder.vhd:90:27  */
  assign n391_o = n384_o[1:0];
  /* rtl/packet_builder.vhd:90:27  */
  always @*
    case (n391_o)
      2'b00: n392_o = n380_o;
      2'b01: n392_o = n381_o;
      2'b10: n392_o = n382_o;
      2'b11: n392_o = n383_o;
    endcase
  /* rtl/packet_builder.vhd:90:27  */
  assign n393_o = n384_o[3:2];
  /* rtl/packet_builder.vhd:90:27  */
  always @*
    case (n393_o)
      2'b00: n394_o = n386_o;
      2'b01: n394_o = n388_o;
      2'b10: n394_o = n390_o;
      2'b11: n394_o = n392_o;
    endcase
endmodule

