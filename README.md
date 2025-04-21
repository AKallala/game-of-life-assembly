# Conway's Game of Life – MIPS Assembly for FPGA

This standalone assembly file implements **Conway's Game of Life**, a cellular automaton simulation written in **MIPS assembly**, designed to run on an **FPGA device** with a LED matrix display and button inputs.

## 🧠 Overview

Conway's Game of Life is a zero-player game where each cell in a 2D grid is either **alive** or **dead**, and the state of the grid evolves over time based on a simple set of rules:

- A **live** cell with fewer than 2 or more than 3 neighbors dies.
- A **dead** cell with exactly 3 neighbors becomes alive.
- A **live** cell with 2 or 3 neighbors survives.

## ⚙️ Platform Details

- **ISA**: MIPS (Microprocessor without Interlocked Pipeline Stages)
- **Target Hardware**: FPGA-based system with:
  - LED matrix for display
  - Buttons for input
  - Memory-mapped I/O for controlling state and rendering

## 🔑 Features

- **Double Buffering**: 
  - Uses two grid buffers (`GSA0` and `GSA1`) for smooth state transitions.

- **Predefined Seeds**: 
  - Built-in patterns like `seed0`, `seed1`, etc., to initialize the simulation.

- **Game Logic**:
  - The `cell_fate` function computes each cell's next state using Conway's rules.

- **Input Handling**:
  - The `get_input` routine reads button states to:
    - Pause/resume the game
    - Change speed
    - Cycle through seeds
    - Reset the simulation

- **Display**:
  - `draw_gsa` updates the LED matrix to reflect the current grid state.

- **Randomization and Masking**:
  - Supports randomized grid generation
  - Masking to constrain active grid areas

## 🎮 Controls

| Button          | Function                        |
|-----------------|----------------------------------|
| Pause / Resume  | Toggle game execution            |
| Speed Control   | Cycle through available speeds   |
| Next Seed       | Load next predefined pattern     |
| Reset           | Restart simulation               |

---

Feel free to use, modify, or integrate it into your own MIPS-on-FPGA projects!
