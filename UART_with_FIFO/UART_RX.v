module reciever (
    input clk,
    input rst,
    input rdy_clr,
    input clk_enb,
    input rx,

    output reg rdy,
    output reg [7:0] data_out
);

    parameter start_state = 2'b00;
    parameter data_state  = 2'b01;
    parameter stop_state  = 2'b10;

    reg [1:0] state;

    reg [3:0] sample;
    reg [2:0] counter;
    reg [7:0] temp_data;

    always @(posedge clk) begin

        if (rst) begin
            rdy       <= 1'b0;
            state     <= start_state;
            sample    <= 4'd0;
            data_out  <= 8'd0;
            counter   <= 3'd0;
            temp_data <= 8'd0;
        end

        else begin

            if (rdy_clr)
                rdy <= 1'b0;

            if (clk_enb) begin

                case (state)
                  

                    start_state: begin

                        if (!rx || sample != 0)
                            sample <= sample + 1'b1;

                        if (sample == 15) begin

                            if (!rx) begin
                                state     <= data_state;
                                sample    <= 0;
                                counter   <= 0;
                                temp_data <= 0;
                            end

                            else begin
                                sample <= 0;
                            end
                        end
                    end
                  
                    data_state: begin

                        if (sample == 15)
                            sample <= 0;
                        else
                            sample <= sample + 1'b1;

                        // Sample in middle of bit
                        if (sample == 8) begin
                            temp_data[counter] <= rx;
                            counter <= counter + 1'b1;
                        end

                        if (counter == 7 && sample == 15) begin
                            state  <= stop_state;
                            sample <= 0;
                        end
                    end

                    stop_state: begin

                        if (sample == 15) begin

                            state    <= start_state;
                            data_out <= temp_data;
                            rdy      <= 1'b1;
                            sample   <= 0;
                        end

                        else begin
                            sample <= sample + 1'b1;
                        end
                    end


                    default: begin
                        state <= start_state;
                    end

                endcase
            end
        end
    end

endmodule
