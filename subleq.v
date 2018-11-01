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
  reg w_a_ld, w_b_ld, w_mar_ld, w_pc_ld, w_pc_inc;
  
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
  reg w_mux_sel_pc_mar;
  wire [7:0] w_mem_addr;
  assign w_mem_addr = !w_mux_sel_pc_mar ? r_pc : r_mar;
  
  // memory write enable
  reg w_mem_we;
  
  // subtractor
  wire signed [7:0] w_b_minus_a;
  assign w_b_minus_a = r_b - r_a;
  
  // branch conditional
  wire w_less_or_equal_to_zero;
  assign w_less_or_equal_to_zero = w_b_minus_a >= 0 ? 1 : 0;
  
  // control state machine
  localparam S_00_PC_TO_MEM_ADDR          =  0,
             S_01_MEM_DATA_TO_MAR         =  1,
             S_02_MAR_TO_MEM_ADDR         =  2,
             S_03_MEM_DATA_TO_A           =  3,
             S_04_PC_TO_MEM_ADDR          =  4,
             S_05_MEM_DATA_TO_MAR         =  5,
             S_06_MAR_TO_MEM_ADDR         =  6,
             S_07_MEM_DATA_TO_B           =  7,
             S_08_B_MINUS_A_TO_MEM_DATA   =  8,
             S_09_PC_TO_MEM_ADDR          =  9,
             S_10_MEM_DATA_TO_MAR         = 10,
             S_11_BRANCH_TO_MAR_OR_INC_PC = 11;
             
  reg [3:0] r_state, r_state_next;
  
  always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) begin
      r_state <= 0;
    end else begin
      r_state <= r_state_next;
    end
  end
  
  always @(r_state) begin
    case (r_state)
      S_00_PC_TO_MEM_ADDR : begin
        r_state_next <= S_01_MEM_DATA_TO_MAR;
      end
      S_01_MEM_DATA_TO_MAR : begin
        r_state_next <= S_02_MAR_TO_MEM_ADDR;
      end
      S_02_MAR_TO_MEM_ADDR : begin
        r_state_next <= S_03_MEM_DATA_TO_A;
      end
      S_03_MEM_DATA_TO_A : begin
        r_state_next <= S_04_PC_TO_MEM_ADDR;
      end
      S_04_PC_TO_MEM_ADDR : begin
        r_state_next <= S_05_MEM_DATA_TO_MAR;
      end
      S_05_MEM_DATA_TO_MAR : begin
        r_state_next <= S_06_MAR_TO_MEM_ADDR;
      end
      S_06_MAR_TO_MEM_ADDR : begin
        r_state_next <= S_07_MEM_DATA_TO_B;
      end
      S_07_MEM_DATA_TO_B : begin
        r_state_next <= S_08_B_MINUS_A_TO_MEM_DATA;
      end
      S_08_B_MINUS_A_TO_MEM_DATA : begin
        r_state_next <= S_09_PC_TO_MEM_ADDR;
      end
      S_09_PC_TO_MEM_ADDR : begin
        r_state_next <= S_10_MEM_DATA_TO_MAR;
      end
      S_10_MEM_DATA_TO_MAR : begin
        r_state_next <= S_11_BRANCH_TO_MAR_OR_INC_PC;
      end
      S_11_BRANCH_TO_MAR_OR_INC_PC : begin
        r_state_next <= S_00_PC_TO_MEM_ADDR;
      end
      default : begin
        r_state_next <= S_00_PC_TO_MEM_ADDR;
      end
    endcase
  end
   
  always @(r_state) begin
  // assign default value to all control signals
      w_a_ld           <= 0;
      w_b_ld           <= 0;
      w_mar_ld         <= 0;
      w_pc_ld          <= 0;
      w_pc_inc         <= 0;
      w_mux_sel_pc_mar <= 0;
      w_mem_we         <= 0;
    case (r_state)
        S_00_PC_TO_MEM_ADDR : begin
          
        end
        S_01_MEM_DATA_TO_MAR : begin
          w_mar_ld <= 1;
        end
        S_02_MAR_TO_MEM_ADDR : begin
          w_mux_sel_pc_mar <= 1;
        end
        S_03_MEM_DATA_TO_A : begin
          w_mux_sel_pc_mar <= 1;
          w_pc_inc <= 1;
          w_a_ld <= 1;
        end
        S_04_PC_TO_MEM_ADDR : begin
          
        end
        S_05_MEM_DATA_TO_MAR : begin
          w_mar_ld <= 1;
        end
        S_06_MAR_TO_MEM_ADDR : begin
          w_mux_sel_pc_mar <= 1;
        end
        S_07_MEM_DATA_TO_B : begin
          w_mux_sel_pc_mar <= 1;
          w_pc_inc <= 1;
          w_b_ld <= 1;
        end
        S_08_B_MINUS_A_TO_MEM_DATA : begin
          w_mux_sel_pc_mar <= 1;
          w_mem_we         <= 1;
        end
        S_09_PC_TO_MEM_ADDR : begin
          
        end
        S_10_MEM_DATA_TO_MAR : begin
          w_mar_ld <= 1;
        end
        S_11_BRANCH_TO_MAR_OR_INC_PC : begin
          w_pc_inc         <= 1;
          w_pc_ld          <= w_less_or_equal_to_zero;          
        end
    endcase
  end
  
  // assign outputs
  assign o_waddr = r_mar;
  assign o_raddr = w_mem_addr;
  assign o_wdata = w_b_minus_a;
  assign o_we    = w_mem_we;
  
endmodule