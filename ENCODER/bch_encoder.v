`timescale 1ns / 1ps

module tb_bch_encoder_decoder_15_5;

    reg clk, rst, start;
    reg [4:0] data_in;
    reg [14:0] corrupted;
    wire [14:0] codeword;
    wire done;
    wire [14:0] corrected_codeword;

    // Instantiate encoder
    bch_encoder_15_5 uut_encoder (
        .clk(clk),
        .rst(rst),
        .start(start),
        .data_in(data_in),
        .codeword(codeword),
        .done(done)
    );

  

    // Clock generator
    always #5 clk = ~clk;

    initial begin
        $display("=== BCH(15,5,3) Encoder Testbench ===");

        // Waveform generation
        $dumpfile("bch_encoder_decoder.vcd");
        $dumpvars(0, tb_bch_encoder_decoder_15_5);

        // Init
        clk = 0;
        rst = 1;
        start = 0;
        data_in = 5'b0;

        // Reset pulse
        #10 rst = 0;

        // Apply input
        data_in = 5'b10101;  // Example data
        start = 1;
        #10 start = 0;

        // Wait for encoding
        wait(done);
        #10;
        $display("Input Data: %b", data_in);
        $display("Original Codeword: %b", codeword);

        // Inject 3 bit errors (flip bits at positions 13, 9, and 0)
        corrupted = codeword;
        corrupted[13] = ~corrupted[13];
        corrupted[9]  = ~corrupted[9];
        corrupted[0]  = ~corrupted[0];

        $display("Corrupted Codeword (3 errors): %b", corrupted);

        

        $finish;
    end

endmodule
