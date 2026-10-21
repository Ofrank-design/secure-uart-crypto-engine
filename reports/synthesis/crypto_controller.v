module packet_builder_256
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
  wire n1444_o;
  wire n1445_o;
  wire n1449_o;
  wire n1450_o;
  wire n1451_o;
  wire n1452_o;
  wire [15:0] n1458_o;
  wire n1460_o;
  wire n1462_o;
  wire n1464_o;
  wire [7:0] n1465_o;
  wire n1467_o;
  wire [7:0] n1468_o;
  wire n1470_o;
  wire [6:0] n1485_o;
  wire [6:0] n1487_o;
  wire n1492_o;
  wire n1493_o;
  wire n1494_o;
  wire [7:0] n1495_o;
  wire n1497_o;
  wire [7:0] n1498_o;
  wire [6:0] n1499_o;
  reg [7:0] n1502_o;
  wire n1504_o;
  wire [7:0] n1505_o;
  wire n1507_o;
  wire [6:0] n1518_o;
  wire [6:0] n1520_o;
  wire n1524_o;
  wire [2:0] n1525_o;
  reg [7:0] n1527_o;
  wire n1534_o;
  wire [1:0] n1536_o;
  wire [7:0] n1537_o;
  wire [7:0] n1538_o;
  wire [15:0] n1539_o;
  wire [95:0] n1540_o;
  wire [8:0] n1541_o;
  wire [127:0] n1542_o;
  wire n1543_o;
  wire n1544_o;
  wire [4:0] n1546_o;
  wire [8:0] n1548_o;
  wire [3:0] n1550_o;
  wire [3:0] n1552_o;
  wire [3:0] n1554_o;
  wire n1556_o;
  wire n1557_o;
  wire [31:0] n1558_o;
  wire n1560_o;
  wire [31:0] n1561_o;
  wire n1563_o;
  wire n1569_o;
  wire n1571_o;
  wire [1:0] n1573_o;
  wire n1575_o;
  wire n1576_o;
  wire [1:0] n1578_o;
  wire [31:0] n1579_o;
  wire [31:0] n1581_o;
  wire [4:0] n1582_o;
  wire n1584_o;
  wire n1585_o;
  wire [1:0] n1586_o;
  wire [4:0] n1587_o;
  wire n1589_o;
  wire [31:0] n1590_o;
  wire [31:0] n1592_o;
  wire [31:0] n1593_o;
  wire n1594_o;
  wire n1600_o;
  wire n1602_o;
  wire [1:0] n1604_o;
  wire [31:0] n1605_o;
  wire [31:0] n1607_o;
  wire [8:0] n1608_o;
  wire [31:0] n1609_o;
  wire n1611_o;
  wire [31:0] n1612_o;
  wire [31:0] n1614_o;
  wire [3:0] n1615_o;
  wire [31:0] n1616_o;
  wire [31:0] n1618_o;
  wire [3:0] n1619_o;
  wire [3:0] n1620_o;
  wire [3:0] n1622_o;
  wire n1624_o;
  wire n1625_o;
  wire n1626_o;
  wire [8:0] n1627_o;
  wire [3:0] n1628_o;
  wire [3:0] n1629_o;
  wire n1631_o;
  wire [31:0] n1632_o;
  wire n1634_o;
  wire [31:0] n1638_o;
  wire [31:0] n1640_o;
  wire [3:0] n1641_o;
  wire n1644_o;
  wire n1646_o;
  wire [3:0] n1647_o;
  wire n1649_o;
  wire [2:0] n1650_o;
  reg n1652_o;
  reg n1654_o;
  reg [1:0] n1656_o;
  reg [4:0] n1658_o;
  reg [8:0] n1660_o;
  reg [3:0] n1662_o;
  reg [3:0] n1664_o;
  reg [3:0] n1666_o;
  wire n1668_o;
  wire n1669_o;
  wire [1:0] n1670_o;
  wire [4:0] n1671_o;
  wire [8:0] n1672_o;
  wire [3:0] n1673_o;
  wire [3:0] n1674_o;
  wire [3:0] n1675_o;
  wire n1677_o;
  wire [1:0] n1678_o;
  reg n1681_o;
  reg n1683_o;
  reg [1:0] n1685_o;
  reg [7:0] n1687_o;
  reg [7:0] n1689_o;
  reg [15:0] n1691_o;
  reg [95:0] n1693_o;
  reg [8:0] n1695_o;
  reg [127:0] n1697_o;
  reg n1699_o;
  reg n1701_o;
  reg [4:0] n1703_o;
  reg [8:0] n1705_o;
  reg [3:0] n1707_o;
  reg [3:0] n1709_o;
  reg [3:0] n1711_o;
  wire n1713_o;
  wire n1716_o;
  wire [1:0] n1718_o;
  wire [7:0] n1719_o;
  wire [7:0] n1720_o;
  wire [15:0] n1721_o;
  wire [95:0] n1722_o;
  wire [8:0] n1723_o;
  wire [127:0] n1724_o;
  wire n1725_o;
  wire n1726_o;
  wire [4:0] n1728_o;
  wire [8:0] n1729_o;
  wire [3:0] n1730_o;
  wire [3:0] n1731_o;
  wire [3:0] n1732_o;
  reg n1750_q;
  reg [1:0] n1751_q;
  reg [7:0] n1752_q;
  reg [7:0] n1753_q;
  reg [15:0] n1754_q;
  reg [95:0] n1755_q;
  reg [8:0] n1756_q;
  reg [127:0] n1757_q;
  reg n1758_q;
  reg n1759_q;
  reg [4:0] n1760_q;
  reg [8:0] n1761_q;
  reg [3:0] n1762_q;
  reg [3:0] n1763_q;
  reg [3:0] n1764_q;
  reg n1765_q;
  wire [7:0] n1766_o;
  wire [7:0] n1767_o;
  wire [7:0] n1768_o;
  wire [7:0] n1769_o;
  wire [7:0] n1770_o;
  wire [7:0] n1771_o;
  wire [7:0] n1772_o;
  wire [7:0] n1773_o;
  wire [7:0] n1774_o;
  wire [7:0] n1775_o;
  wire [7:0] n1776_o;
  wire [7:0] n1777_o;
  wire [3:0] n1778_o;
  wire [1:0] n1779_o;
  reg [7:0] n1780_o;
  wire [1:0] n1781_o;
  reg [7:0] n1782_o;
  wire [1:0] n1783_o;
  reg [7:0] n1784_o;
  wire n1785_o;
  wire [7:0] n1786_o;
  wire n1787_o;
  wire [7:0] n1788_o;
  wire [7:0] n1789_o;
  wire [7:0] n1790_o;
  wire [7:0] n1791_o;
  wire [7:0] n1792_o;
  wire [7:0] n1793_o;
  wire [7:0] n1794_o;
  wire [7:0] n1795_o;
  wire [7:0] n1796_o;
  wire [7:0] n1797_o;
  wire [7:0] n1798_o;
  wire [7:0] n1799_o;
  wire [7:0] n1800_o;
  wire [7:0] n1801_o;
  wire [7:0] n1802_o;
  wire [7:0] n1803_o;
  wire [7:0] n1804_o;
  wire [3:0] n1805_o;
  wire [1:0] n1806_o;
  reg [7:0] n1807_o;
  wire [1:0] n1808_o;
  reg [7:0] n1809_o;
  wire [1:0] n1810_o;
  reg [7:0] n1811_o;
  wire [1:0] n1812_o;
  reg [7:0] n1813_o;
  wire [1:0] n1814_o;
  reg [7:0] n1815_o;
  assign busy = n1445_o;
  assign done = n1765_q;
  assign pay_blk = p_blk;
  assign pay_byte = p_byte;
  assign wr_en = n1452_o;
  assign wr_data = n1527_o;
  /* rtl/packet_builder.vhd:49:12  */
  always @*
    state = n1750_q; // (isignal)
  initial
    state = 1'b0;
  /* rtl/packet_builder.vhd:50:12  */
  always @*
    phase = n1751_q; // (isignal)
  initial
    phase = 2'b00;
  /* rtl/packet_builder.vhd:52:12  */
  always @*
    l_type = n1752_q; // (isignal)
  initial
    l_type = 8'b00000000;
  /* rtl/packet_builder.vhd:52:20  */
  always @*
    l_code = n1753_q; // (isignal)
  initial
    l_code = 8'b00000000;
  /* rtl/packet_builder.vhd:53:12  */
  always @*
    l_seq = n1754_q; // (isignal)
  initial
    l_seq = 16'b0000000000000000;
  /* rtl/packet_builder.vhd:54:12  */
  always @*
    l_nonce = n1755_q; // (isignal)
  initial
    l_nonce = 96'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
  /* rtl/packet_builder.vhd:55:12  */
  always @*
    l_len = n1756_q; // (isignal)
  initial
    l_len = 9'b000000000;
  /* rtl/packet_builder.vhd:56:12  */
  always @*
    l_tag = n1757_q; // (isignal)
  initial
    l_tag = 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
  /* rtl/packet_builder.vhd:57:12  */
  always @*
    l_has_tag = n1758_q; // (isignal)
  initial
    l_has_tag = 1'b0;
  /* rtl/packet_builder.vhd:57:23  */
  always @*
    l_is_err = n1759_q; // (isignal)
  initial
    l_is_err = 1'b0;
  /* rtl/packet_builder.vhd:59:12  */
  always @*
    ri = n1760_q; // (isignal)
  initial
    ri = 5'b00000;
  /* rtl/packet_builder.vhd:60:12  */
  always @*
    pay_idx = n1761_q; // (isignal)
  initial
    pay_idx = 9'b000000000;
  /* rtl/packet_builder.vhd:61:12  */
  always @*
    p_blk = n1762_q; // (isignal)
  initial
    p_blk = 4'b0000;
  /* rtl/packet_builder.vhd:62:12  */
  always @*
    p_byte = n1763_q; // (isignal)
  initial
    p_byte = 4'b0000;
  /* rtl/packet_builder.vhd:62:20  */
  always @*
    tag_j = n1764_q; // (isignal)
  initial
    tag_j = 4'b0000;
  /* rtl/packet_builder.vhd:64:32  */
  assign n1444_o = state == 1'b0;
  /* rtl/packet_builder.vhd:64:21  */
  assign n1445_o = n1444_o ? 1'b0 : 1'b1;
  /* rtl/packet_builder.vhd:65:32  */
  assign n1449_o = state == 1'b1;
  /* rtl/packet_builder.vhd:65:48  */
  assign n1450_o = ~full;
  /* rtl/packet_builder.vhd:65:39  */
  assign n1451_o = n1450_o & n1449_o;
  /* rtl/packet_builder.vhd:65:21  */
  assign n1452_o = n1451_o ? 1'b1 : 1'b0;
  /* rtl/packet_builder.vhd:74:31  */
  assign n1458_o = {7'b0, l_len};  //  uext
  /* rtl/packet_builder.vhd:78:21  */
  assign n1460_o = ri == 5'b00000;
  /* rtl/packet_builder.vhd:79:21  */
  assign n1462_o = ri == 5'b00001;
  /* rtl/packet_builder.vhd:80:21  */
  assign n1464_o = ri == 5'b00010;
  /* rtl/packet_builder.vhd:81:47  */
  assign n1465_o = l_seq[15:8];
  /* rtl/packet_builder.vhd:81:21  */
  assign n1467_o = ri == 5'b00011;
  /* rtl/packet_builder.vhd:82:47  */
  assign n1468_o = l_seq[7:0];
  /* rtl/packet_builder.vhd:82:21  */
  assign n1470_o = ri == 5'b00100;
  /* rtl/packet_builder.vhd:83:49  */
  assign n1485_o = {2'b0, ri};  //  uext
  /* rtl/packet_builder.vhd:83:49  */
  assign n1487_o = 7'b0010000 - n1485_o;
  /* rtl/packet_builder.vhd:83:21  */
  assign n1492_o = $unsigned(ri) >= $unsigned(5'b00101);
  /* rtl/packet_builder.vhd:83:21  */
  assign n1493_o = $unsigned(ri) <= $unsigned(5'b10000);
  /* rtl/packet_builder.vhd:83:21  */
  assign n1494_o = n1492_o & n1493_o;
  /* rtl/packet_builder.vhd:84:43  */
  assign n1495_o = n1458_o[15:8];
  /* rtl/packet_builder.vhd:84:21  */
  assign n1497_o = ri == 5'b10001;
  /* rtl/packet_builder.vhd:85:43  */
  assign n1498_o = n1458_o[7:0];
  assign n1499_o = {n1497_o, n1494_o, n1470_o, n1467_o, n1464_o, n1462_o, n1460_o};
  /* rtl/packet_builder.vhd:77:17  */
  always @*
    case (n1499_o)
      7'b1000000: n1502_o = n1495_o;
      7'b0100000: n1502_o = n1788_o;
      7'b0010000: n1502_o = n1468_o;
      7'b0001000: n1502_o = n1465_o;
      7'b0000100: n1502_o = l_type;
      7'b0000010: n1502_o = 8'b00000001;
      7'b0000001: n1502_o = 8'b10100101;
      default: n1502_o = n1498_o;
    endcase
  /* rtl/packet_builder.vhd:76:13  */
  assign n1504_o = phase == 2'b00;
  /* rtl/packet_builder.vhd:88:17  */
  assign n1505_o = l_is_err ? l_code : pay_data;
  /* rtl/packet_builder.vhd:87:13  */
  assign n1507_o = phase == 2'b01;
  /* rtl/packet_builder.vhd:90:27  */
  assign n1518_o = {3'b0, tag_j};  //  uext
  /* rtl/packet_builder.vhd:90:27  */
  assign n1520_o = 7'b0001111 - n1518_o;
  /* rtl/packet_builder.vhd:89:13  */
  assign n1524_o = phase == 2'b10;
  assign n1525_o = {n1524_o, n1507_o, n1504_o};
  /* rtl/packet_builder.vhd:75:9  */
  always @*
    case (n1525_o)
      3'b100: n1527_o = n1815_o;
      3'b010: n1527_o = n1505_o;
      3'b001: n1527_o = n1502_o;
      default: n1527_o = 8'bX;
    endcase
  /* rtl/packet_builder.vhd:111:25  */
  assign n1534_o = start ? 1'b1 : state;
  /* rtl/packet_builder.vhd:111:25  */
  assign n1536_o = start ? 2'b00 : phase;
  /* rtl/packet_builder.vhd:111:25  */
  assign n1537_o = start ? resp_type : l_type;
  /* rtl/packet_builder.vhd:111:25  */
  assign n1538_o = start ? resp_code : l_code;
  /* rtl/packet_builder.vhd:111:25  */
  assign n1539_o = start ? resp_seq : l_seq;
  /* rtl/packet_builder.vhd:111:25  */
  assign n1540_o = start ? resp_nonce : l_nonce;
  /* rtl/packet_builder.vhd:111:25  */
  assign n1541_o = start ? resp_len : l_len;
  /* rtl/packet_builder.vhd:111:25  */
  assign n1542_o = start ? resp_tag : l_tag;
  /* rtl/packet_builder.vhd:111:25  */
  assign n1543_o = start ? resp_has_tag : l_has_tag;
  /* rtl/packet_builder.vhd:111:25  */
  assign n1544_o = start ? resp_is_err : l_is_err;
  /* rtl/packet_builder.vhd:111:25  */
  assign n1546_o = start ? 5'b00000 : ri;
  /* rtl/packet_builder.vhd:111:25  */
  assign n1548_o = start ? 9'b000000000 : pay_idx;
  /* rtl/packet_builder.vhd:111:25  */
  assign n1550_o = start ? 4'b0000 : p_blk;
  /* rtl/packet_builder.vhd:111:25  */
  assign n1552_o = start ? 4'b0000 : p_byte;
  /* rtl/packet_builder.vhd:111:25  */
  assign n1554_o = start ? 4'b0000 : tag_j;
  /* rtl/packet_builder.vhd:110:21  */
  assign n1556_o = state == 1'b0;
  /* rtl/packet_builder.vhd:130:33  */
  assign n1557_o = ~full;
  /* rtl/packet_builder.vhd:133:43  */
  assign n1558_o = {27'b0, ri};  //  uext
  /* rtl/packet_builder.vhd:133:43  */
  assign n1560_o = n1558_o == 32'b00000000000000000000000000010010;
  /* rtl/packet_builder.vhd:134:50  */
  assign n1561_o = {23'b0, l_len};  //  uext
  /* rtl/packet_builder.vhd:134:50  */
  assign n1563_o = $signed(n1561_o) > $signed(32'b00000000000000000000000000000000);
  /* rtl/packet_builder.vhd:136:41  */
  assign n1569_o = l_has_tag ? 1'b0 : 1'b1;
  /* rtl/packet_builder.vhd:136:41  */
  assign n1571_o = l_has_tag ? state : 1'b0;
  /* rtl/packet_builder.vhd:136:41  */
  assign n1573_o = l_has_tag ? 2'b10 : phase;
  /* rtl/packet_builder.vhd:134:41  */
  assign n1575_o = n1563_o ? 1'b0 : n1569_o;
  /* rtl/packet_builder.vhd:134:41  */
  assign n1576_o = n1563_o ? state : n1571_o;
  /* rtl/packet_builder.vhd:134:41  */
  assign n1578_o = n1563_o ? 2'b01 : n1573_o;
  /* rtl/packet_builder.vhd:142:50  */
  assign n1579_o = {27'b0, ri};  //  uext
  /* rtl/packet_builder.vhd:142:50  */
  assign n1581_o = n1579_o + 32'b00000000000000000000000000000001;
  /* rtl/packet_builder.vhd:142:47  */
  assign n1582_o = n1581_o[4:0];  // trunc
  /* rtl/packet_builder.vhd:133:37  */
  assign n1584_o = n1560_o ? n1575_o : 1'b0;
  /* rtl/packet_builder.vhd:133:37  */
  assign n1585_o = n1560_o ? n1576_o : state;
  /* rtl/packet_builder.vhd:133:37  */
  assign n1586_o = n1560_o ? n1578_o : phase;
  /* rtl/packet_builder.vhd:133:37  */
  assign n1587_o = n1560_o ? ri : n1582_o;
  /* rtl/packet_builder.vhd:132:33  */
  assign n1589_o = phase == 2'b00;
  /* rtl/packet_builder.vhd:145:48  */
  assign n1590_o = {23'b0, pay_idx};  //  uext
  /* rtl/packet_builder.vhd:145:48  */
  assign n1592_o = n1590_o + 32'b00000000000000000000000000000001;
  /* rtl/packet_builder.vhd:145:52  */
  assign n1593_o = {23'b0, l_len};  //  uext
  /* rtl/packet_builder.vhd:145:52  */
  assign n1594_o = n1592_o == n1593_o;
  /* rtl/packet_builder.vhd:146:41  */
  assign n1600_o = l_has_tag ? 1'b0 : 1'b1;
  /* rtl/packet_builder.vhd:146:41  */
  assign n1602_o = l_has_tag ? state : 1'b0;
  /* rtl/packet_builder.vhd:145:37  */
  assign n1604_o = n1626_o ? 2'b10 : phase;
  /* rtl/packet_builder.vhd:148:60  */
  assign n1605_o = {23'b0, pay_idx};  //  uext
  /* rtl/packet_builder.vhd:148:60  */
  assign n1607_o = n1605_o + 32'b00000000000000000000000000000001;
  /* rtl/packet_builder.vhd:148:52  */
  assign n1608_o = n1607_o[8:0];  // trunc
  /* rtl/packet_builder.vhd:149:51  */
  assign n1609_o = {28'b0, p_byte};  //  uext
  /* rtl/packet_builder.vhd:149:51  */
  assign n1611_o = n1609_o == 32'b00000000000000000000000000001111;
  /* rtl/packet_builder.vhd:150:73  */
  assign n1612_o = {28'b0, p_blk};  //  uext
  /* rtl/packet_builder.vhd:150:73  */
  assign n1614_o = n1612_o + 32'b00000000000000000000000000000001;
  /* rtl/packet_builder.vhd:150:67  */
  assign n1615_o = n1614_o[3:0];  // trunc
  /* rtl/packet_builder.vhd:152:62  */
  assign n1616_o = {28'b0, p_byte};  //  uext
  /* rtl/packet_builder.vhd:152:62  */
  assign n1618_o = n1616_o + 32'b00000000000000000000000000000001;
  /* rtl/packet_builder.vhd:152:55  */
  assign n1619_o = n1618_o[3:0];  // trunc
  /* rtl/packet_builder.vhd:149:41  */
  assign n1620_o = n1611_o ? n1615_o : p_blk;
  /* rtl/packet_builder.vhd:149:41  */
  assign n1622_o = n1611_o ? 4'b0000 : n1619_o;
  /* rtl/packet_builder.vhd:145:37  */
  assign n1624_o = n1594_o ? n1600_o : 1'b0;
  /* rtl/packet_builder.vhd:145:37  */
  assign n1625_o = n1594_o ? n1602_o : state;
  /* rtl/packet_builder.vhd:145:37  */
  assign n1626_o = l_has_tag & n1594_o;
  /* rtl/packet_builder.vhd:145:37  */
  assign n1627_o = n1594_o ? pay_idx : n1608_o;
  /* rtl/packet_builder.vhd:145:37  */
  assign n1628_o = n1594_o ? p_blk : n1620_o;
  /* rtl/packet_builder.vhd:145:37  */
  assign n1629_o = n1594_o ? p_byte : n1622_o;
  /* rtl/packet_builder.vhd:144:33  */
  assign n1631_o = phase == 2'b01;
  /* rtl/packet_builder.vhd:156:46  */
  assign n1632_o = {28'b0, tag_j};  //  uext
  /* rtl/packet_builder.vhd:156:46  */
  assign n1634_o = n1632_o == 32'b00000000000000000000000000001111;
  /* rtl/packet_builder.vhd:156:84  */
  assign n1638_o = {28'b0, tag_j};  //  uext
  /* rtl/packet_builder.vhd:156:84  */
  assign n1640_o = n1638_o + 32'b00000000000000000000000000000001;
  /* rtl/packet_builder.vhd:156:78  */
  assign n1641_o = n1640_o[3:0];  // trunc
  /* rtl/packet_builder.vhd:156:37  */
  assign n1644_o = n1634_o ? 1'b1 : 1'b0;
  /* rtl/packet_builder.vhd:156:37  */
  assign n1646_o = n1634_o ? 1'b0 : state;
  /* rtl/packet_builder.vhd:156:37  */
  assign n1647_o = n1634_o ? tag_j : n1641_o;
  /* rtl/packet_builder.vhd:155:33  */
  assign n1649_o = phase == 2'b10;
  assign n1650_o = {n1649_o, n1631_o, n1589_o};
  /* rtl/packet_builder.vhd:131:29  */
  always @*
    case (n1650_o)
      3'b100: n1652_o = n1644_o;
      3'b010: n1652_o = n1624_o;
      3'b001: n1652_o = n1584_o;
      default: n1652_o = 1'bX;
    endcase
  /* rtl/packet_builder.vhd:131:29  */
  always @*
    case (n1650_o)
      3'b100: n1654_o = n1646_o;
      3'b010: n1654_o = n1625_o;
      3'b001: n1654_o = n1585_o;
      default: n1654_o = 1'bX;
    endcase
  /* rtl/packet_builder.vhd:131:29  */
  always @*
    case (n1650_o)
      3'b100: n1656_o = phase;
      3'b010: n1656_o = n1604_o;
      3'b001: n1656_o = n1586_o;
      default: n1656_o = 2'bX;
    endcase
  /* rtl/packet_builder.vhd:131:29  */
  always @*
    case (n1650_o)
      3'b100: n1658_o = ri;
      3'b010: n1658_o = ri;
      3'b001: n1658_o = n1587_o;
      default: n1658_o = 5'bX;
    endcase
  /* rtl/packet_builder.vhd:131:29  */
  always @*
    case (n1650_o)
      3'b100: n1660_o = pay_idx;
      3'b010: n1660_o = n1627_o;
      3'b001: n1660_o = pay_idx;
      default: n1660_o = 9'bX;
    endcase
  /* rtl/packet_builder.vhd:131:29  */
  always @*
    case (n1650_o)
      3'b100: n1662_o = p_blk;
      3'b010: n1662_o = n1628_o;
      3'b001: n1662_o = p_blk;
      default: n1662_o = 4'bX;
    endcase
  /* rtl/packet_builder.vhd:131:29  */
  always @*
    case (n1650_o)
      3'b100: n1664_o = p_byte;
      3'b010: n1664_o = n1629_o;
      3'b001: n1664_o = p_byte;
      default: n1664_o = 4'bX;
    endcase
  /* rtl/packet_builder.vhd:131:29  */
  always @*
    case (n1650_o)
      3'b100: n1666_o = n1647_o;
      3'b010: n1666_o = tag_j;
      3'b001: n1666_o = tag_j;
      default: n1666_o = 4'bX;
    endcase
  /* rtl/packet_builder.vhd:130:25  */
  assign n1668_o = n1557_o ? n1652_o : 1'b0;
  /* rtl/packet_builder.vhd:130:25  */
  assign n1669_o = n1557_o ? n1654_o : state;
  /* rtl/packet_builder.vhd:130:25  */
  assign n1670_o = n1557_o ? n1656_o : phase;
  /* rtl/packet_builder.vhd:130:25  */
  assign n1671_o = n1557_o ? n1658_o : ri;
  /* rtl/packet_builder.vhd:130:25  */
  assign n1672_o = n1557_o ? n1660_o : pay_idx;
  /* rtl/packet_builder.vhd:130:25  */
  assign n1673_o = n1557_o ? n1662_o : p_blk;
  /* rtl/packet_builder.vhd:130:25  */
  assign n1674_o = n1557_o ? n1664_o : p_byte;
  /* rtl/packet_builder.vhd:130:25  */
  assign n1675_o = n1557_o ? n1666_o : tag_j;
  /* rtl/packet_builder.vhd:129:21  */
  assign n1677_o = state == 1'b1;
  assign n1678_o = {n1677_o, n1556_o};
  /* rtl/packet_builder.vhd:109:17  */
  always @*
    case (n1678_o)
      2'b10: n1681_o = n1668_o;
      2'b01: n1681_o = 1'b0;
      default: n1681_o = 1'bX;
    endcase
  /* rtl/packet_builder.vhd:109:17  */
  always @*
    case (n1678_o)
      2'b10: n1683_o = n1669_o;
      2'b01: n1683_o = n1534_o;
      default: n1683_o = 1'bX;
    endcase
  /* rtl/packet_builder.vhd:109:17  */
  always @*
    case (n1678_o)
      2'b10: n1685_o = n1670_o;
      2'b01: n1685_o = n1536_o;
      default: n1685_o = 2'bX;
    endcase
  /* rtl/packet_builder.vhd:109:17  */
  always @*
    case (n1678_o)
      2'b10: n1687_o = l_type;
      2'b01: n1687_o = n1537_o;
      default: n1687_o = 8'bX;
    endcase
  /* rtl/packet_builder.vhd:109:17  */
  always @*
    case (n1678_o)
      2'b10: n1689_o = l_code;
      2'b01: n1689_o = n1538_o;
      default: n1689_o = 8'bX;
    endcase
  /* rtl/packet_builder.vhd:109:17  */
  always @*
    case (n1678_o)
      2'b10: n1691_o = l_seq;
      2'b01: n1691_o = n1539_o;
      default: n1691_o = 16'bX;
    endcase
  /* rtl/packet_builder.vhd:109:17  */
  always @*
    case (n1678_o)
      2'b10: n1693_o = l_nonce;
      2'b01: n1693_o = n1540_o;
      default: n1693_o = 96'bX;
    endcase
  /* rtl/packet_builder.vhd:109:17  */
  always @*
    case (n1678_o)
      2'b10: n1695_o = l_len;
      2'b01: n1695_o = n1541_o;
      default: n1695_o = 9'bX;
    endcase
  /* rtl/packet_builder.vhd:109:17  */
  always @*
    case (n1678_o)
      2'b10: n1697_o = l_tag;
      2'b01: n1697_o = n1542_o;
      default: n1697_o = 128'bX;
    endcase
  /* rtl/packet_builder.vhd:109:17  */
  always @*
    case (n1678_o)
      2'b10: n1699_o = l_has_tag;
      2'b01: n1699_o = n1543_o;
      default: n1699_o = 1'bX;
    endcase
  /* rtl/packet_builder.vhd:109:17  */
  always @*
    case (n1678_o)
      2'b10: n1701_o = l_is_err;
      2'b01: n1701_o = n1544_o;
      default: n1701_o = 1'bX;
    endcase
  /* rtl/packet_builder.vhd:109:17  */
  always @*
    case (n1678_o)
      2'b10: n1703_o = n1671_o;
      2'b01: n1703_o = n1546_o;
      default: n1703_o = 5'bX;
    endcase
  /* rtl/packet_builder.vhd:109:17  */
  always @*
    case (n1678_o)
      2'b10: n1705_o = n1672_o;
      2'b01: n1705_o = n1548_o;
      default: n1705_o = 9'bX;
    endcase
  /* rtl/packet_builder.vhd:109:17  */
  always @*
    case (n1678_o)
      2'b10: n1707_o = n1673_o;
      2'b01: n1707_o = n1550_o;
      default: n1707_o = 4'bX;
    endcase
  /* rtl/packet_builder.vhd:109:17  */
  always @*
    case (n1678_o)
      2'b10: n1709_o = n1674_o;
      2'b01: n1709_o = n1552_o;
      default: n1709_o = 4'bX;
    endcase
  /* rtl/packet_builder.vhd:109:17  */
  always @*
    case (n1678_o)
      2'b10: n1711_o = n1675_o;
      2'b01: n1711_o = n1554_o;
      default: n1711_o = 4'bX;
    endcase
  /* rtl/packet_builder.vhd:104:13  */
  assign n1713_o = rst ? 1'b0 : n1681_o;
  /* rtl/packet_builder.vhd:104:13  */
  assign n1716_o = rst ? 1'b0 : n1683_o;
  /* rtl/packet_builder.vhd:104:13  */
  assign n1718_o = rst ? 2'b00 : n1685_o;
  /* rtl/packet_builder.vhd:104:13  */
  assign n1719_o = rst ? l_type : n1687_o;
  /* rtl/packet_builder.vhd:104:13  */
  assign n1720_o = rst ? l_code : n1689_o;
  /* rtl/packet_builder.vhd:104:13  */
  assign n1721_o = rst ? l_seq : n1691_o;
  /* rtl/packet_builder.vhd:104:13  */
  assign n1722_o = rst ? l_nonce : n1693_o;
  /* rtl/packet_builder.vhd:104:13  */
  assign n1723_o = rst ? l_len : n1695_o;
  /* rtl/packet_builder.vhd:104:13  */
  assign n1724_o = rst ? l_tag : n1697_o;
  /* rtl/packet_builder.vhd:104:13  */
  assign n1725_o = rst ? l_has_tag : n1699_o;
  /* rtl/packet_builder.vhd:104:13  */
  assign n1726_o = rst ? l_is_err : n1701_o;
  /* rtl/packet_builder.vhd:104:13  */
  assign n1728_o = rst ? 5'b00000 : n1703_o;
  /* rtl/packet_builder.vhd:104:13  */
  assign n1729_o = rst ? pay_idx : n1705_o;
  /* rtl/packet_builder.vhd:104:13  */
  assign n1730_o = rst ? p_blk : n1707_o;
  /* rtl/packet_builder.vhd:104:13  */
  assign n1731_o = rst ? p_byte : n1709_o;
  /* rtl/packet_builder.vhd:104:13  */
  assign n1732_o = rst ? tag_j : n1711_o;
  /* rtl/packet_builder.vhd:102:9  */
  always @(posedge clk)
    n1750_q <= n1716_o;
  initial
    n1750_q = 1'b0;
  /* rtl/packet_builder.vhd:102:9  */
  always @(posedge clk)
    n1751_q <= n1718_o;
  initial
    n1751_q = 2'b00;
  /* rtl/packet_builder.vhd:102:9  */
  always @(posedge clk)
    n1752_q <= n1719_o;
  initial
    n1752_q = 8'b00000000;
  /* rtl/packet_builder.vhd:102:9  */
  always @(posedge clk)
    n1753_q <= n1720_o;
  initial
    n1753_q = 8'b00000000;
  /* rtl/packet_builder.vhd:102:9  */
  always @(posedge clk)
    n1754_q <= n1721_o;
  initial
    n1754_q = 16'b0000000000000000;
  /* rtl/packet_builder.vhd:102:9  */
  always @(posedge clk)
    n1755_q <= n1722_o;
  initial
    n1755_q = 96'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
  /* rtl/packet_builder.vhd:102:9  */
  always @(posedge clk)
    n1756_q <= n1723_o;
  initial
    n1756_q = 9'b000000000;
  /* rtl/packet_builder.vhd:102:9  */
  always @(posedge clk)
    n1757_q <= n1724_o;
  initial
    n1757_q = 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
  /* rtl/packet_builder.vhd:102:9  */
  always @(posedge clk)
    n1758_q <= n1725_o;
  initial
    n1758_q = 1'b0;
  /* rtl/packet_builder.vhd:102:9  */
  always @(posedge clk)
    n1759_q <= n1726_o;
  initial
    n1759_q = 1'b0;
  /* rtl/packet_builder.vhd:102:9  */
  always @(posedge clk)
    n1760_q <= n1728_o;
  initial
    n1760_q = 5'b00000;
  /* rtl/packet_builder.vhd:102:9  */
  always @(posedge clk)
    n1761_q <= n1729_o;
  initial
    n1761_q = 9'b000000000;
  /* rtl/packet_builder.vhd:102:9  */
  always @(posedge clk)
    n1762_q <= n1730_o;
  initial
    n1762_q = 4'b0000;
  /* rtl/packet_builder.vhd:102:9  */
  always @(posedge clk)
    n1763_q <= n1731_o;
  initial
    n1763_q = 4'b0000;
  /* rtl/packet_builder.vhd:102:9  */
  always @(posedge clk)
    n1764_q <= n1732_o;
  initial
    n1764_q = 4'b0000;
  /* rtl/packet_builder.vhd:102:9  */
  always @(posedge clk)
    n1765_q <= n1713_o;
  /* rtl/packet_builder.vhd:40:9  */
  assign n1766_o = l_nonce[7:0];
  /* rtl/packet_builder.vhd:39:9  */
  assign n1767_o = l_nonce[15:8];
  /* rtl/packet_builder.vhd:36:9  */
  assign n1768_o = l_nonce[23:16];
  /* rtl/packet_builder.vhd:35:9  */
  assign n1769_o = l_nonce[31:24];
  /* rtl/packet_builder.vhd:24:9  */
  assign n1770_o = l_nonce[39:32];
  /* rtl/packet_builder.vhd:23:9  */
  assign n1771_o = l_nonce[47:40];
  assign n1772_o = l_nonce[55:48];
  assign n1773_o = l_nonce[63:56];
  /* rtl/packet_builder.vhd:96:19  */
  assign n1774_o = l_nonce[71:64];
  /* rtl/packet_builder.vhd:96:19  */
  assign n1775_o = l_nonce[79:72];
  /* rtl/packet_builder.vhd:96:19  */
  assign n1776_o = l_nonce[87:80];
  /* rtl/packet_builder.vhd:96:19  */
  assign n1777_o = l_nonce[95:88];
  /* rtl/packet_builder.vhd:83:49  */
  assign n1778_o = n1487_o[3:0];  // trunc
  /* rtl/packet_builder.vhd:83:49  */
  assign n1779_o = n1778_o[1:0];
  /* rtl/packet_builder.vhd:83:49  */
  always @*
    case (n1779_o)
      2'b00: n1780_o = n1766_o;
      2'b01: n1780_o = n1767_o;
      2'b10: n1780_o = n1768_o;
      2'b11: n1780_o = n1769_o;
    endcase
  /* rtl/packet_builder.vhd:83:49  */
  assign n1781_o = n1778_o[1:0];
  /* rtl/packet_builder.vhd:83:49  */
  always @*
    case (n1781_o)
      2'b00: n1782_o = n1770_o;
      2'b01: n1782_o = n1771_o;
      2'b10: n1782_o = n1772_o;
      2'b11: n1782_o = n1773_o;
    endcase
  /* rtl/packet_builder.vhd:83:49  */
  assign n1783_o = n1778_o[1:0];
  /* rtl/packet_builder.vhd:83:49  */
  always @*
    case (n1783_o)
      2'b00: n1784_o = n1774_o;
      2'b01: n1784_o = n1775_o;
      2'b10: n1784_o = n1776_o;
      2'b11: n1784_o = n1777_o;
    endcase
  /* rtl/packet_builder.vhd:90:59  */
  assign n1785_o = n1778_o[2];
  /* rtl/packet_builder.vhd:83:49  */
  assign n1786_o = n1785_o ? n1782_o : n1780_o;
  /* rtl/packet_builder.vhd:90:59  */
  assign n1787_o = n1778_o[3];
  /* rtl/packet_builder.vhd:83:49  */
  assign n1788_o = n1787_o ? n1784_o : n1786_o;
  /* rtl/packet_builder.vhd:83:49  */
  assign n1789_o = l_tag[7:0];
  /* rtl/packet_builder.vhd:83:49  */
  assign n1790_o = l_tag[15:8];
  assign n1791_o = l_tag[23:16];
  /* rtl/packet_builder.vhd:90:36  */
  assign n1792_o = l_tag[31:24];
  assign n1793_o = l_tag[39:32];
  /* rtl/packet_builder.vhd:90:36  */
  assign n1794_o = l_tag[47:40];
  /* rtl/packet_builder.vhd:83:78  */
  assign n1795_o = l_tag[55:48];
  assign n1796_o = l_tag[63:56];
  /* rtl/packet_builder.vhd:83:82  */
  assign n1797_o = l_tag[71:64];
  assign n1798_o = l_tag[79:72];
  /* rtl/packet_builder.vhd:83:88  */
  assign n1799_o = l_tag[87:80];
  assign n1800_o = l_tag[95:88];
  /* rtl/packet_builder.vhd:83:88  */
  assign n1801_o = l_tag[103:96];
  /* rtl/packet_builder.vhd:83:53  */
  assign n1802_o = l_tag[111:104];
  assign n1803_o = l_tag[119:112];
  /* rtl/packet_builder.vhd:83:57  */
  assign n1804_o = l_tag[127:120];
  /* rtl/packet_builder.vhd:90:27  */
  assign n1805_o = n1520_o[3:0];  // trunc
  /* rtl/packet_builder.vhd:90:27  */
  assign n1806_o = n1805_o[1:0];
  /* rtl/packet_builder.vhd:90:27  */
  always @*
    case (n1806_o)
      2'b00: n1807_o = n1789_o;
      2'b01: n1807_o = n1790_o;
      2'b10: n1807_o = n1791_o;
      2'b11: n1807_o = n1792_o;
    endcase
  /* rtl/packet_builder.vhd:90:27  */
  assign n1808_o = n1805_o[1:0];
  /* rtl/packet_builder.vhd:90:27  */
  always @*
    case (n1808_o)
      2'b00: n1809_o = n1793_o;
      2'b01: n1809_o = n1794_o;
      2'b10: n1809_o = n1795_o;
      2'b11: n1809_o = n1796_o;
    endcase
  /* rtl/packet_builder.vhd:90:27  */
  assign n1810_o = n1805_o[1:0];
  /* rtl/packet_builder.vhd:90:27  */
  always @*
    case (n1810_o)
      2'b00: n1811_o = n1797_o;
      2'b01: n1811_o = n1798_o;
      2'b10: n1811_o = n1799_o;
      2'b11: n1811_o = n1800_o;
    endcase
  /* rtl/packet_builder.vhd:90:27  */
  assign n1812_o = n1805_o[1:0];
  /* rtl/packet_builder.vhd:90:27  */
  always @*
    case (n1812_o)
      2'b00: n1813_o = n1801_o;
      2'b01: n1813_o = n1802_o;
      2'b10: n1813_o = n1803_o;
      2'b11: n1813_o = n1804_o;
    endcase
  /* rtl/packet_builder.vhd:90:27  */
  assign n1814_o = n1805_o[3:2];
  /* rtl/packet_builder.vhd:90:27  */
  always @*
    case (n1814_o)
      2'b00: n1815_o = n1807_o;
      2'b01: n1815_o = n1809_o;
      2'b10: n1815_o = n1811_o;
      2'b11: n1815_o = n1813_o;
    endcase
endmodule

module crypto_controller
  (input  clk,
   input  rst,
   input  pkt_valid,
   input  pkt_err,
   input  [2:0] err_code,
   input  [7:0] hdr_type,
   input  [15:0] hdr_seq,
   input  [95:0] hdr_nonce,
   input  [8:0] hdr_len,
   input  [127:0] tag_in,
   input  [7:0] buf_data,
   input  [127:0] key,
   input  key_valid,
   input  [63:0] ctr_init,
   input  ctr_valid,
   input  ctr_store_ack,
   input  [15:0] seq_init,
   input  seq_have_init,
   input  seq_valid,
   input  seq_store_ack,
   input  eng_in_ready,
   input  eng_in_is_aad,
   input  eng_out_valid,
   input  [127:0] eng_out_block,
   input  eng_done,
   input  [127:0] eng_tag_out,
   input  eng_auth_ok,
   input  tx_full,
   output pkt_ack,
   output [7:0] buf_addr,
   output ctr_store_req,
   output [63:0] ctr_store_val,
   output seq_store_req,
   output [15:0] seq_store_val,
   output eng_start,
   output eng_decrypt,
   output [127:0] eng_key,
   output [95:0] eng_iv,
   output [11:0] eng_aad_len,
   output [11:0] eng_data_len,
   output [127:0] eng_tag_in,
   output eng_in_valid,
   output [127:0] eng_in_block,
   output tx_wr_en,
   output [7:0] tx_wr_data,
   output busy,
   output evt_parse_err,
   output evt_auth_fail,
   output evt_replay);
  reg [3:0] state;
  reg [2047:0] obuf;
  reg is_dec;
  reg held;
  reg cur_aad;
  reg have_last;
  reg ctr_seen;
  reg seq_seen;
  reg [15:0] last_seq;
  reg [63:0] ctr;
  reg [95:0] iv_sel;
  reg [95:0] nonce_used;
  reg [4:0] di;
  reg [4:0] oi;
  reg [4:0] ci;
  reg [4:0] ld_i;
  reg [127:0] in_reg;
  reg [25:0] nv_cnt;
  reg [7:0] resp_type;
  reg [7:0] resp_code;
  reg [15:0] resp_seq;
  reg [95:0] resp_nonce;
  reg [8:0] resp_len;
  reg resp_has_tag;
  reg resp_is_err;
  reg [127:0] resp_tag;
  reg [3:0] pay_blk;
  reg [3:0] pay_byte;
  wire [7:0] pay_data;
  wire bld_start;
  wire bld_done;
  wire [7:0] aad_type;
  wire [127:0] aad_block;
  wire [15:0] len16;
  wire [15:0] n51_o;
  wire [7:0] n53_o;
  wire [15:0] n56_o;
  wire [31:0] n57_o;
  wire [47:0] n58_o;
  wire [127:0] n60_o;
  wire n63_o;
  wire n64_o;
  localparam [11:0] n66_o = 12'b000000000110;
  wire [11:0] n67_o;
  wire n70_o;
  wire n71_o;
  wire n75_o;
  wire n76_o;
  wire [63:0] n79_o;
  wire n82_o;
  wire n83_o;
  wire [31:0] n85_o;
  wire [31:0] n87_o;
  wire [31:0] n88_o;
  wire [31:0] n89_o;
  wire [7:0] n90_o;
  wire [31:0] n91_o;
  wire [31:0] n93_o;
  wire [31:0] n94_o;
  wire [31:0] n95_o;
  wire n97_o;
  wire [7:0] n98_o;
  wire n102_o;
  wire n103_o;
  wire n107_o;
  wire n108_o;
  wire n112_o;
  wire n113_o;
  wire [3:0] n116_o;
  wire [6:0] n128_o;
  wire [6:0] n130_o;
  wire u_bld_busy;
  wire u_bld_done;
  wire [3:0] u_bld_pay_blk;
  wire [3:0] u_bld_pay_byte;
  wire u_bld_wr_en;
  wire [7:0] u_bld_wr_data;
  wire n142_o;
  wire n143_o;
  wire n145_o;
  wire [63:0] n146_o;
  wire n147_o;
  wire n148_o;
  wire n149_o;
  wire n151_o;
  wire [15:0] n152_o;
  wire n153_o;
  wire n158_o;
  wire [31:0] n159_o;
  wire n161_o;
  wire n165_o;
  wire n166_o;
  wire n167_o;
  wire n171_o;
  wire n172_o;
  wire n178_o;
  wire [3:0] n181_o;
  wire n183_o;
  wire [95:0] n184_o;
  wire [7:0] n186_o;
  wire [7:0] n188_o;
  wire [15:0] n189_o;
  wire [95:0] n191_o;
  wire [8:0] n193_o;
  wire n195_o;
  wire n197_o;
  wire n199_o;
  wire [3:0] n201_o;
  wire n202_o;
  wire [95:0] n203_o;
  wire [7:0] n205_o;
  wire [7:0] n207_o;
  wire [15:0] n208_o;
  wire [95:0] n210_o;
  wire [8:0] n212_o;
  wire n214_o;
  wire n216_o;
  wire n218_o;
  wire [3:0] n220_o;
  wire n221_o;
  wire [95:0] n222_o;
  wire [7:0] n224_o;
  wire [7:0] n226_o;
  wire [15:0] n227_o;
  wire [95:0] n229_o;
  wire [8:0] n231_o;
  wire n233_o;
  wire n235_o;
  wire n236_o;
  wire n237_o;
  wire n238_o;
  wire n239_o;
  wire n240_o;
  wire [3:0] n246_o;
  wire n248_o;
  wire [25:0] n250_o;
  wire [7:0] n252_o;
  wire [7:0] n254_o;
  wire [15:0] n255_o;
  wire [95:0] n257_o;
  wire [8:0] n259_o;
  wire n261_o;
  wire n263_o;
  wire n265_o;
  wire [3:0] n266_o;
  wire n267_o;
  wire [95:0] n268_o;
  wire [25:0] n269_o;
  wire [7:0] n270_o;
  wire [7:0] n271_o;
  wire [15:0] n272_o;
  wire [95:0] n273_o;
  wire [8:0] n274_o;
  wire n275_o;
  wire n276_o;
  wire n278_o;
  wire [3:0] n280_o;
  wire n281_o;
  wire [95:0] n282_o;
  wire [25:0] n283_o;
  wire [7:0] n285_o;
  wire [7:0] n287_o;
  wire [15:0] n288_o;
  wire [95:0] n290_o;
  wire [8:0] n292_o;
  wire n294_o;
  wire n296_o;
  wire [7:0] n299_o;
  wire n304_o;
  wire [3:0] n306_o;
  wire n308_o;
  wire [7:0] n310_o;
  wire [7:0] n311_o;
  wire [15:0] n313_o;
  wire [95:0] n315_o;
  wire [8:0] n317_o;
  wire n319_o;
  wire n321_o;
  wire n323_o;
  wire n325_o;
  wire [3:0] n326_o;
  wire n327_o;
  wire n329_o;
  wire [95:0] n330_o;
  wire [4:0] n332_o;
  wire [4:0] n334_o;
  wire [25:0] n335_o;
  wire [7:0] n336_o;
  wire [7:0] n337_o;
  wire [15:0] n338_o;
  wire [95:0] n339_o;
  wire [8:0] n340_o;
  wire n341_o;
  wire n342_o;
  wire n344_o;
  wire [95:0] n346_o;
  wire [95:0] n348_o;
  wire [63:0] n350_o;
  wire [31:0] n351_o;
  wire n353_o;
  wire [31:0] n357_o;
  wire [31:0] n359_o;
  wire [25:0] n360_o;
  wire [3:0] n362_o;
  wire n364_o;
  wire [25:0] n365_o;
  wire [7:0] n367_o;
  wire [7:0] n369_o;
  wire [15:0] n370_o;
  wire [95:0] n372_o;
  wire [8:0] n374_o;
  wire n376_o;
  wire n378_o;
  wire [3:0] n380_o;
  wire n381_o;
  wire [63:0] n382_o;
  wire [95:0] n383_o;
  wire [95:0] n384_o;
  wire [25:0] n385_o;
  wire [7:0] n386_o;
  wire [7:0] n387_o;
  wire [15:0] n388_o;
  wire [95:0] n389_o;
  wire [8:0] n390_o;
  wire n391_o;
  wire n392_o;
  wire n394_o;
  wire [31:0] n395_o;
  wire n397_o;
  wire [31:0] n401_o;
  wire [31:0] n403_o;
  wire [25:0] n404_o;
  wire [3:0] n406_o;
  wire n408_o;
  wire [4:0] n410_o;
  wire [25:0] n411_o;
  wire [7:0] n413_o;
  wire [7:0] n415_o;
  wire [15:0] n416_o;
  wire [95:0] n418_o;
  wire [8:0] n420_o;
  wire n422_o;
  wire n424_o;
  wire [3:0] n426_o;
  wire n427_o;
  wire n429_o;
  wire [15:0] n430_o;
  wire [4:0] n431_o;
  wire [25:0] n432_o;
  wire [7:0] n434_o;
  wire [7:0] n435_o;
  wire [15:0] n436_o;
  wire [95:0] n437_o;
  wire [8:0] n438_o;
  wire n440_o;
  wire n442_o;
  wire n444_o;
  wire n446_o;
  wire [3:0] n447_o;
  wire [3:0] n449_o;
  wire [31:0] n452_o;
  wire [31:0] n454_o;
  wire [4:0] n455_o;
  wire [2047:0] n456_o;
  wire [4:0] n457_o;
  wire n458_o;
  wire n459_o;
  wire [3:0] n465_o;
  wire [25:0] n467_o;
  wire [7:0] n469_o;
  wire [15:0] n470_o;
  wire [95:0] n471_o;
  wire [8:0] n472_o;
  wire n474_o;
  wire n476_o;
  wire [127:0] n477_o;
  wire n480_o;
  wire [3:0] n482_o;
  wire n484_o;
  wire [4:0] n486_o;
  wire [25:0] n487_o;
  wire [7:0] n489_o;
  wire [7:0] n491_o;
  wire [15:0] n492_o;
  wire [95:0] n494_o;
  wire [8:0] n496_o;
  wire n498_o;
  wire n500_o;
  wire [127:0] n501_o;
  wire [3:0] n504_o;
  wire [4:0] n506_o;
  wire [127:0] n508_o;
  wire [3:0] n509_o;
  wire n510_o;
  wire [4:0] n511_o;
  wire [127:0] n512_o;
  wire n514_o;
  wire [3:0] n515_o;
  wire n516_o;
  wire n517_o;
  wire n518_o;
  wire [4:0] n519_o;
  wire [127:0] n520_o;
  wire [25:0] n522_o;
  wire [7:0] n523_o;
  wire n524_o;
  wire [15:0] n525_o;
  wire [95:0] n526_o;
  wire [8:0] n527_o;
  wire n528_o;
  wire n529_o;
  wire [127:0] n530_o;
  wire n532_o;
  wire [31:0] n533_o;
  wire n535_o;
  wire [31:0] n536_o;
  wire [31:0] n538_o;
  wire [31:0] n539_o;
  wire [31:0] n540_o;
  wire [31:0] n541_o;
  wire n542_o;
  wire [6:0] n553_o;
  wire [6:0] n555_o;
  wire [127:0] n558_o;
  wire [31:0] n559_o;
  wire [31:0] n561_o;
  wire [4:0] n562_o;
  wire [3:0] n564_o;
  wire [4:0] n565_o;
  wire [127:0] n566_o;
  wire n568_o;
  wire n569_o;
  wire [31:0] n570_o;
  wire [31:0] n572_o;
  wire [4:0] n573_o;
  wire [4:0] n574_o;
  wire [3:0] n576_o;
  wire n577_o;
  wire n579_o;
  wire [3:0] n580_o;
  wire [3:0] n582_o;
  wire [31:0] n586_o;
  wire n588_o;
  wire [31:0] n589_o;
  wire [31:0] n591_o;
  wire [4:0] n592_o;
  wire [3:0] n594_o;
  wire [4:0] n595_o;
  wire n597_o;
  wire n599_o;
  wire [3:0] n605_o;
  wire [3:0] n606_o;
  wire n608_o;
  wire n610_o;
  wire [10:0] n611_o;
  reg n614_o;
  reg n617_o;
  reg n620_o;
  reg [3:0] n625_o;
  reg [2047:0] n627_o;
  reg n629_o;
  reg n632_o;
  reg n634_o;
  reg n636_o;
  reg [15:0] n638_o;
  reg [63:0] n640_o;
  reg [95:0] n642_o;
  reg [95:0] n644_o;
  reg [4:0] n646_o;
  reg [4:0] n648_o;
  reg [4:0] n650_o;
  reg [4:0] n652_o;
  reg [127:0] n654_o;
  reg [25:0] n658_o;
  reg [7:0] n660_o;
  reg [7:0] n662_o;
  reg [15:0] n664_o;
  reg [95:0] n666_o;
  reg [8:0] n668_o;
  reg n670_o;
  reg n672_o;
  reg [127:0] n674_o;
  wire n676_o;
  wire n679_o;
  wire n682_o;
  wire [3:0] n685_o;
  wire [2047:0] n686_o;
  wire n688_o;
  wire n690_o;
  wire n692_o;
  wire n694_o;
  wire n696_o;
  wire n698_o;
  wire [15:0] n700_o;
  wire [63:0] n701_o;
  wire [95:0] n702_o;
  wire [95:0] n703_o;
  wire [4:0] n705_o;
  wire [4:0] n707_o;
  wire [4:0] n709_o;
  wire [4:0] n711_o;
  wire [127:0] n712_o;
  wire [25:0] n715_o;
  wire [7:0] n716_o;
  wire [7:0] n717_o;
  wire [15:0] n718_o;
  wire [95:0] n719_o;
  wire [8:0] n720_o;
  wire n721_o;
  wire n722_o;
  wire [127:0] n723_o;
  reg [3:0] n755_q;
  reg [2047:0] n756_q;
  reg n757_q;
  reg n758_q;
  reg n759_q;
  reg n760_q;
  reg n761_q;
  reg n762_q;
  reg [15:0] n763_q;
  reg [63:0] n764_q;
  reg [95:0] n765_q;
  reg [95:0] n766_q;
  reg [4:0] n767_q;
  reg [4:0] n768_q;
  reg [4:0] n769_q;
  reg [4:0] n770_q;
  reg [127:0] n771_q;
  reg [25:0] n773_q;
  reg [7:0] n774_q;
  reg [7:0] n775_q;
  reg [15:0] n776_q;
  reg [95:0] n777_q;
  reg [8:0] n778_q;
  reg n779_q;
  reg n780_q;
  reg [127:0] n781_q;
  reg n782_q;
  reg n783_q;
  reg n784_q;
  wire [7:0] n785_o;
  wire [7:0] n786_o;
  wire [7:0] n787_o;
  wire [7:0] n788_o;
  wire [7:0] n789_o;
  wire [7:0] n790_o;
  wire [7:0] n791_o;
  wire [7:0] n792_o;
  wire [7:0] n793_o;
  wire [7:0] n794_o;
  wire [7:0] n795_o;
  wire [7:0] n796_o;
  wire [7:0] n797_o;
  wire [7:0] n798_o;
  wire [7:0] n799_o;
  wire [7:0] n800_o;
  wire [7:0] n801_o;
  wire [7:0] n802_o;
  wire [7:0] n803_o;
  wire [7:0] n804_o;
  wire [7:0] n805_o;
  wire [7:0] n806_o;
  wire [7:0] n807_o;
  wire [7:0] n808_o;
  wire [7:0] n809_o;
  wire [7:0] n810_o;
  wire [7:0] n811_o;
  wire [7:0] n812_o;
  wire [7:0] n813_o;
  wire [7:0] n814_o;
  wire [7:0] n815_o;
  wire [7:0] n816_o;
  wire [7:0] n817_o;
  wire [7:0] n818_o;
  wire [7:0] n819_o;
  wire [7:0] n820_o;
  wire [7:0] n821_o;
  wire [7:0] n822_o;
  wire [7:0] n823_o;
  wire [7:0] n824_o;
  wire [7:0] n825_o;
  wire [7:0] n826_o;
  wire [7:0] n827_o;
  wire [7:0] n828_o;
  wire [7:0] n829_o;
  wire [7:0] n830_o;
  wire [7:0] n831_o;
  wire [7:0] n832_o;
  wire [7:0] n833_o;
  wire [7:0] n834_o;
  wire [7:0] n835_o;
  wire [7:0] n836_o;
  wire [7:0] n837_o;
  wire [7:0] n838_o;
  wire [7:0] n839_o;
  wire [7:0] n840_o;
  wire [7:0] n841_o;
  wire [7:0] n842_o;
  wire [7:0] n843_o;
  wire [7:0] n844_o;
  wire [7:0] n845_o;
  wire [7:0] n846_o;
  wire [7:0] n847_o;
  wire [7:0] n848_o;
  wire [7:0] n849_o;
  wire [7:0] n850_o;
  wire [7:0] n851_o;
  wire [7:0] n852_o;
  wire [7:0] n853_o;
  wire [7:0] n854_o;
  wire [7:0] n855_o;
  wire [7:0] n856_o;
  wire [7:0] n857_o;
  wire [7:0] n858_o;
  wire [7:0] n859_o;
  wire [7:0] n860_o;
  wire [7:0] n861_o;
  wire [7:0] n862_o;
  wire [7:0] n863_o;
  wire [7:0] n864_o;
  wire [7:0] n865_o;
  wire [7:0] n866_o;
  wire [7:0] n867_o;
  wire [7:0] n868_o;
  wire [7:0] n869_o;
  wire [7:0] n870_o;
  wire [7:0] n871_o;
  wire [7:0] n872_o;
  wire [7:0] n873_o;
  wire [7:0] n874_o;
  wire [7:0] n875_o;
  wire [7:0] n876_o;
  wire [7:0] n877_o;
  wire [7:0] n878_o;
  wire [7:0] n879_o;
  wire [7:0] n880_o;
  wire [7:0] n881_o;
  wire [7:0] n882_o;
  wire [7:0] n883_o;
  wire [7:0] n884_o;
  wire [7:0] n885_o;
  wire [7:0] n886_o;
  wire [7:0] n887_o;
  wire [7:0] n888_o;
  wire [7:0] n889_o;
  wire [7:0] n890_o;
  wire [7:0] n891_o;
  wire [7:0] n892_o;
  wire [7:0] n893_o;
  wire [7:0] n894_o;
  wire [7:0] n895_o;
  wire [7:0] n896_o;
  wire [7:0] n897_o;
  wire [7:0] n898_o;
  wire [7:0] n899_o;
  wire [7:0] n900_o;
  wire [7:0] n901_o;
  wire [7:0] n902_o;
  wire [7:0] n903_o;
  wire [7:0] n904_o;
  wire [7:0] n905_o;
  wire [7:0] n906_o;
  wire [7:0] n907_o;
  wire [7:0] n908_o;
  wire [7:0] n909_o;
  wire [7:0] n910_o;
  wire [7:0] n911_o;
  wire [7:0] n912_o;
  wire [7:0] n913_o;
  wire [7:0] n914_o;
  wire [7:0] n915_o;
  wire [7:0] n916_o;
  wire [7:0] n917_o;
  wire [7:0] n918_o;
  wire [7:0] n919_o;
  wire [7:0] n920_o;
  wire [7:0] n921_o;
  wire [7:0] n922_o;
  wire [7:0] n923_o;
  wire [7:0] n924_o;
  wire [7:0] n925_o;
  wire [7:0] n926_o;
  wire [7:0] n927_o;
  wire [7:0] n928_o;
  wire [7:0] n929_o;
  wire [7:0] n930_o;
  wire [7:0] n931_o;
  wire [7:0] n932_o;
  wire [7:0] n933_o;
  wire [7:0] n934_o;
  wire [7:0] n935_o;
  wire [7:0] n936_o;
  wire [7:0] n937_o;
  wire [7:0] n938_o;
  wire [7:0] n939_o;
  wire [7:0] n940_o;
  wire [7:0] n941_o;
  wire [7:0] n942_o;
  wire [7:0] n943_o;
  wire [7:0] n944_o;
  wire [7:0] n945_o;
  wire [7:0] n946_o;
  wire [7:0] n947_o;
  wire [7:0] n948_o;
  wire [7:0] n949_o;
  wire [7:0] n950_o;
  wire [7:0] n951_o;
  wire [7:0] n952_o;
  wire [7:0] n953_o;
  wire [7:0] n954_o;
  wire [7:0] n955_o;
  wire [7:0] n956_o;
  wire [7:0] n957_o;
  wire [7:0] n958_o;
  wire [7:0] n959_o;
  wire [7:0] n960_o;
  wire [7:0] n961_o;
  wire [7:0] n962_o;
  wire [7:0] n963_o;
  wire [7:0] n964_o;
  wire [7:0] n965_o;
  wire [7:0] n966_o;
  wire [7:0] n967_o;
  wire [7:0] n968_o;
  wire [7:0] n969_o;
  wire [7:0] n970_o;
  wire [7:0] n971_o;
  wire [7:0] n972_o;
  wire [7:0] n973_o;
  wire [7:0] n974_o;
  wire [7:0] n975_o;
  wire [7:0] n976_o;
  wire [7:0] n977_o;
  wire [7:0] n978_o;
  wire [7:0] n979_o;
  wire [7:0] n980_o;
  wire [7:0] n981_o;
  wire [7:0] n982_o;
  wire [7:0] n983_o;
  wire [7:0] n984_o;
  wire [7:0] n985_o;
  wire [7:0] n986_o;
  wire [7:0] n987_o;
  wire [7:0] n988_o;
  wire [7:0] n989_o;
  wire [7:0] n990_o;
  wire [7:0] n991_o;
  wire [7:0] n992_o;
  wire [7:0] n993_o;
  wire [7:0] n994_o;
  wire [7:0] n995_o;
  wire [7:0] n996_o;
  wire [7:0] n997_o;
  wire [7:0] n998_o;
  wire [7:0] n999_o;
  wire [7:0] n1000_o;
  wire [7:0] n1001_o;
  wire [7:0] n1002_o;
  wire [7:0] n1003_o;
  wire [7:0] n1004_o;
  wire [7:0] n1005_o;
  wire [7:0] n1006_o;
  wire [7:0] n1007_o;
  wire [7:0] n1008_o;
  wire [7:0] n1009_o;
  wire [7:0] n1010_o;
  wire [7:0] n1011_o;
  wire [7:0] n1012_o;
  wire [7:0] n1013_o;
  wire [7:0] n1014_o;
  wire [7:0] n1015_o;
  wire [7:0] n1016_o;
  wire [7:0] n1017_o;
  wire [7:0] n1018_o;
  wire [7:0] n1019_o;
  wire [7:0] n1020_o;
  wire [7:0] n1021_o;
  wire [7:0] n1022_o;
  wire [7:0] n1023_o;
  wire [7:0] n1024_o;
  wire [7:0] n1025_o;
  wire [7:0] n1026_o;
  wire [7:0] n1027_o;
  wire [7:0] n1028_o;
  wire [7:0] n1029_o;
  wire [7:0] n1030_o;
  wire [7:0] n1031_o;
  wire [7:0] n1032_o;
  wire [7:0] n1033_o;
  wire [7:0] n1034_o;
  wire [7:0] n1035_o;
  wire [7:0] n1036_o;
  wire [7:0] n1037_o;
  wire [7:0] n1038_o;
  wire [7:0] n1039_o;
  wire [7:0] n1040_o;
  wire [10:0] n1041_o;
  wire [7:0] n1042_o;
  wire [1:0] n1043_o;
  reg [7:0] n1044_o;
  wire [1:0] n1045_o;
  reg [7:0] n1046_o;
  wire [1:0] n1047_o;
  reg [7:0] n1048_o;
  wire [1:0] n1049_o;
  reg [7:0] n1050_o;
  wire [1:0] n1051_o;
  reg [7:0] n1052_o;
  wire [1:0] n1053_o;
  reg [7:0] n1054_o;
  wire [1:0] n1055_o;
  reg [7:0] n1056_o;
  wire [1:0] n1057_o;
  reg [7:0] n1058_o;
  wire [1:0] n1059_o;
  reg [7:0] n1060_o;
  wire [1:0] n1061_o;
  reg [7:0] n1062_o;
  wire [1:0] n1063_o;
  reg [7:0] n1064_o;
  wire [1:0] n1065_o;
  reg [7:0] n1066_o;
  wire [1:0] n1067_o;
  reg [7:0] n1068_o;
  wire [1:0] n1069_o;
  reg [7:0] n1070_o;
  wire [1:0] n1071_o;
  reg [7:0] n1072_o;
  wire [1:0] n1073_o;
  reg [7:0] n1074_o;
  wire [1:0] n1075_o;
  reg [7:0] n1076_o;
  wire [1:0] n1077_o;
  reg [7:0] n1078_o;
  wire [1:0] n1079_o;
  reg [7:0] n1080_o;
  wire [1:0] n1081_o;
  reg [7:0] n1082_o;
  wire [1:0] n1083_o;
  reg [7:0] n1084_o;
  wire [1:0] n1085_o;
  reg [7:0] n1086_o;
  wire [1:0] n1087_o;
  reg [7:0] n1088_o;
  wire [1:0] n1089_o;
  reg [7:0] n1090_o;
  wire [1:0] n1091_o;
  reg [7:0] n1092_o;
  wire [1:0] n1093_o;
  reg [7:0] n1094_o;
  wire [1:0] n1095_o;
  reg [7:0] n1096_o;
  wire [1:0] n1097_o;
  reg [7:0] n1098_o;
  wire [1:0] n1099_o;
  reg [7:0] n1100_o;
  wire [1:0] n1101_o;
  reg [7:0] n1102_o;
  wire [1:0] n1103_o;
  reg [7:0] n1104_o;
  wire [1:0] n1105_o;
  reg [7:0] n1106_o;
  wire [1:0] n1107_o;
  reg [7:0] n1108_o;
  wire [1:0] n1109_o;
  reg [7:0] n1110_o;
  wire [1:0] n1111_o;
  reg [7:0] n1112_o;
  wire [1:0] n1113_o;
  reg [7:0] n1114_o;
  wire [1:0] n1115_o;
  reg [7:0] n1116_o;
  wire [1:0] n1117_o;
  reg [7:0] n1118_o;
  wire [1:0] n1119_o;
  reg [7:0] n1120_o;
  wire [1:0] n1121_o;
  reg [7:0] n1122_o;
  wire [1:0] n1123_o;
  reg [7:0] n1124_o;
  wire [1:0] n1125_o;
  reg [7:0] n1126_o;
  wire [1:0] n1127_o;
  reg [7:0] n1128_o;
  wire [1:0] n1129_o;
  reg [7:0] n1130_o;
  wire [1:0] n1131_o;
  reg [7:0] n1132_o;
  wire [1:0] n1133_o;
  reg [7:0] n1134_o;
  wire [1:0] n1135_o;
  reg [7:0] n1136_o;
  wire [1:0] n1137_o;
  reg [7:0] n1138_o;
  wire [1:0] n1139_o;
  reg [7:0] n1140_o;
  wire [1:0] n1141_o;
  reg [7:0] n1142_o;
  wire [1:0] n1143_o;
  reg [7:0] n1144_o;
  wire [1:0] n1145_o;
  reg [7:0] n1146_o;
  wire [1:0] n1147_o;
  reg [7:0] n1148_o;
  wire [1:0] n1149_o;
  reg [7:0] n1150_o;
  wire [1:0] n1151_o;
  reg [7:0] n1152_o;
  wire [1:0] n1153_o;
  reg [7:0] n1154_o;
  wire [1:0] n1155_o;
  reg [7:0] n1156_o;
  wire [1:0] n1157_o;
  reg [7:0] n1158_o;
  wire [1:0] n1159_o;
  reg [7:0] n1160_o;
  wire [1:0] n1161_o;
  reg [7:0] n1162_o;
  wire [1:0] n1163_o;
  reg [7:0] n1164_o;
  wire [1:0] n1165_o;
  reg [7:0] n1166_o;
  wire [1:0] n1167_o;
  reg [7:0] n1168_o;
  wire [1:0] n1169_o;
  reg [7:0] n1170_o;
  wire [1:0] n1171_o;
  reg [7:0] n1172_o;
  wire [1:0] n1173_o;
  reg [7:0] n1174_o;
  wire [1:0] n1175_o;
  reg [7:0] n1176_o;
  wire [1:0] n1177_o;
  reg [7:0] n1178_o;
  wire [1:0] n1179_o;
  reg [7:0] n1180_o;
  wire [1:0] n1181_o;
  reg [7:0] n1182_o;
  wire [1:0] n1183_o;
  reg [7:0] n1184_o;
  wire [1:0] n1185_o;
  reg [7:0] n1186_o;
  wire [1:0] n1187_o;
  reg [7:0] n1188_o;
  wire [1:0] n1189_o;
  reg [7:0] n1190_o;
  wire [1:0] n1191_o;
  reg [7:0] n1192_o;
  wire [1:0] n1193_o;
  reg [7:0] n1194_o;
  wire [1:0] n1195_o;
  reg [7:0] n1196_o;
  wire [1:0] n1197_o;
  reg [7:0] n1198_o;
  wire [1:0] n1199_o;
  reg [7:0] n1200_o;
  wire [1:0] n1201_o;
  reg [7:0] n1202_o;
  wire [1:0] n1203_o;
  reg [7:0] n1204_o;
  wire [1:0] n1205_o;
  reg [7:0] n1206_o;
  wire [1:0] n1207_o;
  reg [7:0] n1208_o;
  wire [1:0] n1209_o;
  reg [7:0] n1210_o;
  wire [1:0] n1211_o;
  reg [7:0] n1212_o;
  wire n1213_o;
  wire n1214_o;
  wire n1215_o;
  wire n1216_o;
  wire n1217_o;
  wire n1218_o;
  wire n1219_o;
  wire n1220_o;
  wire n1221_o;
  wire n1222_o;
  wire n1223_o;
  wire n1224_o;
  wire n1225_o;
  wire n1226_o;
  wire n1227_o;
  wire n1228_o;
  wire n1229_o;
  wire n1230_o;
  wire n1231_o;
  wire n1232_o;
  wire n1233_o;
  wire n1234_o;
  wire n1235_o;
  wire n1236_o;
  wire n1237_o;
  wire n1238_o;
  wire n1239_o;
  wire n1240_o;
  wire n1241_o;
  wire n1242_o;
  wire n1243_o;
  wire n1244_o;
  wire n1245_o;
  wire n1246_o;
  wire n1247_o;
  wire n1248_o;
  wire [127:0] n1249_o;
  wire [127:0] n1250_o;
  wire [127:0] n1251_o;
  wire [127:0] n1252_o;
  wire [127:0] n1253_o;
  wire [127:0] n1254_o;
  wire [127:0] n1255_o;
  wire [127:0] n1256_o;
  wire [127:0] n1257_o;
  wire [127:0] n1258_o;
  wire [127:0] n1259_o;
  wire [127:0] n1260_o;
  wire [127:0] n1261_o;
  wire [127:0] n1262_o;
  wire [127:0] n1263_o;
  wire [127:0] n1264_o;
  wire [127:0] n1265_o;
  wire [127:0] n1266_o;
  wire [127:0] n1267_o;
  wire [127:0] n1268_o;
  wire [127:0] n1269_o;
  wire [127:0] n1270_o;
  wire [127:0] n1271_o;
  wire [127:0] n1272_o;
  wire [127:0] n1273_o;
  wire [127:0] n1274_o;
  wire [127:0] n1275_o;
  wire [127:0] n1276_o;
  wire [127:0] n1277_o;
  wire [127:0] n1278_o;
  wire [127:0] n1279_o;
  wire [127:0] n1280_o;
  wire [2047:0] n1281_o;
  wire [3:0] n1282_o;
  wire n1283_o;
  wire n1284_o;
  wire n1285_o;
  wire n1286_o;
  wire n1287_o;
  wire n1288_o;
  wire n1289_o;
  wire n1290_o;
  wire n1291_o;
  wire n1292_o;
  wire n1293_o;
  wire n1294_o;
  wire n1295_o;
  wire n1296_o;
  wire n1297_o;
  wire n1298_o;
  wire n1299_o;
  wire n1300_o;
  wire n1301_o;
  wire n1302_o;
  wire n1303_o;
  wire n1304_o;
  wire n1305_o;
  wire n1306_o;
  wire n1307_o;
  wire n1308_o;
  wire n1309_o;
  wire n1310_o;
  wire n1311_o;
  wire n1312_o;
  wire n1313_o;
  wire n1314_o;
  wire n1315_o;
  wire n1316_o;
  wire n1317_o;
  wire n1318_o;
  wire [7:0] n1319_o;
  wire [7:0] n1320_o;
  wire [7:0] n1321_o;
  wire [7:0] n1322_o;
  wire [7:0] n1323_o;
  wire [7:0] n1324_o;
  wire [7:0] n1325_o;
  wire [7:0] n1326_o;
  wire [7:0] n1327_o;
  wire [7:0] n1328_o;
  wire [7:0] n1329_o;
  wire [7:0] n1330_o;
  wire [7:0] n1331_o;
  wire [7:0] n1332_o;
  wire [7:0] n1333_o;
  wire [7:0] n1334_o;
  wire [7:0] n1335_o;
  wire [7:0] n1336_o;
  wire [7:0] n1337_o;
  wire [7:0] n1338_o;
  wire [7:0] n1339_o;
  wire [7:0] n1340_o;
  wire [7:0] n1341_o;
  wire [7:0] n1342_o;
  wire [7:0] n1343_o;
  wire [7:0] n1344_o;
  wire [7:0] n1345_o;
  wire [7:0] n1346_o;
  wire [7:0] n1347_o;
  wire [7:0] n1348_o;
  wire [7:0] n1349_o;
  wire [7:0] n1350_o;
  wire [127:0] n1351_o;
  wire n1352_o;
  wire n1353_o;
  wire n1354_o;
  wire n1355_o;
  wire n1356_o;
  wire n1357_o;
  wire n1358_o;
  wire n1359_o;
  wire n1360_o;
  wire n1361_o;
  wire n1362_o;
  wire n1363_o;
  wire n1364_o;
  wire n1365_o;
  wire n1366_o;
  wire n1367_o;
  wire n1368_o;
  wire n1369_o;
  wire n1370_o;
  wire n1371_o;
  wire n1372_o;
  wire n1373_o;
  wire n1374_o;
  wire n1375_o;
  wire n1376_o;
  wire n1377_o;
  wire n1378_o;
  wire n1379_o;
  wire n1380_o;
  wire n1381_o;
  wire n1382_o;
  wire n1383_o;
  wire n1384_o;
  wire n1385_o;
  wire n1386_o;
  wire n1387_o;
  wire [127:0] n1388_o;
  wire [127:0] n1389_o;
  wire [127:0] n1390_o;
  wire [127:0] n1391_o;
  wire [127:0] n1392_o;
  wire [127:0] n1393_o;
  wire [127:0] n1394_o;
  wire [127:0] n1395_o;
  wire [127:0] n1396_o;
  wire [127:0] n1397_o;
  wire [127:0] n1398_o;
  wire [127:0] n1399_o;
  wire [127:0] n1400_o;
  wire [127:0] n1401_o;
  wire [127:0] n1402_o;
  wire [127:0] n1403_o;
  wire [127:0] n1404_o;
  wire [127:0] n1405_o;
  wire [127:0] n1406_o;
  wire [127:0] n1407_o;
  wire [127:0] n1408_o;
  wire [127:0] n1409_o;
  wire [127:0] n1410_o;
  wire [127:0] n1411_o;
  wire [127:0] n1412_o;
  wire [127:0] n1413_o;
  wire [127:0] n1414_o;
  wire [127:0] n1415_o;
  wire [127:0] n1416_o;
  wire [127:0] n1417_o;
  wire [127:0] n1418_o;
  wire [127:0] n1419_o;
  wire [2047:0] n1420_o;
  assign pkt_ack = n103_o;
  assign buf_addr = n98_o;
  assign ctr_store_req = n76_o;
  assign ctr_store_val = n79_o;
  assign seq_store_req = n83_o;
  assign seq_store_val = hdr_seq;
  assign eng_start = n64_o;
  assign eng_decrypt = is_dec;
  assign eng_key = key;
  assign eng_iv = iv_sel;
  assign eng_aad_len = n66_o;
  assign eng_data_len = n67_o;
  assign eng_tag_in = tag_in;
  assign eng_in_valid = n71_o;
  assign eng_in_block = in_reg;
  assign tx_wr_en = u_bld_wr_en;
  assign tx_wr_data = u_bld_wr_data;
  assign busy = n108_o;
  assign evt_parse_err = n782_q;
  assign evt_auth_fail = n783_q;
  assign evt_replay = n784_q;
  /* rtl/crypto_controller.vhd:111:12  */
  always @*
    state = n755_q; // (isignal)
  initial
    state = 4'b0000;
  /* rtl/crypto_controller.vhd:112:12  */
  always @*
    obuf = n756_q; // (isignal)
  initial
    obuf = 2048'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
  /* rtl/crypto_controller.vhd:114:12  */
  always @*
    is_dec = n757_q; // (isignal)
  initial
    is_dec = 1'b0;
  /* rtl/crypto_controller.vhd:114:20  */
  always @*
    held = n758_q; // (isignal)
  initial
    held = 1'b0;
  /* rtl/crypto_controller.vhd:114:26  */
  always @*
    cur_aad = n759_q; // (isignal)
  initial
    cur_aad = 1'b0;
  /* rtl/crypto_controller.vhd:115:12  */
  always @*
    have_last = n760_q; // (isignal)
  initial
    have_last = 1'b0;
  /* rtl/crypto_controller.vhd:115:23  */
  always @*
    ctr_seen = n761_q; // (isignal)
  initial
    ctr_seen = 1'b0;
  /* rtl/crypto_controller.vhd:115:33  */
  always @*
    seq_seen = n762_q; // (isignal)
  initial
    seq_seen = 1'b0;
  /* rtl/crypto_controller.vhd:116:12  */
  always @*
    last_seq = n763_q; // (isignal)
  initial
    last_seq = 16'b0000000000000000;
  /* rtl/crypto_controller.vhd:117:12  */
  always @*
    ctr = n764_q; // (isignal)
  initial
    ctr = 64'b0000000000000000000000000000000000000000000000000000000000000000;
  /* rtl/crypto_controller.vhd:118:12  */
  always @*
    iv_sel = n765_q; // (isignal)
  initial
    iv_sel = 96'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
  /* rtl/crypto_controller.vhd:118:20  */
  always @*
    nonce_used = n766_q; // (isignal)
  initial
    nonce_used = 96'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
  /* rtl/crypto_controller.vhd:119:12  */
  always @*
    di = n767_q; // (isignal)
  initial
    di = 5'b00000;
  /* rtl/crypto_controller.vhd:119:16  */
  always @*
    oi = n768_q; // (isignal)
  initial
    oi = 5'b00000;
  /* rtl/crypto_controller.vhd:119:20  */
  always @*
    ci = n769_q; // (isignal)
  initial
    ci = 5'b00000;
  /* rtl/crypto_controller.vhd:120:12  */
  always @*
    ld_i = n770_q; // (isignal)
  initial
    ld_i = 5'b00000;
  /* rtl/crypto_controller.vhd:121:12  */
  always @*
    in_reg = n771_q; // (isignal)
  initial
    in_reg = 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
  /* rtl/crypto_controller.vhd:122:12  */
  always @*
    nv_cnt = n773_q; // (isignal)
  initial
    nv_cnt = 26'b00000000000000000000000000;
  /* rtl/crypto_controller.vhd:124:12  */
  always @*
    resp_type = n774_q; // (isignal)
  initial
    resp_type = 8'b00000000;
  /* rtl/crypto_controller.vhd:124:23  */
  always @*
    resp_code = n775_q; // (isignal)
  initial
    resp_code = 8'b00000000;
  /* rtl/crypto_controller.vhd:125:12  */
  always @*
    resp_seq = n776_q; // (isignal)
  initial
    resp_seq = 16'b0000000000000000;
  /* rtl/crypto_controller.vhd:126:12  */
  always @*
    resp_nonce = n777_q; // (isignal)
  initial
    resp_nonce = 96'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
  /* rtl/crypto_controller.vhd:127:12  */
  always @*
    resp_len = n778_q; // (isignal)
  initial
    resp_len = 9'b000000000;
  /* rtl/crypto_controller.vhd:128:12  */
  always @*
    resp_has_tag = n779_q; // (isignal)
  initial
    resp_has_tag = 1'b0;
  /* rtl/crypto_controller.vhd:128:26  */
  always @*
    resp_is_err = n780_q; // (isignal)
  initial
    resp_is_err = 1'b0;
  /* rtl/crypto_controller.vhd:129:12  */
  always @*
    resp_tag = n781_q; // (isignal)
  initial
    resp_tag = 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
  /* rtl/crypto_controller.vhd:130:12  */
  always @*
    pay_blk = u_bld_pay_blk; // (isignal)
  initial
    pay_blk = 4'b0000;
  /* rtl/crypto_controller.vhd:131:12  */
  always @*
    pay_byte = u_bld_pay_byte; // (isignal)
  initial
    pay_byte = 4'b0000;
  /* rtl/crypto_controller.vhd:132:12  */
  assign pay_data = n1212_o; // (signal)
  /* rtl/crypto_controller.vhd:133:12  */
  assign bld_start = n113_o; // (signal)
  /* rtl/crypto_controller.vhd:133:23  */
  assign bld_done = u_bld_done; // (signal)
  /* rtl/crypto_controller.vhd:135:12  */
  assign aad_type = n53_o; // (signal)
  /* rtl/crypto_controller.vhd:136:12  */
  assign aad_block = n60_o; // (signal)
  /* rtl/crypto_controller.vhd:137:12  */
  assign len16 = n51_o; // (signal)
  /* rtl/crypto_controller.vhd:140:35  */
  assign n51_o = {7'b0, hdr_len};  //  uext
  /* rtl/crypto_controller.vhd:141:24  */
  assign n53_o = is_dec ? 8'b00000001 : 8'b10000001;
  /* rtl/crypto_controller.vhd:142:24  */
  assign n56_o = {8'b00000001, aad_type};
  /* rtl/crypto_controller.vhd:142:35  */
  assign n57_o = {n56_o, hdr_seq};
  /* rtl/crypto_controller.vhd:142:45  */
  assign n58_o = {n57_o, len16};
  /* rtl/crypto_controller.vhd:142:53  */
  assign n60_o = {n58_o, 80'b00000000000000000000000000000000000000000000000000000000000000000000000000000000};
  /* rtl/crypto_controller.vhd:144:37  */
  assign n63_o = state == 4'b0011;
  /* rtl/crypto_controller.vhd:144:26  */
  assign n64_o = n63_o ? 1'b1 : 1'b0;
  /* rtl/crypto_controller.vhd:149:22  */
  assign n67_o = {3'b0, hdr_len};  //  uext
  /* rtl/crypto_controller.vhd:151:37  */
  assign n70_o = state == 4'b0110;
  /* rtl/crypto_controller.vhd:151:26  */
  assign n71_o = n70_o ? 1'b1 : 1'b0;
  /* rtl/crypto_controller.vhd:154:37  */
  assign n75_o = state == 4'b0001;
  /* rtl/crypto_controller.vhd:154:26  */
  assign n76_o = n75_o ? 1'b1 : 1'b0;
  /* rtl/crypto_controller.vhd:155:43  */
  assign n79_o = ctr + 64'b0000000000000000000000000000000000000000000000000000000000000001;
  /* rtl/crypto_controller.vhd:156:37  */
  assign n82_o = state == 4'b0010;
  /* rtl/crypto_controller.vhd:156:26  */
  assign n83_o = n82_o ? 1'b1 : 1'b0;
  /* rtl/crypto_controller.vhd:159:20  */
  assign n85_o = {27'b0, di};  //  uext
  /* rtl/crypto_controller.vhd:159:20  */
  assign n87_o = 32'b00000000000000000000000000010000 * n85_o; // smul
  /* rtl/crypto_controller.vhd:159:25  */
  assign n88_o = {27'b0, ld_i};  //  uext
  /* rtl/crypto_controller.vhd:159:25  */
  assign n89_o = n87_o + n88_o;
  /* rtl/crypto_controller.vhd:159:17  */
  assign n90_o = n89_o[7:0];  // trunc
  /* rtl/crypto_controller.vhd:159:40  */
  assign n91_o = {27'b0, di};  //  uext
  /* rtl/crypto_controller.vhd:159:40  */
  assign n93_o = 32'b00000000000000000000000000010000 * n91_o; // smul
  /* rtl/crypto_controller.vhd:159:45  */
  assign n94_o = {27'b0, ld_i};  //  uext
  /* rtl/crypto_controller.vhd:159:45  */
  assign n95_o = n93_o + n94_o;
  /* rtl/crypto_controller.vhd:159:52  */
  assign n97_o = $signed(n95_o) < $signed(32'b00000000000000000000000100000000);
  /* rtl/crypto_controller.vhd:159:32  */
  assign n98_o = n97_o ? n90_o : 8'b00000000;
  /* rtl/crypto_controller.vhd:160:32  */
  assign n102_o = state == 4'b1010;
  /* rtl/crypto_controller.vhd:160:21  */
  assign n103_o = n102_o ? 1'b1 : 1'b0;
  /* rtl/crypto_controller.vhd:161:32  */
  assign n107_o = state == 4'b0000;
  /* rtl/crypto_controller.vhd:161:21  */
  assign n108_o = n107_o ? 1'b0 : 1'b1;
  /* rtl/crypto_controller.vhd:163:33  */
  assign n112_o = state == 4'b1000;
  /* rtl/crypto_controller.vhd:163:22  */
  assign n113_o = n112_o ? 1'b1 : 1'b0;
  /* rtl/crypto_controller.vhd:164:23  */
  assign n116_o = 4'b1111 - pay_blk;
  /* rtl/crypto_controller.vhd:164:31  */
  assign n128_o = {3'b0, pay_byte};  //  uext
  /* rtl/crypto_controller.vhd:164:31  */
  assign n130_o = 7'b0001111 - n128_o;
  /* rtl/crypto_controller.vhd:166:5  */
  packet_builder_256 u_bld (
    .clk(clk),
    .rst(rst),
    .start(bld_start),
    .resp_type(resp_type),
    .resp_seq(resp_seq),
    .resp_nonce(resp_nonce),
    .resp_len(resp_len),
    .resp_has_tag(resp_has_tag),
    .resp_is_err(resp_is_err),
    .resp_code(resp_code),
    .resp_tag(resp_tag),
    .pay_data(pay_data),
    .full(tx_full),
    .busy(),
    .done(u_bld_done),
    .pay_blk(u_bld_pay_blk),
    .pay_byte(u_bld_pay_byte),
    .wr_en(u_bld_wr_en),
    .wr_data(u_bld_wr_data));
  /* rtl/crypto_controller.vhd:216:49  */
  assign n142_o = ~ctr_seen;
  /* rtl/crypto_controller.vhd:216:36  */
  assign n143_o = n142_o & ctr_valid;
  /* rtl/crypto_controller.vhd:216:17  */
  assign n145_o = n143_o ? 1'b1 : ctr_seen;
  /* rtl/crypto_controller.vhd:216:17  */
  assign n146_o = n143_o ? ctr_init : ctr;
  /* rtl/crypto_controller.vhd:220:49  */
  assign n147_o = ~seq_seen;
  /* rtl/crypto_controller.vhd:220:36  */
  assign n148_o = n147_o & seq_valid;
  /* rtl/crypto_controller.vhd:220:17  */
  assign n149_o = n148_o ? seq_have_init : have_last;
  /* rtl/crypto_controller.vhd:220:17  */
  assign n151_o = n148_o ? 1'b1 : seq_seen;
  /* rtl/crypto_controller.vhd:220:17  */
  assign n152_o = n148_o ? seq_init : last_seq;
  /* rtl/crypto_controller.vhd:232:42  */
  assign n153_o = ~key_valid;
  /* rtl/crypto_controller.vhd:234:44  */
  assign n158_o = hdr_type == 8'b00000001;
  /* rtl/crypto_controller.vhd:235:45  */
  assign n159_o = hdr_nonce[95:64];
  /* rtl/crypto_controller.vhd:235:60  */
  assign n161_o = n159_o == 32'b11000000111111111110111000000001;
  /* rtl/crypto_controller.vhd:237:49  */
  assign n165_o = ~seq_valid;
  /* rtl/crypto_controller.vhd:237:67  */
  assign n166_o = ~seq_seen;
  /* rtl/crypto_controller.vhd:237:55  */
  assign n167_o = n165_o | n166_o;
  /* rtl/crypto_controller.vhd:239:77  */
  assign n171_o = $unsigned(hdr_seq) <= $unsigned(last_seq);
  /* rtl/crypto_controller.vhd:239:55  */
  assign n172_o = n171_o & have_last;
  /* rtl/crypto_controller.vhd:239:33  */
  assign n178_o = n172_o ? 1'b1 : 1'b0;
  /* rtl/crypto_controller.vhd:239:33  */
  assign n181_o = n172_o ? 4'b1000 : 4'b0011;
  /* rtl/crypto_controller.vhd:239:33  */
  assign n183_o = n172_o ? is_dec : 1'b1;
  /* rtl/crypto_controller.vhd:239:33  */
  assign n184_o = n172_o ? iv_sel : hdr_nonce;
  /* rtl/crypto_controller.vhd:239:33  */
  assign n186_o = n172_o ? 8'b11100000 : resp_type;
  /* rtl/crypto_controller.vhd:239:33  */
  assign n188_o = n172_o ? 8'b00000010 : resp_code;
  /* rtl/crypto_controller.vhd:239:33  */
  assign n189_o = n172_o ? hdr_seq : resp_seq;
  /* rtl/crypto_controller.vhd:239:33  */
  assign n191_o = n172_o ? 96'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : resp_nonce;
  /* rtl/crypto_controller.vhd:239:33  */
  assign n193_o = n172_o ? 9'b000000001 : resp_len;
  /* rtl/crypto_controller.vhd:239:33  */
  assign n195_o = n172_o ? 1'b0 : resp_has_tag;
  /* rtl/crypto_controller.vhd:239:33  */
  assign n197_o = n172_o ? 1'b1 : resp_is_err;
  /* rtl/crypto_controller.vhd:237:33  */
  assign n199_o = n167_o ? 1'b0 : n178_o;
  /* rtl/crypto_controller.vhd:237:33  */
  assign n201_o = n167_o ? 4'b1000 : n181_o;
  /* rtl/crypto_controller.vhd:237:33  */
  assign n202_o = n167_o ? is_dec : n183_o;
  /* rtl/crypto_controller.vhd:237:33  */
  assign n203_o = n167_o ? iv_sel : n184_o;
  /* rtl/crypto_controller.vhd:237:33  */
  assign n205_o = n167_o ? 8'b11100000 : n186_o;
  /* rtl/crypto_controller.vhd:237:33  */
  assign n207_o = n167_o ? 8'b00000011 : n188_o;
  /* rtl/crypto_controller.vhd:237:33  */
  assign n208_o = n167_o ? hdr_seq : n189_o;
  /* rtl/crypto_controller.vhd:237:33  */
  assign n210_o = n167_o ? 96'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : n191_o;
  /* rtl/crypto_controller.vhd:237:33  */
  assign n212_o = n167_o ? 9'b000000001 : n193_o;
  /* rtl/crypto_controller.vhd:237:33  */
  assign n214_o = n167_o ? 1'b0 : n195_o;
  /* rtl/crypto_controller.vhd:237:33  */
  assign n216_o = n167_o ? 1'b1 : n197_o;
  /* rtl/crypto_controller.vhd:235:33  */
  assign n218_o = n161_o ? 1'b0 : n199_o;
  /* rtl/crypto_controller.vhd:235:33  */
  assign n220_o = n161_o ? 4'b1000 : n201_o;
  /* rtl/crypto_controller.vhd:235:33  */
  assign n221_o = n161_o ? is_dec : n202_o;
  /* rtl/crypto_controller.vhd:235:33  */
  assign n222_o = n161_o ? iv_sel : n203_o;
  /* rtl/crypto_controller.vhd:235:33  */
  assign n224_o = n161_o ? 8'b11100000 : n205_o;
  /* rtl/crypto_controller.vhd:235:33  */
  assign n226_o = n161_o ? 8'b00000101 : n207_o;
  /* rtl/crypto_controller.vhd:235:33  */
  assign n227_o = n161_o ? hdr_seq : n208_o;
  /* rtl/crypto_controller.vhd:235:33  */
  assign n229_o = n161_o ? 96'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : n210_o;
  /* rtl/crypto_controller.vhd:235:33  */
  assign n231_o = n161_o ? 9'b000000001 : n212_o;
  /* rtl/crypto_controller.vhd:235:33  */
  assign n233_o = n161_o ? 1'b0 : n214_o;
  /* rtl/crypto_controller.vhd:235:33  */
  assign n235_o = n161_o ? 1'b1 : n216_o;
  /* rtl/crypto_controller.vhd:250:49  */
  assign n236_o = ~ctr_valid;
  /* rtl/crypto_controller.vhd:250:67  */
  assign n237_o = ~ctr_seen;
  /* rtl/crypto_controller.vhd:250:55  */
  assign n238_o = n236_o | n237_o;
  /* rtl/crypto_controller.vhd:250:77  */
  assign n239_o = &(ctr);
  /* rtl/crypto_controller.vhd:250:73  */
  assign n240_o = n238_o | n239_o;
  /* rtl/crypto_controller.vhd:250:33  */
  assign n246_o = n240_o ? 4'b1000 : 4'b0001;
  /* rtl/crypto_controller.vhd:250:33  */
  assign n248_o = n240_o ? is_dec : 1'b0;
  /* rtl/crypto_controller.vhd:250:33  */
  assign n250_o = n240_o ? nv_cnt : 26'b00000000000000000000000000;
  /* rtl/crypto_controller.vhd:250:33  */
  assign n252_o = n240_o ? 8'b11100000 : resp_type;
  /* rtl/crypto_controller.vhd:250:33  */
  assign n254_o = n240_o ? 8'b00000011 : resp_code;
  /* rtl/crypto_controller.vhd:250:33  */
  assign n255_o = n240_o ? hdr_seq : resp_seq;
  /* rtl/crypto_controller.vhd:250:33  */
  assign n257_o = n240_o ? 96'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : resp_nonce;
  /* rtl/crypto_controller.vhd:250:33  */
  assign n259_o = n240_o ? 9'b000000001 : resp_len;
  /* rtl/crypto_controller.vhd:250:33  */
  assign n261_o = n240_o ? 1'b0 : resp_has_tag;
  /* rtl/crypto_controller.vhd:250:33  */
  assign n263_o = n240_o ? 1'b1 : resp_is_err;
  /* rtl/crypto_controller.vhd:234:29  */
  assign n265_o = n158_o ? n218_o : 1'b0;
  /* rtl/crypto_controller.vhd:234:29  */
  assign n266_o = n158_o ? n220_o : n246_o;
  /* rtl/crypto_controller.vhd:234:29  */
  assign n267_o = n158_o ? n221_o : n248_o;
  /* rtl/crypto_controller.vhd:234:29  */
  assign n268_o = n158_o ? n222_o : iv_sel;
  /* rtl/crypto_controller.vhd:234:29  */
  assign n269_o = n158_o ? nv_cnt : n250_o;
  /* rtl/crypto_controller.vhd:234:29  */
  assign n270_o = n158_o ? n224_o : n252_o;
  /* rtl/crypto_controller.vhd:234:29  */
  assign n271_o = n158_o ? n226_o : n254_o;
  /* rtl/crypto_controller.vhd:234:29  */
  assign n272_o = n158_o ? n227_o : n255_o;
  /* rtl/crypto_controller.vhd:234:29  */
  assign n273_o = n158_o ? n229_o : n257_o;
  /* rtl/crypto_controller.vhd:234:29  */
  assign n274_o = n158_o ? n231_o : n259_o;
  /* rtl/crypto_controller.vhd:234:29  */
  assign n275_o = n158_o ? n233_o : n261_o;
  /* rtl/crypto_controller.vhd:234:29  */
  assign n276_o = n158_o ? n235_o : n263_o;
  /* rtl/crypto_controller.vhd:232:29  */
  assign n278_o = n153_o ? 1'b0 : n265_o;
  /* rtl/crypto_controller.vhd:232:29  */
  assign n280_o = n153_o ? 4'b1000 : n266_o;
  /* rtl/crypto_controller.vhd:232:29  */
  assign n281_o = n153_o ? is_dec : n267_o;
  /* rtl/crypto_controller.vhd:232:29  */
  assign n282_o = n153_o ? iv_sel : n268_o;
  /* rtl/crypto_controller.vhd:232:29  */
  assign n283_o = n153_o ? nv_cnt : n269_o;
  /* rtl/crypto_controller.vhd:232:29  */
  assign n285_o = n153_o ? 8'b11100000 : n270_o;
  /* rtl/crypto_controller.vhd:232:29  */
  assign n287_o = n153_o ? 8'b00000100 : n271_o;
  /* rtl/crypto_controller.vhd:232:29  */
  assign n288_o = n153_o ? hdr_seq : n272_o;
  /* rtl/crypto_controller.vhd:232:29  */
  assign n290_o = n153_o ? 96'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : n273_o;
  /* rtl/crypto_controller.vhd:232:29  */
  assign n292_o = n153_o ? 9'b000000001 : n274_o;
  /* rtl/crypto_controller.vhd:232:29  */
  assign n294_o = n153_o ? 1'b0 : n275_o;
  /* rtl/crypto_controller.vhd:232:29  */
  assign n296_o = n153_o ? 1'b1 : n276_o;
  /* rtl/crypto_controller.vhd:260:45  */
  assign n299_o = {5'b00010, err_code};
  /* rtl/crypto_controller.vhd:258:25  */
  assign n304_o = pkt_err ? 1'b1 : 1'b0;
  /* rtl/crypto_controller.vhd:258:25  */
  assign n306_o = pkt_err ? 4'b1000 : state;
  /* rtl/crypto_controller.vhd:258:25  */
  assign n308_o = pkt_err ? 1'b0 : held;
  /* rtl/crypto_controller.vhd:258:25  */
  assign n310_o = pkt_err ? 8'b11100000 : resp_type;
  /* rtl/crypto_controller.vhd:258:25  */
  assign n311_o = pkt_err ? n299_o : resp_code;
  /* rtl/crypto_controller.vhd:258:25  */
  assign n313_o = pkt_err ? 16'b0000000000000000 : resp_seq;
  /* rtl/crypto_controller.vhd:258:25  */
  assign n315_o = pkt_err ? 96'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : resp_nonce;
  /* rtl/crypto_controller.vhd:258:25  */
  assign n317_o = pkt_err ? 9'b000000001 : resp_len;
  /* rtl/crypto_controller.vhd:258:25  */
  assign n319_o = pkt_err ? 1'b0 : resp_has_tag;
  /* rtl/crypto_controller.vhd:258:25  */
  assign n321_o = pkt_err ? 1'b1 : resp_is_err;
  /* rtl/crypto_controller.vhd:228:25  */
  assign n323_o = pkt_valid ? 1'b0 : n304_o;
  /* rtl/crypto_controller.vhd:228:25  */
  assign n325_o = pkt_valid ? n278_o : 1'b0;
  /* rtl/crypto_controller.vhd:228:25  */
  assign n326_o = pkt_valid ? n280_o : n306_o;
  /* rtl/crypto_controller.vhd:228:25  */
  assign n327_o = pkt_valid ? n281_o : is_dec;
  /* rtl/crypto_controller.vhd:228:25  */
  assign n329_o = pkt_valid ? 1'b1 : n308_o;
  /* rtl/crypto_controller.vhd:228:25  */
  assign n330_o = pkt_valid ? n282_o : iv_sel;
  /* rtl/crypto_controller.vhd:228:25  */
  assign n332_o = pkt_valid ? 5'b00000 : di;
  /* rtl/crypto_controller.vhd:228:25  */
  assign n334_o = pkt_valid ? 5'b00000 : oi;
  /* rtl/crypto_controller.vhd:228:25  */
  assign n335_o = pkt_valid ? n283_o : nv_cnt;
  /* rtl/crypto_controller.vhd:228:25  */
  assign n336_o = pkt_valid ? n285_o : n310_o;
  /* rtl/crypto_controller.vhd:228:25  */
  assign n337_o = pkt_valid ? n287_o : n311_o;
  /* rtl/crypto_controller.vhd:228:25  */
  assign n338_o = pkt_valid ? n288_o : n313_o;
  /* rtl/crypto_controller.vhd:228:25  */
  assign n339_o = pkt_valid ? n290_o : n315_o;
  /* rtl/crypto_controller.vhd:228:25  */
  assign n340_o = pkt_valid ? n292_o : n317_o;
  /* rtl/crypto_controller.vhd:228:25  */
  assign n341_o = pkt_valid ? n294_o : n319_o;
  /* rtl/crypto_controller.vhd:228:25  */
  assign n342_o = pkt_valid ? n296_o : n321_o;
  /* rtl/crypto_controller.vhd:227:21  */
  assign n344_o = state == 4'b0000;
  /* rtl/crypto_controller.vhd:266:53  */
  assign n346_o = {32'b11000000111111111110111000000001, ctr};
  /* rtl/crypto_controller.vhd:267:53  */
  assign n348_o = {32'b11000000111111111110111000000001, ctr};
  /* rtl/crypto_controller.vhd:268:47  */
  assign n350_o = ctr + 64'b0000000000000000000000000000000000000000000000000000000000000001;
  /* rtl/crypto_controller.vhd:270:38  */
  assign n351_o = {6'b0, nv_cnt};  //  uext
  /* rtl/crypto_controller.vhd:270:38  */
  assign n353_o = n351_o == 32'b00000010111110101111000010000000;
  /* rtl/crypto_controller.vhd:273:46  */
  assign n357_o = {6'b0, nv_cnt};  //  uext
  /* rtl/crypto_controller.vhd:273:46  */
  assign n359_o = n357_o + 32'b00000000000000000000000000000001;
  /* rtl/crypto_controller.vhd:273:39  */
  assign n360_o = n359_o[25:0];  // trunc
  /* rtl/crypto_controller.vhd:270:25  */
  assign n362_o = n353_o ? 4'b1000 : state;
  /* rtl/crypto_controller.vhd:270:25  */
  assign n364_o = n353_o ? 1'b1 : held;
  /* rtl/crypto_controller.vhd:270:25  */
  assign n365_o = n353_o ? nv_cnt : n360_o;
  /* rtl/crypto_controller.vhd:270:25  */
  assign n367_o = n353_o ? 8'b11100000 : resp_type;
  /* rtl/crypto_controller.vhd:270:25  */
  assign n369_o = n353_o ? 8'b00000011 : resp_code;
  /* rtl/crypto_controller.vhd:270:25  */
  assign n370_o = n353_o ? hdr_seq : resp_seq;
  /* rtl/crypto_controller.vhd:270:25  */
  assign n372_o = n353_o ? 96'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : resp_nonce;
  /* rtl/crypto_controller.vhd:270:25  */
  assign n374_o = n353_o ? 9'b000000001 : resp_len;
  /* rtl/crypto_controller.vhd:270:25  */
  assign n376_o = n353_o ? 1'b0 : resp_has_tag;
  /* rtl/crypto_controller.vhd:270:25  */
  assign n378_o = n353_o ? 1'b1 : resp_is_err;
  /* rtl/crypto_controller.vhd:265:25  */
  assign n380_o = ctr_store_ack ? 4'b0011 : n362_o;
  /* rtl/crypto_controller.vhd:265:25  */
  assign n381_o = ctr_store_ack ? held : n364_o;
  /* rtl/crypto_controller.vhd:265:25  */
  assign n382_o = ctr_store_ack ? n350_o : n146_o;
  /* rtl/crypto_controller.vhd:265:25  */
  assign n383_o = ctr_store_ack ? n346_o : iv_sel;
  /* rtl/crypto_controller.vhd:265:25  */
  assign n384_o = ctr_store_ack ? n348_o : nonce_used;
  /* rtl/crypto_controller.vhd:265:25  */
  assign n385_o = ctr_store_ack ? nv_cnt : n365_o;
  /* rtl/crypto_controller.vhd:265:25  */
  assign n386_o = ctr_store_ack ? resp_type : n367_o;
  /* rtl/crypto_controller.vhd:265:25  */
  assign n387_o = ctr_store_ack ? resp_code : n369_o;
  /* rtl/crypto_controller.vhd:265:25  */
  assign n388_o = ctr_store_ack ? resp_seq : n370_o;
  /* rtl/crypto_controller.vhd:265:25  */
  assign n389_o = ctr_store_ack ? resp_nonce : n372_o;
  /* rtl/crypto_controller.vhd:265:25  */
  assign n390_o = ctr_store_ack ? resp_len : n374_o;
  /* rtl/crypto_controller.vhd:265:25  */
  assign n391_o = ctr_store_ack ? resp_has_tag : n376_o;
  /* rtl/crypto_controller.vhd:265:25  */
  assign n392_o = ctr_store_ack ? resp_is_err : n378_o;
  /* rtl/crypto_controller.vhd:264:21  */
  assign n394_o = state == 4'b0001;
  /* rtl/crypto_controller.vhd:287:38  */
  assign n395_o = {6'b0, nv_cnt};  //  uext
  /* rtl/crypto_controller.vhd:287:38  */
  assign n397_o = n395_o == 32'b00000010111110101111000010000000;
  /* rtl/crypto_controller.vhd:292:46  */
  assign n401_o = {6'b0, nv_cnt};  //  uext
  /* rtl/crypto_controller.vhd:292:46  */
  assign n403_o = n401_o + 32'b00000000000000000000000000000001;
  /* rtl/crypto_controller.vhd:292:39  */
  assign n404_o = n403_o[25:0];  // trunc
  /* rtl/crypto_controller.vhd:287:25  */
  assign n406_o = n397_o ? 4'b0111 : state;
  /* rtl/crypto_controller.vhd:287:25  */
  assign n408_o = n397_o ? 1'b1 : held;
  /* rtl/crypto_controller.vhd:287:25  */
  assign n410_o = n397_o ? 5'b00000 : ci;
  /* rtl/crypto_controller.vhd:287:25  */
  assign n411_o = n397_o ? nv_cnt : n404_o;
  /* rtl/crypto_controller.vhd:287:25  */
  assign n413_o = n397_o ? 8'b11100000 : resp_type;
  /* rtl/crypto_controller.vhd:287:25  */
  assign n415_o = n397_o ? 8'b00000011 : resp_code;
  /* rtl/crypto_controller.vhd:287:25  */
  assign n416_o = n397_o ? hdr_seq : resp_seq;
  /* rtl/crypto_controller.vhd:287:25  */
  assign n418_o = n397_o ? 96'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : resp_nonce;
  /* rtl/crypto_controller.vhd:287:25  */
  assign n420_o = n397_o ? 9'b000000001 : resp_len;
  /* rtl/crypto_controller.vhd:287:25  */
  assign n422_o = n397_o ? 1'b0 : resp_has_tag;
  /* rtl/crypto_controller.vhd:287:25  */
  assign n424_o = n397_o ? 1'b1 : resp_is_err;
  /* rtl/crypto_controller.vhd:277:25  */
  assign n426_o = seq_store_ack ? 4'b1000 : n406_o;
  /* rtl/crypto_controller.vhd:277:25  */
  assign n427_o = seq_store_ack ? held : n408_o;
  /* rtl/crypto_controller.vhd:277:25  */
  assign n429_o = seq_store_ack ? 1'b1 : n149_o;
  /* rtl/crypto_controller.vhd:277:25  */
  assign n430_o = seq_store_ack ? hdr_seq : n152_o;
  /* rtl/crypto_controller.vhd:277:25  */
  assign n431_o = seq_store_ack ? ci : n410_o;
  /* rtl/crypto_controller.vhd:277:25  */
  assign n432_o = seq_store_ack ? nv_cnt : n411_o;
  /* rtl/crypto_controller.vhd:277:25  */
  assign n434_o = seq_store_ack ? 8'b10000010 : n413_o;
  /* rtl/crypto_controller.vhd:277:25  */
  assign n435_o = seq_store_ack ? resp_code : n415_o;
  /* rtl/crypto_controller.vhd:277:25  */
  assign n436_o = seq_store_ack ? hdr_seq : n416_o;
  /* rtl/crypto_controller.vhd:277:25  */
  assign n437_o = seq_store_ack ? hdr_nonce : n418_o;
  /* rtl/crypto_controller.vhd:277:25  */
  assign n438_o = seq_store_ack ? hdr_len : n420_o;
  /* rtl/crypto_controller.vhd:277:25  */
  assign n440_o = seq_store_ack ? 1'b0 : n422_o;
  /* rtl/crypto_controller.vhd:277:25  */
  assign n442_o = seq_store_ack ? 1'b0 : n424_o;
  /* rtl/crypto_controller.vhd:276:21  */
  assign n444_o = state == 4'b0010;
  /* rtl/crypto_controller.vhd:295:21  */
  assign n446_o = state == 4'b0011;
  /* rtl/crypto_controller.vhd:300:34  */
  assign n447_o = oi[3:0];  // trunc
  /* rtl/crypto_controller.vhd:300:34  */
  assign n449_o = 4'b1111 - n447_o;
  /* rtl/crypto_controller.vhd:301:44  */
  assign n452_o = {27'b0, oi};  //  uext
  /* rtl/crypto_controller.vhd:301:44  */
  assign n454_o = n452_o + 32'b00000000000000000000000000000001;
  /* rtl/crypto_controller.vhd:301:41  */
  assign n455_o = n454_o[4:0];  // trunc
  /* rtl/crypto_controller.vhd:299:25  */
  assign n456_o = eng_out_valid ? n1281_o : obuf;
  /* rtl/crypto_controller.vhd:299:25  */
  assign n457_o = eng_out_valid ? n455_o : oi;
  /* rtl/crypto_controller.vhd:305:61  */
  assign n458_o = ~eng_auth_ok;
  /* rtl/crypto_controller.vhd:305:45  */
  assign n459_o = n458_o & is_dec;
  /* rtl/crypto_controller.vhd:310:29  */
  assign n465_o = is_dec ? 4'b0010 : 4'b1000;
  /* rtl/crypto_controller.vhd:310:29  */
  assign n467_o = is_dec ? 26'b00000000000000000000000000 : nv_cnt;
  /* rtl/crypto_controller.vhd:310:29  */
  assign n469_o = is_dec ? resp_type : 8'b10000001;
  /* rtl/crypto_controller.vhd:310:29  */
  assign n470_o = is_dec ? resp_seq : hdr_seq;
  /* rtl/crypto_controller.vhd:310:29  */
  assign n471_o = is_dec ? resp_nonce : nonce_used;
  /* rtl/crypto_controller.vhd:310:29  */
  assign n472_o = is_dec ? resp_len : hdr_len;
  /* rtl/crypto_controller.vhd:310:29  */
  assign n474_o = is_dec ? resp_has_tag : 1'b1;
  /* rtl/crypto_controller.vhd:310:29  */
  assign n476_o = is_dec ? resp_is_err : 1'b0;
  /* rtl/crypto_controller.vhd:310:29  */
  assign n477_o = is_dec ? resp_tag : eng_tag_out;
  /* rtl/crypto_controller.vhd:305:29  */
  assign n480_o = n459_o ? 1'b1 : 1'b0;
  /* rtl/crypto_controller.vhd:305:29  */
  assign n482_o = n459_o ? 4'b0111 : n465_o;
  /* rtl/crypto_controller.vhd:303:25  */
  assign n484_o = n516_o ? 1'b1 : held;
  /* rtl/crypto_controller.vhd:303:25  */
  assign n486_o = n518_o ? 5'b00000 : ci;
  /* rtl/crypto_controller.vhd:305:29  */
  assign n487_o = n459_o ? nv_cnt : n467_o;
  /* rtl/crypto_controller.vhd:305:29  */
  assign n489_o = n459_o ? 8'b11100000 : n469_o;
  /* rtl/crypto_controller.vhd:303:25  */
  assign n491_o = n524_o ? 8'b00000001 : resp_code;
  /* rtl/crypto_controller.vhd:305:29  */
  assign n492_o = n459_o ? hdr_seq : n470_o;
  /* rtl/crypto_controller.vhd:305:29  */
  assign n494_o = n459_o ? 96'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : n471_o;
  /* rtl/crypto_controller.vhd:305:29  */
  assign n496_o = n459_o ? 9'b000000001 : n472_o;
  /* rtl/crypto_controller.vhd:305:29  */
  assign n498_o = n459_o ? 1'b0 : n474_o;
  /* rtl/crypto_controller.vhd:305:29  */
  assign n500_o = n459_o ? 1'b1 : n476_o;
  /* rtl/crypto_controller.vhd:305:29  */
  assign n501_o = n459_o ? resp_tag : n477_o;
  /* rtl/crypto_controller.vhd:325:29  */
  assign n504_o = eng_in_is_aad ? 4'b0110 : 4'b0101;
  /* rtl/crypto_controller.vhd:325:29  */
  assign n506_o = eng_in_is_aad ? ld_i : 5'b00000;
  /* rtl/crypto_controller.vhd:325:29  */
  assign n508_o = eng_in_is_aad ? aad_block : 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
  /* rtl/crypto_controller.vhd:323:25  */
  assign n509_o = eng_in_ready ? n504_o : state;
  /* rtl/crypto_controller.vhd:323:25  */
  assign n510_o = eng_in_ready ? eng_in_is_aad : cur_aad;
  /* rtl/crypto_controller.vhd:323:25  */
  assign n511_o = eng_in_ready ? n506_o : ld_i;
  /* rtl/crypto_controller.vhd:323:25  */
  assign n512_o = eng_in_ready ? n508_o : in_reg;
  /* rtl/crypto_controller.vhd:303:25  */
  assign n514_o = eng_done ? n480_o : 1'b0;
  /* rtl/crypto_controller.vhd:303:25  */
  assign n515_o = eng_done ? n482_o : n509_o;
  /* rtl/crypto_controller.vhd:303:25  */
  assign n516_o = n459_o & eng_done;
  /* rtl/crypto_controller.vhd:303:25  */
  assign n517_o = eng_done ? cur_aad : n510_o;
  /* rtl/crypto_controller.vhd:303:25  */
  assign n518_o = n459_o & eng_done;
  /* rtl/crypto_controller.vhd:303:25  */
  assign n519_o = eng_done ? ld_i : n511_o;
  /* rtl/crypto_controller.vhd:303:25  */
  assign n520_o = eng_done ? in_reg : n512_o;
  /* rtl/crypto_controller.vhd:303:25  */
  assign n522_o = eng_done ? n487_o : nv_cnt;
  /* rtl/crypto_controller.vhd:303:25  */
  assign n523_o = eng_done ? n489_o : resp_type;
  /* rtl/crypto_controller.vhd:303:25  */
  assign n524_o = n459_o & eng_done;
  /* rtl/crypto_controller.vhd:303:25  */
  assign n525_o = eng_done ? n492_o : resp_seq;
  /* rtl/crypto_controller.vhd:303:25  */
  assign n526_o = eng_done ? n494_o : resp_nonce;
  /* rtl/crypto_controller.vhd:303:25  */
  assign n527_o = eng_done ? n496_o : resp_len;
  /* rtl/crypto_controller.vhd:303:25  */
  assign n528_o = eng_done ? n498_o : resp_has_tag;
  /* rtl/crypto_controller.vhd:303:25  */
  assign n529_o = eng_done ? n500_o : resp_is_err;
  /* rtl/crypto_controller.vhd:303:25  */
  assign n530_o = eng_done ? n501_o : resp_tag;
  /* rtl/crypto_controller.vhd:298:21  */
  assign n532_o = state == 4'b0100;
  /* rtl/crypto_controller.vhd:336:33  */
  assign n533_o = {27'b0, ld_i};  //  uext
  /* rtl/crypto_controller.vhd:336:33  */
  assign n535_o = n533_o == 32'b00000000000000000000000000010000;
  /* rtl/crypto_controller.vhd:339:35  */
  assign n536_o = {27'b0, di};  //  uext
  /* rtl/crypto_controller.vhd:339:35  */
  assign n538_o = 32'b00000000000000000000000000010000 * n536_o; // smul
  /* rtl/crypto_controller.vhd:339:40  */
  assign n539_o = {27'b0, ld_i};  //  uext
  /* rtl/crypto_controller.vhd:339:40  */
  assign n540_o = n538_o + n539_o;
  /* rtl/crypto_controller.vhd:339:47  */
  assign n541_o = {23'b0, hdr_len};  //  uext
  /* rtl/crypto_controller.vhd:339:47  */
  assign n542_o = $signed(n540_o) < $signed(n541_o);
  /* rtl/crypto_controller.vhd:340:39  */
  assign n553_o = {2'b0, ld_i};  //  uext
  /* rtl/crypto_controller.vhd:340:39  */
  assign n555_o = 7'b0001111 - n553_o;
  /* rtl/crypto_controller.vhd:339:29  */
  assign n558_o = n542_o ? n1351_o : in_reg;
  /* rtl/crypto_controller.vhd:342:42  */
  assign n559_o = {27'b0, ld_i};  //  uext
  /* rtl/crypto_controller.vhd:342:42  */
  assign n561_o = n559_o + 32'b00000000000000000000000000000001;
  /* rtl/crypto_controller.vhd:342:37  */
  assign n562_o = n561_o[4:0];  // trunc
  /* rtl/crypto_controller.vhd:336:25  */
  assign n564_o = n535_o ? 4'b0110 : state;
  /* rtl/crypto_controller.vhd:336:25  */
  assign n565_o = n535_o ? ld_i : n562_o;
  /* rtl/crypto_controller.vhd:336:25  */
  assign n566_o = n535_o ? in_reg : n558_o;
  /* rtl/crypto_controller.vhd:335:21  */
  assign n568_o = state == 4'b0101;
  /* rtl/crypto_controller.vhd:347:40  */
  assign n569_o = ~cur_aad;
  /* rtl/crypto_controller.vhd:347:60  */
  assign n570_o = {27'b0, di};  //  uext
  /* rtl/crypto_controller.vhd:347:60  */
  assign n572_o = n570_o + 32'b00000000000000000000000000000001;
  /* rtl/crypto_controller.vhd:347:57  */
  assign n573_o = n572_o[4:0];  // trunc
  /* rtl/crypto_controller.vhd:346:25  */
  assign n574_o = n577_o ? n573_o : di;
  /* rtl/crypto_controller.vhd:346:25  */
  assign n576_o = eng_in_ready ? 4'b0100 : state;
  /* rtl/crypto_controller.vhd:346:25  */
  assign n577_o = n569_o & eng_in_ready;
  /* rtl/crypto_controller.vhd:345:21  */
  assign n579_o = state == 4'b0110;
  /* rtl/crypto_controller.vhd:352:30  */
  assign n580_o = ci[3:0];  // trunc
  /* rtl/crypto_controller.vhd:352:30  */
  assign n582_o = 4'b1111 - n580_o;
  /* rtl/crypto_controller.vhd:353:31  */
  assign n586_o = {27'b0, ci};  //  uext
  /* rtl/crypto_controller.vhd:353:31  */
  assign n588_o = n586_o == 32'b00000000000000000000000000001111;
  /* rtl/crypto_controller.vhd:356:38  */
  assign n589_o = {27'b0, ci};  //  uext
  /* rtl/crypto_controller.vhd:356:38  */
  assign n591_o = n589_o + 32'b00000000000000000000000000000001;
  /* rtl/crypto_controller.vhd:356:35  */
  assign n592_o = n591_o[4:0];  // trunc
  /* rtl/crypto_controller.vhd:353:25  */
  assign n594_o = n588_o ? 4'b1000 : state;
  /* rtl/crypto_controller.vhd:353:25  */
  assign n595_o = n588_o ? ci : n592_o;
  /* rtl/crypto_controller.vhd:351:21  */
  assign n597_o = state == 4'b0111;
  /* rtl/crypto_controller.vhd:359:21  */
  assign n599_o = state == 4'b1000;
  /* rtl/crypto_controller.vhd:193:13  */
  assign n605_o = held ? 4'b1010 : 4'b0000;
  /* rtl/crypto_controller.vhd:363:25  */
  assign n606_o = bld_done ? n605_o : state;
  /* rtl/crypto_controller.vhd:362:21  */
  assign n608_o = state == 4'b1001;
  /* rtl/crypto_controller.vhd:367:21  */
  assign n610_o = state == 4'b1010;
  assign n611_o = {n610_o, n608_o, n599_o, n597_o, n579_o, n568_o, n532_o, n446_o, n444_o, n394_o, n344_o};
  /* rtl/crypto_controller.vhd:226:17  */
  always @*
    case (n611_o)
      11'b10000000000: n614_o = 1'b0;
      11'b01000000000: n614_o = 1'b0;
      11'b00100000000: n614_o = 1'b0;
      11'b00010000000: n614_o = 1'b0;
      11'b00001000000: n614_o = 1'b0;
      11'b00000100000: n614_o = 1'b0;
      11'b00000010000: n614_o = 1'b0;
      11'b00000001000: n614_o = 1'b0;
      11'b00000000100: n614_o = 1'b0;
      11'b00000000010: n614_o = 1'b0;
      11'b00000000001: n614_o = n323_o;
      default: n614_o = 1'bX;
    endcase
  /* rtl/crypto_controller.vhd:226:17  */
  always @*
    case (n611_o)
      11'b10000000000: n617_o = 1'b0;
      11'b01000000000: n617_o = 1'b0;
      11'b00100000000: n617_o = 1'b0;
      11'b00010000000: n617_o = 1'b0;
      11'b00001000000: n617_o = 1'b0;
      11'b00000100000: n617_o = 1'b0;
      11'b00000010000: n617_o = n514_o;
      11'b00000001000: n617_o = 1'b0;
      11'b00000000100: n617_o = 1'b0;
      11'b00000000010: n617_o = 1'b0;
      11'b00000000001: n617_o = 1'b0;
      default: n617_o = 1'bX;
    endcase
  /* rtl/crypto_controller.vhd:226:17  */
  always @*
    case (n611_o)
      11'b10000000000: n620_o = 1'b0;
      11'b01000000000: n620_o = 1'b0;
      11'b00100000000: n620_o = 1'b0;
      11'b00010000000: n620_o = 1'b0;
      11'b00001000000: n620_o = 1'b0;
      11'b00000100000: n620_o = 1'b0;
      11'b00000010000: n620_o = 1'b0;
      11'b00000001000: n620_o = 1'b0;
      11'b00000000100: n620_o = 1'b0;
      11'b00000000010: n620_o = 1'b0;
      11'b00000000001: n620_o = n325_o;
      default: n620_o = 1'bX;
    endcase
  /* rtl/crypto_controller.vhd:226:17  */
  always @*
    case (n611_o)
      11'b10000000000: n625_o = 4'b0000;
      11'b01000000000: n625_o = n606_o;
      11'b00100000000: n625_o = 4'b1001;
      11'b00010000000: n625_o = n594_o;
      11'b00001000000: n625_o = n576_o;
      11'b00000100000: n625_o = n564_o;
      11'b00000010000: n625_o = n515_o;
      11'b00000001000: n625_o = 4'b0100;
      11'b00000000100: n625_o = n426_o;
      11'b00000000010: n625_o = n380_o;
      11'b00000000001: n625_o = n326_o;
      default: n625_o = 4'bX;
    endcase
  /* rtl/crypto_controller.vhd:226:17  */
  always @*
    case (n611_o)
      11'b10000000000: n627_o = obuf;
      11'b01000000000: n627_o = obuf;
      11'b00100000000: n627_o = obuf;
      11'b00010000000: n627_o = n1420_o;
      11'b00001000000: n627_o = obuf;
      11'b00000100000: n627_o = obuf;
      11'b00000010000: n627_o = n456_o;
      11'b00000001000: n627_o = obuf;
      11'b00000000100: n627_o = obuf;
      11'b00000000010: n627_o = obuf;
      11'b00000000001: n627_o = obuf;
      default: n627_o = 2048'bX;
    endcase
  /* rtl/crypto_controller.vhd:226:17  */
  always @*
    case (n611_o)
      11'b10000000000: n629_o = is_dec;
      11'b01000000000: n629_o = is_dec;
      11'b00100000000: n629_o = is_dec;
      11'b00010000000: n629_o = is_dec;
      11'b00001000000: n629_o = is_dec;
      11'b00000100000: n629_o = is_dec;
      11'b00000010000: n629_o = is_dec;
      11'b00000001000: n629_o = is_dec;
      11'b00000000100: n629_o = is_dec;
      11'b00000000010: n629_o = is_dec;
      11'b00000000001: n629_o = n327_o;
      default: n629_o = 1'bX;
    endcase
  /* rtl/crypto_controller.vhd:226:17  */
  always @*
    case (n611_o)
      11'b10000000000: n632_o = 1'b0;
      11'b01000000000: n632_o = held;
      11'b00100000000: n632_o = held;
      11'b00010000000: n632_o = held;
      11'b00001000000: n632_o = held;
      11'b00000100000: n632_o = held;
      11'b00000010000: n632_o = n484_o;
      11'b00000001000: n632_o = held;
      11'b00000000100: n632_o = n427_o;
      11'b00000000010: n632_o = n381_o;
      11'b00000000001: n632_o = n329_o;
      default: n632_o = 1'bX;
    endcase
  /* rtl/crypto_controller.vhd:226:17  */
  always @*
    case (n611_o)
      11'b10000000000: n634_o = cur_aad;
      11'b01000000000: n634_o = cur_aad;
      11'b00100000000: n634_o = cur_aad;
      11'b00010000000: n634_o = cur_aad;
      11'b00001000000: n634_o = cur_aad;
      11'b00000100000: n634_o = cur_aad;
      11'b00000010000: n634_o = n517_o;
      11'b00000001000: n634_o = cur_aad;
      11'b00000000100: n634_o = cur_aad;
      11'b00000000010: n634_o = cur_aad;
      11'b00000000001: n634_o = cur_aad;
      default: n634_o = 1'bX;
    endcase
  /* rtl/crypto_controller.vhd:226:17  */
  always @*
    case (n611_o)
      11'b10000000000: n636_o = n149_o;
      11'b01000000000: n636_o = n149_o;
      11'b00100000000: n636_o = n149_o;
      11'b00010000000: n636_o = n149_o;
      11'b00001000000: n636_o = n149_o;
      11'b00000100000: n636_o = n149_o;
      11'b00000010000: n636_o = n149_o;
      11'b00000001000: n636_o = n149_o;
      11'b00000000100: n636_o = n429_o;
      11'b00000000010: n636_o = n149_o;
      11'b00000000001: n636_o = n149_o;
      default: n636_o = 1'bX;
    endcase
  /* rtl/crypto_controller.vhd:226:17  */
  always @*
    case (n611_o)
      11'b10000000000: n638_o = n152_o;
      11'b01000000000: n638_o = n152_o;
      11'b00100000000: n638_o = n152_o;
      11'b00010000000: n638_o = n152_o;
      11'b00001000000: n638_o = n152_o;
      11'b00000100000: n638_o = n152_o;
      11'b00000010000: n638_o = n152_o;
      11'b00000001000: n638_o = n152_o;
      11'b00000000100: n638_o = n430_o;
      11'b00000000010: n638_o = n152_o;
      11'b00000000001: n638_o = n152_o;
      default: n638_o = 16'bX;
    endcase
  /* rtl/crypto_controller.vhd:226:17  */
  always @*
    case (n611_o)
      11'b10000000000: n640_o = n146_o;
      11'b01000000000: n640_o = n146_o;
      11'b00100000000: n640_o = n146_o;
      11'b00010000000: n640_o = n146_o;
      11'b00001000000: n640_o = n146_o;
      11'b00000100000: n640_o = n146_o;
      11'b00000010000: n640_o = n146_o;
      11'b00000001000: n640_o = n146_o;
      11'b00000000100: n640_o = n146_o;
      11'b00000000010: n640_o = n382_o;
      11'b00000000001: n640_o = n146_o;
      default: n640_o = 64'bX;
    endcase
  /* rtl/crypto_controller.vhd:226:17  */
  always @*
    case (n611_o)
      11'b10000000000: n642_o = iv_sel;
      11'b01000000000: n642_o = iv_sel;
      11'b00100000000: n642_o = iv_sel;
      11'b00010000000: n642_o = iv_sel;
      11'b00001000000: n642_o = iv_sel;
      11'b00000100000: n642_o = iv_sel;
      11'b00000010000: n642_o = iv_sel;
      11'b00000001000: n642_o = iv_sel;
      11'b00000000100: n642_o = iv_sel;
      11'b00000000010: n642_o = n383_o;
      11'b00000000001: n642_o = n330_o;
      default: n642_o = 96'bX;
    endcase
  /* rtl/crypto_controller.vhd:226:17  */
  always @*
    case (n611_o)
      11'b10000000000: n644_o = nonce_used;
      11'b01000000000: n644_o = nonce_used;
      11'b00100000000: n644_o = nonce_used;
      11'b00010000000: n644_o = nonce_used;
      11'b00001000000: n644_o = nonce_used;
      11'b00000100000: n644_o = nonce_used;
      11'b00000010000: n644_o = nonce_used;
      11'b00000001000: n644_o = nonce_used;
      11'b00000000100: n644_o = nonce_used;
      11'b00000000010: n644_o = n384_o;
      11'b00000000001: n644_o = nonce_used;
      default: n644_o = 96'bX;
    endcase
  /* rtl/crypto_controller.vhd:226:17  */
  always @*
    case (n611_o)
      11'b10000000000: n646_o = di;
      11'b01000000000: n646_o = di;
      11'b00100000000: n646_o = di;
      11'b00010000000: n646_o = di;
      11'b00001000000: n646_o = n574_o;
      11'b00000100000: n646_o = di;
      11'b00000010000: n646_o = di;
      11'b00000001000: n646_o = di;
      11'b00000000100: n646_o = di;
      11'b00000000010: n646_o = di;
      11'b00000000001: n646_o = n332_o;
      default: n646_o = 5'bX;
    endcase
  /* rtl/crypto_controller.vhd:226:17  */
  always @*
    case (n611_o)
      11'b10000000000: n648_o = oi;
      11'b01000000000: n648_o = oi;
      11'b00100000000: n648_o = oi;
      11'b00010000000: n648_o = oi;
      11'b00001000000: n648_o = oi;
      11'b00000100000: n648_o = oi;
      11'b00000010000: n648_o = n457_o;
      11'b00000001000: n648_o = oi;
      11'b00000000100: n648_o = oi;
      11'b00000000010: n648_o = oi;
      11'b00000000001: n648_o = n334_o;
      default: n648_o = 5'bX;
    endcase
  /* rtl/crypto_controller.vhd:226:17  */
  always @*
    case (n611_o)
      11'b10000000000: n650_o = ci;
      11'b01000000000: n650_o = ci;
      11'b00100000000: n650_o = ci;
      11'b00010000000: n650_o = n595_o;
      11'b00001000000: n650_o = ci;
      11'b00000100000: n650_o = ci;
      11'b00000010000: n650_o = n486_o;
      11'b00000001000: n650_o = ci;
      11'b00000000100: n650_o = n431_o;
      11'b00000000010: n650_o = ci;
      11'b00000000001: n650_o = ci;
      default: n650_o = 5'bX;
    endcase
  /* rtl/crypto_controller.vhd:226:17  */
  always @*
    case (n611_o)
      11'b10000000000: n652_o = ld_i;
      11'b01000000000: n652_o = ld_i;
      11'b00100000000: n652_o = ld_i;
      11'b00010000000: n652_o = ld_i;
      11'b00001000000: n652_o = ld_i;
      11'b00000100000: n652_o = n565_o;
      11'b00000010000: n652_o = n519_o;
      11'b00000001000: n652_o = ld_i;
      11'b00000000100: n652_o = ld_i;
      11'b00000000010: n652_o = ld_i;
      11'b00000000001: n652_o = ld_i;
      default: n652_o = 5'bX;
    endcase
  /* rtl/crypto_controller.vhd:226:17  */
  always @*
    case (n611_o)
      11'b10000000000: n654_o = in_reg;
      11'b01000000000: n654_o = in_reg;
      11'b00100000000: n654_o = in_reg;
      11'b00010000000: n654_o = in_reg;
      11'b00001000000: n654_o = in_reg;
      11'b00000100000: n654_o = n566_o;
      11'b00000010000: n654_o = n520_o;
      11'b00000001000: n654_o = in_reg;
      11'b00000000100: n654_o = in_reg;
      11'b00000000010: n654_o = in_reg;
      11'b00000000001: n654_o = in_reg;
      default: n654_o = 128'bX;
    endcase
  /* rtl/crypto_controller.vhd:226:17  */
  always @*
    case (n611_o)
      11'b10000000000: n658_o = nv_cnt;
      11'b01000000000: n658_o = nv_cnt;
      11'b00100000000: n658_o = nv_cnt;
      11'b00010000000: n658_o = nv_cnt;
      11'b00001000000: n658_o = nv_cnt;
      11'b00000100000: n658_o = nv_cnt;
      11'b00000010000: n658_o = n522_o;
      11'b00000001000: n658_o = nv_cnt;
      11'b00000000100: n658_o = n432_o;
      11'b00000000010: n658_o = n385_o;
      11'b00000000001: n658_o = n335_o;
      default: n658_o = 26'bX;
    endcase
  /* rtl/crypto_controller.vhd:226:17  */
  always @*
    case (n611_o)
      11'b10000000000: n660_o = resp_type;
      11'b01000000000: n660_o = resp_type;
      11'b00100000000: n660_o = resp_type;
      11'b00010000000: n660_o = resp_type;
      11'b00001000000: n660_o = resp_type;
      11'b00000100000: n660_o = resp_type;
      11'b00000010000: n660_o = n523_o;
      11'b00000001000: n660_o = resp_type;
      11'b00000000100: n660_o = n434_o;
      11'b00000000010: n660_o = n386_o;
      11'b00000000001: n660_o = n336_o;
      default: n660_o = 8'bX;
    endcase
  /* rtl/crypto_controller.vhd:226:17  */
  always @*
    case (n611_o)
      11'b10000000000: n662_o = resp_code;
      11'b01000000000: n662_o = resp_code;
      11'b00100000000: n662_o = resp_code;
      11'b00010000000: n662_o = resp_code;
      11'b00001000000: n662_o = resp_code;
      11'b00000100000: n662_o = resp_code;
      11'b00000010000: n662_o = n491_o;
      11'b00000001000: n662_o = resp_code;
      11'b00000000100: n662_o = n435_o;
      11'b00000000010: n662_o = n387_o;
      11'b00000000001: n662_o = n337_o;
      default: n662_o = 8'bX;
    endcase
  /* rtl/crypto_controller.vhd:226:17  */
  always @*
    case (n611_o)
      11'b10000000000: n664_o = resp_seq;
      11'b01000000000: n664_o = resp_seq;
      11'b00100000000: n664_o = resp_seq;
      11'b00010000000: n664_o = resp_seq;
      11'b00001000000: n664_o = resp_seq;
      11'b00000100000: n664_o = resp_seq;
      11'b00000010000: n664_o = n525_o;
      11'b00000001000: n664_o = resp_seq;
      11'b00000000100: n664_o = n436_o;
      11'b00000000010: n664_o = n388_o;
      11'b00000000001: n664_o = n338_o;
      default: n664_o = 16'bX;
    endcase
  /* rtl/crypto_controller.vhd:226:17  */
  always @*
    case (n611_o)
      11'b10000000000: n666_o = resp_nonce;
      11'b01000000000: n666_o = resp_nonce;
      11'b00100000000: n666_o = resp_nonce;
      11'b00010000000: n666_o = resp_nonce;
      11'b00001000000: n666_o = resp_nonce;
      11'b00000100000: n666_o = resp_nonce;
      11'b00000010000: n666_o = n526_o;
      11'b00000001000: n666_o = resp_nonce;
      11'b00000000100: n666_o = n437_o;
      11'b00000000010: n666_o = n389_o;
      11'b00000000001: n666_o = n339_o;
      default: n666_o = 96'bX;
    endcase
  /* rtl/crypto_controller.vhd:226:17  */
  always @*
    case (n611_o)
      11'b10000000000: n668_o = resp_len;
      11'b01000000000: n668_o = resp_len;
      11'b00100000000: n668_o = resp_len;
      11'b00010000000: n668_o = resp_len;
      11'b00001000000: n668_o = resp_len;
      11'b00000100000: n668_o = resp_len;
      11'b00000010000: n668_o = n527_o;
      11'b00000001000: n668_o = resp_len;
      11'b00000000100: n668_o = n438_o;
      11'b00000000010: n668_o = n390_o;
      11'b00000000001: n668_o = n340_o;
      default: n668_o = 9'bX;
    endcase
  /* rtl/crypto_controller.vhd:226:17  */
  always @*
    case (n611_o)
      11'b10000000000: n670_o = resp_has_tag;
      11'b01000000000: n670_o = resp_has_tag;
      11'b00100000000: n670_o = resp_has_tag;
      11'b00010000000: n670_o = resp_has_tag;
      11'b00001000000: n670_o = resp_has_tag;
      11'b00000100000: n670_o = resp_has_tag;
      11'b00000010000: n670_o = n528_o;
      11'b00000001000: n670_o = resp_has_tag;
      11'b00000000100: n670_o = n440_o;
      11'b00000000010: n670_o = n391_o;
      11'b00000000001: n670_o = n341_o;
      default: n670_o = 1'bX;
    endcase
  /* rtl/crypto_controller.vhd:226:17  */
  always @*
    case (n611_o)
      11'b10000000000: n672_o = resp_is_err;
      11'b01000000000: n672_o = resp_is_err;
      11'b00100000000: n672_o = resp_is_err;
      11'b00010000000: n672_o = resp_is_err;
      11'b00001000000: n672_o = resp_is_err;
      11'b00000100000: n672_o = resp_is_err;
      11'b00000010000: n672_o = n529_o;
      11'b00000001000: n672_o = resp_is_err;
      11'b00000000100: n672_o = n442_o;
      11'b00000000010: n672_o = n392_o;
      11'b00000000001: n672_o = n342_o;
      default: n672_o = 1'bX;
    endcase
  /* rtl/crypto_controller.vhd:226:17  */
  always @*
    case (n611_o)
      11'b10000000000: n674_o = resp_tag;
      11'b01000000000: n674_o = resp_tag;
      11'b00100000000: n674_o = resp_tag;
      11'b00010000000: n674_o = resp_tag;
      11'b00001000000: n674_o = resp_tag;
      11'b00000100000: n674_o = resp_tag;
      11'b00000010000: n674_o = n530_o;
      11'b00000001000: n674_o = resp_tag;
      11'b00000000100: n674_o = resp_tag;
      11'b00000000010: n674_o = resp_tag;
      11'b00000000001: n674_o = resp_tag;
      default: n674_o = 128'bX;
    endcase
  /* rtl/crypto_controller.vhd:201:13  */
  assign n676_o = rst ? 1'b0 : n614_o;
  /* rtl/crypto_controller.vhd:201:13  */
  assign n679_o = rst ? 1'b0 : n617_o;
  /* rtl/crypto_controller.vhd:201:13  */
  assign n682_o = rst ? 1'b0 : n620_o;
  /* rtl/crypto_controller.vhd:201:13  */
  assign n685_o = rst ? 4'b0000 : n625_o;
  /* rtl/crypto_controller.vhd:201:13  */
  assign n686_o = rst ? obuf : n627_o;
  /* rtl/crypto_controller.vhd:201:13  */
  assign n688_o = rst ? 1'b0 : n629_o;
  /* rtl/crypto_controller.vhd:201:13  */
  assign n690_o = rst ? 1'b0 : n632_o;
  /* rtl/crypto_controller.vhd:201:13  */
  assign n692_o = rst ? 1'b0 : n634_o;
  /* rtl/crypto_controller.vhd:201:13  */
  assign n694_o = rst ? 1'b0 : n636_o;
  /* rtl/crypto_controller.vhd:201:13  */
  assign n696_o = rst ? 1'b0 : n145_o;
  /* rtl/crypto_controller.vhd:201:13  */
  assign n698_o = rst ? 1'b0 : n151_o;
  /* rtl/crypto_controller.vhd:201:13  */
  assign n700_o = rst ? 16'b0000000000000000 : n638_o;
  /* rtl/crypto_controller.vhd:201:13  */
  assign n701_o = rst ? ctr : n640_o;
  /* rtl/crypto_controller.vhd:201:13  */
  assign n702_o = rst ? iv_sel : n642_o;
  /* rtl/crypto_controller.vhd:201:13  */
  assign n703_o = rst ? nonce_used : n644_o;
  /* rtl/crypto_controller.vhd:201:13  */
  assign n705_o = rst ? 5'b00000 : n646_o;
  /* rtl/crypto_controller.vhd:201:13  */
  assign n707_o = rst ? 5'b00000 : n648_o;
  /* rtl/crypto_controller.vhd:201:13  */
  assign n709_o = rst ? 5'b00000 : n650_o;
  /* rtl/crypto_controller.vhd:201:13  */
  assign n711_o = rst ? 5'b00000 : n652_o;
  /* rtl/crypto_controller.vhd:201:13  */
  assign n712_o = rst ? in_reg : n654_o;
  /* rtl/crypto_controller.vhd:201:13  */
  assign n715_o = rst ? 26'b00000000000000000000000000 : n658_o;
  /* rtl/crypto_controller.vhd:201:13  */
  assign n716_o = rst ? resp_type : n660_o;
  /* rtl/crypto_controller.vhd:201:13  */
  assign n717_o = rst ? resp_code : n662_o;
  /* rtl/crypto_controller.vhd:201:13  */
  assign n718_o = rst ? resp_seq : n664_o;
  /* rtl/crypto_controller.vhd:201:13  */
  assign n719_o = rst ? resp_nonce : n666_o;
  /* rtl/crypto_controller.vhd:201:13  */
  assign n720_o = rst ? resp_len : n668_o;
  /* rtl/crypto_controller.vhd:201:13  */
  assign n721_o = rst ? resp_has_tag : n670_o;
  /* rtl/crypto_controller.vhd:201:13  */
  assign n722_o = rst ? resp_is_err : n672_o;
  /* rtl/crypto_controller.vhd:201:13  */
  assign n723_o = rst ? resp_tag : n674_o;
  /* rtl/crypto_controller.vhd:196:9  */
  always @(posedge clk)
    n755_q <= n685_o;
  initial
    n755_q = 4'b0000;
  /* rtl/crypto_controller.vhd:196:9  */
  always @(posedge clk)
    n756_q <= n686_o;
  initial
    n756_q = 2048'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
  /* rtl/crypto_controller.vhd:196:9  */
  always @(posedge clk)
    n757_q <= n688_o;
  initial
    n757_q = 1'b0;
  /* rtl/crypto_controller.vhd:196:9  */
  always @(posedge clk)
    n758_q <= n690_o;
  initial
    n758_q = 1'b0;
  /* rtl/crypto_controller.vhd:196:9  */
  always @(posedge clk)
    n759_q <= n692_o;
  initial
    n759_q = 1'b0;
  /* rtl/crypto_controller.vhd:196:9  */
  always @(posedge clk)
    n760_q <= n694_o;
  initial
    n760_q = 1'b0;
  /* rtl/crypto_controller.vhd:196:9  */
  always @(posedge clk)
    n761_q <= n696_o;
  initial
    n761_q = 1'b0;
  /* rtl/crypto_controller.vhd:196:9  */
  always @(posedge clk)
    n762_q <= n698_o;
  initial
    n762_q = 1'b0;
  /* rtl/crypto_controller.vhd:196:9  */
  always @(posedge clk)
    n763_q <= n700_o;
  initial
    n763_q = 16'b0000000000000000;
  /* rtl/crypto_controller.vhd:196:9  */
  always @(posedge clk)
    n764_q <= n701_o;
  initial
    n764_q = 64'b0000000000000000000000000000000000000000000000000000000000000000;
  /* rtl/crypto_controller.vhd:196:9  */
  always @(posedge clk)
    n765_q <= n702_o;
  initial
    n765_q = 96'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
  /* rtl/crypto_controller.vhd:196:9  */
  always @(posedge clk)
    n766_q <= n703_o;
  initial
    n766_q = 96'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
  /* rtl/crypto_controller.vhd:196:9  */
  always @(posedge clk)
    n767_q <= n705_o;
  initial
    n767_q = 5'b00000;
  /* rtl/crypto_controller.vhd:196:9  */
  always @(posedge clk)
    n768_q <= n707_o;
  initial
    n768_q = 5'b00000;
  /* rtl/crypto_controller.vhd:196:9  */
  always @(posedge clk)
    n769_q <= n709_o;
  initial
    n769_q = 5'b00000;
  /* rtl/crypto_controller.vhd:196:9  */
  always @(posedge clk)
    n770_q <= n711_o;
  initial
    n770_q = 5'b00000;
  /* rtl/crypto_controller.vhd:196:9  */
  always @(posedge clk)
    n771_q <= n712_o;
  initial
    n771_q = 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
  /* rtl/crypto_controller.vhd:196:9  */
  always @(posedge clk)
    n773_q <= n715_o;
  initial
    n773_q = 26'b00000000000000000000000000;
  /* rtl/crypto_controller.vhd:196:9  */
  always @(posedge clk)
    n774_q <= n716_o;
  initial
    n774_q = 8'b00000000;
  /* rtl/crypto_controller.vhd:196:9  */
  always @(posedge clk)
    n775_q <= n717_o;
  initial
    n775_q = 8'b00000000;
  /* rtl/crypto_controller.vhd:196:9  */
  always @(posedge clk)
    n776_q <= n718_o;
  initial
    n776_q = 16'b0000000000000000;
  /* rtl/crypto_controller.vhd:196:9  */
  always @(posedge clk)
    n777_q <= n719_o;
  initial
    n777_q = 96'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
  /* rtl/crypto_controller.vhd:196:9  */
  always @(posedge clk)
    n778_q <= n720_o;
  initial
    n778_q = 9'b000000000;
  /* rtl/crypto_controller.vhd:196:9  */
  always @(posedge clk)
    n779_q <= n721_o;
  initial
    n779_q = 1'b0;
  /* rtl/crypto_controller.vhd:196:9  */
  always @(posedge clk)
    n780_q <= n722_o;
  initial
    n780_q = 1'b0;
  /* rtl/crypto_controller.vhd:196:9  */
  always @(posedge clk)
    n781_q <= n723_o;
  initial
    n781_q = 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
  /* rtl/crypto_controller.vhd:196:9  */
  always @(posedge clk)
    n782_q <= n676_o;
  /* rtl/crypto_controller.vhd:196:9  */
  always @(posedge clk)
    n783_q <= n679_o;
  /* rtl/crypto_controller.vhd:196:9  */
  always @(posedge clk)
    n784_q <= n682_o;
  /* rtl/crypto_controller.vhd:173:49  */
  assign n785_o = obuf[7:0];
  /* rtl/crypto_controller.vhd:173:28  */
  assign n786_o = obuf[15:8];
  /* rtl/crypto_controller.vhd:172:51  */
  assign n787_o = obuf[23:16];
  /* rtl/crypto_controller.vhd:172:30  */
  assign n788_o = obuf[31:24];
  /* rtl/crypto_controller.vhd:168:85  */
  assign n789_o = obuf[39:32];
  /* rtl/crypto_controller.vhd:101:9  */
  assign n790_o = obuf[47:40];
  /* rtl/crypto_controller.vhd:100:9  */
  assign n791_o = obuf[55:48];
  /* rtl/crypto_controller.vhd:99:9  */
  assign n792_o = obuf[63:56];
  /* rtl/crypto_controller.vhd:98:9  */
  assign n793_o = obuf[71:64];
  /* rtl/crypto_controller.vhd:94:9  */
  assign n794_o = obuf[79:72];
  /* rtl/crypto_controller.vhd:93:9  */
  assign n795_o = obuf[87:80];
  /* rtl/crypto_controller.vhd:85:9  */
  assign n796_o = obuf[95:88];
  /* rtl/crypto_controller.vhd:84:9  */
  assign n797_o = obuf[103:96];
  /* rtl/crypto_controller.vhd:81:9  */
  assign n798_o = obuf[111:104];
  /* rtl/crypto_controller.vhd:80:9  */
  assign n799_o = obuf[119:112];
  /* rtl/crypto_controller.vhd:79:9  */
  assign n800_o = obuf[127:120];
  /* rtl/crypto_controller.vhd:78:9  */
  assign n801_o = obuf[135:128];
  /* rtl/crypto_controller.vhd:77:9  */
  assign n802_o = obuf[143:136];
  /* rtl/crypto_controller.vhd:76:9  */
  assign n803_o = obuf[151:144];
  /* rtl/crypto_controller.vhd:75:9  */
  assign n804_o = obuf[159:152];
  /* rtl/crypto_controller.vhd:71:9  */
  assign n805_o = obuf[167:160];
  /* rtl/crypto_controller.vhd:70:9  */
  assign n806_o = obuf[175:168];
  /* rtl/crypto_controller.vhd:63:9  */
  assign n807_o = obuf[183:176];
  /* rtl/crypto_controller.vhd:62:9  */
  assign n808_o = obuf[191:184];
  /* rtl/crypto_controller.vhd:52:9  */
  assign n809_o = obuf[199:192];
  /* rtl/crypto_controller.vhd:44:9  */
  assign n810_o = obuf[207:200];
  /* rtl/crypto_controller.vhd:196:9  */
  assign n811_o = obuf[215:208];
  assign n812_o = obuf[223:216];
  /* rtl/crypto_controller.vhd:201:13  */
  assign n813_o = obuf[231:224];
  assign n814_o = obuf[239:232];
  assign n815_o = obuf[247:240];
  assign n816_o = obuf[255:248];
  /* rtl/crypto_controller.vhd:226:17  */
  assign n817_o = obuf[263:256];
  assign n818_o = obuf[271:264];
  /* rtl/crypto_controller.vhd:191:19  */
  assign n819_o = obuf[279:272];
  /* rtl/crypto_controller.vhd:191:19  */
  assign n820_o = obuf[287:280];
  /* rtl/crypto_controller.vhd:340:66  */
  assign n821_o = obuf[295:288];
  assign n822_o = obuf[303:296];
  /* rtl/crypto_controller.vhd:340:70  */
  assign n823_o = obuf[311:304];
  assign n824_o = obuf[319:312];
  /* rtl/crypto_controller.vhd:340:70  */
  assign n825_o = obuf[327:320];
  /* rtl/crypto_controller.vhd:340:44  */
  assign n826_o = obuf[335:328];
  assign n827_o = obuf[343:336];
  /* rtl/crypto_controller.vhd:340:48  */
  assign n828_o = obuf[351:344];
  assign n829_o = obuf[359:352];
  /* rtl/crypto_controller.vhd:340:48  */
  assign n830_o = obuf[367:360];
  /* rtl/crypto_controller.vhd:303:25  */
  assign n831_o = obuf[375:368];
  /* rtl/crypto_controller.vhd:177:19  */
  assign n832_o = obuf[383:376];
  /* rtl/crypto_controller.vhd:177:19  */
  assign n833_o = obuf[391:384];
  /* rtl/crypto_controller.vhd:177:19  */
  assign n834_o = obuf[399:392];
  /* rtl/crypto_controller.vhd:177:19  */
  assign n835_o = obuf[407:400];
  /* rtl/crypto_controller.vhd:177:19  */
  assign n836_o = obuf[415:408];
  /* rtl/crypto_controller.vhd:177:19  */
  assign n837_o = obuf[423:416];
  /* rtl/crypto_controller.vhd:177:19  */
  assign n838_o = obuf[431:424];
  /* rtl/crypto_controller.vhd:177:19  */
  assign n839_o = obuf[439:432];
  /* rtl/crypto_controller.vhd:177:19  */
  assign n840_o = obuf[447:440];
  /* rtl/crypto_controller.vhd:177:19  */
  assign n841_o = obuf[455:448];
  /* rtl/crypto_controller.vhd:177:19  */
  assign n842_o = obuf[463:456];
  /* rtl/crypto_controller.vhd:177:19  */
  assign n843_o = obuf[471:464];
  /* rtl/crypto_controller.vhd:177:19  */
  assign n844_o = obuf[479:472];
  /* rtl/crypto_controller.vhd:177:19  */
  assign n845_o = obuf[487:480];
  /* rtl/crypto_controller.vhd:177:19  */
  assign n846_o = obuf[495:488];
  /* rtl/crypto_controller.vhd:177:19  */
  assign n847_o = obuf[503:496];
  /* rtl/crypto_controller.vhd:177:19  */
  assign n848_o = obuf[511:504];
  /* rtl/crypto_controller.vhd:177:19  */
  assign n849_o = obuf[519:512];
  /* rtl/crypto_controller.vhd:176:5  */
  assign n850_o = obuf[527:520];
  /* rtl/crypto_controller.vhd:164:62  */
  assign n851_o = obuf[535:528];
  assign n852_o = obuf[543:536];
  /* rtl/crypto_controller.vhd:164:66  */
  assign n853_o = obuf[551:544];
  assign n854_o = obuf[559:552];
  /* rtl/crypto_controller.vhd:164:66  */
  assign n855_o = obuf[567:560];
  /* rtl/crypto_controller.vhd:164:36  */
  assign n856_o = obuf[575:568];
  assign n857_o = obuf[583:576];
  /* rtl/crypto_controller.vhd:164:40  */
  assign n858_o = obuf[591:584];
  assign n859_o = obuf[599:592];
  /* rtl/crypto_controller.vhd:164:40  */
  assign n860_o = obuf[607:600];
  /* rtl/crypto_controller.vhd:140:47  */
  assign n861_o = obuf[615:608];
  /* rtl/crypto_controller.vhd:121:20  */
  assign n862_o = obuf[623:616];
  assign n863_o = obuf[631:624];
  /* rtl/crypto_controller.vhd:196:9  */
  assign n864_o = obuf[639:632];
  assign n865_o = obuf[647:640];
  assign n866_o = obuf[655:648];
  assign n867_o = obuf[663:656];
  assign n868_o = obuf[671:664];
  assign n869_o = obuf[679:672];
  assign n870_o = obuf[687:680];
  assign n871_o = obuf[695:688];
  assign n872_o = obuf[703:696];
  assign n873_o = obuf[711:704];
  assign n874_o = obuf[719:712];
  assign n875_o = obuf[727:720];
  assign n876_o = obuf[735:728];
  assign n877_o = obuf[743:736];
  assign n878_o = obuf[751:744];
  assign n879_o = obuf[759:752];
  assign n880_o = obuf[767:760];
  assign n881_o = obuf[775:768];
  assign n882_o = obuf[783:776];
  assign n883_o = obuf[791:784];
  assign n884_o = obuf[799:792];
  assign n885_o = obuf[807:800];
  assign n886_o = obuf[815:808];
  assign n887_o = obuf[823:816];
  assign n888_o = obuf[831:824];
  assign n889_o = obuf[839:832];
  assign n890_o = obuf[847:840];
  assign n891_o = obuf[855:848];
  assign n892_o = obuf[863:856];
  assign n893_o = obuf[871:864];
  assign n894_o = obuf[879:872];
  assign n895_o = obuf[887:880];
  assign n896_o = obuf[895:888];
  assign n897_o = obuf[903:896];
  assign n898_o = obuf[911:904];
  assign n899_o = obuf[919:912];
  assign n900_o = obuf[927:920];
  assign n901_o = obuf[935:928];
  assign n902_o = obuf[943:936];
  assign n903_o = obuf[951:944];
  assign n904_o = obuf[959:952];
  assign n905_o = obuf[967:960];
  assign n906_o = obuf[975:968];
  assign n907_o = obuf[983:976];
  assign n908_o = obuf[991:984];
  assign n909_o = obuf[999:992];
  assign n910_o = obuf[1007:1000];
  assign n911_o = obuf[1015:1008];
  assign n912_o = obuf[1023:1016];
  assign n913_o = obuf[1031:1024];
  assign n914_o = obuf[1039:1032];
  assign n915_o = obuf[1047:1040];
  assign n916_o = obuf[1055:1048];
  assign n917_o = obuf[1063:1056];
  assign n918_o = obuf[1071:1064];
  assign n919_o = obuf[1079:1072];
  assign n920_o = obuf[1087:1080];
  assign n921_o = obuf[1095:1088];
  assign n922_o = obuf[1103:1096];
  assign n923_o = obuf[1111:1104];
  assign n924_o = obuf[1119:1112];
  assign n925_o = obuf[1127:1120];
  assign n926_o = obuf[1135:1128];
  assign n927_o = obuf[1143:1136];
  assign n928_o = obuf[1151:1144];
  assign n929_o = obuf[1159:1152];
  assign n930_o = obuf[1167:1160];
  assign n931_o = obuf[1175:1168];
  assign n932_o = obuf[1183:1176];
  assign n933_o = obuf[1191:1184];
  assign n934_o = obuf[1199:1192];
  assign n935_o = obuf[1207:1200];
  assign n936_o = obuf[1215:1208];
  assign n937_o = obuf[1223:1216];
  assign n938_o = obuf[1231:1224];
  assign n939_o = obuf[1239:1232];
  assign n940_o = obuf[1247:1240];
  assign n941_o = obuf[1255:1248];
  assign n942_o = obuf[1263:1256];
  assign n943_o = obuf[1271:1264];
  assign n944_o = obuf[1279:1272];
  assign n945_o = obuf[1287:1280];
  assign n946_o = obuf[1295:1288];
  assign n947_o = obuf[1303:1296];
  assign n948_o = obuf[1311:1304];
  assign n949_o = obuf[1319:1312];
  assign n950_o = obuf[1327:1320];
  assign n951_o = obuf[1335:1328];
  assign n952_o = obuf[1343:1336];
  assign n953_o = obuf[1351:1344];
  assign n954_o = obuf[1359:1352];
  assign n955_o = obuf[1367:1360];
  assign n956_o = obuf[1375:1368];
  assign n957_o = obuf[1383:1376];
  assign n958_o = obuf[1391:1384];
  assign n959_o = obuf[1399:1392];
  assign n960_o = obuf[1407:1400];
  assign n961_o = obuf[1415:1408];
  assign n962_o = obuf[1423:1416];
  assign n963_o = obuf[1431:1424];
  assign n964_o = obuf[1439:1432];
  assign n965_o = obuf[1447:1440];
  assign n966_o = obuf[1455:1448];
  assign n967_o = obuf[1463:1456];
  assign n968_o = obuf[1471:1464];
  assign n969_o = obuf[1479:1472];
  assign n970_o = obuf[1487:1480];
  assign n971_o = obuf[1495:1488];
  assign n972_o = obuf[1503:1496];
  assign n973_o = obuf[1511:1504];
  assign n974_o = obuf[1519:1512];
  assign n975_o = obuf[1527:1520];
  assign n976_o = obuf[1535:1528];
  assign n977_o = obuf[1543:1536];
  assign n978_o = obuf[1551:1544];
  assign n979_o = obuf[1559:1552];
  assign n980_o = obuf[1567:1560];
  assign n981_o = obuf[1575:1568];
  assign n982_o = obuf[1583:1576];
  assign n983_o = obuf[1591:1584];
  assign n984_o = obuf[1599:1592];
  assign n985_o = obuf[1607:1600];
  assign n986_o = obuf[1615:1608];
  assign n987_o = obuf[1623:1616];
  assign n988_o = obuf[1631:1624];
  assign n989_o = obuf[1639:1632];
  assign n990_o = obuf[1647:1640];
  assign n991_o = obuf[1655:1648];
  assign n992_o = obuf[1663:1656];
  assign n993_o = obuf[1671:1664];
  assign n994_o = obuf[1679:1672];
  assign n995_o = obuf[1687:1680];
  assign n996_o = obuf[1695:1688];
  assign n997_o = obuf[1703:1696];
  assign n998_o = obuf[1711:1704];
  assign n999_o = obuf[1719:1712];
  assign n1000_o = obuf[1727:1720];
  assign n1001_o = obuf[1735:1728];
  assign n1002_o = obuf[1743:1736];
  assign n1003_o = obuf[1751:1744];
  assign n1004_o = obuf[1759:1752];
  assign n1005_o = obuf[1767:1760];
  assign n1006_o = obuf[1775:1768];
  assign n1007_o = obuf[1783:1776];
  assign n1008_o = obuf[1791:1784];
  assign n1009_o = obuf[1799:1792];
  assign n1010_o = obuf[1807:1800];
  assign n1011_o = obuf[1815:1808];
  assign n1012_o = obuf[1823:1816];
  assign n1013_o = obuf[1831:1824];
  assign n1014_o = obuf[1839:1832];
  assign n1015_o = obuf[1847:1840];
  assign n1016_o = obuf[1855:1848];
  assign n1017_o = obuf[1863:1856];
  assign n1018_o = obuf[1871:1864];
  assign n1019_o = obuf[1879:1872];
  assign n1020_o = obuf[1887:1880];
  assign n1021_o = obuf[1895:1888];
  assign n1022_o = obuf[1903:1896];
  assign n1023_o = obuf[1911:1904];
  assign n1024_o = obuf[1919:1912];
  assign n1025_o = obuf[1927:1920];
  assign n1026_o = obuf[1935:1928];
  assign n1027_o = obuf[1943:1936];
  assign n1028_o = obuf[1951:1944];
  assign n1029_o = obuf[1959:1952];
  assign n1030_o = obuf[1967:1960];
  assign n1031_o = obuf[1975:1968];
  assign n1032_o = obuf[1983:1976];
  assign n1033_o = obuf[1991:1984];
  assign n1034_o = obuf[1999:1992];
  assign n1035_o = obuf[2007:2000];
  assign n1036_o = obuf[2015:2008];
  assign n1037_o = obuf[2023:2016];
  assign n1038_o = obuf[2031:2024];
  assign n1039_o = obuf[2039:2032];
  assign n1040_o = obuf[2047:2040];
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1041_o = {n116_o, n130_o};
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1042_o = n1041_o[7:0];  // trunc
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1043_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1043_o)
      2'b00: n1044_o = n785_o;
      2'b01: n1044_o = n786_o;
      2'b10: n1044_o = n787_o;
      2'b11: n1044_o = n788_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1045_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1045_o)
      2'b00: n1046_o = n789_o;
      2'b01: n1046_o = n790_o;
      2'b10: n1046_o = n791_o;
      2'b11: n1046_o = n792_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1047_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1047_o)
      2'b00: n1048_o = n793_o;
      2'b01: n1048_o = n794_o;
      2'b10: n1048_o = n795_o;
      2'b11: n1048_o = n796_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1049_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1049_o)
      2'b00: n1050_o = n797_o;
      2'b01: n1050_o = n798_o;
      2'b10: n1050_o = n799_o;
      2'b11: n1050_o = n800_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1051_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1051_o)
      2'b00: n1052_o = n801_o;
      2'b01: n1052_o = n802_o;
      2'b10: n1052_o = n803_o;
      2'b11: n1052_o = n804_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1053_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1053_o)
      2'b00: n1054_o = n805_o;
      2'b01: n1054_o = n806_o;
      2'b10: n1054_o = n807_o;
      2'b11: n1054_o = n808_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1055_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1055_o)
      2'b00: n1056_o = n809_o;
      2'b01: n1056_o = n810_o;
      2'b10: n1056_o = n811_o;
      2'b11: n1056_o = n812_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1057_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1057_o)
      2'b00: n1058_o = n813_o;
      2'b01: n1058_o = n814_o;
      2'b10: n1058_o = n815_o;
      2'b11: n1058_o = n816_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1059_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1059_o)
      2'b00: n1060_o = n817_o;
      2'b01: n1060_o = n818_o;
      2'b10: n1060_o = n819_o;
      2'b11: n1060_o = n820_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1061_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1061_o)
      2'b00: n1062_o = n821_o;
      2'b01: n1062_o = n822_o;
      2'b10: n1062_o = n823_o;
      2'b11: n1062_o = n824_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1063_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1063_o)
      2'b00: n1064_o = n825_o;
      2'b01: n1064_o = n826_o;
      2'b10: n1064_o = n827_o;
      2'b11: n1064_o = n828_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1065_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1065_o)
      2'b00: n1066_o = n829_o;
      2'b01: n1066_o = n830_o;
      2'b10: n1066_o = n831_o;
      2'b11: n1066_o = n832_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1067_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1067_o)
      2'b00: n1068_o = n833_o;
      2'b01: n1068_o = n834_o;
      2'b10: n1068_o = n835_o;
      2'b11: n1068_o = n836_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1069_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1069_o)
      2'b00: n1070_o = n837_o;
      2'b01: n1070_o = n838_o;
      2'b10: n1070_o = n839_o;
      2'b11: n1070_o = n840_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1071_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1071_o)
      2'b00: n1072_o = n841_o;
      2'b01: n1072_o = n842_o;
      2'b10: n1072_o = n843_o;
      2'b11: n1072_o = n844_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1073_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1073_o)
      2'b00: n1074_o = n845_o;
      2'b01: n1074_o = n846_o;
      2'b10: n1074_o = n847_o;
      2'b11: n1074_o = n848_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1075_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1075_o)
      2'b00: n1076_o = n849_o;
      2'b01: n1076_o = n850_o;
      2'b10: n1076_o = n851_o;
      2'b11: n1076_o = n852_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1077_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1077_o)
      2'b00: n1078_o = n853_o;
      2'b01: n1078_o = n854_o;
      2'b10: n1078_o = n855_o;
      2'b11: n1078_o = n856_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1079_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1079_o)
      2'b00: n1080_o = n857_o;
      2'b01: n1080_o = n858_o;
      2'b10: n1080_o = n859_o;
      2'b11: n1080_o = n860_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1081_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1081_o)
      2'b00: n1082_o = n861_o;
      2'b01: n1082_o = n862_o;
      2'b10: n1082_o = n863_o;
      2'b11: n1082_o = n864_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1083_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1083_o)
      2'b00: n1084_o = n865_o;
      2'b01: n1084_o = n866_o;
      2'b10: n1084_o = n867_o;
      2'b11: n1084_o = n868_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1085_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1085_o)
      2'b00: n1086_o = n869_o;
      2'b01: n1086_o = n870_o;
      2'b10: n1086_o = n871_o;
      2'b11: n1086_o = n872_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1087_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1087_o)
      2'b00: n1088_o = n873_o;
      2'b01: n1088_o = n874_o;
      2'b10: n1088_o = n875_o;
      2'b11: n1088_o = n876_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1089_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1089_o)
      2'b00: n1090_o = n877_o;
      2'b01: n1090_o = n878_o;
      2'b10: n1090_o = n879_o;
      2'b11: n1090_o = n880_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1091_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1091_o)
      2'b00: n1092_o = n881_o;
      2'b01: n1092_o = n882_o;
      2'b10: n1092_o = n883_o;
      2'b11: n1092_o = n884_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1093_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1093_o)
      2'b00: n1094_o = n885_o;
      2'b01: n1094_o = n886_o;
      2'b10: n1094_o = n887_o;
      2'b11: n1094_o = n888_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1095_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1095_o)
      2'b00: n1096_o = n889_o;
      2'b01: n1096_o = n890_o;
      2'b10: n1096_o = n891_o;
      2'b11: n1096_o = n892_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1097_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1097_o)
      2'b00: n1098_o = n893_o;
      2'b01: n1098_o = n894_o;
      2'b10: n1098_o = n895_o;
      2'b11: n1098_o = n896_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1099_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1099_o)
      2'b00: n1100_o = n897_o;
      2'b01: n1100_o = n898_o;
      2'b10: n1100_o = n899_o;
      2'b11: n1100_o = n900_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1101_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1101_o)
      2'b00: n1102_o = n901_o;
      2'b01: n1102_o = n902_o;
      2'b10: n1102_o = n903_o;
      2'b11: n1102_o = n904_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1103_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1103_o)
      2'b00: n1104_o = n905_o;
      2'b01: n1104_o = n906_o;
      2'b10: n1104_o = n907_o;
      2'b11: n1104_o = n908_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1105_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1105_o)
      2'b00: n1106_o = n909_o;
      2'b01: n1106_o = n910_o;
      2'b10: n1106_o = n911_o;
      2'b11: n1106_o = n912_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1107_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1107_o)
      2'b00: n1108_o = n913_o;
      2'b01: n1108_o = n914_o;
      2'b10: n1108_o = n915_o;
      2'b11: n1108_o = n916_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1109_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1109_o)
      2'b00: n1110_o = n917_o;
      2'b01: n1110_o = n918_o;
      2'b10: n1110_o = n919_o;
      2'b11: n1110_o = n920_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1111_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1111_o)
      2'b00: n1112_o = n921_o;
      2'b01: n1112_o = n922_o;
      2'b10: n1112_o = n923_o;
      2'b11: n1112_o = n924_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1113_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1113_o)
      2'b00: n1114_o = n925_o;
      2'b01: n1114_o = n926_o;
      2'b10: n1114_o = n927_o;
      2'b11: n1114_o = n928_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1115_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1115_o)
      2'b00: n1116_o = n929_o;
      2'b01: n1116_o = n930_o;
      2'b10: n1116_o = n931_o;
      2'b11: n1116_o = n932_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1117_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1117_o)
      2'b00: n1118_o = n933_o;
      2'b01: n1118_o = n934_o;
      2'b10: n1118_o = n935_o;
      2'b11: n1118_o = n936_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1119_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1119_o)
      2'b00: n1120_o = n937_o;
      2'b01: n1120_o = n938_o;
      2'b10: n1120_o = n939_o;
      2'b11: n1120_o = n940_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1121_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1121_o)
      2'b00: n1122_o = n941_o;
      2'b01: n1122_o = n942_o;
      2'b10: n1122_o = n943_o;
      2'b11: n1122_o = n944_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1123_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1123_o)
      2'b00: n1124_o = n945_o;
      2'b01: n1124_o = n946_o;
      2'b10: n1124_o = n947_o;
      2'b11: n1124_o = n948_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1125_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1125_o)
      2'b00: n1126_o = n949_o;
      2'b01: n1126_o = n950_o;
      2'b10: n1126_o = n951_o;
      2'b11: n1126_o = n952_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1127_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1127_o)
      2'b00: n1128_o = n953_o;
      2'b01: n1128_o = n954_o;
      2'b10: n1128_o = n955_o;
      2'b11: n1128_o = n956_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1129_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1129_o)
      2'b00: n1130_o = n957_o;
      2'b01: n1130_o = n958_o;
      2'b10: n1130_o = n959_o;
      2'b11: n1130_o = n960_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1131_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1131_o)
      2'b00: n1132_o = n961_o;
      2'b01: n1132_o = n962_o;
      2'b10: n1132_o = n963_o;
      2'b11: n1132_o = n964_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1133_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1133_o)
      2'b00: n1134_o = n965_o;
      2'b01: n1134_o = n966_o;
      2'b10: n1134_o = n967_o;
      2'b11: n1134_o = n968_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1135_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1135_o)
      2'b00: n1136_o = n969_o;
      2'b01: n1136_o = n970_o;
      2'b10: n1136_o = n971_o;
      2'b11: n1136_o = n972_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1137_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1137_o)
      2'b00: n1138_o = n973_o;
      2'b01: n1138_o = n974_o;
      2'b10: n1138_o = n975_o;
      2'b11: n1138_o = n976_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1139_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1139_o)
      2'b00: n1140_o = n977_o;
      2'b01: n1140_o = n978_o;
      2'b10: n1140_o = n979_o;
      2'b11: n1140_o = n980_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1141_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1141_o)
      2'b00: n1142_o = n981_o;
      2'b01: n1142_o = n982_o;
      2'b10: n1142_o = n983_o;
      2'b11: n1142_o = n984_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1143_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1143_o)
      2'b00: n1144_o = n985_o;
      2'b01: n1144_o = n986_o;
      2'b10: n1144_o = n987_o;
      2'b11: n1144_o = n988_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1145_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1145_o)
      2'b00: n1146_o = n989_o;
      2'b01: n1146_o = n990_o;
      2'b10: n1146_o = n991_o;
      2'b11: n1146_o = n992_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1147_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1147_o)
      2'b00: n1148_o = n993_o;
      2'b01: n1148_o = n994_o;
      2'b10: n1148_o = n995_o;
      2'b11: n1148_o = n996_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1149_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1149_o)
      2'b00: n1150_o = n997_o;
      2'b01: n1150_o = n998_o;
      2'b10: n1150_o = n999_o;
      2'b11: n1150_o = n1000_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1151_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1151_o)
      2'b00: n1152_o = n1001_o;
      2'b01: n1152_o = n1002_o;
      2'b10: n1152_o = n1003_o;
      2'b11: n1152_o = n1004_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1153_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1153_o)
      2'b00: n1154_o = n1005_o;
      2'b01: n1154_o = n1006_o;
      2'b10: n1154_o = n1007_o;
      2'b11: n1154_o = n1008_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1155_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1155_o)
      2'b00: n1156_o = n1009_o;
      2'b01: n1156_o = n1010_o;
      2'b10: n1156_o = n1011_o;
      2'b11: n1156_o = n1012_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1157_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1157_o)
      2'b00: n1158_o = n1013_o;
      2'b01: n1158_o = n1014_o;
      2'b10: n1158_o = n1015_o;
      2'b11: n1158_o = n1016_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1159_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1159_o)
      2'b00: n1160_o = n1017_o;
      2'b01: n1160_o = n1018_o;
      2'b10: n1160_o = n1019_o;
      2'b11: n1160_o = n1020_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1161_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1161_o)
      2'b00: n1162_o = n1021_o;
      2'b01: n1162_o = n1022_o;
      2'b10: n1162_o = n1023_o;
      2'b11: n1162_o = n1024_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1163_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1163_o)
      2'b00: n1164_o = n1025_o;
      2'b01: n1164_o = n1026_o;
      2'b10: n1164_o = n1027_o;
      2'b11: n1164_o = n1028_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1165_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1165_o)
      2'b00: n1166_o = n1029_o;
      2'b01: n1166_o = n1030_o;
      2'b10: n1166_o = n1031_o;
      2'b11: n1166_o = n1032_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1167_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1167_o)
      2'b00: n1168_o = n1033_o;
      2'b01: n1168_o = n1034_o;
      2'b10: n1168_o = n1035_o;
      2'b11: n1168_o = n1036_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1169_o = n1042_o[1:0];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1169_o)
      2'b00: n1170_o = n1037_o;
      2'b01: n1170_o = n1038_o;
      2'b10: n1170_o = n1039_o;
      2'b11: n1170_o = n1040_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1171_o = n1042_o[3:2];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1171_o)
      2'b00: n1172_o = n1044_o;
      2'b01: n1172_o = n1046_o;
      2'b10: n1172_o = n1048_o;
      2'b11: n1172_o = n1050_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1173_o = n1042_o[3:2];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1173_o)
      2'b00: n1174_o = n1052_o;
      2'b01: n1174_o = n1054_o;
      2'b10: n1174_o = n1056_o;
      2'b11: n1174_o = n1058_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1175_o = n1042_o[3:2];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1175_o)
      2'b00: n1176_o = n1060_o;
      2'b01: n1176_o = n1062_o;
      2'b10: n1176_o = n1064_o;
      2'b11: n1176_o = n1066_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1177_o = n1042_o[3:2];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1177_o)
      2'b00: n1178_o = n1068_o;
      2'b01: n1178_o = n1070_o;
      2'b10: n1178_o = n1072_o;
      2'b11: n1178_o = n1074_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1179_o = n1042_o[3:2];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1179_o)
      2'b00: n1180_o = n1076_o;
      2'b01: n1180_o = n1078_o;
      2'b10: n1180_o = n1080_o;
      2'b11: n1180_o = n1082_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1181_o = n1042_o[3:2];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1181_o)
      2'b00: n1182_o = n1084_o;
      2'b01: n1182_o = n1086_o;
      2'b10: n1182_o = n1088_o;
      2'b11: n1182_o = n1090_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1183_o = n1042_o[3:2];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1183_o)
      2'b00: n1184_o = n1092_o;
      2'b01: n1184_o = n1094_o;
      2'b10: n1184_o = n1096_o;
      2'b11: n1184_o = n1098_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1185_o = n1042_o[3:2];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1185_o)
      2'b00: n1186_o = n1100_o;
      2'b01: n1186_o = n1102_o;
      2'b10: n1186_o = n1104_o;
      2'b11: n1186_o = n1106_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1187_o = n1042_o[3:2];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1187_o)
      2'b00: n1188_o = n1108_o;
      2'b01: n1188_o = n1110_o;
      2'b10: n1188_o = n1112_o;
      2'b11: n1188_o = n1114_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1189_o = n1042_o[3:2];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1189_o)
      2'b00: n1190_o = n1116_o;
      2'b01: n1190_o = n1118_o;
      2'b10: n1190_o = n1120_o;
      2'b11: n1190_o = n1122_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1191_o = n1042_o[3:2];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1191_o)
      2'b00: n1192_o = n1124_o;
      2'b01: n1192_o = n1126_o;
      2'b10: n1192_o = n1128_o;
      2'b11: n1192_o = n1130_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1193_o = n1042_o[3:2];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1193_o)
      2'b00: n1194_o = n1132_o;
      2'b01: n1194_o = n1134_o;
      2'b10: n1194_o = n1136_o;
      2'b11: n1194_o = n1138_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1195_o = n1042_o[3:2];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1195_o)
      2'b00: n1196_o = n1140_o;
      2'b01: n1196_o = n1142_o;
      2'b10: n1196_o = n1144_o;
      2'b11: n1196_o = n1146_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1197_o = n1042_o[3:2];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1197_o)
      2'b00: n1198_o = n1148_o;
      2'b01: n1198_o = n1150_o;
      2'b10: n1198_o = n1152_o;
      2'b11: n1198_o = n1154_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1199_o = n1042_o[3:2];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1199_o)
      2'b00: n1200_o = n1156_o;
      2'b01: n1200_o = n1158_o;
      2'b10: n1200_o = n1160_o;
      2'b11: n1200_o = n1162_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1201_o = n1042_o[3:2];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1201_o)
      2'b00: n1202_o = n1164_o;
      2'b01: n1202_o = n1166_o;
      2'b10: n1202_o = n1168_o;
      2'b11: n1202_o = n1170_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1203_o = n1042_o[5:4];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1203_o)
      2'b00: n1204_o = n1172_o;
      2'b01: n1204_o = n1174_o;
      2'b10: n1204_o = n1176_o;
      2'b11: n1204_o = n1178_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1205_o = n1042_o[5:4];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1205_o)
      2'b00: n1206_o = n1180_o;
      2'b01: n1206_o = n1182_o;
      2'b10: n1206_o = n1184_o;
      2'b11: n1206_o = n1186_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1207_o = n1042_o[5:4];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1207_o)
      2'b00: n1208_o = n1188_o;
      2'b01: n1208_o = n1190_o;
      2'b10: n1208_o = n1192_o;
      2'b11: n1208_o = n1194_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1209_o = n1042_o[5:4];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1209_o)
      2'b00: n1210_o = n1196_o;
      2'b01: n1210_o = n1198_o;
      2'b10: n1210_o = n1200_o;
      2'b11: n1210_o = n1202_o;
    endcase
  /* rtl/crypto_controller.vhd:164:31  */
  assign n1211_o = n1042_o[7:6];
  /* rtl/crypto_controller.vhd:164:31  */
  always @*
    case (n1211_o)
      2'b00: n1212_o = n1204_o;
      2'b01: n1212_o = n1206_o;
      2'b10: n1212_o = n1208_o;
      2'b11: n1212_o = n1210_o;
    endcase
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1213_o = n449_o[3];
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1214_o = ~n1213_o;
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1215_o = n449_o[2];
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1216_o = ~n1215_o;
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1217_o = n1214_o & n1216_o;
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1218_o = n1214_o & n1215_o;
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1219_o = n1213_o & n1216_o;
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1220_o = n1213_o & n1215_o;
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1221_o = n449_o[1];
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1222_o = ~n1221_o;
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1223_o = n1217_o & n1222_o;
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1224_o = n1217_o & n1221_o;
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1225_o = n1218_o & n1222_o;
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1226_o = n1218_o & n1221_o;
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1227_o = n1219_o & n1222_o;
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1228_o = n1219_o & n1221_o;
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1229_o = n1220_o & n1222_o;
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1230_o = n1220_o & n1221_o;
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1231_o = n449_o[0];
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1232_o = ~n1231_o;
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1233_o = n1223_o & n1232_o;
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1234_o = n1223_o & n1231_o;
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1235_o = n1224_o & n1232_o;
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1236_o = n1224_o & n1231_o;
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1237_o = n1225_o & n1232_o;
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1238_o = n1225_o & n1231_o;
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1239_o = n1226_o & n1232_o;
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1240_o = n1226_o & n1231_o;
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1241_o = n1227_o & n1232_o;
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1242_o = n1227_o & n1231_o;
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1243_o = n1228_o & n1232_o;
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1244_o = n1228_o & n1231_o;
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1245_o = n1229_o & n1232_o;
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1246_o = n1229_o & n1231_o;
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1247_o = n1230_o & n1232_o;
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1248_o = n1230_o & n1231_o;
  assign n1249_o = obuf[127:0];
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1250_o = n1233_o ? eng_out_block : n1249_o;
  assign n1251_o = obuf[255:128];
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1252_o = n1234_o ? eng_out_block : n1251_o;
  assign n1253_o = obuf[383:256];
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1254_o = n1235_o ? eng_out_block : n1253_o;
  assign n1255_o = obuf[511:384];
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1256_o = n1236_o ? eng_out_block : n1255_o;
  assign n1257_o = obuf[639:512];
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1258_o = n1237_o ? eng_out_block : n1257_o;
  assign n1259_o = obuf[767:640];
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1260_o = n1238_o ? eng_out_block : n1259_o;
  assign n1261_o = obuf[895:768];
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1262_o = n1239_o ? eng_out_block : n1261_o;
  assign n1263_o = obuf[1023:896];
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1264_o = n1240_o ? eng_out_block : n1263_o;
  assign n1265_o = obuf[1151:1024];
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1266_o = n1241_o ? eng_out_block : n1265_o;
  assign n1267_o = obuf[1279:1152];
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1268_o = n1242_o ? eng_out_block : n1267_o;
  assign n1269_o = obuf[1407:1280];
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1270_o = n1243_o ? eng_out_block : n1269_o;
  assign n1271_o = obuf[1535:1408];
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1272_o = n1244_o ? eng_out_block : n1271_o;
  assign n1273_o = obuf[1663:1536];
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1274_o = n1245_o ? eng_out_block : n1273_o;
  assign n1275_o = obuf[1791:1664];
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1276_o = n1246_o ? eng_out_block : n1275_o;
  assign n1277_o = obuf[1919:1792];
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1278_o = n1247_o ? eng_out_block : n1277_o;
  assign n1279_o = obuf[2047:1920];
  /* rtl/crypto_controller.vhd:300:29  */
  assign n1280_o = n1248_o ? eng_out_block : n1279_o;
  assign n1281_o = {n1280_o, n1278_o, n1276_o, n1274_o, n1272_o, n1270_o, n1268_o, n1266_o, n1264_o, n1262_o, n1260_o, n1258_o, n1256_o, n1254_o, n1252_o, n1250_o};
  /* rtl/crypto_controller.vhd:340:39  */
  assign n1282_o = n555_o[3:0];  // trunc
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1283_o = n1282_o[3];
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1284_o = ~n1283_o;
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1285_o = n1282_o[2];
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1286_o = ~n1285_o;
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1287_o = n1284_o & n1286_o;
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1288_o = n1284_o & n1285_o;
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1289_o = n1283_o & n1286_o;
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1290_o = n1283_o & n1285_o;
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1291_o = n1282_o[1];
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1292_o = ~n1291_o;
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1293_o = n1287_o & n1292_o;
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1294_o = n1287_o & n1291_o;
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1295_o = n1288_o & n1292_o;
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1296_o = n1288_o & n1291_o;
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1297_o = n1289_o & n1292_o;
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1298_o = n1289_o & n1291_o;
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1299_o = n1290_o & n1292_o;
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1300_o = n1290_o & n1291_o;
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1301_o = n1282_o[0];
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1302_o = ~n1301_o;
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1303_o = n1293_o & n1302_o;
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1304_o = n1293_o & n1301_o;
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1305_o = n1294_o & n1302_o;
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1306_o = n1294_o & n1301_o;
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1307_o = n1295_o & n1302_o;
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1308_o = n1295_o & n1301_o;
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1309_o = n1296_o & n1302_o;
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1310_o = n1296_o & n1301_o;
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1311_o = n1297_o & n1302_o;
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1312_o = n1297_o & n1301_o;
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1313_o = n1298_o & n1302_o;
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1314_o = n1298_o & n1301_o;
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1315_o = n1299_o & n1302_o;
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1316_o = n1299_o & n1301_o;
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1317_o = n1300_o & n1302_o;
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1318_o = n1300_o & n1301_o;
  assign n1319_o = in_reg[7:0];
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1320_o = n1303_o ? buf_data : n1319_o;
  assign n1321_o = in_reg[15:8];
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1322_o = n1304_o ? buf_data : n1321_o;
  assign n1323_o = in_reg[23:16];
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1324_o = n1305_o ? buf_data : n1323_o;
  assign n1325_o = in_reg[31:24];
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1326_o = n1306_o ? buf_data : n1325_o;
  assign n1327_o = in_reg[39:32];
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1328_o = n1307_o ? buf_data : n1327_o;
  assign n1329_o = in_reg[47:40];
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1330_o = n1308_o ? buf_data : n1329_o;
  assign n1331_o = in_reg[55:48];
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1332_o = n1309_o ? buf_data : n1331_o;
  assign n1333_o = in_reg[63:56];
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1334_o = n1310_o ? buf_data : n1333_o;
  assign n1335_o = in_reg[71:64];
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1336_o = n1311_o ? buf_data : n1335_o;
  assign n1337_o = in_reg[79:72];
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1338_o = n1312_o ? buf_data : n1337_o;
  assign n1339_o = in_reg[87:80];
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1340_o = n1313_o ? buf_data : n1339_o;
  assign n1341_o = in_reg[95:88];
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1342_o = n1314_o ? buf_data : n1341_o;
  assign n1343_o = in_reg[103:96];
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1344_o = n1315_o ? buf_data : n1343_o;
  assign n1345_o = in_reg[111:104];
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1346_o = n1316_o ? buf_data : n1345_o;
  assign n1347_o = in_reg[119:112];
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1348_o = n1317_o ? buf_data : n1347_o;
  assign n1349_o = in_reg[127:120];
  /* rtl/crypto_controller.vhd:340:33  */
  assign n1350_o = n1318_o ? buf_data : n1349_o;
  assign n1351_o = {n1350_o, n1348_o, n1346_o, n1344_o, n1342_o, n1340_o, n1338_o, n1336_o, n1334_o, n1332_o, n1330_o, n1328_o, n1326_o, n1324_o, n1322_o, n1320_o};
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1352_o = n582_o[3];
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1353_o = ~n1352_o;
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1354_o = n582_o[2];
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1355_o = ~n1354_o;
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1356_o = n1353_o & n1355_o;
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1357_o = n1353_o & n1354_o;
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1358_o = n1352_o & n1355_o;
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1359_o = n1352_o & n1354_o;
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1360_o = n582_o[1];
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1361_o = ~n1360_o;
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1362_o = n1356_o & n1361_o;
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1363_o = n1356_o & n1360_o;
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1364_o = n1357_o & n1361_o;
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1365_o = n1357_o & n1360_o;
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1366_o = n1358_o & n1361_o;
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1367_o = n1358_o & n1360_o;
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1368_o = n1359_o & n1361_o;
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1369_o = n1359_o & n1360_o;
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1370_o = n582_o[0];
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1371_o = ~n1370_o;
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1372_o = n1362_o & n1371_o;
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1373_o = n1362_o & n1370_o;
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1374_o = n1363_o & n1371_o;
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1375_o = n1363_o & n1370_o;
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1376_o = n1364_o & n1371_o;
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1377_o = n1364_o & n1370_o;
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1378_o = n1365_o & n1371_o;
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1379_o = n1365_o & n1370_o;
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1380_o = n1366_o & n1371_o;
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1381_o = n1366_o & n1370_o;
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1382_o = n1367_o & n1371_o;
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1383_o = n1367_o & n1370_o;
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1384_o = n1368_o & n1371_o;
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1385_o = n1368_o & n1370_o;
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1386_o = n1369_o & n1371_o;
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1387_o = n1369_o & n1370_o;
  assign n1388_o = obuf[127:0];
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1389_o = n1372_o ? 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : n1388_o;
  assign n1390_o = obuf[255:128];
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1391_o = n1373_o ? 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : n1390_o;
  assign n1392_o = obuf[383:256];
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1393_o = n1374_o ? 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : n1392_o;
  assign n1394_o = obuf[511:384];
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1395_o = n1375_o ? 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : n1394_o;
  assign n1396_o = obuf[639:512];
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1397_o = n1376_o ? 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : n1396_o;
  assign n1398_o = obuf[767:640];
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1399_o = n1377_o ? 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : n1398_o;
  assign n1400_o = obuf[895:768];
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1401_o = n1378_o ? 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : n1400_o;
  assign n1402_o = obuf[1023:896];
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1403_o = n1379_o ? 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : n1402_o;
  assign n1404_o = obuf[1151:1024];
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1405_o = n1380_o ? 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : n1404_o;
  assign n1406_o = obuf[1279:1152];
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1407_o = n1381_o ? 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : n1406_o;
  assign n1408_o = obuf[1407:1280];
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1409_o = n1382_o ? 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : n1408_o;
  assign n1410_o = obuf[1535:1408];
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1411_o = n1383_o ? 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : n1410_o;
  assign n1412_o = obuf[1663:1536];
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1413_o = n1384_o ? 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : n1412_o;
  assign n1414_o = obuf[1791:1664];
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1415_o = n1385_o ? 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : n1414_o;
  assign n1416_o = obuf[1919:1792];
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1417_o = n1386_o ? 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : n1416_o;
  assign n1418_o = obuf[2047:1920];
  /* rtl/crypto_controller.vhd:352:25  */
  assign n1419_o = n1387_o ? 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : n1418_o;
  assign n1420_o = {n1419_o, n1417_o, n1415_o, n1413_o, n1411_o, n1409_o, n1407_o, n1405_o, n1403_o, n1401_o, n1399_o, n1397_o, n1395_o, n1393_o, n1391_o, n1389_o};
endmodule

