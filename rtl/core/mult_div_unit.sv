// mult_div_unit.sv
// Multi-cycle unit for RV32M Multiplication and Division instructions.

`include "definitions.sv" // Include the definitions file

module mult_div_unit (
    input  logic        clk,
    input  logic        rst,

    // Interface to the EX Stage
    input  logic        start_i,
    input  logic [31:0] operand_a_i,
    input  logic [31:0] operand_b_i,
    input  logic [2:0]  funct3_i,

    output logic [31:0] result_o,
    output logic        ready_o
);

    // State machine definition
    typedef enum logic [1:0] {
        S_IDLE,
        S_CALC,
        S_DONE
    } state_e;

    state_e current_state, next_state;

    // Internal registers
    logic [31:0] divisor;
    logic [63:0] product;
    logic [63:0] remainder_quotient;
    logic [5:0]  cycle_counter;
    logic        op_a_sign, op_b_sign;

    // State Machine Register
    always_ff @(posedge clk or posedge rst) begin
        if (rst) current_state <= S_IDLE;
        else     current_state <= next_state;
    end

    // Calculation Logic (Sequential)
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            cycle_counter      <= 6'd0;
            product            <= 64'd0;
            remainder_quotient <= 64'd0;
            op_a_sign          <= 1'b0;
            op_b_sign          <= 1'b0;
            divisor            <= 32'd0;
        end else begin
            case (current_state)
                S_IDLE: begin
                    if (start_i) begin
                        op_a_sign <= operand_a_i[31];
                        op_b_sign <= operand_b_i[31];
                        if (funct3_i[2] == 1'b0) begin // Multiplication
                            if (funct3_i == `FUNCT3_MULH)      product <= $signed(operand_a_i) * $signed(operand_b_i);
                            else if (funct3_i == `FUNCT3_MULHSU) product <= $signed(operand_a_i) * $unsigned(operand_b_i);
                            else                                 product <= operand_a_i * operand_b_i;
                        end else begin // Division/Remainder
                            divisor            <= (operand_b_i[31] ? -operand_b_i : operand_b_i);
                            remainder_quotient <= {32'h0, (operand_a_i[31] ? -operand_a_i : operand_a_i)};
                            cycle_counter      <= 6'd32;
                        end
                    end
                end
                S_CALC: begin
                    if (cycle_counter > 0) begin
                        logic [31:0] r_old = remainder_quotient[63:32];
                        logic [31:0] q_old = remainder_quotient[31:0];
                        logic [31:0] r_new, q_new;
                        logic [31:0] r_shifted = {r_old[30:0], q_old[31]};
                        if (r_old[31] == 1'b0) r_new = r_shifted - divisor;
                        else                   r_new = r_shifted + divisor;
                        q_new = {q_old[30:0], ~r_new[31]};
                        remainder_quotient <= {r_new, q_new};
                        cycle_counter <= cycle_counter - 1;
                    end
                end
                // --- THIS BLOCK IS THE FIX ---
                S_DONE: begin
                    // Hold results, do nothing.
                end
                default: begin
                    // If in an illegal state, reset calculation registers.
                    cycle_counter      <= 6'd0;
                    product            <= 64'd0;
                    remainder_quotient <= 64'd0;
                end
            endcase
        end
    end
    
    // State Transition Logic
    always_comb begin
        next_state = current_state;
        case (current_state)
            S_IDLE: if (start_i) next_state = (funct3_i[2] == 1'b0) ? S_DONE : S_CALC;
            S_CALC: if (cycle_counter == 1) next_state = S_DONE;
            S_DONE: if (!start_i) next_state = S_IDLE;
            default: next_state = S_IDLE;
        endcase
    end
    
    // Output Logic
    assign ready_o = (current_state == S_IDLE) || (current_state == S_DONE);
    
    logic [31:0] quotient, remainder, final_quotient, final_remainder;

    assign remainder = (remainder_quotient[63]) ? remainder_quotient[63:32] + divisor : remainder_quotient[63:32];
    assign quotient  = remainder_quotient[31:0];
    assign final_quotient = (op_a_sign ^ op_b_sign) ? -quotient : quotient;
    assign final_remainder = op_a_sign ? -remainder : remainder;

    always_comb begin
        result_o = 32'b0;
        // Use named constants for clarity
        case (funct3_i)
            `FUNCT3_MUL:    result_o = product[31:0];
            `FUNCT3_MULH:   result_o = product[63:32];
            `FUNCT3_MULHSU:  result_o = product[63:32];
            `FUNCT3_MULHU:  result_o = product[63:32];
            `FUNCT3_DIV: begin
                if (operand_b_i == 32'b0) result_o = 32'hFFFFFFFF;
                else if (operand_a_i == 32'h80000000 && operand_b_i == 32'hFFFFFFFF) result_o = operand_a_i;
                else result_o = final_quotient;
            end
            `FUNCT3_DIVU: begin
                if (operand_b_i == 32'b0) result_o = 32'hFFFFFFFF;
                else result_o = quotient;
            end
            `FUNCT3_REM: begin
                if (operand_b_i == 32'b0) result_o = operand_a_i;
                else if (operand_a_i == 32'h80000000 && operand_b_i == 32'hFFFFFFFF) result_o = 32'b0;
                else result_o = final_remainder;
            end
            `FUNCT3_REMU: begin
                if (operand_b_i == 32'b0) result_o = operand_a_i;
                else result_o = remainder;
            end
            default: result_o = 32'b0;
        endcase
    end

endmodule
