module reg_file(
    input [4:0] read_reg_num1, read_reg_num2, write_reg,
    input [31:0] write_data,
    output [31:0] read_data1, read_data2,
    input regwrite, clock, reset
);
    reg [31:0] reg_memory [31:0];
    integer k;

    assign read_data1 = (read_reg_num1 == 0) ? 32'b0 : reg_memory[read_reg_num1];
    assign read_data2 = (read_reg_num2 == 0) ? 32'b0 : reg_memory[read_reg_num2];

    always @(posedge clock) begin
        if (regwrite && write_reg != 0) reg_memory[write_reg] <= write_data;
    end

    always @(posedge reset) begin
        for (k=0; k<32; k=k+1) reg_memory[k] = k;
    end
endmodule