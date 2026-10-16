`timescale 1ns / 1ps

module baud_rate_generator #(
    parameter integer CLK_FREQ   = 100_000_000,
    parameter integer BAUD_RATE  = 9600,
    parameter integer OVERSAMPLE = 16
)(
    input  wire clk,
    input  wire rst,
    output reg  tx_clk,
    output reg  rx_clk
);

    localparam integer TX_DIV =
        (CLK_FREQ + BAUD_RATE/2) / BAUD_RATE;

    localparam integer RX_DIV =
        (CLK_FREQ + (BAUD_RATE*OVERSAMPLE)/2) /
        (BAUD_RATE*OVERSAMPLE);

    localparam integer TX_W =
        (TX_DIV > 1) ? $clog2(TX_DIV) : 1;

    localparam integer RX_W =
        (RX_DIV > 1) ? $clog2(RX_DIV) : 1;

    reg [TX_W-1:0] tx_count;
    reg [RX_W-1:0] rx_count;

    always @(posedge clk) begin
        if (rst) begin
            tx_count <= 0;
            rx_count <= 0;
            tx_clk   <= 0;
            rx_clk   <= 0;
        end
        else begin
            tx_clk <= 0;
            rx_clk <= 0;

            if (tx_count == TX_DIV-1) begin
                tx_count <= 0;
                tx_clk   <= 1;
            end
            else
                tx_count <= tx_count + 1'b1;

            if (rx_count == RX_DIV-1) begin
                rx_count <= 0;
                rx_clk   <= 1;
            end
            else
                rx_count <= rx_count + 1'b1;
        end
    end

endmodule

