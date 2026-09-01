# SPI Master-Slave Controller (Verilog)

A simple SPI (Serial Peripheral Interface) master and slave implementation in Verilog, with a top-level wrapper connecting them back-to-back for verification.

## Overview

This project implements:
- **spi_master** — drives the SPI clock, chip select, and MOSI line; shifts out an 8-bit parallel word serially, MSB first.
- **spi_slave** — receives serial data on MOSI, synchronized to spi_clk and spi_cs, and reconstructs the 8-bit word.
- **spi_top** — connects master and slave together for loopback testing.

## Features

- Configurable data width (default 8 bits) via DATA_WIDTH parameter
- Configurable clock divider (default 4) via CLK_DIV parameter
- Standard SPI Mode 0 style timing: MOSI changes on falling edge, sampled on rising edge
- Active-low chip select (CS)
- Simple valid/ready style handshake using data_valid

## Module: spi_master

### Ports

| Signal        | Direction | Width       | Description                          |
|---------------|-----------|-------------|---------------------------------------|
| clk           | input     | 1           | System clock (high frequency)         |
| rst_n         | input     | 1           | Active-low asynchronous reset         |
| parallel_data | input     | DATA_WIDTH  | Parallel data to transmit             |
| data_valid    | input     | 1           | Pulse high for 1 cycle to start a transfer |
| spi_clk       | output    | 1           | Generated SPI clock                   |
| spi_cs        | output    | 1           | Chip select, active low               |
| spi_mosi      | output    | 1           | Serial data out (Master Out Slave In) |

### FSM States

- IDLE  — waits for data_valid
- LOAD  — latches parallel_data, pulls CS low, preloads MSB, enables SPI clock
- SHIFT — shifts out remaining bits, one per falling edge of spi_clk
- DONE  — deasserts CS, disables SPI clock, returns to IDLE

## Module: spi_slave

### Ports

| Signal    | Direction | Width | Description                       |
|-----------|-----------|-------|------------------------------------|
| spi_clk   | input     | 1     | SPI clock from master              |
| spi_cs    | input     | 1     | Chip select, active low            |
| spi_mosi  | input     | 1     | Serial data in                     |
| rx_data   | output    | 8     | Received parallel data             |
| rx_valid  | output    | 1     | Pulses high when rx_data is valid  |

Samples spi_mosi on the rising edge of spi_clk while spi_cs is low. Resets bit counter whenever spi_cs goes high (idle).

## Module: spi_top

Top-level wrapper instantiating spi_master and spi_slave with MOSI, spi_clk, and spi_cs connected directly (loopback), for simulation and testing purposes.

## Simulation

A testbench (spi_top_tb) is included that:
1. Applies reset
2. Drives an 8-bit value into parallel_data with data_valid pulsed
3. Waits for rx_valid from the slave
4. Compares the received data against the transmitted data and prints PASS/FAIL

Run with any Verilog simulator (tested on Icarus Verilog / EDA Playground):

    iverilog -Wall -g2012 design.sv testbench.sv && unbuffer vvp a.out

## Timing Notes

- MOSI is updated on the falling edge of spi_clk and sampled by the slave on the rising edge, giving a full half-period of setup/hold margin (SPI Mode 0 convention).
- spi_clk frequency = clk frequency / (2 * CLK_DIV).
- A full 8-bit transfer takes approximately DATA_WIDTH * 2 * CLK_DIV clk cycles, plus one cycle each for LOAD and DONE.

## Possible Extensions

- Add MISO support for full-duplex (currently unidirectional, MOSI only)
- Support multiple slave select lines
- Add configurable SPI mode (CPOL/CPHA)

## License

MIT
