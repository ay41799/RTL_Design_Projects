module button_onepulse (
    input  wire clk,
    input  wire rst,
    input  wire button,
    output reg  pulse
);

    (* ASYNC_REG = "TRUE" *) reg sync1;
    (* ASYNC_REG = "TRUE" *) reg sync2;

    reg stable;
    reg [19:0] count;

    always @(posedge clk) begin
        if (rst) begin
            sync1 <= 0;
            sync2 <= 0;
            stable <= 0;
            count  <= 0;
            pulse  <= 0;
        end
        else begin
            sync1 <= button;
            sync2 <= sync1;
            pulse <= 0;

            if (sync2 == stable) begin
                count <= 0;
            end
            else if (count == 20'd999_999) begin
                stable <= sync2;
                count <= 0;

                if (sync2)
                    pulse <= 1'b1;
            end
            else begin
                count <= count + 1'b1;
            end
        end
    end

endmodule

