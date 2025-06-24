// reg_file_tb.cpp

#include <iostream>
#include <verilated.h>
#include "Vreg_file.h" 
#include <cassert>     

// Keep track of simulation time
vluint64_t main_time = 0;

// Called by $time in Verilog
double sc_time_stamp() {
    return main_time;
}

// Helper function to tick the clock
void tick(Vreg_file* dut) {
    dut->clk = 0;
    dut->eval();
    main_time++;
    dut->clk = 1;
    dut->eval();
    main_time++;
}

// Helper function to write to a register
void write_reg(Vreg_file* dut, uint8_t addr, uint32_t data) {
    dut->reg_write_en_i = 1;
    dut->rd_addr_i = addr;
    dut->rd_data_i = data;
    tick(dut); // Commit the write on the clock edge
    dut->reg_write_en_i = 0; // De-assert write enable
}

// Helper function to read from two registers simultaneously
void read_regs(Vreg_file* dut, uint8_t addr1, uint8_t addr2) {
    dut->rs1_addr_i = addr1;
    dut->rs2_addr_i = addr2;
    dut->eval(); // Update outputs based on new addresses
}

int main(int argc, char** argv) {
    // Initialize Verilator
    Verilated::commandArgs(argc, argv);

    // Instantiate the DUT
    Vreg_file* dut = new Vreg_file;

    // --- Start of Test Sequence ---
    std::cout << "Starting Register File Testbench..." << std::endl;
    
    // 1. Apply Reset
    dut->rst = 1;
    tick(dut);
    dut->rst = 0;
    std::cout << "Reset applied." << std::endl;

    // 2. Write to several registers
    std::cout << "\n--- Writing to Registers ---" << std::endl;
    write_reg(dut, 5, 0xAAAAAAAA);
    std::cout << "Wrote 0xAAAAAAAA to x5" << std::endl;
    write_reg(dut, 10, 0x55555555);
    std::cout << "Wrote 0x55555555 to x10" << std::endl;
    write_reg(dut, 31, 0x12345678);
    std::cout << "Wrote 0x12345678 to x31" << std::endl;

    // 3. Attempt to write to x0 (the zero register)
    std::cout << "\n--- Testing Zero Register (x0) ---" << std::endl;
    write_reg(dut, 0, 0xFFFFFFFF);
    std::cout << "Attempted to write 0xFFFFFFFF to x0" << std::endl;
    
    tick(dut); // Give a cycle for reads to settle

    // 4. Read back and verify all values
    std::cout << "\n--- Reading and Verifying ---" << std::endl;
    
    // Read x5 and x10
    read_regs(dut, 5, 10);
    assert(dut->rs1_data_o == 0xAAAAAAAA);
    std::cout << "[PASS] Read from x5 correct: 0x" << std::hex << dut->rs1_data_o << std::endl;
    assert(dut->rs2_data_o == 0x55555555);
    std::cout << "[PASS] Read from x10 correct: 0x" << std::hex << dut->rs2_data_o << std::endl;

    // Read x31 and x0
    read_regs(dut, 31, 0);
    assert(dut->rs1_data_o == 0x12345678);
    std::cout << "[PASS] Read from x31 correct: 0x" << std::hex << dut->rs1_data_o << std::endl;
    assert(dut->rs2_data_o == 0x00000000);
    std::cout << "[PASS] Read from x0 is zero, as expected." << std::endl;
    
    // Read from an unwritten register (should be 0 from reset)
    read_regs(dut, 20, 0);
    assert(dut->rs1_data_o == 0x00000000);
    std::cout << "[PASS] Read from unwritten register x20 is zero." << std::endl;

    // Final check on x0 to be sure
    read_regs(dut, 0, 0);
    assert(dut->rs1_data_o == 0 && dut->rs2_data_o == 0);
    std::cout << "[PASS] Confirmed x0 is still zero after write attempt." << std::endl;

    // --- End of Test Sequence ---
    std::cout << "\nAll tests passed successfully!" << std::endl;

    // Cleanup
    dut->final();
    delete dut;

    return 0;
}