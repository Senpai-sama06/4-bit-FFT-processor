# 4-Point Pipelined FFT Processor (RTL-to-GDSII)

This project details the complete semi-custom VLSI design flow for a 4-point Fast Fourier Transform (FFT) processor. The design was taken from RTL (Verilog) through synthesis with **Cadence Genus** and place-and-route (PNR) with **Cadence Innovus**, resulting in a final GDSII layout.

* **Technology Library:** 90nm 
* **Core Logic:** 3-Stage Pipelined 4-Point Radix-2 DIT FFT

---

## 1. Overview

The core of this project is `rtl/fft_4pt.v`, a 3-stage pipelined FFT processor. It implements the **Radix-2 Decimation-in-Time (DIT)** algorithm, which expects inputs in bit-reversed order (`x[0], x[2], x[1], x[3]`) to produce outputs in natural order (`X[0], X[1], X[2], X[3]`).

### Key Architectural Features:
* **Pipelined Design:** The design is broken into 3 register stages (Input Regs, Stage 1 Regs, Stage 2 Regs) to maximize throughput. A new set of 4 inputs can be accepted on every clock cycle.
* **Algorithm:**
    * **Stage 1** performs two parallel butterfly operations: `(x[0], x[2])` and `(x[1], x[3])`.
    * **Stage 2** performs the final butterflies and applies the twiddle factor $W_4^1 = -j$.
* **Complex Arithmetic:** The multiplication by $W_4^1 = -j$ is implemented efficiently with no multipliers. For a complex number $D = (D_r + j \cdot D_i)$, the operation $D \cdot (-j)$ becomes $(D_i - j \cdot D_r)$.
* **Bit Growth:** The datapath width is managed to prevent overflow, growing from `DATA_WIDTH` (16-bit) to `S1_WIDTH` (17-bit) and finally to `S2_WIDTH` (18-bit).



---

## 2. Design Verification

The RTL design was verified using the `tb/tb_fft_4pt.v` testbench.



---

## 3. Physical Design (RTL-to-GDSII) Flow

### 3.1. Synthesis (Cadence Genus)

* **Script:** `scripts/synth.tcl`
* **Constraints:** `scripts/constraints.sdc`
* **Target Clock:** **100 MHz (10 ns period)** 
* **Output Netlist:** `results/fft_4pt_netlist.v`

#### Post-Synthesis Results
*(From files in `reports/synthesis/`)*

| Metric | Value |
| :--- | :--- |
| Timing Slack (WNS) | **+4700 ps** |
| Total Area | **13697.619 um²**  |
| Cell Area | **13697.619 um²** |
| Total Power | **1.358 mW** |

### 3.2. Place & Route (Cadence Innovus)

* **Script:** `scripts/pnr.tcl` 
* **Key Steps:** Floorplanning, Power Planning, Placement, Clock Tree Synthesis (CTS), Routing.
* **Output Layout:** `results/fft_4pt.gds`

