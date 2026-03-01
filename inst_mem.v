module inst_mem(
    input clk, write_en,
    input [31:0] write_addr, write_data,
    input [31:0] read_addr,
    output [31:0] read_data
);
    reg [7:0] memory [0:4095]; // Updated to 4KB limit

    assign read_data = {memory[read_addr+3], memory[read_addr+2], memory[read_addr+1], memory[read_addr]};

    always @(posedge clk) begin
        if (write_en) begin
            memory[write_addr]   <= write_data[7:0];
            memory[write_addr+1] <= write_data[15:8];
            memory[write_addr+2] <= write_data[23:16];
            memory[write_addr+3] <= write_data[31:24];
        end
    end
endmodule