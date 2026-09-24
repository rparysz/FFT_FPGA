# Audio Spectrum Analyzer — 1024-point FFT on FPGA (Zynq-7000 / Zedboard)

A hand-written radix-2 FFT core in VHDL, synthesized and run on a Digilent
Zedboard (Xilinx Zynq-7000). It captures live audio from the board's onboard
codec over I²S, computes a 1024-point FFT, and renders the magnitude spectrum
on a VGA display.

This repository holds the **custom RTL** — the FFT datapath and its control.
It was one block in a larger Vivado block design; the surrounding system
(clocking, I²S capture, VGA timing) was assembled from vendor IP. That full
Vivado project is no longer archived, so this repo is the FFT core itself, not
a one-click buildable project.

## Signal path

    audio codec ──I²S──▶ 1024-sample FIFO ──▶ FFT core ──▶ fft_mag ──▶ VGA
                                                  │
                            COMPLEX_RAM ⇄ BFU (× twiddle)   ×10 stages
                                   ▲ AGU: bit-reversal + per-stage addressing

Audio samples stream in from the codec over I²S and fill a 1024-deep FIFO; once
full, the FFT runs over the captured block, magnitudes are computed, and the
spectrum is drawn to screen.

## Architecture

Iterative, in-place radix-2 decimation-in-time. A single pipelined butterfly is
reused across all log₂(1024) = 10 stages, rather than unrolling one butterfly
per stage:

- **AGU** — address generation: input bit-reversal, per-stage even/odd operand
  addressing, span/stage sequencing.
- **BFU** — pipelined radix-2 butterfly (complex multiply-add against a twiddle).
- **twiddle_rom** — precomputed cos / −sin table (Q1.15).
- **COMPLEX_RAM** — dual-bank ("ping-pong") complex sample memory.
- **fft_mag → fft_out_ram → vga_input_controller** — magnitude + spectrum display.

## Specs

| | |
|---|---|
| Application | Live audio spectrum analyzer |
| Input | Onboard audio codec over I²S → 1024-sample FIFO |
| Transform | 1024-point complex FFT |
| Algorithm | Radix-2, decimation-in-time, in-place iterative |
| Datapath | 29-bit internal fixed-point (24-bit source samples, widened for headroom); 16-bit (Q1.15) twiddles |
| Butterfly | Single pipelined BFU reused across 10 stages |
| Memory | Dual-bank complex BRAM |
| Output | Magnitude spectrum on VGA |
| Target | Xilinx Zynq-7000 (Digilent Zedboard) |
| Language | VHDL |

## Status

Worked on hardware — the spectrum rendered live on the VGA output from the audio
input. Every block has a testbench (`*_tb.vhd`) for simulation.

Known limitations, left as they were in 2021:

- **Linear magnitude scale** — a log / dB scale would make low-amplitude bins
  readable.
- **Mirrored spectrum** — for a real input the display shows the full 0…fₛ
  range; it would be cleaner to fold it and show only 0…fₛ/2.

## Files

`FFT_TOP.vhd` ties it together; `AGU`, `BFU`, `COMPLEX_RAM`, `twiddle_rom`,
`complex_mult`, `RAM_BLOCK` are the core; `fft_mag`, `fft_out_ram`,
`vga_input_controller` handle display; `*_tb.vhd` are the testbenches.
