module datapath(
    input [31:0] instr,
    input [3:0] alu_ctrl,
    input [4:0] fpu_ctrl,
    input regwrite, fp_regwrite, alusrc, mem_read, mem_write, mem_to_reg,
    input clk, rst,
    output [31:0] result_out
);
    wire [31:0] rd1, rd2, alu_in2, alu_res, mem_data;
    wire [63:0] fp_rd1, fp_rd2, fp_rd3, fp_res;
    reg [31:0] imm;
    wire zero;
    // UPDATED: Added 7'b1001111 for FNMADD.S
    wire is_fp_instr = (instr[6:0] == 7'b1010011 || instr[6:0] == 7'b1000011 || instr[6:0] == 7'b1000111 || instr[6:0] == 7'b1001011 || instr[6:0] == 7'b1001111);

    always @(*) begin
        case (instr[6:0])
            7'b0100011, 7'b0100111: imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            7'b1100011: imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            7'b0110111, 7'b0010111: imm = {instr[31:12], 12'b0};
            7'b1101111: imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
            default:    imm = {{20{instr[31]}}, instr[31:20]};
        endcase
    end

    reg_file reg_file_module(instr[19:15], instr[24:20], instr[11:7], result_out, rd1, rd2, regwrite, clk, rst);
    fp_reg fp_reg_file(instr[19:15], instr[24:20], instr[31:27], instr[11:7], fp_res, fp_rd1, fp_rd2, fp_rd3, fp_regwrite, clk, rst);

    assign alu_in2 = (alusrc) ? imm : rd2;
    alu alu_module(rd1, alu_in2, alu_ctrl, alu_res, zero);
    fpu fpu_module(fp_rd1, fp_rd2, fp_rd3, fpu_ctrl, fp_res); 
    data_mem dmem_unit(clk, mem_read, mem_write, alu_res, rd2, mem_data);
    
    assign result_out = (mem_to_reg) ? mem_data : (is_fp_instr ? fp_res[31:0] : alu_res);
endmodule