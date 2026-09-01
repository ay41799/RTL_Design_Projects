module transmitter (
    input clk,
    input rst,

    input wr_enb,
    input tx_clk,

    input [7:0] data_in,

    output reg data_out_temp,
    output tx_busy
);

    parameter idle_state  = 2'b00;
    parameter start_state = 2'b01;
    parameter data_state  = 2'b10;
    parameter stop_state  = 2'b11;

    reg [1:0] state;
    reg [2:0] counter;

    reg [7:0] data_input_temp;

    always @(posedge clk) begin

        if (rst) begin

            data_out_temp  <= 1'b1;
            state          <= idle_state;
            counter        <= 3'b000;
            data_input_temp <= 8'd0;
        end

        else begin

            case (state)

                idle_state: begin

                    if (wr_enb) begin

                        state           <= start_state;
                        data_input_temp <= data_in;
                        counter         <= 3'b000;
                    end

                    else begin
                        state <= idle_state;
                    end
                end

                start_state: begin

                    if (tx_clk) begin

                        state         <= data_state;
                        data_out_temp <= 1'b0;
                    end

                    else begin
                        state <= start_state;
                    end
                end

                data_state: begin

                    if (tx_clk) begin

                        data_out_temp <= data_input_temp[counter];

                        if (counter == 3'b111)
                            state <= stop_state;

                        else
                            counter <= counter + 1'b1;
                    end
                end

                stop_state: begin

                    if (tx_clk) begin

                        data_out_temp <= 1'b1;
                        state <= idle_state;
                    end
                end


                default: begin

                    state         <= idle_state;
                    data_out_temp <= 1'b1;
                end

            endcase
        end
    end

    assign tx_busy = (state != idle_state);
endmodule

endmodule
