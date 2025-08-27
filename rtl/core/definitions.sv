
`ifndef DEFINITIONS_SV
`define DEFINITIONS_SV

// RISC-V Instruction Opcodes (Instruction bits [6:0])

`define OPCODE_LUI      7'b0110111  // Load Upper Immediate
`define OPCODE_AUIPC    7'b0010111  // Add Upper Immediate to PC
`define OPCODE_JAL      7'b1101111  // Jump and Link
`define OPCODE_JALR     7'b1100111  // Jump and Link Register

`define OPCODE_BRANCH   7'b1100011  // Branch Instructions (BEQ, BNE, etc.)
`define OPCODE_LOAD     7'b0000011  // Load Instructions (LW, LH, LB, etc.)
`define OPCODE_STORE    7'b0100011  // Store Instructions (SW, SH, SB)

`define OPCODE_I_TYPE   7'b0010011  // Integer Register-Immediate Instructions (ADDI, SLTI, etc.)
`define OPCODE_R_TYPE   7'b0110011  // Integer Register-Register Instructions (ADD, SUB, MUL, etc.)

`define OPCODE_FENCE    7'b0001111  // Fence instruction


// Funct3 Codes (Instruction bits [14:12])

// For BRANCH instructions
`define FUNCT3_BEQ      3'b000
`define FUNCT3_BNE      3'b001
`define FUNCT3_BLT      3'b100
`define FUNCT3_BGE      3'b101
`define FUNCT3_BLTU     3'b110
`define FUNCT3_BGEU     3'b111

// For LOAD instructions
`define FUNCT3_LB       3'b000
`define FUNCT3_LH       3'b001
`define FUNCT3_LW       3'b010
`define FUNCT3_LBU      3'b100
`define FUNCT3_LHU      3'b101

// For STORE instructions
`define FUNCT3_SB       3'b000
`define FUNCT3_SH       3'b001
`define FUNCT3_SW       3'b010

// For I-Type and R-Type instructions (some are shared)
`define FUNCT3_ADD_SUB  3'b000  // ADDI, ADD, SUB
`define FUNCT3_SLL      3'b001  // SLLI, SLL
`define FUNCT3_SLT      3'b010  // SLTI, SLT
`define FUNCT3_SLTU     3'b011  // SLTIU, SLTU
`define FUNCT3_XOR      3'b100  // XORI, XOR
`define FUNCT3_SR       3'b101  // SRLI/SRAI, SRL/SRA
`define FUNCT3_OR       3'b110  // ORI, OR
`define FUNCT3_AND      3'b111  // ANDI, AND

// For M-Extension (all share R-Type opcode)
`define FUNCT3_MUL      3'b000  // MUL
`define FUNCT3_MULH     3'b001  // MULH
`define FUNCT3_MULHSU   3'b010  // MULHSU
`define FUNCT3_MULHU    3'b011  // MULHU
`define FUNCT3_DIV      3'b100  // DIV
`define FUNCT3_DIVU     3'b101  // DIVU
`define FUNCT3_REM      3'b110  // REM
`define FUNCT3_REMU     3'b111  // REMU


// Funct7 Codes (Instruction bits [31:25])

`define FUNCT7_ADD      7'b0000000
`define FUNCT7_SUB      7'b0100000
`define FUNCT7_SLL      7'b0000000
`define FUNCT7_SLT      7'b0000000
`define FUNCT7_SLTU     7'b0000000
`define FUNCT7_XOR      7'b0000000
`define FUNCT7_SRL      7'b0000000
`define FUNCT7_SRA      7'b0100000 // Note: SRAI also uses this funct7
`define FUNCT7_OR       7'b0000000
`define FUNCT7_AND      7'b0000000
`define FUNCT7_MULDIV   7'b0000001

`define ALU_OP_WIDTH 4
`define ALU_ADD     `ALU_OP_WIDTH'b0000
`define ALU_SUB     `ALU_OP_WIDTH'b0001
`define ALU_SLL     `ALU_OP_WIDTH'b0010
`define ALU_SLT     `ALU_OP_WIDTH'b0011
`define ALU_SLTU    `ALU_OP_WIDTH'b0100
`define ALU_XOR     `ALU_OP_WIDTH'b0101
`define ALU_SRL     `ALU_OP_WIDTH'b0110
`define ALU_SRA     `ALU_OP_WIDTH'b0111
`define ALU_OR      `ALU_OP_WIDTH'b1000
`define ALU_AND     `ALU_OP_WIDTH'b1001

`define ALU_MUL     `ALU_OP_WIDTH'b0000
`define ALU_MULH     `ALU_OP_WIDTH'b0001
`define ALU_MULSHU     `ALU_OP_WIDTH'b0010
`define ALU_MULHU     `ALU_OP_WIDTH'b0011
`define ALU_DIV    `ALU_OP_WIDTH'b0100
`define ALU_DIVU     `ALU_OP_WIDTH'b0101
`define ALU_REM     `ALU_OP_WIDTH'b0110
`define ALU_REMU     `ALU_OP_WIDTH'b0111


// Initial PC address at reset
`define RESET_PC        32'h00000000

`endif // DEFINITIONS_SV