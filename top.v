module top(
    input clk, reset_btn, uart_rx_pin,
    output uart_tx_pin, output error_led
);
    wire [31:0] proc_result, mem_write_addr, mem_write_data, pc, instruction_code, result_to_convert;
    wire [12:0] rx_byte_count;
    wire [7:0] rx_byte, ascii_char;
    wire rx_valid, mem_we, proc_reset, start_tx, tx_busy, tx_done, b2a_start_tx, rx_dma_done, rx_end_marker;

    uart_rx receiver(.clk(clk), .reset(reset_btn), .rx(uart_rx_pin), .rx_data(rx_byte), .rx_valid(rx_valid));
    
    // Abstracting RX stream to FSM DMA inputs for 4KB limits
    assign mem_we = rx_valid; 
    
    system_fsm controller(
        .clk(clk), .rst_n(~reset_btn), .dma_done(rx_dma_done), .dma_byte_count(rx_byte_count),
        .end_marker_seen(rx_end_marker), .proc_result(proc_result), .tx_done(tx_done),
        .cpu_reset(proc_reset), .error_flag(error_led), .start_tx(start_tx), .result_to_b2a(result_to_convert)
    );

    inst_mem memory_unit(
        .clk(clk), .write_en(mem_we), .write_addr(mem_write_addr),
        .write_data(mem_write_data), .read_addr(pc), .read_data(instruction_code)
    );

    processor core(
        .clock(clk), .reset(proc_reset), .instruction_code(instruction_code),
        .pc(pc), .zero(), .result_out(proc_result)
    );

    bin_to_ascii b2a(
        .clk(clk), .reset(reset_btn), .bin_in(result_to_convert), .start(start_tx),
        .ascii_out(ascii_char), .tx_start(b2a_start_tx), .tx_busy(tx_busy), .done(tx_done)
    );

    uart_tx transmitter(
        .clk(clk), .reset(reset_btn), .tx_start(b2a_start_tx), .tx_data(ascii_char),
        .tx(uart_tx_pin), .tx_busy(tx_busy)
    );
endmodule