`timescale 1ns / 1ps
module reciever (
    input  wire clk,
    input  wire rst,
    input  wire clk_enb,
    input  wire rx,

    output reg  rdy,
    output reg  [7:0] data_out
);

    localparam [1:0]
        IDLE  = 2'd0,
        START = 2'd1,
        DATA  = 2'd2,
        STOP  = 2'd3;

    reg [1:0] state;
    reg [3:0] sample;
    reg [2:0] bit_count;
    reg [7:0] shift_reg;

    (* ASYNC_REG = "TRUE" *) reg rx_meta;
    (* ASYNC_REG = "TRUE" *) reg rx_sync;

    always @(posedge clk) begin
        if (rst) begin
            rx_meta <= 1'b1;
            rx_sync <= 1'b1;
        end
        else begin
            rx_meta <= rx;
            rx_sync <= rx_meta;
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            state     <= IDLE;
            sample    <= 0;
            bit_count <= 0;
            shift_reg <= 0;
            data_out  <= 0;
            rdy       <= 0;
        end
        else begin
            rdy <= 0;

            if (clk_enb) begin
                case (state)

                    IDLE: begin
                        sample <= 0;

                        if (!rx_sync)
                            state <= START;
                    end

                    START: begin
                        if (sample == 7) begin
                            sample <= 0;

                            if (!rx_sync) begin
                                bit_count <= 0;
                                state <= DATA;
                            end
                            else
                                state <= IDLE;
                        end
                        else
                            sample <= sample + 1'b1;
                    end

                    DATA: begin
                        if (sample == 15) begin
                            sample <= 0;

                            shift_reg[bit_count] <= rx_sync;

                            if (bit_count == 7)
                                state <= STOP;
                            else
                                bit_count <= bit_count + 1'b1;
                        end
                        else
                            sample <= sample + 1'b1;
                    end

                    STOP: begin
                        if (sample == 15) begin
                            sample <= 0;
                            state <= IDLE;

                            if (rx_sync) begin
                                data_out <= shift_reg;
                                rdy <= 1'b1;
                            end
                        end
                        else
                            sample <= sample + 1'b1;
                    end

                    default:
                        state <= IDLE;

                endcase
            end
        end
    end

endmodule

