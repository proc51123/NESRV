// if_stage.sv
// Instruction Fetch (IF) stage of the RISC-V processor.
// Fetches instructions from memory based on the Program Counter (PC).
// Uses named constants from definitions.sv.

`include "definitions.sv"

module if_stage (
    input  logic        clk,
    input  logic        rst,

    // Control signals from Hazard Unit
    input  logic        pc_stall_i,      // Freezes the PC when high
    input  logic        pc_src_i,        // 0: Next PC is PC+4, 1: Next PC is branch/jump target
    input  logic [31:0] branch_target_i, // The target address for a branch or jump

    // Outputs to instruction memory and the IF/ID register
    output logic [31:0] pc_o             // The address of the instruction to fetch
);

    logic [31:0] pc_reg;
    logic [31:0] pc_next;
    logic [31:0] pc_plus_4;

    // The Program Counter (PC) register.
    // On reset, it loads the `RESET_PC` address from definitions.sv.
    // It can be stalled by the hazard unit.
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_reg <= `RESET_PC;
        end else if (!pc_stall_i) begin
            pc_reg <= pc_next;
        end
        // If pc_stall_i is high, pc_reg holds its value.
    end

    // Combinational logic to determine the address of the next instruction.
    assign pc_plus_4 = pc_reg + 4;
    assign pc_next = pc_src_i ? branch_target_i : pc_plus_4;

    // The output of this stage is the current PC address, which is sent to
    // instruction memory and the IF/ID pipeline register.
    assign pc_o = pc_reg;

endmodule

