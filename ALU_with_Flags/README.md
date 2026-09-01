# 32-bit ALU (Arithmetic Logic Unit) — Verilog Design

A parametrized 32-bit ALU implemented in Verilog/SystemVerilog, supporting arithmetic and logic operations selected via a 2-bit control signal, with standard status flags (Zero, Negative, Overflow, Carry).

## Overview

This ALU takes two 32-bit operands and performs one of four operations based on `ALUControl`, producing a 32-bit result along with condition flags commonly used in processor datapaths.

## Operations

| ALUControl | Operation |
|---|---|
| `00` | Addition (A + B) |
| `01` | Subtraction (A + ~B + 1, via inverted B and carry-in) |
| `10` | Bitwise AND (A & B) |
| `11` | Bitwise OR (A | B) |

## Architecture

- **AND / OR / NOT paths:** `a_and_b`, `a_or_b`, and `not_b` are computed combinationally in parallel with the arithmetic path.
- **Adder/Subtractor:** A single adder computes `A + mux_1 + ALUControl[0]`, where `mux_1` selects between `B` (for addition) and `~B` (for subtraction), with the control bit feeding the carry-in — a standard add/subtract-by-XOR-and-carry-in technique.
- **Result Mux:** Selects between the adder/subtractor output and the logic (AND/OR) outputs based on `ALUControl`.

## Status Flags

- **Z (Zero):** Set when `Result == 0`
- **N (Negative):** Set from the MSB of `Result` (sign bit)
- **V (Overflow):** Set on signed overflow during add/subtract, derived from operand and result sign bits
- **C (Carry):** Set from the adder's carry-out, valid only for add/subtract operations (masked off for logic operations)

## Ports

**Inputs:** `A[31:0]`, `B[31:0]`, `ALUControl[1:0]`
**Outputs:** `Result[31:0]`, `Z`, `N`, `V`, `C`

## Verification

Verified using a Verilog testbench that applies operand/control combinations and checks `Result` and flag outputs via `$monitor`, simulated on EDA Playground (Icarus Verilog).

## Tools Used

- **HDL:** Verilog / SystemVerilog
- **Simulation:** Icarus Verilog (via EDA Playground)

## Repository Structure
