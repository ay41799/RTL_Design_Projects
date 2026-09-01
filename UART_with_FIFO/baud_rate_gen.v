module baud_rate_gen #(parameter clk = 50000000 ;
                       parameter baud_rate = 9600 ;
                       parameter oversample = 16 ;)
                      (input clk,rst,
                       output tx_enb,rx_enb);
 
  localparam tx_width = $clog2(clk/baud_rate) + 1;
  localparam rx_width = $clog2(clk/ (baud_rate * oversample) +1;
  localparam tx_div = clk/baud_rate;
  localparam rx_div = clk/ (baud_rate * oversample);
    
  reg [tx_width - 1 : 0] count_tx;
  reg [rx_width - 1 : 0] count_rx;
  
  always @ (posedge clk)
    begin
     if(rst)
       begin
        count_tx <= 0;
        tx_enb <= 0;
       end
     else 
      begin 
        tx_enb <= 0  ; 
          if (count_tx == tx_div)
             begin
               count_tx <= 0;
               tx_enb <= 1'b1;
             end
          else 
           begin
            count_tx <= count_tx + 1'b1 ;
           end
     end
  
  always @ (posedge clk)
      begin
       if (rst)
          begin
            count_rx <= 0 ;
            rx_enb <= 0 ;
          end
       else 
        begin
         rx_enb <= 0  ; 
          if (count == tx_div)
            begin
             count_rx <= 0;
             rx_enb <= 1'b1
            end
          else
            begin
              count_rx <= count_rx + 1'b1 ;
            end
         end
      end

endmodule
         

