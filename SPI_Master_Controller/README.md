# SPI Master-Slave Controller (Verilog)

A lightweight SPI master and slave in Verilog, with a top-level loopback wrapper for verification.

## Modules

- **spi_master** — Shifts out an 8-bit parallel word serially (MSB first), generates spi_clk and active-low CS.
- **spi_slave** — Samples MOSI on rising spi_clk edges, reconstructs the 8-bit word, flags rx_valid.
- **spi_top** — Connects master and slave for loopback testing.

## Parameters

- `DATA_WIDTH` (default 8) — word size
- `CLK_DIV` (default 4) — SPI clock divider from system clk

## Master FSM

IDLE → LOAD → SHIFT → DONE → IDLE

- IDLE: wait for `data_valid`
- LOAD: latch data, CS low, preload MSB
- SHIFT: shift 1 bit per falling edge of spi_clk
- DONE: CS high, clear state, return to IDLE

## Timing

- MOSI changes on falling edge, sampled on rising edge (SPI Mode 0 style)
- spi_clk freq = clk freq / (2 × CLK_DIV)

## Simulation

Testbench `spi_top_tb` drives 8-bit data through the master, waits for `rx_valid` from the slave, and checks it matches.

**In Vivado:**
1. Create a new project (or add sources to an existing one)
2. Add `design.sv` (or your RTL file) under Design Sources
3. Add `spi_top_tb.sv` under Simulation Sources
4. Set `spi_top_tb` as the top module for simulation
5. Run **Flow Navigator → Simulation → Run Behavioral Simulation**
6. Check the Tcl console / simulation log for the PASS/FAIL message

## Extensions

- Add MISO for full-duplex
- Multiple slave selects
- Configurable CPOL/CPHA

## License

MIT
