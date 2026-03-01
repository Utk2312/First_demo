// bin_to_ascii.v
module bin_to_ascii(
    input clk, reset,
    input [31:0] bin_in, input start,
    output reg [7:0] ascii_out,
    output reg tx_start, input tx_busy, output reg done
);
    reg [3:0] char_count;
    reg [2:0] state;
    reg [3:0] nibble;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            char_count <= 0; tx_start <= 0; done <= 0; state <= 0;
        end else begin
            case(state)
                0: if (start) begin char_count <= 8; done <= 0; state <= 1; end
                1: begin
                    if (char_count == 0) begin done <= 1; state <= 0; end
                    else if (!tx_busy) begin
                        case (char_count)
                            8: nibble = bin_in[31:28]; 7: nibble = bin_in[27:24];
                            6: nibble = bin_in[23:20]; 5: nibble = bin_in[19:16];
                            4: nibble = bin_in[15:12]; 3: nibble = bin_in[11:8];
                            2: nibble = bin_in[7:4];   1: nibble = bin_in[3:0];
                            default: nibble = 0;
                        endcase
                        ascii_out <= (nibble > 9) ? (nibble + 8'h37) : (nibble + 8'h30);
                        tx_start <= 1; state <= 2;
                    end
                end
                2: begin tx_start <= 0; if (tx_busy) state <= 3; end
                3: begin if (!tx_busy) begin char_count <= char_count - 1; state <= 1; end end
            endcase
        end
    end
endmodule