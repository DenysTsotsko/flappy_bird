// Score Counter - Increments on scoring event
module scoreCounter (Clock, Reset, Increment, Score);
    input logic Clock, Reset;
    input logic Increment;
    output logic [11:0] Score;  // Up to 999
    
    // Track previous increment to detect edge
    logic inc_prev;
    
    always_ff @(posedge Clock) begin
        if (Reset) begin
            Score <= 0;
            inc_prev <= 0;
        end
        else begin
            inc_prev <= Increment;
            // Increment on rising edge only
            if (Increment && !inc_prev && Score < 999)
                Score <= Score + 1;
        end
    end
endmodule

module scoreCounter_testbench();
    logic Clock, Reset, Increment;
    logic [11:0] Score;
    
    scoreCounter dut (Clock, Reset, Increment, Score);
    
    parameter CLOCK_PERIOD = 100;
    initial begin
        Clock <= 0;
        forever #(CLOCK_PERIOD/2) Clock <= ~Clock;
    end
    
    initial begin
        // Reset
        Reset <= 1; Increment <= 0; @(posedge Clock);
        Reset <= 0; repeat(2) @(posedge Clock);
        
        // Increment score
        Increment <= 1; @(posedge Clock);
        Increment <= 0; repeat(2) @(posedge Clock);
        
        // Increment again
        Increment <= 1; @(posedge Clock);
        Increment <= 0; repeat(2) @(posedge Clock);
        
        // Multiple increments
        repeat(5) begin
            Increment <= 1; @(posedge Clock);
            Increment <= 0; repeat(2) @(posedge Clock);
        end
        
        $stop;
    end
endmodule