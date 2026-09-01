module tb ;
  reg [15:0]a,b;
  wire [31:0]z;
  
  mul_16_bit DUT (a,b,z);
  
  initial
   begin
     $monitor ("time=%d ,a =%d, b=%d, z =%d",$time,a,b,z);
      a = 16'h8210 ; b = 16'h9122  ;
     #20
      a = 16'h0000 ; b = 16'h9022 ;
     # 20
      a = 16'h0001 ; b = 16'hffff ;
     #20
      $finish;
   end
endmodule
