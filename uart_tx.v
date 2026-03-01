// uart_tx.v
module uart_tx #(parameter CLKS_PER_BIT = 868)(
    input clk, reset, input tx_start, input [7:0] tx_data,
    output reg tx, output reg tx_busy
);
    reg [2:0] state; reg [9:0] clk_count; reg [2:0] bit_index;
    always @(posedge clk or posedge reset) begin
        if (reset) begin tx <= 1; tx_busy <= 0; state <= 0; end
        else case (state)
            0: if (tx_start) begin tx_busy <= 1; tx <= 0; clk_count <= 0; state <= 1; end
            1: if (clk_count < CLKS_PER_BIT-1) clk_count <= clk_count + 1;
               else begin clk_count <= 0; tx <= tx_data[0]; bit_index <= 0; state <= 2; end
            2: if (clk_count < CLKS_PER_BIT-1) clk_count <= clk_count + 1;
               else begin
                   clk_count <= 0;
                   if (bit_index < 7) begin bit_index <= bit_index + 1; tx <= tx_data[bit_index+1]; end
                   else begin tx <= 1; state <= 3; end
               end
            3: if (clk_count < CLKS_PER_BIT-1) clk_count <= clk_count + 1;
               else begin tx_busy <= 0; state <= 0; end
        endcase
    end
endmodule