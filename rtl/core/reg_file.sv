// reg_file.sv
// A 32-entry, 32-bit register file for the RISC-V processor.
// Features two asynchronous read ports and one synchronous write port.

module reg_file (
    input  logic        clk,
    input  logic        rst,

    // Write Port (from Write Back stage)
    input  logic        reg_write_en_i, // Write enable signal
    input  logic [4:0]  rd_addr_i,      // Address of WriteBack
    input  logic [31:0] rd_data_i,      // Data from WB

    // Read Port 1 (for rs1)
    input  logic [4:0]  rs1_addr_i,     // Address of the first register to read
    output logic [31:0] rs1_data_o,     // Data read from rs1_addr_i

    // Read Port 2 (for rs2)
    input  logic [4:0]  rs2_addr_i,     // Address of the second register to read
    output logic [31:0] rs2_data_o      // Data read from rs2_addr_i
);

    // The core of the register file: an array of 32 registers, each 32 bits wide.
    logic [31:0] registers[0:31];

    // Synchronous Write Logic
    // The write operation only occurs on the positive edge of the clock.
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // On reset, initialize all registers to zero.
            for (int i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end else begin
            // If write enable is high and the destination is not x0, write the data.
            // Writes to register x0 are ignored to keep it hardwired to zero.
            if (reg_write_en_i && (rd_addr_i != 5'b0)) begin
                registers[rd_addr_i] <= rd_data_i;
            end
        end
    end

    // Asynchronous Read Logic
    // The output changes immediately when the read address changes.
    // Reading from address 0 must always return 0.
    assign rs1_data_o = (rs1_addr_i == 5'b0) ? 32'b0 : registers[rs1_addr_i];
    assign rs2_data_o = (rs2_addr_i == 5'b0) ? 32'b0 : registers[rs2_addr_i];

endmodule
