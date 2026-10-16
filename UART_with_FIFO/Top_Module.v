`timescale 1ns / 1ps
module top_module #(
    parameter integer CLK_FREQ  = 100_000_000,
    parameter integer BAUD_RATE = 9600
)(
    input  wire clk,
    input  wire rst,

    input  wire wr_enb,
    input  wire rdy_clr,

    input  wire [7:0] data_in,
    output wire [7:0] data_out,

    output wire rdy,
    output wire busy,

    output wire tx_fifo_full,
    output wire tx_fifo_empty,

    output wire rx_fifo_full,
    output wire rx_fifo_empty,

    output reg rx_overflow,
    output reg tx_write_rejected
);

    wire tx_clk_enb;
    wire rx_clk_enb;

    wire serial_data;

    wire [7:0] tx_fifo_data_out;
    wire [7:0] rx_data;

    wire rx_valid;
    wire tx_busy;

    reg tx_fifo_rd;
    reg tx_start;

    localparam [2:0]
        FETCH     = 3'd0,
        WAIT_DATA = 3'd1,
        LAUNCH    = 3'd2,
        WAIT_BUSY = 3'd3,
        WAIT_IDLE = 3'd4;

    reg [2:0] tx_state;


    baud_rate_generator #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .OVERSAMPLE(16)
    ) baud (
        .clk(clk),
        .rst(rst),
        .tx_clk(tx_clk_enb),
        .rx_clk(rx_clk_enb)
    );

    
    fifo_sync #(
        .FIFO_DEPTH(8),
        .DATA_WIDTH(8)
    ) tx_fifo (
        .clk(clk),
        .rst_n(~rst),
        .cs(1'b1),

        .wr_en(wr_enb),
        .rd_en(tx_fifo_rd),

        .data_in(data_in),
        .data_out(tx_fifo_data_out),

        .empty(tx_fifo_empty),
        .full(tx_fifo_full)
    );

    

    always @(posedge clk) begin
        if (rst) begin
            tx_state   <= FETCH;
            tx_fifo_rd <= 0;
            tx_start   <= 0;
        end
        else begin
            tx_fifo_rd <= 0;
            tx_start   <= 0;

            case (tx_state)

                FETCH: begin
                    if (!tx_fifo_empty && !tx_busy && !rx_fifo_full) begin
                        tx_fifo_rd <= 1'b1;
                        tx_state <= WAIT_DATA;
                    end
                end

                WAIT_DATA: begin
                    tx_state <= LAUNCH;
                end

                LAUNCH: begin
                    tx_start <= 1'b1;
                    tx_state <= WAIT_BUSY;
                end

                WAIT_BUSY: begin
                    if (tx_busy)
                        tx_state <= WAIT_IDLE;
                end

                WAIT_IDLE: begin
                    if (!tx_busy)
                        tx_state <= FETCH;
                end

                default:
                    tx_state <= FETCH;

            endcase
        end
    end

    

    transmitter tx (
        .clk(clk),
        .rst(rst),

        .wr_enb(tx_start),
        .tx_clk(tx_clk_enb),

        .data_in(tx_fifo_data_out),

        .data_out_temp(serial_data),
        .tx_busy(tx_busy)
    );

    assign busy = tx_busy;

    reciever rx (
        .clk(clk),
        .rst(rst),

        .clk_enb(rx_clk_enb),
        .rx(serial_data),

        .rdy(rx_valid),
        .data_out(rx_data)
    );

   

    fifo_sync #(
        .FIFO_DEPTH(8),
        .DATA_WIDTH(8)
    ) rx_fifo (
        .clk(clk),
        .rst_n(~rst),
        .cs(1'b1),

        .wr_en(rx_valid && !rx_fifo_full),
        .rd_en(rdy_clr),

        .data_in(rx_data),
        .data_out(data_out),

        .empty(rx_fifo_empty),
        .full(rx_fifo_full)
    );

    assign rdy = !rx_fifo_empty;

    always @(posedge clk) begin
        if (rst)
            rx_overflow <= 1'b0;
        else if (rx_valid && rx_fifo_full)
            rx_overflow <= 1'b1;
    end

    
    always @(posedge clk) begin
    if (rst)
        tx_write_rejected <= 1'b0;
    else if (wr_enb && tx_fifo_full)
        tx_write_rejected <= 1'b1;
end

endmodule

