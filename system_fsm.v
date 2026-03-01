module system_fsm (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        dma_done,
    input  wire [12:0] dma_byte_count,
    input  wire        end_marker_seen,
    input  wire [31:0] proc_result,
    input  wire        tx_done,
    output reg         cpu_reset,
    output reg         error_flag,
    output reg         start_tx,
    output reg  [31:0] result_to_b2a
);
    localparam MAX_BYTES   = 13'd4096;
    localparam TIMEOUT_MAX = 32'd50_000_000;
    localparam EXEC_MAX    = 32'd60_000;

    localparam HALT     = 3'd0,
               WAIT_DMA = 3'd1,
               RUN      = 3'd2,
               CONVERT  = 3'd3,
               REPORT   = 3'd4,
               DONE     = 3'd5,
               ERROR    = 3'd6;

    reg [2:0] state, next_state;
    reg [31:0] timeout_cnt, exec_cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            timeout_cnt <= 0;
            exec_cnt <= 0;
        end else begin
            if (state == WAIT_DMA) timeout_cnt <= timeout_cnt + 1'b1;
            else timeout_cnt <= 0;
            
            if (state == RUN) exec_cnt <= exec_cnt + 1'b1;
            else exec_cnt <= 0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= HALT;
        else state <= next_state;
    end

    always @(*) begin
        next_state = state;
        case (state)
            HALT: next_state = WAIT_DMA;
            WAIT_DMA: begin
                if (dma_byte_count > MAX_BYTES) next_state = ERROR;
                else if (timeout_cnt > TIMEOUT_MAX) next_state = ERROR;
                else if (dma_done && end_marker_seen) next_state = RUN;
            end
            RUN: if (exec_cnt > EXEC_MAX) next_state = CONVERT;
            CONVERT: next_state = REPORT;
            REPORT: if (tx_done) next_state = DONE;
            DONE: next_state = DONE;
            ERROR: next_state = ERROR;
        endcase
    end

    always @(posedge clk) begin
        if (state == RUN && next_state == CONVERT) result_to_b2a <= proc_result;
    end

    always @(*) begin
        cpu_reset = 1'b1;
        error_flag = 1'b0;
        start_tx = 1'b0;

        case (state)
            HALT: cpu_reset = 1'b1;
            WAIT_DMA: cpu_reset = 1'b1;
            RUN: cpu_reset = 1'b0;
            CONVERT: begin cpu_reset = 1'b1; start_tx = 1'b1; end
            REPORT: cpu_reset = 1'b1;
            DONE: cpu_reset = 1'b1;
            ERROR: begin cpu_reset = 1'b1; error_flag = 1'b1; end
        endcase
    end
endmodule