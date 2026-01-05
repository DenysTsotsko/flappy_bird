module bird_physics (
    input  logic        clk,
    input  logic        reset,
    input  logic        playing,      // Only active when game is playing
    input  logic        flap,          // Flap signal (edge-detected)
    output logic [3:0]  bird_y
);
    logic [31:0] gravity_counter;
    
    always_ff @(posedge clk) begin
        if (reset) begin
            bird_y <= 8;
            gravity_counter <= 0;
        end else if (playing) begin
            // Gravity
            gravity_counter <= gravity_counter + 1;
            if (gravity_counter >= 20_000_000) begin
                if (bird_y < 15) begin
                    bird_y <= bird_y + 1;
                end
                gravity_counter <= 0;
            end
            
            // Flapping
            if (flap) begin
                if (bird_y > 0) begin
                    bird_y <= bird_y - 1;
                end
            end
        end
    end
endmodule



module bird_physics_testbench();
    logic clk, reset, playing, flap;
    logic [3:0] bird_y;
    
    bird_physics dut (clk, reset, playing, flap, bird_y);
    
    parameter CLOCK_PERIOD = 100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end
    
    initial begin
        // Reset
        reset <= 1; playing <= 0; flap <= 0;
        repeat(2) @(posedge clk);
        reset <= 0;
        repeat(2) @(posedge clk);
        
        // Start playing
        playing <= 1;
        repeat(10) @(posedge clk);
        
        // Test flapping
        flap <= 1; @(posedge clk);
        flap <= 0; repeat(5) @(posedge clk);
        
        flap <= 1; @(posedge clk);
        flap <= 0; repeat(5) @(posedge clk);
        
        // Let gravity work
        repeat(20) @(posedge clk);
        
        // Stop playing
        playing <= 0;
        repeat(5) @(posedge clk);
        
        $stop;
    end
endmodule