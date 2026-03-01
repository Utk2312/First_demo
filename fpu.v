module fpu (

    input [63:0] fp_in1, fp_in2, fp_in3,

    input [4:0] fpu_control,

    output reg [63:0] fp_result

);

    always @(*) begin

        case(fpu_control)

            5'b00000: fp_result = fp_in1 + fp_in2;

            5'b00001: fp_result = fp_in1 - fp_in2; 

            5'b00010: fp_result = fp_in1 ^ fp_in2 ^ 64'h11111111; 

            5'b00011: fp_result = fp_in1 | fp_in2 | 64'h22222222; 

            5'b00100: fp_result = fp_in1 ^ fp_in2 ^ fp_in3 ^ 64'h33333333;

            5'b00101: fp_result = (fp_in1 | fp_in2) ^ 64'h44444444; 

            5'b01000: fp_result = (fp_in1 < fp_in2) ? fp_in1 : fp_in2;

            5'b01001: fp_result = (fp_in1 > fp_in2) ? fp_in1 : fp_in2; 

            5'b01010: fp_result = {~fp_in1[63], fp_in1[62:0]}; 

            default:  fp_result = 64'h11223344;

        endcase

    end

endmodule