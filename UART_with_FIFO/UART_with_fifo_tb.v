`timescale 1ns/1ps

module uart_fifo_tb;

    reg        clk;
    reg        rst;
    reg        wr_enb;
    reg        rdy_clr;

    reg  [7:0] data_in;

    wire [7:0] data_out;
    wire       rdy;
    wire       busy;


    top_module DUT (
        .clk      (clk),
        .rst      (rst),
        .wr_enb   (wr_enb),
        .rdy_clr  (rdy_clr),
        .data_in  (data_in),
        .data_out (data_out),
        .rdy      (rdy),
        .busy     (busy)
    );


    initial begin
        clk = 1'b0;
    end

    always #10 clk = ~clk;


    initial begin
        $dumpfile("uart_fifo.vcd");
        $dumpvars(0, uart_fifo_tb);
    end


    task send_byte;
        input [7:0] byte_data;

        begin

            @(negedge clk);

            data_in = byte_data;
            wr_enb  = 1'b1;

            @(negedge clk);

            wr_enb = 1'b0;

            $display("[%0t ns] TX FIFO write : %h",
                     $time, byte_data);

        end
    endtask

    task read_byte;

        begin

            wait (rdy == 1'b1);

            @(negedge clk);

            $display("[%0t ns] RX FIFO data : %h",
                     $time, data_out);

            rdy_clr = 1'b1;

            @(negedge clk);

            rdy_clr = 1'b0;

        end

    endtask

    initial begin

        // Initial values
        rst     = 1'b0;
        wr_enb  = 1'b0;
        rdy_clr = 1'b0;
        data_in = 8'h00;


        @(negedge clk);

        rst = 1'b1;

        $display("[%0t ns] RESET ASSERTED", $time);

        repeat(2)
            @(negedge clk);

        rst = 1'b0;

        $display("[%0t ns] RESET RELEASED", $time);

        send_byte(8'h55);
        read_byte();

        send_byte(8'h41);
        read_byte();


        send_byte(8'h11);
        send_byte(8'h22);
        send_byte(8'h33);
        send_byte(8'h44);

        read_byte();
        read_byte();
        read_byte();
        read_byte();

        #1000;

        $display("--------------------------------------");
        $display("UART WITH FIFO TEST COMPLETED");
        $display("--------------------------------------");

        $finish;

    end

endmodule
