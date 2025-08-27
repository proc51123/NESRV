`include "definitions.sv"

module control_unit (
    input  logic [6:0] opcode_i,
    input  logic [2:0] funct3_i,
    input  logic [6:0] funct7_i,

    output logic [1:0] branch_o,        
    output logic [1:0] mem_read_o,      
    output logic [1:0] mem_write_o,     
    output logic [1:0] mem_to_reg_o,    
    output logic [1:0] reg_write_o,     
    output logic [1:0] alu_src_a_o,     
    output logic [1:0] alu_src_b_o,     
    output logic [`ALU_OP_WIDTH-1:0] alu_op_o, 
    output logic [1:0] is_muldiv_o    
);

    // Default/safe values
    always_comb begin
        branch_o      = 2'b00;
        mem_read_o    = 2'b00;
        mem_write_o   = 2'b00;
        mem_to_reg_o  = 2'b00;
        reg_write_o   = 2'b00;
        alu_src_a_o   = 2'b00;
        alu_src_b_o   = 2'b00;
        alu_op_o      = `ALU_ADD; // safe default (address calc often uses ADD)
        is_muldiv_o   = 2'b00;

        unique case (opcode_i)

            // ----------------------------------------------------
            // R-type: register-register arithmetic (ADD,SUB,MUL,DIV,REM,...)
            // ----------------------------------------------------
            `OPCODE_R_TYPE: begin
                reg_write_o = 2'b01;   // write result to rd
                alu_src_a_o = 2'b00;   // rs1
                alu_src_b_o = 2'b00;   // rs2

                // M-extension instructions identified by funct7 == FUNCT7_MULDIV
                if (funct7_i == `FUNCT7_MULDIV) begin
                    // MUL/DIV/REM group (use funct3 to select)
                    case (funct3_i)
                        `FUNCT3_MUL:  begin alu_op_o = `ALU_MUL;  is_muldiv_o = 2'b01; end
                        `FUNCT3_MULH: begin alu_op_o = `ALU_MULH;  is_muldiv_o = 2'b01; end
                        `FUNCT3_MULHSU: begin alu_op_o = `ALU_MULSHU; is_muldiv_o = 2'b01; end
                        `FUNCT3_MULHU: begin alu_op_o = `ALU_MULHU; is_muldiv_o = 2'b01; end
                        `FUNCT3_DIV:  begin alu_op_o = `ALU_DIV;  is_muldiv_o = 2'b10; end
                        `FUNCT3_DIVU: begin alu_op_o = `ALU_DIVU;  is_muldiv_o = 2'b10; end
                        `FUNCT3_REM:  begin alu_op_o = `ALU_REM;  is_muldiv_o = 2'b10; end
                        `FUNCT3_REMU: begin alu_op_o = `ALU_REMU;  is_muldiv_o = 2'b10; end
                        default: begin alu_op_o = `ALU_ADD; is_muldiv_o = 2'b00; end
                    endcase
                end else begin
                    // Standard R-type operations based on funct3/funct7
                    unique case (funct3_i)
                        `FUNCT3_ADD_SUB: begin
                            if (funct7_i == `FUNCT7_SUB) alu_op_o = `ALU_SUB;
                            else                          alu_op_o = `ALU_ADD;
                        end
                        `FUNCT3_SLL:  alu_op_o = `ALU_SLL;
                        `FUNCT3_SLT:  alu_op_o = `ALU_SLT;
                        `FUNCT3_SLTU: alu_op_o = `ALU_SLTU;
                        `FUNCT3_XOR:  alu_op_o = `ALU_XOR;
                        `FUNCT3_SR:   begin
                            // SRLI vs SRAI distinction relies on funct7 (SRA uses FUNCT7_SRA)
                            if (funct7_i == `FUNCT7_SRA) alu_op_o = `ALU_SRA;
                            else                         alu_op_o = `ALU_SRL;
                        end
                        `FUNCT3_OR:   alu_op_o = `ALU_OR;
                        `FUNCT3_AND:  alu_op_o = `ALU_AND;
                        default:      alu_op_o = `ALU_ADD;
                    endcase
                end
            end

            // ----------------------------------------------------
            // I-type arithmetic (ADDI, SLTI, XORI, ORI, ANDI, shift-immediates)
            // ----------------------------------------------------
            `OPCODE_I_TYPE: begin
                reg_write_o = 2'b01;
                alu_src_a_o = 2'b00;    // rs1
                alu_src_b_o = 2'b01;    // immediate
                unique case (funct3_i)
                    `FUNCT3_ADD_SUB: alu_op_o = `ALU_ADD; // ADDI
                    `FUNCT3_SLL:     alu_op_o = `ALU_SLL; // SLLI
                    `FUNCT3_SLT:     alu_op_o = `ALU_SLT; // SLTI
                    `FUNCT3_XOR:     alu_op_o = `ALU_XOR; // XORI
                    `FUNCT3_SR: begin
                        if (funct7_i == `FUNCT7_SRA) alu_op_o = `ALU_SRA;
                        else                         alu_op_o = `ALU_SRL;
                    end
                    `FUNCT3_OR:      alu_op_o = `ALU_OR;
                    `FUNCT3_AND:     alu_op_o = `ALU_AND;
                    default:         alu_op_o = `ALU_ADD;
                endcase
            end

            // ----------------------------------------------------
            // Load instructions (LB/LH/LW/LBU/LHU)
            // ----------------------------------------------------
            `OPCODE_LOAD: begin
                reg_write_o  = 2'b01;    // write loaded value to rd
                mem_to_reg_o = 2'b01;    // select memory result in WB
                alu_src_a_o  = 2'b00;    // rs1 (base)
                alu_src_b_o  = 2'b01;    // immediate (offset)
                alu_op_o     = `ALU_ADD; // address calc: base + offset
                case (funct3_i)
                    `FUNCT3_LB:  mem_read_o = 2'b01;
                    `FUNCT3_LH:  mem_read_o = 2'b10;
                    `FUNCT3_LW:  mem_read_o = 2'b11;
                    `FUNCT3_LBU: mem_read_o = 2'b01;
                    `FUNCT3_LHU: mem_read_o = 2'b10;
                    default:     mem_read_o = 2'b00;
                endcase
            end

            // ----------------------------------------------------
            // Store instructions (SB/SH/SW)
            // ----------------------------------------------------
            `OPCODE_STORE: begin
                reg_write_o  = 2'b00;
                alu_src_a_o  = 2'b00;
                alu_src_b_o  = 2'b01;
                alu_op_o     = `ALU_ADD; // address calc
                case (funct3_i)
                    `FUNCT3_SB: mem_write_o = 2'b01;
                    `FUNCT3_SH: mem_write_o = 2'b10;
                    `FUNCT3_SW: mem_write_o = 2'b11;
                    default:    mem_write_o = 2'b00;
                endcase
            end

            // ----------------------------------------------------
            // Branch instructions (BEQ/BNE/BLT/BGE/BLTU/BGEU)
            // ----------------------------------------------------
            `OPCODE_BRANCH: begin
                reg_write_o  = 2'b00;
                branch_o     = 2'b10; // conditional branch
                alu_src_a_o  = 2'b00; // rs1
                alu_src_b_o  = 2'b00; // rs2
                case (funct3_i)
                    `FUNCT3_BEQ:  alu_op_o = `ALU_SUB; // check zero
                    `FUNCT3_BNE:  alu_op_o = `ALU_SUB; // check not zero
                    `FUNCT3_BLT:  alu_op_o = `ALU_SLT; // signed compare
                    `FUNCT3_BGE:  alu_op_o = `ALU_SLT; // invert result in branch logic
                    `FUNCT3_BLTU: alu_op_o = `ALU_SLTU;
                    `FUNCT3_BGEU: alu_op_o = `ALU_SLTU;
                    default:      alu_op_o = `ALU_SUB;
                endcase
            end

            // ----------------------------------------------------
            // JAL (Jump and Link)
            // ----------------------------------------------------
            `OPCODE_JAL: begin
                reg_write_o  = 2'b01;   // write PC+4 to rd
                mem_to_reg_o = 2'b10;   // PC+4 selection
                branch_o     = 2'b01;   // unconditional
                alu_src_a_o  = 2'b01;   // PC
                alu_src_b_o  = 2'b01;   // immediate (J-type)
                alu_op_o     = `ALU_ADD;
            end

            // ----------------------------------------------------
            // JALR (Jump and Link Register)
            // ----------------------------------------------------
            `OPCODE_JALR: begin
                reg_write_o  = 2'b01;
                mem_to_reg_o = 2'b10;
                branch_o     = 2'b01;
                alu_src_a_o  = 2'b00;   // rs1
                alu_src_b_o  = 2'b01;   // immediate
                alu_op_o     = `ALU_ADD;
            end

            // ----------------------------------------------------
            // LUI / AUIPC
            // ----------------------------------------------------
            `OPCODE_LUI: begin
                reg_write_o  = 2'b01;
                // EX stage will handle imm<<12; here set ALU to pass/ADD imm as needed
                alu_src_a_o  = 2'b00;
                alu_src_b_o  = 2'b01;
                alu_op_o     = `ALU_ADD;
            end

            `OPCODE_AUIPC: begin
                reg_write_o  = 2'b01;
                alu_src_a_o  = 2'b01; // PC
                alu_src_b_o  = 2'b01; // imm
                alu_op_o     = `ALU_ADD;
            end

            // ----------------------------------------------------
            // Default: unrecognized opcode -> keep all signals at safe defaults
            // ----------------------------------------------------
            default: begin
                // nothing to do (defaults already applied)
            end
        endcase
    end

endmodule


