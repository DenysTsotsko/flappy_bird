// Top-level DE1_SoC module for Flappy Bird
module DE1_SoC (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, GPIO_1);
    input logic CLOCK_50;
    output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    output logic [9:0] LEDR;
    input logic [3:0] KEY;
    input logic [9:0] SW;
    output logic [35:0] GPIO_1;
    
    // Clock and reset signals
    logic reset;
    logic clkSelect;
    logic [31:0] div_clk;
    assign reset = SW[9];
    
    // Clock divider (no reset input per instructor's file)
    parameter whichClock = 15;  // ~763Hz for gameplay
    clock_divider cdiv (.clock(CLOCK_50), .divided_clocks(div_clk));
    
    // !!!!! SELECT ONE !!!!!
    // assign clkSelect = CLOCK_50;           // For simulation
    assign clkSelect = div_clk[whichClock];  // For board
    
    // LED matrix signals
    logic [15:0][15:0] RedPixels, GrnPixels;
    
    // LED Driver (per instructor's file)
    LEDDriver Driver (.CLK(div_clk[15]), .RST(reset), .EnableCount(1'b1),
                      .RedPixels(RedPixels), .GrnPixels(GrnPixels), .GPIO_1(GPIO_1));
    
    // Flappy Bird game
    // KEY[0] = Flap, KEY[3] = Reset (active-low, inverted inside)
    // SW[0] = Pause
    flappy_bird game (.Clock(clkSelect), .Reset(reset),
                      .FlapButton(~KEY[0]), .ResetButton(~KEY[3]),
                      .PauseSwitch(SW[0]),
                      .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2),
                      .RedPixels(RedPixels), .GrnPixels(GrnPixels));
    
    // Blank unused displays
    assign HEX3 = 7'b1111111;
    assign HEX4 = 7'b1111111;
    assign HEX5 = 7'b1111111;
    
    // Status LEDs
    assign LEDR = 10'b0;
endmodule

module DE1_SoC_testbench();
    logic CLOCK_50;
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    logic [9:0] LEDR;
    logic [3:0] KEY;
    logic [9:0] SW;
    logic [35:0] GPIO_1;
    
    DE1_SoC dut (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, 
                 KEY, LEDR, SW, GPIO_1);
    
    parameter CLOCK_PERIOD = 100;
    initial begin
        CLOCK_50 <= 0;
        forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
    end
    
    initial begin
        // Initialize - keys released, switches off
        KEY <= 4'b1111; SW <= 10'b0;
        
        // Reset
        SW[9] <= 1; repeat(2) @(posedge CLOCK_50);
        SW[9] <= 0; repeat(3) @(posedge CLOCK_50);
        
        // Start game - press KEY[0]
        KEY[0] <= 0; @(posedge CLOCK_50);
        KEY[0] <= 1; repeat(5) @(posedge CLOCK_50);
        
        // Let bird fall
        repeat(20) @(posedge CLOCK_50);
        
        // Flap
        KEY[0] <= 0; @(posedge CLOCK_50);
        KEY[0] <= 1; repeat(10) @(posedge CLOCK_50);
        
        // Flap again
        KEY[0] <= 0; @(posedge CLOCK_50);
        KEY[0] <= 1; repeat(10) @(posedge CLOCK_50);
        
        // Test pause
        SW[0] <= 1; repeat(10) @(posedge CLOCK_50);
        SW[0] <= 0; repeat(10) @(posedge CLOCK_50);
        
        // Continue playing
        repeat(50) @(posedge CLOCK_50);
        
        // More flaps
        KEY[0] <= 0; @(posedge CLOCK_50);
        KEY[0] <= 1; repeat(10) @(posedge CLOCK_50);
        
        KEY[0] <= 0; @(posedge CLOCK_50);
        KEY[0] <= 1; repeat(10) @(posedge CLOCK_50);
        
        // Let game run
        repeat(100) @(posedge CLOCK_50);
        
        // Reset to IDLE - press KEY[3]
        KEY[3] <= 0; @(posedge CLOCK_50);
        KEY[3] <= 1; repeat(5) @(posedge CLOCK_50);
        
        // Start new game
        KEY[0] <= 0; @(posedge CLOCK_50);
        KEY[0] <= 1; repeat(20) @(posedge CLOCK_50);
        
        // Global reset
        SW[9] <= 1; repeat(2) @(posedge CLOCK_50);
        SW[9] <= 0; repeat(5) @(posedge CLOCK_50);
        
        $stop;
    end
endmodule