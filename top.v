`timescale 1ns / 1ps

module top(
  input i_clk,
  input i_rstn
);

  wire [7:0] w_raddr, w_rdata, w_waddr, w_wdata;
  wire w_we;
  
  subleq subleq_0 (
    .i_clk   (i_clk),
    .i_rstn  (i_rstn),
    .o_raddr (w_raddr),
    .i_rdata (w_rdata),
    .o_waddr (w_waddr),
    .o_wdata (w_wdata),
    .o_we    (w_we)
  );
  
  mem mem_0 (
    .i_clk   (i_clk),
    .i_raddr (w_raddr),
    .o_rdata (w_rdata),
    .i_waddr (w_waddr),
    .i_wdata (w_wdata),
    .i_we    (w_we)
  );
  
endmodule
