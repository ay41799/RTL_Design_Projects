`timescale 1ns / 1ps
module transmitter (
    input  wire clk,
    input  wire rst,
    input  wire wr_enb,
    input  wire tx_clk,
    input  wire [7:0] data_in,

    output reg  data_out_temp,
    output wire tx_busy
);

    localparam [2:0]
        IDLE  = 3'd0,
        ARM   = 3'd1,
        START = 3'd2,
        DATA  = 3'd3,
        STOP  = 3'd4;

    reg [2:0] state;
    reg [7:0] shift_reg;
    reg [2:0] bit_count;

    assign tx_busy = (state != IDLE);

    always @(posedge clk) begin
        if (rst) begin
            state         <= IDLE;
            shift_reg     <= 0;
            bit_count     <= 0;
            data_out_temp <= 1'b1;
        end
        else begin
            case (state)

                IDLE: begin
                    data_out_temp <= 1'b1;

                    if (wr_enb) begin
                        shift_reg <= data_in;
                        bit_count <= 0;
                        state <= ARM;
                    end
                end

                ARM: begin
                    if (tx_clk) begin
                        data_out_temp <= 1'b0;
                        state <= START;
                    end
                end

                START: begin
                    if (tx_clk) begin
                        data_out_temp <= shift_reg[0];
                        state <= DATA;
                    end
                end

                DATA: begin
                    if (tx_clk) begin
                        if (bit_count == 7) begin
                            data_out_temp <= 1'b1;
                            state <= STOP;
                        end
                        else begin
                            bit_count <= bit_count + 1'b1;
                            data_out_temp <=
                                shift_reg[bit_count + 1'b1];
                        end
                    end
                end

                STOP: begin
                    if (tx_clk) begin
                        data_out_temp <= 1'b1;
                        state <= IDLE;
                    end
                end

                default: begin
                    state <= IDLE;
                    data_out_temp <= 1'b1;
                end

            endcase
        end
    end

endmodule


