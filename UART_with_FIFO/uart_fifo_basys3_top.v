`timescale 1ns / 1ps
module uart_fifo_basys3_top (
    input  wire clk,
    input  wire btnC,
    input  wire btnU,
    input  wire btnR,

    input  wire [7:0] sw,
    output wire [14:0] led
);

    wire wr_pulse;
    wire rd_pulse;

    wire [7:0] received_data;
    wire tx_rejected;

    wire rdy;
    wire busy;

    wire tx_full;
    wire tx_empty;

    wire rx_full;
    wire rx_empty;

    wire overflow;

   

    button_onepulse write_button (
        .clk(clk),
        .rst(btnC),
        .button(btnU),
        .pulse(wr_pulse)
    );

   
    button_onepulse read_button (
        .clk(clk),
        .rst(btnC),
        .button(btnR),
        .pulse(rd_pulse)
    );

   
    top_module #(
        .CLK_FREQ(100_000_000),
        .BAUD_RATE(9600)
    ) uart_core (
        .clk(clk),
        .rst(btnC),
        .tx_write_rejected(tx_rejected),
        .wr_enb(wr_pulse),
        .rdy_clr(rd_pulse),

        .data_in(sw),
        .data_out(received_data),

        .rdy(rdy),
        .busy(busy),

        .tx_fifo_full(tx_full),
        .tx_fifo_empty(tx_empty),

        .rx_fifo_full(rx_full),
        .rx_fifo_empty(rx_empty),

        .rx_overflow(overflow)
    );

   

    assign led[7:0] = received_data;

    assign led[8]  = busy;
    assign led[9]  = tx_full;
    assign led[10] = rx_empty;
    assign led[11] = rx_full;
    assign led[12] = overflow;
    assign led[14] = tx_rejected;

endmodule
