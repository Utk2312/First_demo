module uart_rx #(
    parameter CLKS_PER_BIT = 868 // Set for 100MHz Clock and 115200 Baud Rate
)(
    input clk,
    input reset,
    input rx,
    output reg [7:0] rx_data,
    output reg rx_valid
);
    reg [2:0] state;
    reg [9:0] clk_count;
    reg [2:0] bit_index;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= 3'b000;
            clk_count <= 0;
            bit_index <= 0;
            rx_valid <= 0;
            rx_data <= 8'b0;
        end else begin
            case (state)
                3'b000: begin // IDLE State
                    rx_valid <= 0;
                    clk_count <= 0;
                    bit_index <= 0;
                    if (rx == 1'b0) state <= 3'b001; // Start bit detected
                end
                
                3'b001: begin // START BIT State
                    if (clk_count == (CLKS_PER_BIT)/2) begin
                        if (rx == 1'b0) begin
                            clk_count <= 0;
                            state <= 3'b010;
                        end else state <= 3'b000;
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end
                
                3'b010: begin // DATA BITS State
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 0;
                        rx_data[bit_index] <= rx;
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            bit_index <= 0;
                            state <= 3'b011;
                        end
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end
                
                3'b011: begin // STOP BIT State
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        rx_valid <= 1;
                        state <= 3'b000;
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end
                
                default: state <= 3'b000;
            endcase
        end
    end
endmodule