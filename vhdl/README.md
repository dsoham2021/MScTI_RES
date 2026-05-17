## 1. How can we cascade multiple BRAM blocks to form larger memories?

We use address decoding. To combine smaller blocks (like 18Kb or 36Kb) into a larger memory, we can connect the lower bits of our address bus to all the BRAM blocks simultaneously. We can then use the Most Significant Bit(s) (MSB) of our address to do something like this:

1. Drive a multiplexer (MUX) to select which BRAM's output data is sent to the rest of the circuit.
2. Control the Write Enable (WE) pins so that when we want to store a pixel, we only write it to the specific, active BRAM block, leaving the others untouched.

---

## 2. Why is it not recommended to use a simple clock divider to generate the pixel clock?

This is because it leads to clock skew in the final hardware. If we use a standard counter or T-flip-flop to generate a clock, the output signal is routed through the FPGA's standard, general-purpose logic matrix, such that the signal will arrive at different flip-flops at slightly different nanosecond intervals, causing severe timing violations.
Real clock signals must be therefore routed through dedicated, low-latency clock trees which are etched into the silicon. We should thus try to use a dedicated hardware clock manager (like a PLL or MMCM) to generate new frequencies, or use something like a clock enable tick on the main system clock like the `pxl_tick` we used in our own design.

---

## 3. You can use BRAMs to implement FIFOs. How would that work?

A FIFO buffer can be made using a BRAM configured in true dual-port mode, managed by two independent counters: a write pointer and a read pointer like this:
* When data arrives, it is written to the address of the WP, and the WP increments by 1.
* When the system needs data, it reads from the address of the RP, and the RP increments by 1.
* Logic circuits would then constantly compare the two pointers to generate "FIFO Empty" (this happens when the two pointers point to the same area) and "FIFO Full" flags.

---

## 4. What could go wrong if we implement this with different clocks for read and write?

We would have many problems because of clock domain crossing (CDC), leading to metastability. If the write operations happen at 100 MHz and the read operations happen at let's say 25 MHz, the two pointers are updating entirely out of sync. If the 25 MHz domain tries to then check the "Full/Empty" status exactly as the 100 MHz domain is incrementing the pointer, the flip-flops can get stuck between a 0 and a 1, which would lead to corrupting the data or locking up the FIFO completely. To solve such problems, we can use gray code counters and multi-stage synchronizers to safely pass pointer values between different clock domains.

---

## 5. Propose at least two schemes that allow us to save on-FPGA memory.

On the Artix-7, the BRAM only has a capacity of around 1800 Kbits (225 KB). Different possible approaches:
* We can store only a smaller image (in our case we use a 256x256 fractal) in the BRAM and mathematically force the rest of the 640x480 screen to just output pure black.
* Instead of using 12 bits per pixel, we can use 8 bits per pixel (for e.g., 3 Red, 3 Green, 2 Blue). This would reduce the width of the memory arrays required.
* We can also store a tiny 320x240 image in BRAM. During VGA output, we hold the exact same memory address for two horizontal pixel ticks and two vertical lines. This means that the image scales up to 640x480 on the monitor while using exactly one-quarter of the BRAM.
It is also possible to combine these approaches.

---

### Notes while developing the VGA controller

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
