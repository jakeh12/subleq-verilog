module mem (
  input        i_clk,
  input  [7:0] i_raddr,
  output [7:0] o_rdata,
  input  [7:0] i_waddr,
  input  [7:0] i_wdata,
  input        i_we
);
  
  // 256 byte memory
  reg [7:0] ram [0:255];
  
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