// id_stage.sv

module id_stage (
    // Inputs from IF/ID Pipeline Register
    input wire [31:0] id_pc_i,
    input wire [31:0] id_instr_i,

    // Inputs from Write Back (WB) Stage (Feedback for Register File)
    input wire        wb_reg_write_en_i,
    input wire [4:0]  wb_rd_addr_i,
    input wire [31:0] wb_result_i,

    // Outputs to ID/EX Pipeline Register (Data Path)
    output wire [31:0] ex_pc_o,
    output wire [31:0] ex_read_data1_o,
    output wire [31:0] ex_read_data2_o,
    output wire [31:0] ex_imm_o,

    // Outputs to ID/EX Pipeline Register (Control Signals)
    output wire        ex_branch_o,
    output wire        ex_mem_read_o,
    output wire        ex_mem_write_o,
    output wire        ex_reg_write_o,
    output wire [1:0]  ex_alu_src_a_o,
    output wire [1:0]  ex_alu_src_b_o,
    output wire [4:0]  ex_alu_op_o,
    output wire [1:0]  ex_mem_to_reg_o,
    output wire        ex_jump_o, // Assuming a jump control signal from the control unit

    // Outputs to ID/EX Pipeline Register (Debugging/Hazard Unit Values)
    output wire [4:0]  ex_rs1_addr_o,
    output wire [4:0]  ex_rs2_addr_o,
    output wire [4:0]  ex_rd_addr_o
);

    // --- Internal Wires for Instruction Parsing ---
    wire [6:0] opcode   = id_instr_i[6:0];
    wire [4:0] rd_addr  = id_instr_i[11:7];
    wire [2:0] funct3   = id_instr_i[14:12];
    wire [4:0] rs1_addr = id_instr_i[19:15];
    wire [4:0] rs2_addr = id_instr_i[24:20];
    wire [6:0] funct7   = id_instr_i[31:25];

    // --- Wires for connecting sub-module outputs to id_stage outputs ---
    wire [31:0] rf_read_data1;
    wire [31:0] rf_read_data2;
    wire [31:0] immediate_value;

    wire        ctrl_branch;
    wire        ctrl_mem_read;
    wire        ctrl_mem_write;
    wire        ctrl_reg_write;
    wire [1:0]  ctrl_alu_src_a;
    wire [1:0]  ctrl_alu_src_b;
    wire [4:0]  ctrl_alu_op;
    wire [1:0]  ctrl_mem_to_reg;
    wire        ctrl_jump;

    // --- Instantiate Sub-Components ---

    // Control Unit Instance
    // Make sure the port names match your control_unit.sv module
    control_unit ctrl_unit_inst (
        .opcode_i    (opcode),
        .funct3_i    (funct3),
        .funct7_i    (funct7),
        .branch_o    (ctrl_branch),
        .mem_read_o  (ctrl_mem_read),
        .mem_write_o (ctrl_mem_write),
        .reg_write_o (ctrl_reg_write),
        .alu_src_a_o (ctrl_alu_src_a),
        .alu_src_b_o (ctrl_alu_src_b),
        .alu_op_o    (ctrl_alu_op),
        .mem_to_reg_o(ctrl_mem_to_reg),
        .jump_o      (ctrl_jump) // Assuming 'jump_o' is an output from your control_unit
    );

    // Immediate Generator Instance
    // Make sure the port names match your imm_gen.sv module
    imm_gen imm_gen_inst (
        .instr_i (id_instr_i),
        .imm_o   (immediate_value)
    );

    // Register File Instance
    // Make sure the port names match your reg_file.sv module
    reg_file reg_file_inst (
        .clk_i         (clk), // Assuming you will have a clock input to the ID stage
        .rs1_addr_i    (rs1_addr),
        .rs2_addr_i    (rs2_addr),
        .read_data1_o  (rf_read_data1),
        .read_data2_o  (rf_read_data2),
        .reg_write_en_i(wb_reg_write_en_i),
        .rd_addr_i     (wb_rd_addr_i),
        .rd_data_i     (wb_result_i)
    );

    // --- Connect Outputs to ID/EX Pipeline Register ---

    // Data Path Outputs
    assign ex_pc_o          = id_pc_i;
    assign ex_read_data1_o  = rf_read_data1;
    assign ex_read_data2_o  = rf_read_data2;
    assign ex_imm_o         = immediate_value;

    // Control Signal Outputs
    assign ex_branch_o      = ctrl_branch;
    assign ex_mem_read_o    = ctrl_mem_read;
    assign ex_mem_write_o   = ctrl_mem_write;
    assign ex_reg_write_o   = ctrl_reg_write;
    assign ex_alu_src_a_o   = ctrl_alu_src_a;
    assign ex_alu_src_b_o   = ctrl_alu_src_b;
    assign ex_alu_op_o      = ctrl_alu_op;
    assign ex_mem_to_reg_o  = ctrl_mem_to_reg;
    assign ex_jump_o        = ctrl_jump;

    // Debugging/Hazard Unit Values Outputs
    assign ex_rs1_addr_o    = rs1_addr;
    assign ex_rs2_addr_o    = rs2_addr;
    assign ex_rd_addr_o     = rd_addr;

endmodule