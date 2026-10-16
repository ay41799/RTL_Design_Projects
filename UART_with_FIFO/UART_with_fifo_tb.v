
`timescale 1ns / 1ps

module tb_uart_fifo_full;

    reg clk = 0;
    reg rst = 1;
    reg wr_enb = 0;
    reg rdy_clr = 0;
    reg [7:0] data_in = 0;

    wire [7:0] data_out;
    wire rdy, busy;
    wire tx_fifo_full, tx_fifo_empty;
    wire rx_fifo_full, rx_fifo_empty;
    wire rx_overflow, tx_write_rejected;

    
    always #5 clk = ~clk;

    top_module dut (
        .clk(clk),
        .rst(rst),
        .wr_enb(wr_enb),
        .rdy_clr(rdy_clr),
        .data_in(data_in),
        .data_out(data_out),
        .rdy(rdy),
        .busy(busy),
        .tx_fifo_full(tx_fifo_full),
        .tx_fifo_empty(tx_fifo_empty),
        .rx_fifo_full(rx_fifo_full),
        .rx_fifo_empty(rx_fifo_empty),
        .rx_overflow(rx_overflow),
        .tx_write_rejected(tx_write_rejected)
    );

    reg [7:0] expected [0:31];
    integer wr_count = 0;
    integer rd_count = 0;
    integer errors = 0;
    integer i;

    
    localparam integer FRAME_NS = 1100000;

    task check;
        input condition;
        input [255:0] message;
        begin
            if (condition)
                $display("[PASS] %0s at %0t", message, $time);
            else begin
                $display("[FAIL] %0s at %0t", message, $time);
                errors = errors + 1;
            end
        end
    endtask
    ]
    task write_byte;
        input [7:0] value;
        begin
            @(negedge clk);
            data_in = value;
            wr_enb = 1'b1;

            @(negedge clk);
            wr_enb = 1'b0;

            $display("TX REQUEST: 0x%02h at %0t",
                     value, $time);
        end
    endtask

    task read_byte;
        input [7:0] expected_value;
        begin
            
            wait (!rx_fifo_empty);

            @(negedge clk);
            rdy_clr = 1'b1;

            @(negedge clk);
            rdy_clr = 1'b0;

            if (data_out === expected_value)
                $display("[PASS] RX 0x%02h at %0t",
                         data_out, $time);
            else begin
                $display("[FAIL] RX expected 0x%02h, got 0x%02h",
                         expected_value, data_out);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        $display("==================================");
        $display(" UART + DUAL FIFO FULL VERIFICATION");
        $display("==================================");

       
        repeat (10) @(negedge clk);
        rst = 0;
        repeat (5) @(negedge clk);

        check(tx_fifo_empty, "TX FIFO empty after reset");
        check(rx_fifo_empty, "RX FIFO empty after reset");
        check(!rx_overflow, "RX overflow cleared");
        check(!tx_write_rejected,
              "TX write rejection cleared");

       
        $display("\nTEST 2: SINGLE BYTE");

        write_byte(8'h55);
        read_byte(8'h55);

        $display("\nTEST 3: MULTIPLE BYTES");

        write_byte(8'hA5);
        write_byte(8'h3C);
        write_byte(8'hF0);
        write_byte(8'h0F);

        repeat (5) @(negedge clk);

        read_byte(8'hA5);
        read_byte(8'h3C);
        read_byte(8'hF0);
        read_byte(8'h0F);

        
        #(FRAME_NS);

      
        $display("\nTEST 4: RX FIFO FULL");

        for (i = 0; i < 8; i = i + 1) begin
            write_byte(8'h20 + i);
            #(FRAME_NS);
        end

        check(rx_fifo_full, "RX FIFO reaches full");
        check(!rx_overflow, "No RX overflow");

        
        $display("\nTEST 5: TX FIFO FULL");

        for (i = 0; i < 8; i = i + 1)
            write_byte(8'h40 + i);

        repeat (10) @(negedge clk);

        check(tx_fifo_full, "TX FIFO reaches full");
        check(rx_fifo_full, "RX FIFO remains full");

        
        $display("\nTEST 6: TX WRITE REJECTION");

        write_byte(8'hEE);

        repeat (5) @(negedge clk);

        check(tx_write_rejected,
              "TX write rejected when FIFO full");
        check(!rx_overflow,
              "RX overflow still clear");

       
        $display("\nTEST 7: FLOW CONTROL");

        check(!busy,
              "UART transmitter paused");

        
        for (i = 0; i < 8; i = i + 1) begin
            read_byte(8'h20 + i);
            #(FRAME_NS);
        end

       
        for (i = 0; i < 8; i = i + 1) begin
            read_byte(8'h40 + i);
            #(FRAME_NS);
        end

        check(!rx_overflow,
              "No RX overflow during recovery");

       
        $display("\nTEST 8: RESET RECOVERY");

        @(negedge clk);
        rst = 1'b1;
        repeat (5) @(negedge clk);
        rst = 1'b0;
        repeat (5) @(negedge clk);

        check(tx_fifo_empty,
              "TX FIFO empty after second reset");
        check(rx_fifo_empty,
              "RX FIFO empty after second reset");
        check(!tx_write_rejected,
              "TX rejection cleared after reset");
        check(!rx_overflow,
              "RX overflow cleared after reset");

      
        $display("\n==================================");

        if (errors == 0)
            $display("ALL CHECKS PASSED");
        else
            $display("FAILED CHECKS: %0d", errors);

        $display("==================================");

        $finish;
    end

    
    initial begin
        #60000000;
        $display("[FAIL] SIMULATION TIMEOUT");
        $finish;
    end

endmodule
