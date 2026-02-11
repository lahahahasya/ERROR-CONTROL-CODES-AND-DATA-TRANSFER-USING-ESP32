`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.04.2025 15:46:27
// Design Name: 
// Module Name: bch_encoder_15_7_2
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bch_encoder_15_5 (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,
    input  wire [4:0]  data_in,
    output reg  [14:0] codeword,
    output reg         done
);
    reg [14:0] shift_reg;
    reg [2:0]  bit_cnt;
    reg        encoding;
    reg feedback;

    // Generator polynomial: g(x) = x^10 + x^8 + x^5 + x^4 + x^2 + x + 1
    // Tap positions correspond to [8, 5, 4, 2, 1, 0] (after shifting by 5)
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_reg <= 15'd0;
            bit_cnt   <= 0;
            encoding  <= 0;
            codeword  <= 15'd0;
            done      <= 0;
        end else begin
            if (start && !encoding) begin
                // Load message into high bits, pad 10 zeros
                shift_reg <= {data_in, 10'b0};
                bit_cnt   <= 0;
                encoding  <= 1;
                done      <= 0;
            end else if (encoding) begin
                // Take MSB as feedback
                feedback = shift_reg[14];
                shift_reg <= shift_reg << 1;

                if (feedback) begin
                    // XOR with g(x) taps
                    shift_reg[13] <= shift_reg[13]^ 1; // x^8
                    shift_reg[10] <= shift_reg[10]^ 1; // x^5
                    shift_reg[9] <= shift_reg[9]^ 1;; // x^4
                    shift_reg[7] <= shift_reg[7]^ 1; // x^2
                    shift_reg[6] <= shift_reg[6]^ 1; // x^1
                    shift_reg[5]<= shift_reg[5]^ 1;// x^0
                end

                bit_cnt <= bit_cnt + 1;
                if (bit_cnt == 4) begin
                    codeword <= {data_in, shift_reg[14:5]}; // 5 data + 10 parity
                    done <= 1;
                    encoding <= 0;
                end
            end
        end
    end
endmodule
