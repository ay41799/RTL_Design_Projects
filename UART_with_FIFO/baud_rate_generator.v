module baud_rate_generator #(
    parameter clk_freq  = 50000000,
    parameter baud_rate = 9600,
    parameter oversample = 16
)(
    input clk,
    input rst,

    output reg tx_clk,
    output reg rx_clk
);

    localparam tx_div =
        (clk_freq / baud_rate) - 1;

    localparam rx_div =
        (clk_freq / (baud_rate * oversample)) - 1;

    localparam tx_width =
        $clog2(tx_div + 1);

    localparam rx_width =
        $clog2(rx_div + 1);

    reg [tx_width-1:0] count_tx;
    reg [rx_width-1:0] count_rx;

    always @(posedge clk) begin

        if (rst) begin

            tx_clk   <= 1'b0;
            count_tx <= 0;
        end

        else begin

            tx_clk <= 1'b0;

            if (count_tx == tx_div) begin

                tx_clk   <= 1'b1;
                count_tx <= 0;
            end

            else begin
                count_tx <= count_tx + 1'b1;
            end
        end
    end

    always @(posedge clk) begin

        if (rst) begin

            rx_clk   <= 1'b0;
            count_rx <= 0;
        end

        else begin

            rx_clk <= 1'b0;

            if (count_rx == rx_div) begin

                rx_clk   <= 1'b1;
                count_rx <= 0;
            end

            else begin
                count_rx <= count_rx + 1'b1;
            end
        end
    end

endmodule
