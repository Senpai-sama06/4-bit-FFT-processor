# 4-Point Pipelined FFT Processor (RTL-to-GDSII)

This project details the complete semi-custom VLSI design flow for a 4-point Fast Fourier Transform (FFT) processor. The design was taken from RTL (Verilog) through synthesis with **Cadence Genus** and place-and-route (PNR) with **Cadence Innovus**, resulting in a final GDSII layout.

* **Technology Library:** 90nm (Inferred from `gsclib090` library files)
* **Core Logic:** 3-Stage Pipelined 4-Point Radix-2 DIT FFT
* **Input Data Width:** 16-bit (Parameterized)

---

## 1. Overview

The core of this project is `rtl/fft_4pt.v`, a 3-stage pipelined FFT processor. It implements the **Radix-2 Decimation-in-Time (DIT)** algorithm, which expects inputs in bit-reversed order (`x[0], x[2], x[1], x[3]`) to produce outputs in natural order (`X[0], X[1], X[2], X[3]`).

### Key Architectural Features:
* **Pipelined Design:** The design is broken into 3 register stages (Input Regs, Stage 1 Regs, Stage 2 Regs) to maximize throughput. A new set of 4 inputs can be accepted on every clock cycle.
* **Algorithm:**
    * **Stage 1** performs two parallel butterfly operations: `(x[0], x[2])` and `(x[1], x[3]`).
    * **Stage 2** performs the final butterflies and applies the twiddle factor $W_4^1 = -j$.
* **Complex Arithmetic:** The multiplication by $W_4^1 = -j$ is implemented efficiently with no multipliers. For a complex number $D = (D_r + j \cdot D_i)$, the operation $D \cdot (-j)$ becomes $(D_i - j \cdot D_r)$.
* **Bit Growth:** The datapath width is managed to prevent overflow, growing from `DATA_WIDTH` (16-bit) to `S1_WIDTH` (17-bit) and finally to `S2_WIDTH` (18-bit).



---

## 2. File Structure

The repository is organized to separate source code from tool scripts, final results, and intermediate tool files.

. 
├── .gitignore 
├── LICENSE 
├── README.md # This file | 
├── rtl/ # Source RTL │ 
    └── fft_4pt.v # The 4-point FFT module │ 
├── tb/ # Testbenches │ 
    └── tb_fft_4pt.v # Testbench for the FFT module │ 
├── scripts/ # All synthesis and P&R scripts │ 
├── synth.tcl # Genus synthesis script │ 
├── pnr.tcl # (TODO: Add your Innovus PNR script) │ 
    └── constraints.sdc # Timing constraints (SDC) │ ├── results/ # Final project deliverables │ 
├── fft_4pt.gds # Final GDSII layout file │ 
    └── fft_4pt_netlist.v # Post-synthesis Verilog netlist│ 
├── reports/ # Synthesis, P&R, and verification reports │ ├── synthesis/ # Area, power, and timing from Genus │ 
    └── pnr/ # Final timing reports from Innovus │ └── tool_work/ # Tool databases (Innovus .enc, .gds.dat, logs, etc.) # (Included for project traceability)


---

## 3. Design Verification

The RTL design was verified using the `tb/tb_fft_4pt.v` testbench.

**(TODO: Add 1-2 sentences describing your testbench. What stimulus did you apply? Did it check the results against a known-good reference?)**

### Simulation Waveform

**(TODO: Add a screenshot from your simulation tool (e.g., `simvision` or `Verdi`) showing the `data_valid_in`, `data_valid_out`, and the inputs/outputs for a successful FFT calculation.)**

``

---

## 4. Physical Design (RTL-to-GDSII) Flow

### 4.1. Synthesis (Cadence Genus)

* **Script:** `scripts/synth.tcl`
* **Constraints:** `scripts/constraints.sdc`
* **Target Clock:** **(TODO: Add your clock frequency, e.g., 200 MHz / 5ns)**
* **Output Netlist:** `results/fft_4pt_netlist.v`

#### Post-Synthesis Results
*(Fill this from the files in `reports/synthesis/`)*

| Metric | Value |
| :--- | :--- |
| Timing Slack (WNS) | `...` ps |
| Total Area | `...` um^2 |
| Cell Area | `...` um^2 |
| Total Power | `...` mW |

### 4.2. Place & Route (Cadence Innovus)

* **Script:** `scripts/pnr.tcl` **(CRITICAL TODO: Find and add your PNR script to the `scripts/` folder. You can often rebuild it from the `innovus.log` file in `tool_work/log/`.)**
* **Key Steps:** Floorplanning, Power Planning, Placement, Clock Tree Synthesis (CTS), Routing.
* **Output Layout:** `results/fft_4pt.gds`

### Final Layout (GDS)

**(TODO: This is your most important image. Add a high-resolution screenshot of the final layout from Innovus.)**

``

#### Post-Layout Results & Verification
*(Fill this from the files in `reports/pnr/`)*

| Metric | Value |
| :--- | :--- |
| Final Timing Slack (WNS) | `...` ps |
| Final Area / Utilization | `...` um^2 / `...` % |
| **DRC Errors** | `...` (Should be 0) |
| **LVS (Netlists Match)** | `...` (Should be 'Pass') |

---

## 5. How to Run

1.  **Run Synthesis:**
    ```bash
    cd scripts
    genus -f synth.tcl
    ```

2.  **Run Place & Route:**
    ```bash
    cd scripts
    innovus -f pnr.tcl
    ```

---