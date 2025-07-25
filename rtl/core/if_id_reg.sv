// if_id_register.sv
// The pipeline register between the Instruction Fetch (IF) and
// Instruction Decode (ID) stages. It holds the fetched instruction and its PC,
// and can be stalled or flushed by the Hazard Unit.

`include "definitions.sv"

module if_id_register (
    input  logic        clk,
    input  logic        rst,

    // Control signals from Hazard Unit
    input  logic        if_id_stall_i,   // When high, register holds its value
    input  logic        if_id_flush_i,   // When high, register is cleared to a NOP

    // Data inputs from IF stage & Instruction Memory
    input  logic [31:0] pc_o,         // PC of the fetched instruction
    input  logic [31:0] instruction_o,      // The 32-bit instruction word from memory

    // Data outputs to ID stage
    output logic [31:0] id_pc_o,
    output logic [31:0] id_instr_o
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // On reset, initialize outputs to a known, safe state.
            id_pc_o    <= 32'b0;
            id_instr_o <= `NOP_INSTRUCTION;
        end else if (if_id_flush_i) begin
            // On a flush (e.g., for a taken branch), insert a NOP.
            // This effectively cancels the instruction that was just fetched.
            id_pc_o    <= 32'b0;
            id_instr_o <= `NOP_INSTRUCTION;
        end else if (!if_id_stall_i) begin
            // If not stalled or flushed, pass the inputs through to the outputs.
            // This is the normal pipeline operation.
            id_pc_o    <= pc_o;
            id_instr_o <= instruction_o;
        end
        // If if_id_stall_i is high, the register holds its previous value,
        // effectively stalling the instruction in this stage.
    end

endmodule
