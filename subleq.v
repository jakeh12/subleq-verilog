module subleq (
  input        i_clk,
  input        i_rstn,
  output [7:0] o_raddr,
  input  [7:0] i_rdata,
  output [7:0] o_waddr,
  output [7:0] o_wdata,
  output       o_we
);
  
  // registers
  reg [7:0] r_a, r_b, r_mar, r_pc;
  wire w_a_ld, w_b_ld, w_mar_ld, w_pc_ld, w_pc_inc;
  
  always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) begin
      r_a   <= 0;
      r_b   <= 0;
      r_mar <= 0;
      r_pc  <= 0;
    end else begin
      if (w_a_ld) begin
        r_a   <= i_rdata;
      end
      if (w_b_ld) begin
        r_b   <= i_rdata;
      end
      if (w_mar_ld) begin
        r_mar <= i_rdata;
      end
      if (w_pc_ld) begin
        r_pc  <= r_mar;
      end else begin
        if (w_pc_inc) begin
          r_pc <= r_pc + 1;
        end
      end
    end
  end
  
  // adress select mux (0: pc, 1: mar)
  wire w_mux_sel_pc_mar;
  wire [7:0] w_mem_addr;
  assign w_mem_addr = !w_mux_sel_pc_mar ? r_pc : r_mar;
  
  // memory write enable
  wire w_mem_we;
  
  // subtractor
  wire signed [7:0] w_b_minus_a;
  assign w_b_minus_a = r_b - r_a;
  
  // branch conditional
  wire w_less_or_equal_to_zero;
  assign w_less_or_equal_to_zero = w_b_minus_a >= 0 ? 1 : 0;
  
  // control state machine
  localparam S_0_LD_MAR_FROM_PC_ADDR       = 0,
             S_1_LD_A_FROM_MAR_ADDR_INC_PC = 1,
             S_2_LD_MAR_FROM_PC_ADDR       = 2,
             S_3_LD_B_FROM_MAR_ADDR_INC_PC = 3,
             S_4_LD_MEM_FROM_MAR_ADDR      = 4,
             S_5_LD_MAR_FROM_PC_ADDR       = 5,
             S_6_BRANCH_TO_MAR_OR_INC_PC   = 6;
             
  reg [3:0] r_state;
  
  always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) begin
      r_state <= 0;
    end else begin
      // assign default value to all control signals
      w_a_ld           <= 0;
      w_b_ld           <= 0;
      w_mar_ld         <= 0;
      w_pc_ld          <= 0;
      w_pc_inc         <= 0;
      w_mux_sel_pc_mar <= 0;
      w_mem_we         <= 0;
      case (r_state)
        S_0_LD_MAR_FROM_PC_ADDR : begin
          w_mar_ld         <= 1;
          r_state          <= S_1_LD_A_FROM_MAR_ADDR_INC_PC;
        end
        S_1_LD_A_FROM_MAR_ADDR_INC_PC : begin
          w_mux_sel_pc_mar <= 1;
          w_a_ld           <= 1;
          w_pc_inc         <= 1;
          r_state          <= S_2_LD_MAR_FROM_PC_ADDR;
        end
        S_2_LD_MAR_FROM_PC_ADDR : begin
          w_mar_ld         <= 1;
          r_state          <= S_3_LD_B_FROM_MAR_ADDR_INC_PC;
        end
        S_3_LD_B_FROM_MAR_ADDR_INC_PC : begin
          w_mux_sel_pc_mar <= 1;
          w_b_ld           <= 1;
          w_pc_inc         <= 1;
          r_state          <= S_4_LD_MEM_FROM_MAR_ADDR;
        end
        S_4_LD_MEM_FROM_MAR_ADDR : begin
          w_mem_we         <= 1;
          r_state          <= S_5_LD_MAR_FROM_PC_ADDR;
        end
        S_5_LD_MAR_FROM_PC_ADDR : begin
          w_mar_ld         <= 1;
          r_state          <= S_6_BRANCH_TO_MAR_OR_INC_PC;
        end
        S_6_BRANCH_TO_MAR_OR_INC_PC : begin
          w_pc_inc         <= 1;
          w_pc_ld          <= w_less_or_equal_to_zero;
          r_state          <= S_0_LD_MAR_FROM_PC_ADDR;
        end
        default : begin
          r_state          <= S_0_LD_MAR_FROM_PC_ADDR;
        end
      endcase
    end
  end
  
  // assign outputs
  assign o_waddr = r_mar;
  assign o_raddr = w_mem_addr;
  assign o_wdata = w_b_minus_a;
  assign o_we    = w_mem_we;
  
endmodule