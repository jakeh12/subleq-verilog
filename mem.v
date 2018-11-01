module mem (
  input            i_clk,
  input      [7:0] i_raddr,
  output reg [7:0] o_rdata,
  input      [7:0] i_waddr,
  input      [7:0] i_wdata,
  input            i_we
);
  
  // 256 byte memory
  reg [7:0] ram [0:255];
  
  initial begin
    ram[  0] <= 8'h0d; // 0x00
    ram[  1] <= 8'h0f; // 0x01
    ram[  2] <= 8'h03; // 0x02
    ram[  3] <= 8'h0f; // 0x03
    ram[  4] <= 8'h0e; // 0x04
    ram[  5] <= 8'h06; // 0x05
    ram[  6] <= 8'h0f; // 0x06
    ram[  7] <= 8'h0f; // 0x07
    ram[  8] <= 8'h06; // 0x08
    ram[  9] <= 8'h00; // 0x09
    ram[ 10] <= 8'h00; // 0x0a
    ram[ 11] <= 8'h00; // 0x0b
    ram[ 12] <= 8'h00; // 0x0c
    ram[ 13] <= 8'h02; // 0x0d
    ram[ 14] <= 8'h03; // 0x0e
    ram[ 15] <= 8'h00; // 0x0f
  end
  
  // write process
  always @(posedge i_clk) begin
    if (i_we) begin
      ram[i_waddr] <= i_wdata;
    end
  end
  
  // read process
  always @(posedge i_clk) begin
    o_rdata <= ram[i_raddr];
  end
  
endmodule