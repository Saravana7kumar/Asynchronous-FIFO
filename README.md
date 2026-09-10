# Asynchronous FIFO

A 16-deep, 8-bit wide FIFO for crossing between two independent clock domains, written in Verilog.

## Files

```
async_fifo.v       # RTL
async_fifo_tb.v    # testbench
```

## Design

- Separate `wclk` (write) and `rclk` (read) domains.
- Read and write pointers are converted to **Gray code** before crossing domains, since Gray code only ever changes one bit at a time — this avoids the multi-bit glitches a binary pointer would cause on a CDC path.
- Each side uses a standard 2-flop synchronizer to sample the other domain's Gray pointer.
- `full` (write domain) and `empty` (read domain) are derived by comparing the local Gray pointer against the synchronized remote Gray pointer, with the top bit(s) inverted for the full check to distinguish wrap-around from equality.

## Ports

| Signal   | Dir | Width | Description                     |
|----------|-----|-------|-----------------------------------|
| wclk     | in  | 1     | write clock                      |
| wrst_n   | in  | 1     | active-low async reset (write domain) |
| wr_en    | in  | 1     | write enable                     |
| din      | in  | 8     | write data                       |
| full     | out | 1     | full flag (write domain)         |
| rclk     | in  | 1     | read clock                       |
| rrst_n   | in  | 1     | active-low async reset (read domain) |
| rd_en    | in  | 1     | read enable                       |
| dout     | out | 8     | read data                         |
| empty    | out | 1     | empty flag (read domain)          |

## Testbench

Runs `wclk` and `rclk` at different frequencies (100MHz / ~71MHz). Bursts writes until `full`, waits for the synchronizers to settle, then bursts reads until `empty`. The settling delay between the write burst and read burst matters — skip it and the read side can briefly report `empty` when data is already in memory but hasn't propagated through the sync flops yet.

## Running the simulation

```bash
iverilog -o sim_async async_fifo.v async_fifo_tb.v
vvp sim_async
```

## Notes

`mem` will infer as distributed RAM on FPGA synthesis tools by default. For deeper FIFOs, retarget to block RAM (e.g. Xilinx `xpm_memory` primitives on Artix-7).
