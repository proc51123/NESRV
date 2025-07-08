// The pipeline register between the Instruction Decode (ID) and Execute (EX) stages.

`include "definitions.sv"

module id_ex_register (
    input  logic        clk,
    input  logic        rst,

    // Control signals from Hazard Unit
    // Note: Stall is not needed here. If ID is stalled, this register won't get new data.
    input  logic        id_ex_flush_i,      // Clears the register to a "bubble" or NOP

    // Data Path Inputs from ID Stage
    input  logic [31:0] id_pc_i,            // PC for branch calculations
    input  logic [31:0] id_read_data1_i,    // Value from register rs1
    input  logic [31:0] id_read_data2_i,    // Value from register rs2
    input  logic [31:0] id_imm_i,           // Sign-extended immediate

    // Register addresses (for forwarding and WB)
    input  logic [4:0]  id_rs1_addr_i,
    input  logic [4:0]  id_rs2_addr_i,
    input  logic [4:0]  id_rd_addr_i,       // Destination register address

    // Control Signal Inputs from Control Unit (via ID stage)
    input  logic [1:0]  id_branch_i,
    input  logic [1:0]  id_mem_read_i,
    input  logic [1:0]  id_mem_write_i,
    input  logic [1:0]  id_mem_to_reg_i,
    input  logic [1:0]  id_reg_write_i,
    input  logic [1:0]  id_alu_src_a_i,
    input  logic [1:0]  id_alu_src_b_i,
    input  logic [`ALU_OP_WIDTH-1:0] id_alu_op_i,
    input  logic [1:0]  id_is_muldiv_i,
    
    // Outputs to EX Stage
    output logic [31:0] ex_pc_o,
    output logic [31:0] ex_read_data1_o,
    output logic [31:0] ex_read_data2_o,
    output logic [31:0] ex_imm_o,
    output logic [4:0]  ex_rs1_addr_o,
    output logic [4:0]  ex_rs2_addr_o,
    output logic [4:0]  ex_rd_addr_o,

    output logic [1:0]  ex_branch_o,
    output logic [1:0]  ex_mem_read_o,
    output logic [1:0]  ex_mem_write_o,
    output logic [1:0]  ex_mem_to_reg_o,
    output logic [1:0]  ex_reg_write_o,
    output logic [1:0]  ex_alu_src_a_o,
    output logic [1:0]  ex_alu_src_b_o,
    output logic [`ALU_OP_WIDTH-1:0] ex_alu_op_o,
    output logic [1:0]  ex_is_muldiv_o
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst || id_ex_flush_i) begin
            // On reset or flush, clear all control signals to their "do nothing" state.
            ex_branch_o     <= 2'b0;
            ex_mem_read_o   <= 2'b0;
            ex_mem_write_o  <= 2'b0;
            ex_mem_to_reg_o <= 2'b0;
            ex_reg_write_o  <= 2'b0;
            ex_alu_src_a_o  <= 2'b0;
            ex_alu_src_b_o  <= 2'b0;
            ex_alu_op_o     <= `ALU_ADD; // Default to ADD
            ex_is_muldiv_o  <= 2'b0;
            ex_rd_addr_o    <= 5'b0; // Important to avoid accidental forwarding
            ex_pc_o         <= 32'b0;
            ex_read_data1_o <= 32'b0;
            ex_read_data2_o <= 32'b0;
            ex_imm_o        <= 32'b0;
            ex_rs1_addr_o   <= 5'b0;
            ex_rs2_addr_o   <= 5'b0;
        end else begin
            // Normal operation: Pass all data and control signals to the next stage.
            ex_pc_o         <= id_pc_i;
            ex_read_data1_o <= id_read_data1_i;
            ex_read_data2_o <= id_read_data2_i;
            ex_imm_o        <= id_imm_i;
            ex_rs1_addr_o   <= id_rs1_addr_i;
            ex_rs2_addr_o   <= id_rs2_addr_i;
            ex_rd_addr_o    <= id_rd_addr_i;

            ex_branch_o     <= id_branch_i;
            ex_mem_read_o   <= id_mem_read_i;
            ex_mem_write_o  <= id_mem_write_i;
            ex_mem_to_reg_o <= id_mem_to_reg_i;
            ex_reg_write_o  <= id_reg_write_i;
            ex_alu_src_a_o  <= id_alu_src_a_i;
            ex_alu_src_b_o  <= id_alu_src_b_i;
            ex_alu_op_o     <= id_alu_op_i;
            ex_is_muldiv_o  <= id_is_muldiv_i;
        end
    end

endmodule