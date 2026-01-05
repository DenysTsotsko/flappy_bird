// Bird Module - Handles vertical position with gravity and flap
module bird (Clock, Reset, Enable, Flap, Y);
    input logic Clock, Reset, Enable;
    input logic Flap;           // Flap input to move up
    output logic [3:0] Y;       // Bird Y position (0-15)
    
    // Gravity counter
    logic [7:0] gravity_cnt;
    parameter GRAVITY_RATE = 8'd150;  // Ticks before bird falls
    
    always_ff @(posedge Clock) begin
        if (Reset) begin
            Y <= 4'd8;          // Start at center
            gravity_cnt <= 0;
        end
        else if (Enable) begin
            // Flap - move up by 2
            if (Flap) begin
                if (Y >= 2)
                    Y <= Y - 2;
                else
                    Y <= 0;
                gravity_cnt <= 0;
            end
            // Gravity - move down by 1
            else begin
                gravity_cnt <= gravity_cnt + 1;
                if (gravity_cnt >= GRAVITY_RATE) begin
                    gravity_cnt <= 0;
                    if (Y < 15)
                        Y <= Y + 1;
                end
            end
        end
    end
endmodule

module bird_testbench();
    logic Clock, Reset, Enable, Flap;
    logic [3:0] Y;
    
    bird dut (Clock, Reset, Enable, Flap, Y);
    
    parameter CLOCK_PERIOD = 100;
    initial begin
        Clock <= 0;
        forever #(CLOCK_PERIOD/2) Clock <= ~Clock;
    end
    
    initial begin
        // Reset
        Reset <= 1; Enable <= 0; Flap <= 0; @(posedge Clock);
        Reset <= 0; Enable <= 1; repeat(2) @(posedge Clock);
        
        // Let bird fall
        repeat(20) @(posedge Clock);
        
        // Flap
        Flap <= 1; @(posedge Clock);
        Flap <= 0; repeat(5) @(posedge Clock);
        
        // Flap again
        Flap <= 1; @(posedge Clock);
        Flap <= 0; repeat(5) @(posedge Clock);
        
        // Let bird fall more
        repeat(30) @(posedge Clock);
        
        $stop;
    end
endmodule