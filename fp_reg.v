module fp_reg(
    input [4:0] read_reg_num1, read_reg_num2, read_reg_num3, write_reg,
    input [63:0] write_data,
    output [63:0] read_data1, read_data2, read_data3,
    input fp_regwrite, clock, reset
);
    reg [63:0] fp_memory [31:0];
    integer k;

    assign read_data1 = fp_memory[read_reg_num1];
    assign read_data2 = fp_memory[read_reg_num2];
    assign read_data3 = fp_memory[read_reg_num3];

    always @(posedge clock) begin
        if (fp_regwrite) fp_memory[write_reg] <= write_data;
    end

    always @(posedge reset) begin
        for (k=0; k<32; k=k+1) fp_memory[k] = {32'h40000000, 32'h00000000 | k};
    end
endmodule