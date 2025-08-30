module extend(
input logic [31:7] instr,
input logic [2:0] immsrcD_i
output logic [31:0] immext),

always_comb
    case(immsrcD_i)
        // I−type signed
        3'b000: immext = {{20{instr[31]}}, instr[31:20]};

        // S−type (stores) signed
        3'b001: immext = {{20{instr[31]}}, instr[31:25], instr[11:7]};

        // B−type (branches) signed
        3'b010: immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1’b0};

        // J−type (jal)
        3'b011: immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1’b0};


        // I−type unsigned
        3'b100: immext = {20'b0, instr[31:20]};
        
        // slli, srli. srai
        3'b101: immext = {27'b0, instr[24:20]};

        // B−type (branches) unsigned
        3'b110: immext = {20'b0, instr[7], instr[30:25], instr[11:8], 1’b0};

        // U-type 
        3b'111: immext = {instr[31:12], 12'b0};


        default: immext = 32'bx; // undefined
    endcase
endmodule