module ifu(
    input clock, reset,
    output reg [31:0] pc
);
    always @(posedge clock or posedge reset) begin
        if(reset == 1) pc <= 0;
        else pc <= pc + 4;
    end
endmodule