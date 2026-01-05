// Display Module - Generates LED matrix patterns
// Red = Bird, Green = Pipe
module display (BirdY, PipeX, GapY, GameState, BlinkOn, RedPixels, GrnPixels);
    input logic [3:0] BirdY;
    input logic [3:0] PipeX, GapY;
    input logic [1:0] GameState;
    input logic BlinkOn;
    output logic [15:0][15:0] RedPixels;
    output logic [15:0][15:0] GrnPixels;
    
    parameter BIRD_X = 4'd12;
    parameter GAP_SIZE = 4;
    parameter IDLE = 2'b00;
    parameter GAME_OVER = 2'b11;
    
    always_comb begin
        // Clear display
        RedPixels = '0;
        GrnPixels = '0;
        
        if (GameState == IDLE) begin
            // Show bird in center when idle
            RedPixels[8][BIRD_X] = 1'b1;
        end
        else begin
            // Draw pipe (green column with gap)
            for (int row = 0; row < 16; row++) begin
                if (row < GapY || row >= (GapY + GAP_SIZE))
                    GrnPixels[row][PipeX] = 1'b1;
            end
            
            // Draw bird (blink during game over)
            if (GameState != GAME_OVER || BlinkOn)
                RedPixels[BirdY][BIRD_X] = 1'b1;
        end
    end
endmodule

module display_testbench();
    logic [3:0] BirdY, PipeX, GapY;
    logic [1:0] GameState;
    logic BlinkOn;
    logic [15:0][15:0] RedPixels, GrnPixels;
    
    display dut (BirdY, PipeX, GapY, GameState, BlinkOn, RedPixels, GrnPixels);
    
    initial begin
        // IDLE state
        GameState = 2'b00; BirdY = 8; PipeX = 5; GapY = 6; BlinkOn = 0;
        #10;
        
        // PLAY state
        GameState = 2'b01;
        #10;
        
        // Move bird
        BirdY = 4; #10;
        BirdY = 10; #10;
        
        // Move pipe
        PipeX = 10; #10;
        PipeX = 12; #10;
        
        // GAME_OVER with blink
        GameState = 2'b11;
        BlinkOn = 1; #10;
        BlinkOn = 0; #10;
        BlinkOn = 1; #10;
        
        $stop;
    end
endmodule