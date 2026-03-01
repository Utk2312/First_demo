module processor( 
    input clock, reset, 
    input [31:0] instruction_code,
    output [31:0] pc, 
    output zero, 
    output [31:0] result_out
);
    wire [3:0] alu_control; wire [4:0] fpu_ctrl;
    wire regwrite, fp_regwrite, alusrc, mem_to_reg, mem_read, mem_write;

    ifu ifu_module(clock, reset, pc);

    control control_module(
        instruction_code[31:25], instruction_code[14:12], instruction_code[6:0],   
        alu_control, fpu_ctrl, regwrite, fp_regwrite, alusrc, mem_to_reg, mem_read, mem_write
    );

    datapath datapath_module(
        instruction_code, alu_control, fpu_ctrl, regwrite, fp_regwrite,
        alusrc, mem_read, mem_write, mem_to_reg, clock, reset, result_out
    );

    assign zero = (result_out == 0);
endmodule