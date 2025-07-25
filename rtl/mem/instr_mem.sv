// instr_mem.sv
// A simple combinational-read instruction memory for the RISC-V processor.

module instr_mem (
    input  logic [31:0] pc_o,
    output logic [31:0] instruction_o
);

    // Define the size of the memory. 256 words = 1024 bytes (1KB).
    localparam MEM_DEPTH = 256;

    // Declare the memory array. This is an array of 32-bit words.
    logic [31:0] memory[0:MEM_DEPTH-1];

    // Pre-load the memory from an external hex file at the start of the simulation.
    // Verilator will need to know where to find this file.
    initial begin
        $readmemh("program.mem", memory);
    end

    // Combinational read logic.
    // The address from the PC is a byte address. We convert it to a word address
    // by taking the upper 30 bits (effectively dividing by 4).
    assign instruction_o = memory[pc_o[31:2]];

endmodule