# UART Communication System with FIFO Buffering

A Verilog implementation of a full-duplex UART (Universal Asynchronous Receiver-Transmitter) with FIFO buffering on both transmit and receive paths, verified through simulation and waveform analysis in Xilinx Vivado.

## Overview

This project implements a UART communication system designed to reliably transmit and receive serial data while decoupling the system's data rate from the UART's fixed baud rate using FIFO buffers. It follows the standard UART frame format and uses 16x oversampling on the receive side for reliable bit sampling.

## Architecture

The design consists of five main blocks:

| Block | Function |
|---|---|
| **Baud-Rate Generator** | Counter-based module that derives the TX timing enable and 16x RX sampling enable from the system clock |
| **UART Transmitter** | Serializes parallel data into a UART frame (start bit, 8 data bits LSB-first, stop bit) |
| **UART Receiver** | Detects the start bit and samples incoming serial data at 16x oversampling to reconstruct the received byte |
| **TX FIFO** | Buffers outgoing parallel data before serial transmission |
| **RX FIFO** | Buffers received parallel data for the system to read at its own pace |

### Transmit Path
Parallel data is written into the TX FIFO. When the FIFO is not empty and the transmitter is idle, the next byte is popped from the FIFO and transmitted serially: 1 start bit → 8 data bits (LSB first) → 1 stop bit.

### Receive Path
The receiver continuously monitors the serial line for a start bit. Once detected, it samples the line at 16x the baud rate to capture each bit near the center of its bit period, improving noise/jitter tolerance. After the 8 data bits and stop bit are received, the byte is reconstructed and pushed into the RX FIFO for the system to read.

## Timing Parameters

- **System Clock:** 50 MHz
- **Baud Rate:** 9600
- **RX Oversampling:** 16x (for center-of-bit sampling)

## Control Signals

- FIFO Empty / Full flags (TX and RX)
- FIFO Read / Write enables
- Transmitter Busy
- Receiver Ready

## Verification

The design was functionally verified using a self-checking Verilog testbench. Simulation waveforms were analyzed in Vivado to confirm:
- Correct UART frame transmission and reception
- Correct FIFO push/pop behavior and flag generation
- Correct baud-rate and oversampling timing

## Tools Used

- **HDL:** Verilog
- **Simulation / Synthesis:** Xilinx Vivado
## How to Run

1. Open Vivado and create a new project targeting your FPGA part of choice.
2. Add all files under `/rtl` as design sources.
3. Add `uart_tb.v` under Simulation Sources.
4. Set `uart_tb` as the simulation top.
5. Run Behavioral Simulation and inspect the waveform viewer to observe transmission, reception, and FIFO status signals.

## Notes

This project focuses on RTL design and functional verification. Baud rate and clock parameters can be adjusted by modifying the baud-rate generator's counter constants for other target frequencies/baud rates.
