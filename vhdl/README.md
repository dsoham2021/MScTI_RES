# Notes on developing the VGA controller

- We generate a 640 x 480 @ 60 Hz using a 25 MHz pixel clock, FPGA sends pixels continuously from left to right, top to bottom
- Horizontal Timing (Pixels):
  - Active Video: 640
  - Front Porch: 16 
  - Sync Pulse: 96
  - Back Porch: 48
  - Total Horizontal Pixels: 800 (from 0 to 799)
- Vertical Timing (Lines):
  - Active Video: 480
  - Front Porch: 10
  - Sync Pulse: 2
  - Back Porch: 33
  - Total Vertical Lines: 525 (from 0 to 524)
- The Basys 3 clock is 100 MHz, but VGA 640x480 requires a 25 MHz pixel clock. It is not recommended to use a simple clock divider (like a counter or T-flip-flops) to generate this because of clock skew. If we route a flip-flop's output to the clock pins of other components, the signal travels through standard logic routing rather than the FPGA's dedicated, high-speed clock trees. This causes timing violations where different parts of the chip receive the clock at slightly different times. The solution is to use a clock enable signal instead of creating a new physical clock, where we keep everything running safely at 100 MHz. We create a counter that ticks from 0 to 3. Every time it hits 0, we pulse a clock_enable signal high for exactly one 100 MHz cycle. We then use this enable signal to tell our VGA logic to only update once every 4 clock cycles ($100 \text{ MHz} / 4 = 25 \text{ MHz}$).