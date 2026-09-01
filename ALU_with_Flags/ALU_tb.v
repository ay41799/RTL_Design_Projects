`timescale 1ns / 1ps

module tb_ALU;
    
    reg [31:0] A;
    reg [31:0] B;
    reg [1:0] ALUControl;

    wire [31:0] Result;
    wire Z, N, V, C;
    
    ALU uut (
        .A(A),
        .B(B),
        .ALUControl(ALUControl),
        .Result(Result),
        .Z(Z),
        .N(N),
        .V(V),
        .C(C)
    );

    initial begin
        
        $monitor("Time=%0t | ALUControl=%b | A=%d, B=%d | Result=%d (Hex: %h) | Flags [Z=%b, N=%b, V=%b, C=%b]",
                 $time, ALUControl, A, B, Result, Result, Z, N, V, C);

        A = 32'd15;
        B = 32'd10;
        ALUControl = 2'b00;
        #10;
      
        A = 32'd15;
        B = 32'd10;
        ALUControl = 2'b01;
        #10;
      
        A = 32'd10;
        B = 32'd10;
        ALUControl = 2'b01;
        #10;

        A = 32'd5;
        B = 32'd10;
        ALUControl = 2'b01;
        #10;

        A = 32'hF0F0F0F0;
        B = 32'hFF00FF00;
        ALUControl = 2'b10;
        #10;
      
        A = 32'hF0F0F0F0;
        B = 32'h0F0F0F0F;
        ALUControl = 3'b11;
        #10;
  
        A = 32'h7FFFFFFF; 
        B = 32'd1;
        ALUControl = 3'b00;
        #10;
      
        $finish;
    end

endmodule
