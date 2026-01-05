module display_renderer (
    input  logic [3:0]  bird_x,
    input  logic [3:0]  bird_y,
    input  logic [3:0]  pipe_x,
    input  logic [3:0]  gap_y,
    input  logic [1:0]  game_state,  // IDLE=0, PLAY=1, PAUSE=2, GAME_OVER=3
    input  logic [24:0] blink_counter,
    output logic [15:0][15:0] RedPixels,
    output logic [15:0][15:0] GrnPixels
);
    parameter GAP_SIZE = 4;
    parameter GAME_OVER = 2'd3;
    
    always_comb begin
        RedPixels = '0;
        GrnPixels = '0;
        
        // Draw pipe
        for (int row = 0; row < 16; row++) begin
            if (row >= gap_y && row < gap_y + GAP_SIZE) begin
                GrnPixels[row][pipe_x] = 1'b0;
            end else begin
                GrnPixels[row][pipe_x] = 1'b1;
            end
        end
        
        // Draw bird (blink if game over)
        if (game_state != GAME_OVER || blink_counter[24]) begin
            RedPixels[bird_y] = 1 << bird_x;
        end
    end
endmodule