# FPGA-Based UART Controller with Dual FIFO and Flow Control

**Verilog HDL | Xilinx Vivado | Basys 3 (Artix-7 FPGA)**

## Overview

This project presents the design, simulation, and FPGA implementation of a UART (Universal Asynchronous Receiver-Transmitter) controller with dual synchronous FIFO buffering and flow control.

The system operates at **9600 baud** using a **100 MHz system clock** and employs **16× oversampling** for UART reception. Separate 8-byte TX and RX FIFOs enable buffered communication, while flow-control logic pauses transmission when the RX FIFO is full.

The design was implemented and tested on the **Digilent Basys 3 FPGA development board (Artix-7 XC7A35T-1CPG236C)** using Xilinx Vivado.

## Key Features

- UART transmitter and receiver designed using finite state machines (FSMs).
- 9600 baud communication with 8 data bits, no parity, and 1 stop bit (8N1).
- 16× oversampling for UART reception.
- Dual 8×8 synchronous FIFO buffers for transmission and reception.
- FIFO full/empty status detection.
- Flow control to pause transmission when the RX FIFO is full.
- TX write-rejection and RX overflow detection.
- Internal UART TX-to-RX loopback for FPGA testing.
- Push-button-controlled FIFO write/read operations.
- LED-based data and status monitoring.

## System Architecture

```text
              100 MHz System Clock
                       |
                Baud-Rate Generator
                       |
              TX / RX Timing Enables

   SW[7:0] (Input Data)
            |
            v
      +-------------+
      |   TX FIFO   |
      |    8 x 8    |
      +-------------+
            |
            v
      +-------------+
      | UART TX FSM |
      +-------------+
            |
            | Serial Data (9600 baud)
            v
      +-------------+
      | UART RX FSM |
      | 16x Sampling|
      +-------------+
            |
            v
      +-------------+
      |   RX FIFO   |
      |    8 x 8    |
      +-------------+
            |
            v
       LD[7:0] Output

Flow Control:
RX FIFO Full ---> Pause TX FIFO Fetch

Error Indicators:
TX Write Rejected ---> LD14
RX Overflow -------> LD12
```

## Design Modules

| Module | Description |
|---|---|
| `baud_rate_generator` | Generates UART TX timing and 16× RX sampling enables |
| `transmitter` | FSM-based UART serial transmitter |
| `reciever` | FSM-based UART receiver with 16× oversampling |
| `fifo_sync` | Parameterized synchronous FIFO with full/empty detection |
| `top_module` | Integrates UART, FIFOs, internal loopback, and flow control |
| `button_onepulse` | Synchronizes and debounces push-button inputs |
| `uart_fifo_basys3_top` | FPGA top module connecting switches, buttons, and LEDs |

## Design Specifications

| Parameter | Value |
|---|---|
| FPGA Board | Digilent Basys 3 |
| FPGA Device | XC7A35T-1CPG236C |
| System Clock | 100 MHz |
| UART Baud Rate | 9600 |
| Frame Format | 8N1 |
| RX Oversampling | 16× |
| TX FIFO Depth | 8 bytes |
| RX FIFO Depth | 8 bytes |
| FIFO Data Width | 8 bits |
| RTL Language | Verilog HDL |
| Development Tool | Xilinx Vivado 2018.3 |

## FPGA Hardware Interface

### Input Controls

| Input | Function |
|---|---|
| SW0–SW7 | 8-bit parallel input data |
| BTNU | Write input byte into TX FIFO |
| BTNR | Read next byte from RX FIFO |
| BTNC | System reset |

### LED Indicators

| LED | Function |
|---|---|
| LD0–LD7 | Last byte read from RX FIFO |
| LD8 | UART transmitter busy |
| LD9 | TX FIFO full |
| LD10 | RX FIFO empty |
| LD11 | RX FIFO full |
| LD12 | RX overflow indicator |
| LD13 | TX FIFO nonempty |
| LD14 | TX write-rejection indicator |

## Flow Control and Error Detection

The design uses FIFO-status-based flow control to prevent continuous UART transmission when the receive buffer is full.

When the RX FIFO becomes full, the TX controller pauses fetching additional bytes. Incoming user data can continue to be buffered in the TX FIFO until that FIFO also becomes full.

Reading a byte from the RX FIFO frees space, allowing the transmitter to resume.

Two sticky error indicators are provided:

- **RX Overflow (LD12):** Indicates that a received byte could not be stored because the RX FIFO was full.
- **TX Write Rejected (LD14):** Indicates that an input write was attempted while the TX FIFO was full.

Both indicators remain asserted until reset.

Flow control protects the receive path during normal operation, while rejected-write detection identifies input data that could not be accepted.

## Functional Verification

The UART system was verified using Verilog testbenches and waveform analysis in Xilinx Vivado.

Verification included:

- UART start-bit, data-bit, and stop-bit transmission.
- Multiple-byte serial loopback.
- Correct reconstruction of transmitted data.
- FIFO read/write operations.
- FIFO full/empty status behavior.
- FPGA hardware testing using switches, push buttons, and LEDs.

### Example Test Data

| Transmitted (Hex) | Received (Hex) |
|---|---|
| 0x55 | 0x55 |
| 0xA5 | 0xA5 |
| 0x3C | 0x3C |
| 0xF0 | 0xF0 |
| 0x0F | 0x0F |

The recorded self-checking UART simulation reported **13 checked serial frames with zero errors**.

## FPGA Implementation Results

**Target FPGA:** Artix-7 XC7A35T-1CPG236C

| Metric | Result |
|---|---:|
| Slice LUTs | 175 |
| Slice Registers | 283 |
| Occupied Slices | 94 |
| Bonded IOBs | 25 |
| BUFGCTRL | 1 |
| Timing-Closed Clock Constraint | 3.40 ns |
| Equivalent Constraint Frequency | 294.12 MHz |
| Setup WNS at 3.40 ns | +0.260 ns |
| Hold WHS at 3.40 ns | +0.159 ns |
| Setup Failing Endpoints | 0 |
| Estimated On-Chip Power | 0.077 W |

**Timing note:** The design achieved timing closure under a 3.40 ns clock constraint, corresponding to approximately 294 MHz. This is an implementation timing result, not a measured hardware operating frequency or a guaranteed Fmax. Actual Basys 3 testing used the onboard 100 MHz clock.

**Power note:** The 77 mW figure is a low-confidence Vivado estimate based on the available switching-activity assumptions, not a physical power measurement.

## Repository Structure

```text
FPGA-UART-Dual-FIFO-Flow-Control/
|
|-- RTL/
|   |-- uart_with_fifo.v
|
|-- Testbench/
|   |-- uart_with_fifo_tb.v
|
|-- Constraints/
|   |-- uart_with_fifo.xdc
|
|-- Results/
|   |-- simulation_waveform.png
|   |-- timing_report.png
|   |-- utilization_report.png
|   |-- power_report.png
|
|-- README.md
```

*Update filenames and paths to match the actual files in the repository.*

## How to Run

1. Open Xilinx Vivado and create a new RTL project.
2. Select the FPGA device `xc7a35tcpg236-1`.
3. Add the Verilog RTL design file.
4. Add the testbench under Simulation Sources.
5. Set the appropriate testbench as the simulation top.
6. Run Behavioral Simulation and inspect the UART/FIFO signals.
7. Add the Basys 3 XDC constraints.
8. Run Synthesis, Implementation, and Generate Bitstream.
9. Open Hardware Manager and program the Basys 3 FPGA.
10. Use switches and push buttons to demonstrate UART communication and FIFO operation.

## Learning Outcomes

This project provided practical experience with:

- RTL design using Verilog HDL.
- FSM-based communication controllers.
- UART timing and serial data framing.
- Synchronous FIFO architecture.
- Buffered data transfer and backpressure.
- FIFO overflow and write-rejection handling.
- Functional simulation and waveform debugging.
- FPGA implementation, resource utilization, and static timing analysis.

## Future Improvements

- External UART communication through FPGA I/O pins.
- Configurable baud rate and FIFO depth.
- UART parity and framing-error detection.
- Expanded self-checking verification for FIFO boundary and backpressure conditions.
- More accurate power estimation using simulation switching activity.

---

**Project Domain:** FPGA Design | RTL Design | Digital VLSI | Communication Protocols
