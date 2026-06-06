# Parameterized AXI-Stream FPGA-Based GEMM Accelerator Using Systolic Array Architecture

## Overview

This project implements a parameterized NxN systolic array architecture for matrix multiplication (GEMM - General Matrix Multiplication) in Verilog HDL. The design integrates AXI-Stream interfaces for efficient data transfer and is suitable for FPGA-based acceleration of compute-intensive matrix operations commonly used in DSP, AI, and machine learning applications.

The accelerator is fully parameterized, allowing different data widths and systolic array sizes to be configured at compile time.

---

## Features

* Parameterized NxN systolic array architecture
* AXI-Stream input interface
* AXI-Stream output interface
* Modular Processing Element (PE) design
* Scalable architecture for different matrix sizes
* Verilog RTL implementation
* Self-checking testbench
* FPGA synthesis verified in Vivado

---

## Architecture

Data enters the accelerator through the AXI-Stream receiver module.

AXI-Stream RX → Systolic Array Core → AXI-Stream TX

The systolic array consists of interconnected Processing Elements (PEs) that perform multiply-and-accumulate operations while propagating data across rows and columns.

---

## Directory Structure
```
RTL/
├── PE.v
├── systolic_array_NxN.v
├── axis_rx.v
├── axis_tx.v
└── systolic_array_axi_top.v

TB/
└── systolic_array_axi_top_tb.v

docs/
├── waveform.png
├── simulation_passed.png
├── synthesis_utilization.png

README.md
```
---

## Processing Element (PE)

Each Processing Element performs:

* Input data forwarding
* Multiplication
* Accumulation
* Pipeline data propagation

The PE serves as the fundamental building block of the systolic array.

---

## Verification

A self-checking testbench was developed to validate functionality.

Verification flow:

1. Generate random input matrices
2. Compute expected output (golden result)
3. Feed inputs through AXI-Stream interface
4. Capture accelerator output
5. Compare DUT output with golden result

Simulation Results:

===== TEST 0 ===== PASSED

===== TEST 1 ===== PASSED

===== TEST 2 ===== PASSED

===== TEST 3 ===== PASSED

===== TEST 4 ===== PASSED

===== SIMULATION DONE =====

---

## FPGA Synthesis Results

Target Device: Xilinx Artix-7

Resource Utilization:

* LUTs: 1472
* Flip-Flops: 1006

Synthesis completed successfully with no critical issues.

---

## Applications

* Matrix Multiplication Acceleration
* Machine Learning Inference Engines
* DSP Systems
* FPGA-Based AI Accelerators
* High-Performance Computing

---

## Future Improvements

* Full GEMM support for multiple matrix rows and columns
* Pipelined MAC units
* Higher throughput AXI interfaces
* FPGA implementation and timing optimization
* Integration with embedded processors

---

## Tools Used

* Verilog HDL
* Xilinx Vivado
* AXI-Stream Protocol
* GitHub

---

## Author

Developed as an FPGA/Digital Design project demonstrating RTL design, AXI-Stream integration, verification, and FPGA synthesis workflows.
