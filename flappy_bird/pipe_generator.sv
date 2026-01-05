module pipe_generator (
    input  logic        clk,
    input  logic        reset,
    input  logic        playing,
    output logic [3:0]  pipe_x,
    output logic [3:0]  gap_y,
    output logic        pipe_passed  // Pulse when pipe moves past bird position
);
    parameter GAP_SIZE = 4;
    parameter BIRD_X = 12;
    
    logic [31:0] pipe_counter;
    logic [15:0] lfsr;
    
    always_ff @(posedge clk) begin
        if (reset) begin
            pipe_x <= 0;
            gap_y <= 6;
            pipe_counter <= 0;
            lfsr <= 16'hACE1;
            pipe_passed <= 0;
        end else if (playing) begin
            // LFSR for randomness
            lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
            
            pipe_counter <= pipe_counter + 1;
            pipe_passed <= 0;
            
            if (pipe_counter >= 10_000_000) begin
                if (pipe_x < 15) begin
                    pipe_x <= pipe_x + 1;
                    // Check if pipe just passed the bird
                    if (pipe_x == BIRD_X) begin
                        pipe_passed <= 1;
                    end
                end else begin
                    pipe_x <= 0;
                    gap_y <= lfsr[3:0] % 12;
                end
                pipe_counter <= 0;
            end
        end
    end
endmodule