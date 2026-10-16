`timescale 1ns / 1ps
module fifo_sync #(
    parameter integer FIFO_DEPTH = 8,
    parameter integer DATA_WIDTH = 8
)(
    input  wire clk,
    input  wire rst_n,
    input  wire cs,
    input  wire wr_en,
    input  wire rd_en,

    input  wire [DATA_WIDTH-1:0] data_in,
    output reg  [DATA_WIDTH-1:0] data_out,

    output wire empty,
    output wire full
);

    localparam integer PTR_W = $clog2(FIFO_DEPTH);

    reg [DATA_WIDTH-1:0] fifo [0:FIFO_DEPTH-1];

    reg [PTR_W:0] write_pointer;
    reg [PTR_W:0] read_pointer;

    assign empty = (write_pointer == read_pointer);

    assign full =
        (write_pointer[PTR_W] != read_pointer[PTR_W]) &&
        (write_pointer[PTR_W-1:0] ==
         read_pointer[PTR_W-1:0]);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            write_pointer <= 0;
            read_pointer  <= 0;
            data_out      <= 0;
        end
        else begin

            if (cs && wr_en && !full) begin
                fifo[write_pointer[PTR_W-1:0]] <= data_in;
                write_pointer <= write_pointer + 1'b1;
            end

            if (cs && rd_en && !empty) begin
                data_out <= fifo[read_pointer[PTR_W-1:0]];
                read_pointer <= read_pointer + 1'b1;
            end

        end
    end

endmodule

