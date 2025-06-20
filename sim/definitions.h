// definitions.h
// Comprehensive C++ constants corresponding to definitions.sv for the RV32IM testbench environment.
// This provides named constants for opcodes, funct3, and funct7 fields.

#ifndef DEFINITIONS_H
#define DEFINITIONS_H

#include <cstdint> // Required for uint8_t, uint32_t

namespace riscv {
    // RISC-V Instruction Opcodes (Instruction bits [6:0])
    enum Opcode : uint8_t {
        OPCODE_LUI      = 0b0110111,
        OPCODE_AUIPC    = 0b0010111,
        OPCODE_JAL      = 0b1101111,
        OPCODE_JALR     = 0b1100111,
        OPCODE_BRANCH   = 0b1100011,
        OPCODE_LOAD     = 0b0000011,
        OPCODE_STORE    = 0b0100011,
        OPCODE_I_TYPE   = 0b0010011, // Integer Register-Immediate
        OPCODE_R_TYPE   = 0b0110011, // Integer Register-Register
        OPCODE_FENCE    = 0b0001111
    };

    // Funct3 Codes (Instruction bits [14:12])
    // These distinguish between instructions that share an opcode.
    
    // For BRANCH instructions
    enum Funct3_Branch : uint8_t {
        FUNCT3_BEQ      = 0b000,
        FUNCT3_BNE      = 0b001,
        FUNCT3_BLT      = 0b100,
        FUNCT3_BGE      = 0b101,
        FUNCT3_BLTU     = 0b110,
        FUNCT3_BGEU     = 0b111
    };

    // For LOAD instructions
    enum Funct3_Load : uint8_t {
        FUNCT3_LB       = 0b000,
        FUNCT3_LH       = 0b001,
        FUNCT3_LW       = 0b010,
        FUNCT3_LBU      = 0b100,
        FUNCT3_LHU      = 0b101
    };

    // For STORE instructions
    enum Funct3_Store : uint8_t {
        FUNCT3_SB       = 0b000,
        FUNCT3_SH       = 0b001,
        FUNCT3_SW       = 0b010
    };

    // For I-Type and R-Type instructions (some are shared)
    enum Funct3_IR_Type : uint8_t {
        FUNCT3_ADD_SUB  = 0b000, // ADDI, ADD, SUB
        FUNCT3_SLL      = 0b001, // SLLI, SLL
        FUNCT3_SLT      = 0b010, // SLTI, SLT
        FUNCT3_SLTU     = 0b011, // SLTIU, SLTU
        FUNCT3_XOR      = 0b100, // XORI, XOR
        FUNCT3_SR       = 0b101, // SRLI/SRAI, SRL/SRA
        FUNCT3_OR       = 0b110, // ORI, OR
        FUNCT3_AND      = 0b111  // ANDI, AND
    };

    // For M-Extension instructions
    enum Funct3_M_Ext : uint8_t {
        FUNCT3_MUL      = 0b000,
        FUNCT3_MULH     = 0b001,
        FUNCT3_MULHSU   = 0b010,
        FUNCT3_MULHU    = 0b011,
        FUNCT3_DIV      = 0b100,
        FUNCT3_DIVU     = 0b101,
        FUNCT3_REM      = 0b110,
        FUNCT3_REMU     = 0b111
    };

    // Funct7 Codes (Instruction bits [31:25])
    // These primarily distinguish between R-Type instructions.
    const uint8_t FUNCT7_ADD      = 0b0000000;
    const uint8_t FUNCT7_SUB      = 0b0100000;
    const uint8_t FUNCT7_SRA      = 0b0100000;
    const uint8_t FUNCT7_MULDIV   = 0b0000001;
    // For many instructions (SLL, SLT, XOR, SRL, OR, AND), Funct7 is 0b0000000

    // Miscellaneous Constants
    // A NOP (No-Operation) instruction is encoded as `addi x0, x0, 0`
    const uint32_t NOP_INSTRUCTION = 0x00000013;

} // namespace riscv

#endif // DEFINITIONS_H
