// Collision Detector
// Checks if bird hits pipe (outside gap)
module collision (BirdX, BirdY, PipeX, GapY, Hit, InGap);
    input logic [3:0] BirdX, BirdY;
    input logic [3:0] PipeX, GapY;
    output logic Hit;    // Bird hit pipe
    output logic InGap;  // Bird is in gap (for scoring)
    
    parameter GAP_SIZE = 4;
    parameter BIRD_X = 4'd12;  // Fixed bird X position
    
    always_comb begin
        Hit = 0;
        InGap = 0;
        
        // Check collision only when bird is at pipe column
        if (PipeX == BIRD_X) begin
            // Bird is in gap (safe)
            if (BirdY >= GapY && BirdY < (GapY + GAP_SIZE))
                InGap = 1;
            else
                Hit = 1;  // Bird hits the pipe
        end
    end
endmodule

module collision_testbench();
    logic [3:0] BirdX, BirdY, PipeX, GapY;
    logic Hit, InGap;
    
    collision dut (BirdX, BirdY, PipeX, GapY, Hit, InGap);
    
    initial begin
        BirdX = 4'd12;  // Bird X is fixed
        GapY = 4'd6;    // Gap from 6-9
        
        // Pipe not at bird yet
        PipeX = 4'd5; BirdY = 4'd8; #10;
        
        // Pipe at bird, bird in gap
        PipeX = 4'd12; BirdY = 4'd7; #10;
        
        // Pipe at bird, bird above gap (hit)
        PipeX = 4'd12; BirdY = 4'd4; #10;
        
        // Pipe at bird, bird below gap (hit)
        PipeX = 4'd12; BirdY = 4'd12; #10;
        
        // Pipe passed bird
        PipeX = 4'd14; BirdY = 4'd12; #10;
        
        $stop;
    end
endmodule