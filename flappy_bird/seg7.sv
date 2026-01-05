// 7-Segment Display Decoder
// Active-low outputs (0 = segment ON)
module seg7 (bcd, leds);
    input logic [3:0] bcd;  // binary coded decimal
    output logic [6:0] leds;
    
    always_comb begin
        case (bcd)
            4'd0: leds = 7'b1000000;
            4'd1: leds = 7'b1111001;
            4'd2: leds = 7'b0100100;
            4'd3: leds = 7'b0110000;
            4'd4: leds = 7'b0011001;
            4'd5: leds = 7'b0010010;
            4'd6: leds = 7'b0000010;
            4'd7: leds = 7'b1111000;
            4'd8: leds = 7'b0000000;
            4'd9: leds = 7'b0010000;
            default: leds = 7'b1111111;
        endcase
    end
endmodule

module seg7_testbench();
    logic [3:0] bcd;
    logic [6:0] leds;
    
    seg7 dut (bcd, leds);
    
    initial begin
        // Test all digits 0-9
        for (int i = 0; i <= 9; i++) begin
            bcd = i; #10;
        end
        
        // Test invalid inputs
        bcd = 4'd10; #10;
        bcd = 4'd15; #10;
        
        $stop;
    end
endmodule