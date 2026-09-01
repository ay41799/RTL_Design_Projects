# RTL Design Projects

A comprehensive collection of Verilog RTL (Register-Transfer Level) digital design projects. This repository includes complex blocks like a UART with FIFO, an SPI Master Controller, a Parameterized FIFO, and a Hierarchical Vedic Multiplier. All designs are fully designed, simulated, and verified.

## 🛠️ Tools & Technologies
* **Language:** Verilog HDL
* **Simulation & Synthesis:** Xilinx Vivado / ModelSim / EDA Playground
* **Verification:** Testbenches with various test cases

---

## 📂 Repository Structure & Projects

### 1. UART with FIFO (`/UART_with_FIFO`)
* **Description:** Universal Asynchronous Receiver-Transmitter integrated with FIFO buffers for reliable, asynchronous serial communication.
* **Features:** Parameterized baud rate generation, parity checking, and independent TX/RX FIFO queues to prevent data overrun.

### 2. SPI Master Controller (`/SPI_Master_Controller`)
* **Description:** A flexible Serial Peripheral Interface master core to communicate with external peripheral sensors or memory.
* **Features:** Supports multiple SPI modes (CPOL/CPHA configuration) and variable clock division.

### 3. Parameterized FIFO (`/Parameterized_FIFO`)
* **Description:** A generic First-In-First-Out memory buffer used for clock domain crossing or data buffering.
* **Features:** Configurable data width and depth parameters with standard `full`, `empty`, `almost_full`, and `almost_empty` status flags.

### 4. Hierarchical Vedic Multiplier (`/Hierarchical_Vedic_Multiplier`)
* **Description:** High-speed multiplier architecture based on ancient Indian Vedic Mathematics (*Urdhva-Tiryagbhyam* sutra).
* **Features:** Hierarchical modular design (e.g., 8x8 built using 4x4 blocks) optimizing propagation delay compared to conventional multipliers.

### 5. ALU with Flags (`/ALU_with_Flags`)
* **Description:** An Arithmetic Logic Unit that executes fundamental math and bitwise operations.
* **Features:** Generates status flags such as Zero (Z), Carry (C), Sign (S), and Overflow (O) for control unit branching.

---

## 🚀 How to Run and Simulate

### Prerequisites
* Xilinx Vivado (or any standard Verilog simulator like Icarus Verilog/ModelSim).

### Steps
1. Clone the repository:
   ```bash
   git clone https://github.com
   ```
2. Open your preferred simulation IDE.
3. Import the `.v` source files and corresponding testbench files (`_tb.v`) from the specific project folder.
4. Run the simulation to view the behavioral waveforms.

---

## 📈 Future Scope
* Adding SystemVerilog or UVM testbenches for advanced verification.
* Implementing AXI-Lite interface wrappers for SoC integration.
*
