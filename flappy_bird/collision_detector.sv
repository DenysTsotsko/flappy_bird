module collision_detector (
    input  logic [3:0]  bird_x,
    input  logic [3:0]  bird_y,
    input  logic [3:0]  pipe_x,
    input  logic [3:0]  gap_y,
    output logic        collision
);
    parameter GAP_SIZE = 4;
    
    always_comb begin
        if (bird_x == pipe_x && (bird_y < gap_y || bird_y >= gap_y + GAP_SIZE)) begin
            collision = 1'b1;
        end else begin
            collision = 1'b0;
        end
    end
endmodule


module collision_detector_testbench();
    logic [3:0] bird_x, bird_y, pipe_x, gap_y;
    logic collision;
    
    collision_detector dut (bird_x, bird_y, pipe_x, gap_y, collision);
    
    initial begin
        // Test no collision - bird away from pipe
        bird_x = 12; bird_y = 8; pipe_x = 5; gap_y = 6;
        #10;
        if (!collision) $display("PASS: No collision when pipe away");
        else $display("FAIL: Should not collide");
        
        // Test no collision - bird in gap
        bird_x = 12; bird_y = 7; pipe_x = 12; gap_y = 6;
        #10;
        if (!collision) $display("PASS: No collision in gap");
        else $display("FAIL: Should not collide in gap");
        
        // Test collision - bird above gap
        bird_x = 12; bird_y = 3; pipe_x = 12; gap_y = 6;
        #10;
        if (collision) $display("PASS: Collision above gap");
        else $display("FAIL: Should collide above gap");
        
        // Test collision - bird below gap
        bird_x = 12; bird_y = 11; pipe_x = 12; gap_y = 6;
        #10;
        if (collision) $display("PASS: Collision below gap");
        else $display("FAIL: Should collide below gap");
        
        $stop;
    end
endmodule