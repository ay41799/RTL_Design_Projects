# Synchronous FIFO (Verilog)

A parameterizable synchronous FIFO with pointer-based full/empty detection.

## Module: fifo_sync

**Parameters:** `FIFO_DEPTH` (default 8), `DATA_WIDTH` (default 32)

**Ports:** clk, rst_n (active-low), cs, wr_en, rd_en, data_in, data_out, empty, full

## Design Notes

- Extra MSB on read/write pointers distinguishes full from empty (no separate counter needed)
- `empty` = pointers fully match; `full` = pointers match on lower bits, differ on MSB
- Write gated by `cs && wr_en && !full`; read gated by `cs && rd_en && !empty`
- `FIFO_DEPTH` should be a power of 2

## Simulation

Testbench `tb_fifo_sync` covers: basic write/read, interleaved write/read across full depth, and fill-to-overflow + full drain.

**In Vivado:**
1. Add `fifo_sync.v` to Design Sources, `tb_fifo_sync.v` to Simulation Sources
2. Set `tb_fifo_sync` as simulation top
3. Run Behavioral Simulation, check log for write/read prints

## Extensions

- Almost-full / almost-empty flags
- Asynchronous FIFO variant
- Overflow/underflow error flags

## License

MIT
