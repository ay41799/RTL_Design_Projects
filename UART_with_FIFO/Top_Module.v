module top_module (
    input        clk,
    input        rst,

    input        wr_enb,
    input        rdy_clr,

    input  [7:0] data_in,
    output [7:0] data_out,

    output       rdy,
    output       busy
);

    wire tx_clk_enb;
    wire rx_clk_enb;

    wire serial_data;
  
    wire [7:0] tx_fifo_data_out;
    wire       tx_fifo_empty;
    wire       tx_fifo_full;

    wire       tx_fifo_rd;
    wire       tx_busy;

    wire [7:0] rx_fifo_data_out;
    wire       rx_fifo_empty;
    wire       rx_fifo_full;

    wire       rx_fifo_wr;

    baud_rate_generator baud (
        .clk    (clk),
        .rst    (rst),
        .tx_clk (tx_clk_enb),
        .rx_clk (rx_clk_enb)
    );

    fifo_sync #(
        .FIFO_DEPTH (8),
        .DATA_WIDTH (8)
    ) tx_fifo (
        .clk      (clk),
        .rst_n    (~rst),
        .cs       (1'b1),
        .wr_en    (wr_enb),
        .rd_en    (tx_fifo_rd),
        .data_in  (data_in),
        .data_out (tx_fifo_data_out),
        .empty    (tx_fifo_empty),
        .full     (tx_fifo_full)
    );

    assign tx_fifo_rd = !tx_fifo_empty && !tx_busy;

    transmitter tx (
        .clk           (clk),
        .rst           (rst),
        .wr_enb        (tx_fifo_rd),
        .tx_clk        (tx_clk_enb),
        .data_in       (tx_fifo_data_out),
        .data_out_temp (serial_data),
        .tx_busy       (tx_busy)
    );

    assign busy = tx_busy;

    reciever rx (
        .clk      (clk),
        .rst      (rst),
        .rdy_clr  (rdy_clr),
        .clk_enb  (rx_clk_enb),
        .rx       (serial_data),
        .rdy      (rx_fifo_wr),
        .data_out (rx_fifo_data_out)
    );

    fifo_sync #(
        .FIFO_DEPTH (8),
        .DATA_WIDTH (8)
    ) rx_fifo (
        .clk      (clk),
        .rst_n    (~rst),
        .cs       (1'b1),
        .wr_en    (rx_fifo_wr),
        .rd_en    (rdy_clr),
        .data_in  (rx_fifo_data_out),
        .data_out (data_out),
        .empty    (rx_fifo_empty),
        .full     (rx_fifo_full)
    );
  
    assign rdy = !rx_fifo_empty;

endmodule
