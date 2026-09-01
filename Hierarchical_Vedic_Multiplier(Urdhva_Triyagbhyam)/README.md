# Vedic Multiplier (Urdhva Tiryagbhyam) — 8/16-bit Hierarchical Design

## Overview
A high-speed, area-efficient multiplier based on the ancient Vedic mathematics 
sutra "Urdhva Tiryagbhyam" (vertically and crosswise). Implemented as a 
hierarchical 8-bit and 16-bit design in Verilog, synthesized on Xilinx 
Vivado (Artix-7 FPGA).

## Key Results(16-bits)
| Metric               | Vedic Multiplier  | Array Multiplier | Improvement   |
|----------------------|-------------------|------------------|---------------|
| LUT Utilization      | 341               | 541              | 37% reduction |
| Critical Path Delay  | 12.481 ns         | 26.416 ns        | 53% improvement |

## Algorithm
Brief explanation of Urdhva Tiryagbhyam — vertical/crosswise partial product 
generation, how the 4x4 blocks compose into 8x8, and 8x8 blocks compose into 16x16.

## Architecture
- Hierarchical build-up: 2-bit → 4-bit → 8-bit → 16-bit


## Tools & Flow
- Verilog RTL
- Xilinx Vivado (synthesis + implementation)
- Target: Artix-7


## Future Work
(optional — e.g., ASIC flow, power analysis)
