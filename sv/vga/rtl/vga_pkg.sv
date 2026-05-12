`timescale  1ns/1ps

package vga_pkg;

parameter int H_ACTIVE = 640;
parameter int H_FPORCH = 16;
parameter int H_SYNC = 96;
parameter int H_BPORCH = 48;
parameter int H_MAX = 800;

parameter int V_ACTIVE = 480;
parameter int V_FPORCH = 10;
parameter int V_SYNC = 2;
parameter int V_BPORCH = 33;
parameter int V_MAX = 526;


// There are two phases when HSYNC and VSYNC are high, with a phase in between, where they are low
// HIGH-LOW-HIGH
// The precise clock cycles for the detection are given below

// H_SYNC1_LO and V_SYNC1_LO is obviously 0

parameter int HSYNC1_END = H_ACTIVE + H_FPORCH - 1; // 655
parameter int VSYNC1_END = V_ACTIVE + V_FPORCH - 1; // 489

parameter int HSYNC2_START = HSYNC1_HI + H_SYNC;
parameter int VSYNC2_START = VSYNC1_HI + V_SYNC;

parameter int HSYNC2_END = H_MAX - 1;
parameter int VSYNC2_END = V_MAX - 1;





endpackage