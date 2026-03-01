module data_mem (
    input clk, mem_read, mem_write,
    input [31:0] addr, write_data,
    output [31:0] read_data
);
    reg [31:0] memory [0:255];

    assign read_data = (mem_read) ? memory[addr[7:2]] : 32'h11223344;

    always @(posedge clk) begin
        if (mem_write) memory[addr[7:2]] <= write_data;
    end

    integer i;
    initial begin
        for(i=0; i<256; i=i+1) memory[i] = 32'h11223344;
    end
endmodule