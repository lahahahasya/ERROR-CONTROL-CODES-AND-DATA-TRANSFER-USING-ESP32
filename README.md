# BCH(15, 5, 7) Error-Correcting Code Implementation in Verilog

This repository contains a complete implementation of a **BCH(15, 5, 7)** error-correcting code in Verilog, capable of correcting up to **t = 3** errors. The design includes both **encoder and decoder** components, structured with modular design principles and a clean testbench-driven validation flow.

The equations and layout for the encoder and decoders are taken from "The design of a VHDL based synthesis tool for BCH codecs" by Ernest Jamro.

## Parameters

The BCH code implemented is (15, 5, 7), meaning:

- **n = 15**: codeword length
- **k = 5**: message length
- **d_min = 7**: minimum hamming distance
- **t = 3**: can correct up to 3 bit errors

These parameters are defined and can be configured in `bch_params.vh`. The code currently compiles under Icarus Verilog, Xilinx ISim and Xilinx.

## Files Structure

| File | Description |
|------|-------------|
| `bch_encode.v` | LFSR encoder module |
| `sim.v` | Decoder module |
| `tb_sim.v` | Testbench to simulate the decoder |
| `bch_syndrome.v` | Syndrome calculator module for the decoder |
| `bch_errors_present.v` | Determines based on syndromes if any errors are present |
| `bch_sigma_*.v` | Key equation solvers (sigma). Takes syndrome equations as input and produces the key equation, as well as the number of bit errors detected |
| `bch_chein.v` | For implementing Chien search algorithm |
| `bch_error_*.v` | Error locator |
| `bch_error_dec.v` | Error location function for T < 3 |

## Technical Implementation

### Encoder

The encoder is implemented using a **10-stage Linear Feedback Shift Register (LFSR)**. The generator polynomial g(x) of degree 10 is used to produce 10 parity bits from a 5-bit input message.

The encoder uses a fixed generator polynomial for BCH(15,5,7) over GF(2⁴). For example, one possible generator polynomial is:

g(x) = (x + α)(x + α²)...(x + α⁶) → Degree 10

This polynomial is used to define the feedback taps in the LFSR.

### Decoder

The decoder is composed of four main modules, all instantiated inside a wrapper module `sim.v`:

1. **Syndrome Calculator**
   - Calculates syndromes S₁, S₂, ..., S₂ₜ using the received word r(x) evaluated at powers of the primitive element α:
   - S_i = r(α^i), i = 1, ..., 6

2. **Key Equation Solver (Berlekamp-Massey Algorithm)**
   - Implements the Berlekamp-Massey algorithm to find the **error locator polynomial** Λ(x), satisfying:
   - Λ(x) = 1 + λ₁x + λ₂x² + ... + λₜx^t
   - This polynomial captures the positions of the errors. The search function will choose the next highest number of correctable errors rather than trying to move to the next polynomial for the error corrector module.

3. **Chien Search**
   - Performs a search over all possible positions i (0 to 14) by evaluating Λ(α^(-i)). A root indicates an error at that position.
   - Λ(α^(-i)) = 0 ⇒ error at position i

4. **Error Corrector**
   - Flips the bits at the positions identified by the Chien Search module to reconstruct the original codeword.
   - r̂(x) = r(x) + e(x)

## Optimization

Many modules accept a `PIPELINE_STAGES` and/or a `REG_RATIO` parameter. These parameters relate to area/speed/latency optimizations.

## About

This project is developed as part of an academic project on BCH code design and hardware-level error correction.
