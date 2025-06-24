// testbench.cpp

#include <iostream>
#include <verilated.h>
#include "Vmult_div_unit.h"
#include <cassert>
#include <bitset>
#include "definitions.h" 

void tick(Vmult_div_unit* dut);
void reset_dut(Vmult_div_unit* dut);
vluint64_t main_time = 0;
double sc_time_stamp() { return main_time; }


// Main test function to run a single operation
void run_test(Vmult_div_unit* dut, int32_t op_a, int32_t op_b, uint8_t funct3, int32_t expected_result, const std::string& test_name) {
    std::cout << "--------------------------------" << std::endl;
    std::cout << "Running Test: " << test_name << std::endl;
    std::cout << "  Inputs: A=" << op_a << ", B=" << op_b << ", funct3=0b" << std::bitset<3>(funct3) << std::endl;
    std::cout << "  Expected Result: " << expected_result << std::endl;
    
    assert(dut->ready_o == 1);

    dut->operand_a_i = op_a;
    dut->operand_b_i = op_b;
    dut->funct3_i = funct3;
    dut->start_i = 1;
    tick(dut);

    dut->start_i = 0;
    tick(dut);
    
    if (dut->ready_o == 1) {
        std::cout << "  (Single-cycle operation detected)" << std::endl;
    } else {
        std::cout << "  (Multi-cycle operation detected, waiting...)" << std::endl;
        int timeout = 40;
        while (dut->ready_o == 0 && timeout > 0) {
            tick(dut);
            timeout--;
            if (timeout == 0) {
                std::cerr << "[FAIL] Timeout waiting for unit to finish!" << std::endl;
                exit(1);
            }
        }
    }

    if (dut->result_o == expected_result) {
        std::cout << "  Actual Result:   " << (int32_t)dut->result_o << " -> [PASS]" << std::endl;
    } else {
        std::cerr << "  Actual Result:   " << (int32_t)dut->result_o << " -> [FAIL]" << std::endl;
        exit(1);
    }
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vmult_div_unit* dut = new Vmult_div_unit;

    reset_dut(dut);

    // --- Test Sequence using named constants ---
    run_test(dut, 5, 10, riscv::FUNCT3_MUL, 50, "MUL: 5 * 10");
    run_test(dut, -5, 10, riscv::FUNCT3_MUL, -50, "MUL: -5 * 10");
    run_test(dut, -5, -10, riscv::FUNCT3_MUL, 50, "MUL: -5 * -10");
    run_test(dut, 70000, 70000, riscv::FUNCT3_MULH, 1, "MULH: 70000 * 70000 (signed)");
    run_test(dut, -70000, 70000, riscv::FUNCT3_MULH, -2, "MULH: -70000 * 70000 (signed)");
    run_test(dut, 0xFFFFFFFF, 0xFFFFFFFF, riscv::FUNCT3_MULHU, 0xFFFFFFFE, "MULHU: unsigned max * max");

    run_test(dut, 100, 10, riscv::FUNCT3_DIV, 10, "DIV: 100 / 10");
    run_test(dut, 103, 10, riscv::FUNCT3_DIV, 10, "DIV: 103 / 10 (truncates)");
    run_test(dut, -100, 10, riscv::FUNCT3_DIV, -10, "DIV: -100 / 10");
    run_test(dut, 100, -10, riscv::FUNCT3_DIV, -10, "DIV: 100 / -10");
    run_test(dut, -100, -10, riscv::FUNCT3_DIV, 10, "DIV: -100 / -10");
    run_test(dut, 100, 10, riscv::FUNCT3_DIVU, 10, "DIVU: 100 / 10");

    run_test(dut, 103, 10, riscv::FUNCT3_REM, 3, "REM: 103 % 10");
    run_test(dut, 103, -10, riscv::FUNCT3_REM, 3, "REM: 103 % -10");
    run_test(dut, -103, 10, riscv::FUNCT3_REM, -3, "REM: -103 % 10");
    run_test(dut, -103, -10, riscv::FUNCT3_REM, -3, "REM: -103 % -10");
    run_test(dut, 103, 10, riscv::FUNCT3_REMU, 3, "REMU: 103 % 10");

    run_test(dut, 12345, 0, riscv::FUNCT3_DIVU, 0xFFFFFFFF, "DIVU by zero");
    run_test(dut, 12345, 0, riscv::FUNCT3_DIV, -1, "DIV by zero");
    run_test(dut, 12345, 0, riscv::FUNCT3_REMU, 12345, "REMU by zero");
    run_test(dut, 12345, 0, riscv::FUNCT3_REM, 12345, "REM by zero");
    run_test(dut, 0x80000000, -1, riscv::FUNCT3_DIV, 0x80000000, "DIV MIN_INT / -1");

    std::cout << "--------------------------------" <<  std::endl;
    std::cout << "All tests passed successfully!" << std::endl;

    dut->final();
    delete dut;

    return 0;
}


void tick(Vmult_div_unit* dut) {
    dut->clk = 0;
    dut->eval();
    main_time++;
    dut->clk = 1;
    dut->eval();
    main_time++;
}

void reset_dut(Vmult_div_unit* dut) {
    std::cout << "Resetting DUT..." << std::endl;
    dut->rst = 1;
    tick(dut);
    tick(dut);
    dut->rst = 0;
    assert(dut->ready_o == 1);
    std::cout << "Reset complete." << std::endl;
}

