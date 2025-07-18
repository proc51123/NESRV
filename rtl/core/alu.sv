// alu.sv
// Arithmetic Logic Unit for the RISC-V Processor
// Performs calculations based on the alu_op_i control signal.
// Uses named constants from definitions.sv for clarity.

`include "definitions.sv"

module alu #(
    parameter int XLEN = 32  // Can be changed to 64 for RV64
) (
    input  logic [`ALU_OP_WIDTH-1:0] alu_op_i,       // Control signal from Control Unit
    input  logic [XLEN-1:0]          operand_a_i,    // First operand (from rs1 or PC)
    input  logic [XLEN-1:0]          operand_b_i,    // Second operand (from rs2 or immediate)

    output logic [XLEN-1:0]          alu_result_o,   // Result of ALU operation
    output logic                     zero_flag_o, // High if result is zero (for branch comparison)
	output logic                     sign_flag_o,   // The sign bit (MSB) of the result
    output logic                     unsigned_less_than_o // High if operand_a < operand_b (unsigned)
);

    // Combinational logic for all ALU operations
    always_comb begin
        case (alu_op_i)
            `ALU_ADD:  alu_result_o = operand_a_i + operand_b_i;
            `ALU_SUB:  alu_result_o = operand_a_i - operand_b_i;
            `ALU_SLL:  alu_result_o = operand_a_i << operand_b_i[4:0];
            `ALU_SLT:  alu_result_o = ($signed(operand_a_i) < $signed(operand_b_i)) ? {{(XLEN-1){1'b0}}, 1'b1} : '0;
            `ALU_SLTU: alu_result_o = (operand_a_i < operand_b_i) ? {{(XLEN-1){1'b0}}, 1'b1} : '0;
            `ALU_XOR:  alu_result_o = operand_a_i ^ operand_b_i;
            `ALU_SRL:  alu_result_o = operand_a_i >> operand_b_i[4:0];
            `ALU_SRA:  alu_result_o = $signed(operand_a_i) >>> operand_b_i[4:0];
            `ALU_OR:   alu_result_o = operand_a_i | operand_b_i;
            `ALU_AND:  alu_result_o = operand_a_i & operand_b_i;

            default:   alu_result_o = 32'hdeadbeef; // Default to an obviously wrong value for debugging
        endcase
    end
   
    // --- Status Flag Assignments ---

    // The zero flag is asserted if the result of the operation is exactly zero.
    assign zero_flag_o = (alu_result_o == 32'b0);

    // The sign flag is simply the most significant bit of the result.
    assign sign_flag_o = alu_result_o[31];

    // This flag is needed for BLTU/BGEU. It performs a direct unsigned comparison.
    // Note: This is independent of the main ALU result for most operations.
    // For a SUB, this would be equivalent to the borrow bit.
    assign unsigned_less_than_o = (operand_a_i < operand_b_i);

endmodule

