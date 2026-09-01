module HA (input a, b, output s, c);
  assign s = a ^ b;
  assign c = a & b;
endmodule

module mul_2_bit (input [1:0] a, b, output [3:0] s);
  wire p0, p1, p2, c;
  
  assign s[0] = a[0] & b[0];
  
  assign p0 = a[1] & b[0];
  assign p1 = a[0] & b[1];
  assign p2 = a[1] & b[1];
  
  HA h0 (p0, p1, s[1], c);
  HA h1 (p2, c,  s[2], s[3]);
endmodule

module mul_4_bit (input [3:0] a, b, output [7:0] s);
  wire [3:0] q0, q1, q2, q3;
  wire [7:0] q4, q5, q6, q7;
  wire [1:0] t_a_lower, t_b_lower, t_a_upper, t_b_upper;
  
  assign t_a_lower = a[1:0];
  assign t_b_lower = b[1:0];
  assign t_a_upper = a[3:2]; 
  assign t_b_upper = b[3:2];
  
  mul_2_bit m0(t_a_lower, t_b_lower, q0);
  mul_2_bit m1(t_a_lower, t_b_upper, q1);
  mul_2_bit m2(t_a_upper, t_b_lower, q2);
  mul_2_bit m3(t_a_upper, t_b_upper, q3); 
  
  assign q4 = {4'b0, q0};
  assign q5 = {2'b0, q1, 2'b0};
  assign q6 = {2'b0, q2, 2'b0};
  assign q7 = {q3, 4'b0};
  
  assign s = q4 + q5 + q6 + q7;
endmodule

module mul_8_bit (input [7:0] a, b, output [15:0] s);
  wire [7:0] q0, q1, q2, q3;
  wire [15:0] q4, q5, q6, q7;
  wire [3:0] t_a_lower, t_b_lower, t_a_upper, t_b_upper;
  
  assign t_a_lower = a[3:0];
  assign t_b_lower = b[3:0];
  assign t_a_upper = a[7:4]; 
  assign t_b_upper = b[7:4];
  
  mul_4_bit m0(t_a_lower, t_b_lower, q0);
  mul_4_bit m1(t_a_lower, t_b_upper, q1);
  mul_4_bit m2(t_a_upper, t_b_lower, q2);
  mul_4_bit m3(t_a_upper, t_b_upper, q3); 
  
  assign q4 = {8'b0, q0};
  assign q5 = {4'b0, q1, 4'b0};
  assign q6 = {4'b0, q2, 4'b0};
  assign q7 = {q3, 8'b0};
  
  assign s = q4 + q5 + q6 + q7;
endmodule

module mul_16_bit (input [15:0] a, b, output [31:0] s);
  wire [15:0] q0, q1, q2, q3;
  wire [31:0] q4, q5, q6, q7;
  wire [7:0] t_a_lower, t_b_lower, t_a_upper, t_b_upper;
  
  assign t_a_lower = a[7:0];
  assign t_b_lower = b[7:0];
  assign t_a_upper = a[15:8]; 
  assign t_b_upper = b[15:8];
  
  mul_8_bit m0(t_a_lower, t_b_lower, q0);
  mul_8_bit m1(t_a_lower, t_b_upper, q1);
  mul_8_bit m2(t_a_upper, t_b_lower, q2);
  mul_8_bit m3(t_a_upper, t_b_upper, q3); 
  
  assign q4 = {16'b0, q0};
  assign q5 = {8'b0, q1, 8'b0};
  assign q6 = {8'b0, q2, 8'b0};
  assign q7 = {q3, 16'b0};
  
  assign s = q4 + q5 + q6 + q7;
endmodule






