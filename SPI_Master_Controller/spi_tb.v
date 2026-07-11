//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 20.03.2026 14:56:58
//// Design Name: 
//// Module Name: tb
//// Project Name: 
//// Target Devices: 
//// Tool Versions: 
//// Description: 
//// 
//// Dependencies: 
//// 
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
//// 
////////////////////////////////////////////////////////////////////////////////////

//module spi_top_tb;

//    reg clk;
//    reg rst_n;
//    reg [7:0] parallel_data;
//    reg data_valid;

//    wire [7:0] received_data;
//    wire received_valid;

//    spi_top dut (
//        .clk(clk),
//        .rst_n(rst_n),
//        .parallel_data(parallel_data),
//        .data_valid(data_valid),
//        .received_data(received_data),
//        .received_valid(received_valid)
//    );

//    always #5 clk = ~clk;  // 100 MHz

//    initial begin
//        clk = 0;
//        rst_n = 0;
//        data_valid = 0;
//        parallel_data = 8'h00;

//        #20 rst_n = 1;

//        #20;
//        parallel_data = 8'hB6;
//        data_valid = 1;

//        #10 data_valid = 0;

//        wait(received_valid);
//        $display("Sent Data     = %h", 8'hA5);
//        $display("Received Data = %h", received_data);

//        #50 $finish;
//    end

//endmodule


module spi_top_tb;

    reg clk, rst_n;
    reg [7:0] parallel_data;
    reg data_valid;
    wire [7:0] received_data;
    wire received_valid;

    spi_top dut (
        .clk(clk), .rst_n(rst_n),
        .parallel_data(parallel_data),
        .data_valid(data_valid),
        .received_data(received_data),
        .received_valid(received_valid)
    );

    always #5 clk = ~clk;

    initial begin
        clk          = 0;
        rst_n        = 0;
        data_valid   = 0;
        parallel_data = 8'h00;

        #20 rst_n = 1;
        #20;

        parallel_data = 8'hAA;  //  make sure this matches what you check
        data_valid    = 1;
        #10 data_valid = 0;

        //  Wait long enough - SPI is slow (CLK_DIV=4, 8 bits = ~320ns minimum)
        wait(received_valid);
        #10; // let signals settle

        $display("Sent Data     = %h", 8'hA5);
        $display("Received Data = %h", received_data);

        if (received_data == 8'hA5)
            $display(" PASS");
        else
            $display(" FAIL - mismatch!");

        #100 $finish;
    end

endmodule