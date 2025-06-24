// ALU TESTBENCH 

#include "Valu.h"
#include "verilated.h"
#include <iostream>
#include <iomanip>
#include <bitset>
#include "definitions.h"

void run_test(Valu* alu, uint8_t op, uint32_t a, uint32_t b, const std::string& label) {
    alu->alu_op_i = op;
    alu->operand_a_i = a;
    alu->operand_b_i = b;

    alu->eval(); // Evaluate combinational logic

    std::cout << std::left << std::setw(10) << label
              << " | OP: " << std::bitset<4>(op)
              << " | A: 0x" << std::hex << std::setw(8) << std::setfill('0') << a
              << " | B: 0x" << std::hex << std::setw(8) << b
              << " | Result: 0x" << std::hex << alu->alu_result_o
              << " | Zero: " << std::dec << alu->zero_flag_o << std::endl;
}

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);
    Valu* alu = new Valu;

    std::cout << "===== ALU Verilator Test Start =====\n";

    run_test(alu, ALU_ADD,  10, 5,    "ADD");
    run_test(alu, ALU_SUB,  10, 10,   "SUB");
    run_test(alu, ALU_SLL,  1, 4,     "SLL");
    run_test(alu, ALU_SLT,  2, 3,     "SLT");
    run_test(alu, ALU_SLTU, 0xFFFFFFFF, 1, "SLTU");
    run_test(alu, ALU_XOR,  0x0F0F0F0F, 0xF0F0F0F0, "XOR");
    run_test(alu, ALU_SRL,  0x000000F0, 4, "SRL");
    run_test(alu, ALU_SRA,  0xF0000000, 4, "SRA");
    run_test(alu, ALU_OR,   0x0F00, 0x00F0, "OR");
    run_test(alu, ALU_AND,  0x0F0F, 0x00FF, "AND");

    std::cout << "===== ALU Verilator Test Complete =====\n";

    delete alu;
    return 0;
}
