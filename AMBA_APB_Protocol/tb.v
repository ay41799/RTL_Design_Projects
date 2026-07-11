`include "top.v"
`timescale 1ns / 1ps

module apb_testbench;

    
    reg pclk;
    reg presetn;

    
    reg transfer, read, write;
    reg [8:0] apb_write_paddr;
    reg [7:0] apb_write_data;
    reg [8:0] apb_read_paddr;

    
    wire pslverr;
    wire [7:0] apb_read_data_out;

    
    initial begin
        pclk = 0;
        forever #5 pclk = ~pclk;  
    end

    
    apb_top dut (
        .pclk(pclk),
        .presetn(presetn),
        .transfer(transfer),
        .read(read),
        .write(write),
        .apb_write_paddr(apb_write_paddr),
        .apb_write_data(apb_write_data),
        .apb_read_paddr(apb_read_paddr),
        .pslverr(pslverr),
        .apb_read_data_out(apb_read_data_out)
    );

    
    task reset_and_init;
        begin
            presetn = 0;
            transfer = 0;
            read = 0;
            write = 0;
            apb_write_paddr = 9'b0;
            apb_write_data = 8'b0;
            apb_read_paddr = 9'b0;
            #20;  
            presetn = 1;
            #10;
        end
    endtask

    // Test Case 1: Basic Write Operation
    task test_write;
        input [8:0] address;
        input [7:0] data;
        begin
            $display("Starting Basic Write Operation Test");
            transfer = 1;
            write = 1;
            read = 0;
            apb_write_paddr = address;
            apb_write_data = data;
            #10;  
            #10;  
            transfer = 0; 
            write = 0;
            $display("Write Operation Completed: Address = %h, Data = %h", address, data);
            #10;
        end
    endtask

    // Test Case 2: Basic Read Operation
    task test_read;
        input [8:0] address;
        begin
            $display("Starting Basic Read Operation Test");
            transfer = 1;
            write = 0;
            read = 1;
            apb_read_paddr = address;
            #10;  
            #10;  
            transfer = 0; 
            read = 0;
            $display("Read Operation Completed: Address = %h, Data Read = %h", address, apb_read_data_out);
            #10;
        end
    endtask

    // Test Case 3: Address Decoding (Slave Selection)
    task test_address_decoding;
        begin
            $display("Starting Address Decoding Test");
            test_write(9'h005, 8'hA5); 
            test_write(9'h085, 8'h5A); 
        end
    endtask

    // Test Case 4: Write with Wait States
    task test_write_with_wait_states;
        input [8:0] address;
        input [7:0] data;
        begin
            $display("Starting Write Operation with Wait States Test");
            transfer = 1;
            write = 1;
            read = 0;
            apb_write_paddr = address;
            apb_write_data = data;
            #10; 
            @(posedge pclk);
            $display("Slave ready signal delayed");
            #20; 
            transfer = 0;
            write = 0;
            $display("Write Completed with Wait States: Address = %h, Data = %h", address, data);
            #10;
        end
    endtask

    // Test Case 5: Read with Wait States
    task test_read_with_wait_states;
        input [8:0] address;
        begin
            $display("Starting Read Operation with Wait States Test");
            transfer = 1;
            write = 0;
            read = 1;
            apb_read_paddr = address;
            #10; 
            
            @(posedge pclk);
            $display("Slave ready signal delayed");
            #20; 
            transfer = 0;
            read = 0;
            $display("Read Completed with Wait States: Address = %h, Data Read = %h", address, apb_read_data_out);
            #10;
        end
    endtask

    // Test Case 6: Error Handling (PSLVERR)
    task test_error_handling;
        input [8:0] invalid_address;
        begin
            $display("Starting Error Handling Test");
            transfer = 1;
            write = 1;
            read = 0;
            apb_write_paddr = invalid_address;
            apb_write_data = 8'hFF;
            #10; 
            #10; 
            transfer = 0;
            write = 0;
            $display("Error Condition PSLVERR = %b for Invalid Address = %h", pslverr, invalid_address);
            #10;
        end
    endtask

    // Test Case 7: Burst Transfers
    task test_burst_transfers;
        begin
            $display("Starting Burst Transfers Test");
            test_write(9'h001, 8'h11);
            test_read(9'h001);
            test_write(9'h002, 8'h22);
            test_read(9'h002);
            test_write(9'h003, 8'h33);
            test_read(9'h003);
            $display("Burst Transfers Completed");
        end
    endtask

    // Case 8: Test Out-of-Range Address Handling
    task test_out_of_range_address;
        input [8:0] invalid_address;
        begin
            $display("\n[Case 8] Testing Out-of-Range Address Handling...");
            transfer = 1;
            write = 1;
            read = 0;
            apb_write_paddr = invalid_address; 
            apb_write_data = 8'hFF;           
            #10; 
            #10; 
            transfer = 0;
            write = 0;
            if (pslverr)
                $display("Error detected for invalid address %h, PSLVERR = %b", invalid_address, pslverr);
            else
                $display("No error detected for invalid address %h, PSLVERR = %b", invalid_address, pslverr);
            #10;
        end
    endtask

    // Case 9: Test Reset Behavior
    task test_reset_behavior;
        begin
            $display("\n[Case 9] Testing Reset Behavior...");
            presetn = 0; 
            #20;
            if (!presetn)
                $display("System Reset Asserted.");
            presetn = 1; 
            #10;
            if (presetn)
                $display("System Reset Released. Registers and signals should return to default states.");
            #10;
        end
    endtask

    // Case 10: Test Randomized Transactions
    task test_randomized_transactions;
        integer i;
        begin
            $display("\n[Case 10] Stress Testing with Randomized Transactions...");
            for (i = 0; i < 20; i = i + 1) begin
                transfer = 1;
                
                if ($random % 2) begin
                    write = 1;
                    read = 0;
                    apb_write_paddr = $random % 9'h100;
                    apb_write_data = $random % 8'hFF;  
                    $display("Write Transaction: Address = %h, Data = %h", apb_write_paddr, apb_write_data);
                end else begin
                    write = 0;
                    read = 1;
                    apb_read_paddr = $random % 9'h100; 
                    $display("Read Transaction: Address = %h", apb_read_paddr);
                end
                #10; 
                #10; 
                transfer = 0;
                write = 0;
                read = 0;
                #10;
            end
            $display("Randomized Transactions Completed.");
        end
    endtask




   
    initial begin
        $display("APB System Testbench Start");
        reset_and_init;
        
        test_write(9'h005, 8'hAA);                  
        test_read(9'h005);                          
        test_address_decoding;                      
        test_write_with_wait_states(9'h010, 8'hBB); 
        test_read_with_wait_states(9'h010);         
        test_error_handling(9'h1FF);                
        test_burst_transfers;                       
        test_out_of_range_address(9'h1FF);          
        test_reset_behavior;                        
        test_randomized_transactions;               
        $display("APB System Testbench Complete");
        $finish;
    end

endmodule
