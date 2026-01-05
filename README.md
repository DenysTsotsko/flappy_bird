# Flappy Bird on FPGA

A hardware implementation of the classic Flappy Bird game on the DE1-SoC FPGA board with a 16x16 LED matrix display.

[Demo video][https://youtube.com/shorts/UjuSr8K63nM?si=VKpkaa4KB-fdJ2nt]

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Hardware Requirements](#hardware-requirements)
- [System Architecture](#system-architecture)
- [Module Descriptions](#module-descriptions)
- [Getting Started](#getting-started)
- [Controls](#controls)
- [Game Rules](#game-rules)
- [Implementation Details](#implementation-details)
- [Testing](#testing)
- [Project Structure](#project-structure)
- [Future Improvements](#future-improvements)
- [License](#license)
- [Acknowledgments](#acknowledgments)

## 🎮 Overview

This project implements a fully functional Flappy Bird game in SystemVerilog for the Altera DE1-SoC FPGA board. The game features physics-based bird movement, procedurally generated obstacles, collision detection, score tracking, and visual feedback on a 16x16 dual-color LED matrix.

The implementation demonstrates key digital design concepts including:
- Finite State Machines (FSM)
- Sequential and combinational logic
- Hardware timing and synchronization
- Pseudo-random number generation (LFSR)
- Modular hardware design

## ✨ Features

- **Physics Engine**: Gravity simulation and flap mechanics
- **Procedural Generation**: Random pipe gap positions using LFSR
- **Collision Detection**: Real-time hit detection with pipes
- **Score System**: Tracks successful pipe passages
- **Game States**: IDLE, PLAY, PAUSE, and GAME_OVER modes
- **Visual Feedback**: 
  - Red LED for bird
  - Green LEDs for pipes
  - Blinking effect on game over
- **Seven-Segment Display**: Real-time score display (up to 999)
- **Pause Functionality**: Game can be paused and resumed

## 🔧 Hardware Requirements

- **FPGA Board**: Altera DE1-SoC (Cyclone V)
- **LED Matrix**: 16x16 dual-color (Red/Green) LED display board
- **Connection**: GPIO_1 header (36-pin)
- **Clock**: 50 MHz system clock

### Pin Configuration

- **KEY[0]**: Flap button (active low, inverted in top module)
- **KEY[3]**: Reset to IDLE (active low, inverted in top module)
- **SW[0]**: Pause switch
- **SW[9]**: Global reset
- **HEX0-HEX2**: Seven-segment displays for score
- **GPIO_1**: LED matrix interface

## 🏗️ System Architecture

![Module Diagram](module_diagram.png)
*System architecture and module interconnections*

The system follows a modular architecture with clear separation of concerns:

```
DE1_SoC (Top Level)
├── clock_divider
├── LEDDriver
└── flappy_bird (Game Logic)
    ├── userInput (x2) - Button debouncing
    ├── gameControl - FSM controller
    ├── bird - Vertical physics
    ├── pipe - Horizontal movement & LFSR
    ├── collision - Hit detection
    ├── scoreCounter - Score tracking
    ├── seg7 (x3) - Display decoders
    └── display - LED matrix renderer
```

## 📦 Module Descriptions

### Core Game Modules

#### `flappy_bird.sv`
Main game integration module that connects all subsystems and manages game flow.

#### `gameControl.sv`
Finite State Machine controlling game states:
- **IDLE**: Waiting to start
- **PLAY**: Active gameplay
- **PAUSE**: Game paused
- **GAME_OVER**: Collision detected

#### `bird.sv`
Manages bird vertical position with:
- Gravity mechanics (falls every 150 clock cycles)
- Flap input (moves up by 2 units)
- Boundary constraints (0-15)

#### `pipe.sv`
Handles pipe movement and gap generation:
- Horizontal scrolling (moves every 200 cycles)
- Internal LFSR for random gap positioning
- Wraps around at screen edge with new random gap

#### `collision.sv`
Detects collisions between bird and pipes:
- Checks if bird is at pipe X position
- Determines if bird is within gap (4 units)
- Outputs collision signal and in-gap status

#### `display.sv`
Renders game state to LED matrix:
- Red pixel for bird
- Green column for pipes (with gap)
- Handles game-over blink effect

### Supporting Modules

#### `LFSR.sv`
16-bit Linear Feedback Shift Register for pseudo-random number generation using XOR feedback taps.

#### `scoreCounter.sv`
Tracks player score with edge detection to prevent multiple increments.

#### `seg7.sv`
Seven-segment display decoder for score digits.

#### `userInput.sv`
Button debouncing and edge detection (implementation not shown but used for KEY inputs).

#### `clock_divider.sv`
Generates divided clock signals from 50 MHz system clock.

#### `LEDDriver.sv`
Low-level driver for 16x16 LED matrix scanning and control.

## 🚀 Getting Started

### Prerequisites

- Intel Quartus Prime (tested with version compatible with Cyclone V)
- ModelSim or Quartus built-in simulator for testbenches
- DE1-SoC board with LED matrix expansion

### Building the Project

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/flappy-bird-fpga.git
   cd flappy-bird-fpga
   ```

2. **Open in Quartus**
   - Create new project or open existing `.qpf` file
   - Add all `.sv` files to project
   - Set `DE1_SoC.sv` as top-level entity

3. **Configure Clock Settings**
   - Import `DE1_SoC_golden_top.sdc` for timing constraints
   - Verify clock constraints match your board

4. **Pin Assignment**
   - Assign pins according to DE1-SoC pinout
   - Verify GPIO_1 connections for LED matrix

5. **Compile**
   - Run Analysis & Synthesis
   - Run Fitter
   - Run Assembler
   - Generate programming file (`.sof`)

6. **Program FPGA**
   - Connect DE1-SoC via USB-Blaster
   - Use Quartus Programmer to load `.sof` file

### Simulation vs Hardware

In `DE1_SoC.sv`, select clock source:
```systemverilog
// For simulation (fast)
assign clkSelect = CLOCK_50;

// For hardware (actual gameplay speed ~763Hz)
assign clkSelect = div_clk[whichClock];
```

## 🎯 Controls

| Input | Function |
|-------|----------|
| **KEY[0]** | Flap (move bird up) / Start game |
| **KEY[3]** | Reset game to IDLE state |
| **SW[0]** | Toggle pause |
| **SW[9]** | Global hardware reset |

## 📏 Game Rules

1. **Objective**: Navigate the bird through gaps in pipes without colliding
2. **Scoring**: +1 point for each pipe successfully passed
3. **Bird Position**: Fixed at X=12, moves vertically (Y: 0-15)
4. **Pipe Gap**: 4 units tall, randomly positioned
5. **Game Over**: Bird hits pipe or boundaries
6. **Physics**:
   - Gravity: Bird falls 1 unit every 150 clock ticks
   - Flap: Bird rises 2 units instantly

## 🔍 Implementation Details

### Clock Frequency
- **System Clock**: 50 MHz
- **Game Clock**: ~763 Hz (50MHz / 2^15)
- **LED Refresh**: ~1.5 kHz (50MHz / 2^15 with FREQDIV=0)

### Timing Parameters
```systemverilog
GRAVITY_RATE = 150;  // Ticks between gravity steps
MOVE_RATE = 200;     // Ticks between pipe movements
GAP_SIZE = 4;        // Height of pipe gap
BIRD_X = 12;         // Fixed bird X position
```

### LFSR Configuration
- **Seed**: 0xACE1
- **Taps**: Positions 16, 14, 13, 11
- **Output**: Maps to gap Y-position (0-11 after modulo 12)

### State Encoding
```systemverilog
IDLE      = 2'b00
PLAY      = 2'b01
PAUSE     = 2'b10
GAME_OVER = 2'b11
```

## 🧪 Testing

Each module includes a comprehensive testbench. (email me if you need)
To run simulations:

1. **Open ModelSim**
2. **Compile all `.sv` files**
3. **Run individual testbenches**:
   ```tcl
   vsim bird_testbench
   vsim pipe_testbench
   vsim collision_testbench
   vsim gameControl_testbench
   vsim flappy_bird_testbench
   ```

### Testbench Coverage

- **bird_testbench**: Tests gravity, flapping, and boundaries
- **pipe_testbench**: Verifies movement and gap randomization
- **collision_testbench**: Validates hit detection logic
- **gameControl_testbench**: FSM state transitions
- **flappy_bird_testbench**: Integration testing
- **DE1_SoC_testbench**: Full system simulation

## 📁 Project Structure

```
flappy-bird-fpga/
├── DE1_SoC.sv                 # Top-level module
├── flappy_bird.sv             # Main game module
├── gameControl.sv             # FSM controller
├── bird.sv                    # Bird physics
├── pipe.sv                    # Pipe generator
├── collision.sv               # Collision detector
├── display.sv                 # LED renderer
├── scoreCounter.sv            # Score tracking
├── LFSR.sv                    # Random number generator
├── seg7.sv                    # 7-segment decoder
├── clock_divider.sv           # Clock generation
├── LEDDriver.sv               # LED matrix driver
├── DE1_SoC_golden_top.sdc     # Timing constraints
├── LED_test.sv                # LED test patterns
└── README.md                  # This file
```

## 🚧 Future Improvements

- [ ] Variable difficulty (increasing speed)
- [ ] High score persistence
- [ ] Sound effects via audio codec
- [ ] Multiple pipe columns
- [ ] Power-ups and special items
- [ ] VGA display output option
- [ ] Configurable game parameters via switches
- [ ] Smoother physics with fixed-point arithmetic
---


## 📧 Contact

For questions or contributions, please open an issue on GitHub or contact [your-email@example.com]

**Project Link**: [https://github.com/yourusername/flappy-bird-fpga](https://github.com/yourusername/flappy-bird-fpga)
