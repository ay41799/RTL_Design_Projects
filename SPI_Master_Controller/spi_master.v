////module spi_master #(
////    parameter DATA_WIDTH = 8,
////    parameter CLK_DIV    = 4
////)(
////    input  wire                   clk,
////    input  wire                   rst_n,

////    input  wire [DATA_WIDTH-1:0]  parallel_data,
////    input  wire                   data_valid,

////    output reg                    spi_clk,
////    output reg                    spi_cs,
////    output reg                    spi_mosi
////);

////    //---------------------------------------
////    // Internal Registers
////    //---------------------------------------
////    reg [DATA_WIDTH-1:0] shift_reg;
////    reg [3:0] bit_cnt;
////    reg [1:0] state;

////    reg [15:0] clk_cnt;
////    reg spi_clk_en;

////    //---------------------------------------
////    // FSM States
////    //---------------------------------------
////    localparam IDLE  = 2'd0;
////    localparam LOAD  = 2'd1;
////    localparam SHIFT = 2'd2;
////    localparam DONE  = 2'd3;

////    //---------------------------------------
////    // SPI Clock Divider
////    //---------------------------------------
////    always @(posedge clk or negedge rst_n)
////    begin
////        if(!rst_n)
////        begin
////            clk_cnt <= 0;
////            spi_clk <= 0;
////        end
////        else if(spi_clk_en)
////        begin
////            if(clk_cnt == CLK_DIV-1)
////            begin
////                clk_cnt <= 0;
////                spi_clk <= ~spi_clk;
////            end
////            else
////                clk_cnt <= clk_cnt + 1;
////        end
////        else
////        begin
////            clk_cnt <= 0;
////            spi_clk <= 0;
////        end
////    end

////    //---------------------------------------
////    // FSM
////    //---------------------------------------
////    always @(posedge clk or negedge rst_n)
////    begin
////        if(!rst_n)
////        begin
////            state <= IDLE;
////            spi_cs <= 1'b1;
////            spi_mosi <= 0;
////            bit_cnt <= 0;
////            spi_clk_en <= 0;
////        end
////        else
////        begin
////            case(state)

////            //---------------------------------------
////            IDLE:
////            //---------------------------------------
////            begin
////                spi_cs <= 1'b1;
////                spi_clk_en <= 0;

////                if(data_valid)
////                    state <= LOAD;
////            end

////            //---------------------------------------
////            LOAD:
////            //---------------------------------------
////            begin
////                spi_cs <= 0;
////                shift_reg <= parallel_data;
////                bit_cnt <= DATA_WIDTH-1;
////                spi_clk_en <= 1;

////                state <= SHIFT;
////            end

////            //---------------------------------------
////            SHIFT:
////            //---------------------------------------
////            begin
////                if(spi_clk == 0 && clk_cnt == CLK_DIV-1)
////                    spi_mosi <= shift_reg[bit_cnt];

////                if(spi_clk == 1 && clk_cnt == CLK_DIV-1)
////                begin
////                    if(bit_cnt == 0)
////                        state <= DONE;
////                    else
////                        bit_cnt <= bit_cnt - 1;
////                end
////            end

////            //---------------------------------------
////            DONE:
////            //---------------------------------------
////            begin
////                spi_cs <= 1'b1;
////                spi_clk_en <= 0;
////                state <= IDLE;
////            end

////            endcase
////        end
////    end

////endmodule








//module spi_master #(
//    parameter DATA_WIDTH = 8,
//    parameter CLK_DIV    = 4
//)(
//    input  wire                   clk,
//    input  wire                   rst_n,

//    input  wire [DATA_WIDTH-1:0]  parallel_data,
//    input  wire                   data_valid,

//    output reg                    spi_clk,
//    output reg                    spi_cs,
//    output reg                    spi_mosi
//);

//    //---------------------------------------
//    // Internal Registers
//    //---------------------------------------
//    reg [DATA_WIDTH-1:0] shift_reg;
//    reg [3:0] bit_cnt;
//    reg [1:0] state;

//    reg [15:0] clk_cnt;
//    reg spi_clk_en;

//    // Edge detection
//    reg spi_clk_d;
//    wire rising_edge;
//    wire falling_edge;

//    //---------------------------------------
//    // FSM States
//    //---------------------------------------
//    localparam IDLE  = 2'd0;
//    localparam LOAD  = 2'd1;
//    localparam SHIFT = 2'd2;
//    localparam DONE  = 2'd3;

//    //---------------------------------------
//    // Edge Detection Logic
//    //---------------------------------------
//    always @(posedge clk or negedge rst_n) begin
//        if(!rst_n)
//            spi_clk_d <= 0;
//        else
//            spi_clk_d <= spi_clk;
//    end

//    assign rising_edge  = (spi_clk == 1'b1 && spi_clk_d == 1'b0);
//    assign falling_edge = (spi_clk == 1'b0 && spi_clk_d == 1'b1);

//    //---------------------------------------
//    // SPI Clock Divider (CPOL = 0 → idle LOW)
//    //---------------------------------------
//    always @(posedge clk or negedge rst_n)
//    begin
//        if(!rst_n)
//        begin
//            clk_cnt <= 0;
//            spi_clk <= 0;
//        end
//        else if(spi_clk_en)
//        begin
//            if(clk_cnt == CLK_DIV-1)
//            begin
//                clk_cnt <= 0;
//                spi_clk <= ~spi_clk;
//            end
//            else
//                clk_cnt <= clk_cnt + 1;
//        end
//        else
//        begin
//            clk_cnt <= 0;
//            spi_clk <= 0; // CPOL = 0
//        end
//    end

//    //---------------------------------------
//    // FSM
//    //---------------------------------------
//    always @(posedge clk or negedge rst_n)
//    begin
//        if(!rst_n)
//        begin
//            state <= IDLE;
//            spi_cs <= 1'b1;
//            spi_mosi <= 0;
//            bit_cnt <= 0;
//            spi_clk_en <= 0;
//            shift_reg <= 0;
//        end
//        else
//        begin
//            case(state)

//            //---------------------------------------
//            IDLE:
//            //---------------------------------------
//            begin
//                spi_cs <= 1'b1;
//                spi_clk_en <= 0;

//                if(data_valid)
//                    state <= LOAD;
//            end

//            //---------------------------------------
//            LOAD:
//            //---------------------------------------
//            begin
//                spi_cs <= 1'b0;
//                shift_reg <= parallel_data;
//                bit_cnt <= DATA_WIDTH-1;
//                spi_clk_en <= 1;

//                // ⭐ CPHA = 0 → preload first bit
//                spi_mosi <= parallel_data[DATA_WIDTH-1];

//                state <= SHIFT;
//            end

//            //---------------------------------------
//            SHIFT:
//            //---------------------------------------
//            begin
//                // SHIFT on falling edge (Mode 0)
//                if(falling_edge && clk_cnt == 0)
//                begin
//                    if(bit_cnt == 0)
//                        state <= DONE;
//                    else
//                        bit_cnt <= bit_cnt - 1;
//                end

//                // Update MOSI on falling edge
//                if(falling_edge && clk_cnt  == 0)
//                    spi_mosi <= shift_reg[bit_cnt];
//            end

//            //---------------------------------------
//            DONE:
//            //---------------------------------------
//            begin
//                spi_cs <= 1'b1;
//                spi_clk_en <= 0;
//                state <= IDLE;
//            end

//            endcase
//        end
//    end

//endmodule


module spi_master #(
    parameter DATA_WIDTH = 8,
    parameter CLK_DIV    = 4
)(
    input  wire                   clk,//high frequency
    input  wire                   rst_n,
    input  wire [DATA_WIDTH-1:0]  parallel_data,
    input  wire                   data_valid,
    output reg                    spi_clk,
    output reg                    spi_cs,
    output reg                    spi_mosi
);

    reg [DATA_WIDTH-1:0] shift_reg;
    reg [3:0]  bit_cnt;
    reg [1:0]  state;
    reg [15:0] clk_cnt;
    reg        spi_clk_en;

    // Edge detection
    reg  spi_clk_d;
    wire falling_edge;
    wire rising_edge;

    localparam IDLE  = 2'd0;
    localparam LOAD  = 2'd1;
    localparam SHIFT = 2'd2;
    localparam DONE  = 2'd3;

    //---------------------------------------
    // Edge Detection
    //---------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) spi_clk_d <= 0;
        else        spi_clk_d <= spi_clk;
    end

    // Falling edge: spi_clk just went LOW
    assign falling_edge = (!spi_clk && spi_clk_d);
    assign rising_edge  = (spi_clk == 1'b1 && spi_clk_d == 1'b0);

    //---------------------------------------
    // SPI Clock Divider
    //---------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_cnt <= 0;
            spi_clk <= 0;
        end
        else if (spi_clk_en) begin
            if (clk_cnt == CLK_DIV - 1) begin //clk_cnt == 3
                clk_cnt <= 0;
                spi_clk <= ~spi_clk;
            end else begin
                clk_cnt <= clk_cnt + 1;
            end
        end else begin
            clk_cnt <= 0;
            spi_clk <= 0;
        end
    end

    //---------------------------------------
    // FSM
    //---------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= IDLE;
            spi_cs     <= 1'b1; //active low
            spi_mosi   <= 0;
            bit_cnt    <= 0;
            spi_clk_en <= 0;
            shift_reg  <= 0;
        end
        else begin
            case (state)

            IDLE: begin
                spi_cs     <= 1'b1;
                spi_clk_en <= 0;
                if (data_valid)
                    state <= LOAD;
            end

           LOAD: begin
    spi_cs     <= 1'b0;
    shift_reg  <= parallel_data;      //  store all 8 bits
    bit_cnt    <= DATA_WIDTH - 1;
    spi_clk_en <= 1;
    spi_mosi   <= parallel_data[DATA_WIDTH-1]; //  preload MSB
    state      <= SHIFT;
end

SHIFT: begin
    if (falling_edge) begin
        if (bit_cnt == 0) begin
            state <= DONE;
        end else begin
            bit_cnt  <= bit_cnt - 1;
            spi_mosi <= shift_reg[bit_cnt - 1]; //  next bit
        end
    end
end

            DONE: begin
                spi_cs     <= 1'b1;
                spi_clk_en <= 0;
                spi_mosi   <= 0;
                state      <= IDLE;
            end

            endcase
        end
    end

endmodule