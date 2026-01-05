// 16-bit LFSR for pseudo-random number generation
// Used for random pipe gap positions
module LFSR (Clock, Reset, Q);
    input logic Clock, Reset;
    output logic [15:0] Q;
    
    always_ff @(posedge Clock) begin
        if (Reset)
            Q <= 16'hACE1;  // Non-zero seed
        else begin
            // Shift with XOR feedback (taps at 16, 14, 13, 11)
            Q <= {Q[14:0], Q[15] ^ Q[13] ^ Q[12] ^ Q[10]};
        end
    end
endmodule

module LFSR_testbench();
    logic Clock, Reset;
    logic [15:0] Q;
    
    LFSR dut (Clock, Reset, Q);
    
    parameter CLOCK_PERIOD = 100;
    initial begin
        Clock <= 0;
        forever #(CLOCK_PERIOD/2) Clock <= ~Clock;
    end
    
    initial begin
        // Reset
        Reset <= 1; @(posedge Clock);
        Reset <= 0;
        
        // Run through many cycles
        repeat(50) @(posedge Clock);
        
        // Reset again
        Reset <= 1; @(posedge Clock);
        Reset <= 0;
        repeat(20) @(posedge Clock);
        
        $stop;
    end
endmodule