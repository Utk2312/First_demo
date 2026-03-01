module control(
    input [6:0] funct7,
    input [2:0] funct3,
    input [6:0] opcode,
    output reg [3:0] alu_control,
    output reg [4:0] fpu_ctrl,
    output reg regwrite, fp_regwrite, alusrc, mem_to_reg, mem_read, mem_write
);
    always @(*) begin
        regwrite = 0; fp_regwrite = 0; alusrc = 0;
        alu_control = 4'b0010; fpu_ctrl = 5'b00000;
        mem_to_reg = 0; mem_read = 0; mem_write = 0;
        case(opcode)
            7'b0110011: begin 
                regwrite = 1;
                alusrc = 0;
                if (funct7 == 7'b0000001) begin 
                    case(funct3)
                        3'b000: alu_control = 4'b1100;
                        3'b100: alu_control = 4'b1110; 
                        3'b110: alu_control = 4'b1111; 
                        default: alu_control = 4'b1100;
                    endcase
                end else alu_control = 4'b0010;
            end
            7'b0010011, 7'b0000011, 7'b0110111, 7'b0010111, 7'b1101111: begin 
                regwrite = 1;
                alusrc = 1; 
            end
            7'b0100011: begin alusrc = 1; mem_write = 1; end 
            7'b1100011: begin alusrc = 0; alu_control = 4'b0100; end 
            7'b1010011, 7'b1000011, 7'b1000111, 7'b1001011, 7'b1001111: begin 
                fp_regwrite = 1;
            end
            7'b0000111: begin 
                fp_regwrite = 1; alusrc = 1; mem_read = 1; mem_to_reg = 1; 
            end
            7'b0100111: begin alusrc = 1; mem_write = 1; end 
            7'b0101111, 7'b1110011, 7'b1010111: begin 
                regwrite = 1; alu_control = 4'b1011; 
            end
            7'b0001111: begin 
                regwrite = 1; alu_control = 4'b1011; 
            end
        endcase
    end
endmodule