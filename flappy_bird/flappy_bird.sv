// Flappy Bird Game Module
// Integrates all game components
module flappy_bird (Clock, Reset, FlapButton, ResetButton, PauseSwitch,
                    HEX0, HEX1, HEX2, RedPixels, GrnPixels);
    input logic Clock, Reset;
    input logic FlapButton;     // Active high (inverted in DE1_SoC)
    input logic ResetButton;    // Active high (inverted in DE1_SoC)
    input logic PauseSwitch;
    output logic [6:0] HEX0, HEX1, HEX2;
    output logic [15:0][15:0] RedPixels, GrnPixels;
    
    // Internal signals
    logic [3:0] bird_y;
    logic [3:0] pipe_x, gap_y;
    logic [1:0] game_state;
    logic game_enable, blink_on;
    logic hit, in_gap;
    logic [11:0] score;
    logic flap_pressed, reset_pressed;
    
    // For score edge detection
    logic in_gap_prev;
    logic score_pulse;
    
    parameter BIRD_X = 4'd12;
    
    // Input handlers
    userInput flapInput (.clk(Clock), .reset(Reset), 
                         .button(~FlapButton), .pressed(flap_pressed));
    userInput resetInput (.clk(Clock), .reset(Reset), 
                          .button(~ResetButton), .pressed(reset_pressed));
    
    // Game state controller
    gameControl ctrl (.Clock(Clock), .Reset(Reset),
                      .StartButton(flap_pressed), .ResetButton(reset_pressed),
                      .PauseSwitch(PauseSwitch), .Collision(hit),
                      .GameState(game_state), .GameEnable(game_enable),
                      .BlinkOn(blink_on));
    
    // Game reset signal
    logic game_reset;
    assign game_reset = Reset | (game_state == 2'b00);
    
    // Bird module
    bird birdy (.Clock(Clock), .Reset(game_reset), .Enable(game_enable),
                .Flap(flap_pressed), .Y(bird_y));
    
    // Pipe module (has internal LFSR)
    pipe pipey (.Clock(Clock), .Reset(game_reset), .Enable(game_enable),
                .X(pipe_x), .GapY(gap_y));
    
    // Collision detector
    collision coll (.BirdX(BIRD_X), .BirdY(bird_y), 
                    .PipeX(pipe_x), .GapY(gap_y),
                    .Hit(hit), .InGap(in_gap));
    
    // Score on rising edge of in_gap (when bird enters gap at pipe position)
    always_ff @(posedge Clock) begin
        if (game_reset)
            in_gap_prev <= 0;
        else
            in_gap_prev <= in_gap;
    end
    
    assign score_pulse = in_gap & ~in_gap_prev;
    
    scoreCounter sc (.Clock(Clock), .Reset(game_reset),
                     .Increment(score_pulse), .Score(score));
    
    // Score digit extraction
    logic [3:0] ones, tens, hundreds;
    assign ones = score % 10;
    assign tens = (score / 10) % 10;
    assign hundreds = (score / 100) % 10;
    
    // 7-segment displays
    seg7 seg0 (.bcd(ones), .leds(HEX0));
    seg7 seg1 (.bcd(tens), .leds(HEX1));
    seg7 seg2 (.bcd(hundreds), .leds(HEX2));
    
    // Display output
    display disp (.BirdY(bird_y), .PipeX(pipe_x), .GapY(gap_y),
                  .GameState(game_state), .BlinkOn(blink_on),
                  .RedPixels(RedPixels), .GrnPixels(GrnPixels));
endmodule


module flappy_bird_testbench();
    logic Clock, Reset;
    logic FlapButton, ResetButton, PauseSwitch;
    logic [6:0] HEX0, HEX1, HEX2;
    logic [15:0][15:0] RedPixels, GrnPixels;
    
    flappy_bird dut (Clock, Reset, FlapButton, ResetButton, PauseSwitch,
                     HEX0, HEX1, HEX2, RedPixels, GrnPixels);
    
    parameter CLOCK_PERIOD = 100;
    initial begin
        Clock <= 0;
        forever #(CLOCK_PERIOD/2) Clock <= ~Clock;
    end
    
    initial begin
        // Reset
        Reset <= 1; FlapButton <= 0; ResetButton <= 0; PauseSwitch <= 0;
        repeat(2) @(posedge Clock);
        Reset <= 0;
        repeat(3) @(posedge Clock);
        
        // Start game
        FlapButton <= 1; @(posedge Clock);
        FlapButton <= 0; repeat(5) @(posedge Clock);
        
        // Let bird fall
        repeat(200) @(posedge Clock);
        
        // Flap
        FlapButton <= 1; @(posedge Clock);
        FlapButton <= 0; repeat(100) @(posedge Clock);
        
        FlapButton <= 1; @(posedge Clock);
        FlapButton <= 0; repeat(100) @(posedge Clock);
        
        // Test pause
        PauseSwitch <= 1; repeat(50) @(posedge Clock);
        PauseSwitch <= 0; repeat(50) @(posedge Clock);
        
        // Keep playing
        repeat(500) @(posedge Clock);
        
        // More flaps
        FlapButton <= 1; @(posedge Clock);
        FlapButton <= 0; repeat(100) @(posedge Clock);
        
        // Let game run longer
        repeat(5000) @(posedge Clock);
        
        // Reset game
        ResetButton <= 1; @(posedge Clock);
        ResetButton <= 0; repeat(5) @(posedge Clock);
        
        $stop;
    end
endmodule