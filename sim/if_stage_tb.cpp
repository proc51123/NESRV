#include "Vif_stage.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <iostream>

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    Vif_stage* dut = new Vif_stage;

    VerilatedVcdC* tfp = new VerilatedVcdC;
    Verilated::traceEverOn(true);
    dut->trace(tfp, 99);
    tfp->open("if_stage.vcd");

    vluint64_t sim_time = 0;

    // Initialize inputs
    dut->clk = 0;
    dut->rst = 1;
    dut->pc_stall_i = 0;
    dut->pc_src_i = 0;
    dut->branch_target_i = 0x10;

    while (!Verilated::gotFinish() && sim_time < 200) {
        dut->clk = !dut->clk;

        if (sim_time == 10) {
            dut->rst = 0;
        }

        if (sim_time == 40) {
            dut->pc_src_i = 1;
            dut->branch_target_i = 0x100;
        }

        if (sim_time == 80) {
            dut->pc_src_i = 0;
        }

        if (sim_time == 120) {
            dut->pc_stall_i = 1;
        }

        if (sim_time == 160) {
            dut->pc_stall_i = 0;
        }

        dut->eval();
        tfp->dump(sim_time);
        sim_time += 1;
    }

    tfp->close();
    delete dut;
    delete tfp;
    return 0;
}

