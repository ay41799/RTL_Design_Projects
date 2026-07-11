//////`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////////
//////// Company: 
//////// Engineer: 
//////// 
//////// Create Date: 20.03.2026 14:55:34
//////// Design Name: 
//////// Module Name: c
//////// Project Name: 
//////// Target Devices: 
//////// Tool Versions: 
//////// Description: 
//////// 
//////// Dependencies: 
//////// 
//////// Revision:
//////// Revision 0.01 - File Created
//////// Additional Comments:
//////// 
////////////////////////////////////////////////////////////////////////////////////////


////module spi_slave (
////    input  wire       spi_clk,
////    input  wire       spi_cs,
////    input  wire       spi_mosi,

////    output reg [7:0]  rx_data,
////    output reg        rx_valid
////);

////    reg [2:0] bit_cnt;

////    always @(posedge spi_clk or posedge spi_cs) begin
////        if (spi_cs) begin
////            bit_cnt <= 3'd7;
////            rx_data <= 8'd0;
////            rx_valid <= 1'b0;
////        end else begin
////          rx_data[bit_cnt] <= spi_mosi;
            

////            if (bit_cnt == 0) begin
////                rx_valid <= 1'b1;
////               // bit_cnt <= 3'd7;
////            end else begin
////                bit_cnt <= bit_cnt - 1;
////                rx_valid <= 1'b0;
////            end
////        end
////    end

////endmodule

//module spi_slave (
//    input  wire       spi_clk,
//    input  wire       spi_cs,      // active-low
//    input  wire       spi_mosi,
//    output reg [7:0]  rx_data,
//    output reg        rx_valid
//);

//    reg [2:0]  bit_cnt;
//    reg [7:0]  shift_reg;   // shift into temp reg, latch only when complete

//    always @(posedge spi_clk or posedge spi_cs) begin
//        if (spi_cs) begin                     // CS deasserted (high) = reset
//            bit_cnt  <= 3'd7;
//            rx_valid <= 1'b0;
//        end else begin                        // CS asserted (low) = active
//            shift_reg[bit_cnt] <= spi_mosi;
//            rx_valid <= 1'b0;

//            if (bit_cnt == 3'd0) begin
//                rx_data  <= {shift_reg[7:1], spi_mosi}; // latch full byte
//                rx_valid <= 1'b1;
//                bit_cnt  <= 3'd7;
//            end else begin
//                bit_cnt <= bit_cnt - 1;
//            end
//        end
//    end

//endmodule


module spi_slave (
    input  wire       spi_clk,
    input  wire       spi_cs,       // active-low
    input  wire       spi_mosi,
    output reg [7:0]  rx_data, // we are going to give it to testbench
    output reg        rx_valid //whatever the date we are giving is a valid data
);

    reg [2:0] bit_cnt;
    reg [7:0] shift_reg;

    //  Reset when CS is HIGH (deasserted), sample on rising spi_clk
    always @(posedge spi_clk or posedge spi_cs) begin
        if (spi_cs) begin               // CS=1 means idle/reset
            bit_cnt  <= 3'd7;
            rx_valid <= 1'b0;
            //  Don't clear rx_data here so last valid data is held
        end else begin
            // Sample MOSI into shift register MSB first
            shift_reg[bit_cnt] <= spi_mosi;

            if (bit_cnt == 3'd0) begin
                rx_data  <= {shift_reg[7:1], spi_mosi}; //  latch full byte atomically
                rx_valid <= 1'b1;
                bit_cnt  <= 3'd7;
            end else begin
                rx_valid <= 1'b0;
                bit_cnt  <= bit_cnt - 1;
            end
        end
    end

endmodule