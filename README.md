# NESRV — A Custom RISC-V Processor

**NESRV** is a RISC-V processor designed and developed as part of an academic and exploratory initiative into open-source hardware. The project is built with modular RTL in SystemVerilog, simulated using Verilator, and prepared for physical design using OpenLane.

---

## 🧠 Project Philosophy

We believe in learning by doing. NESRV is our attempt to go from RTL to GDSII with a self-managed, script-driven workflow. No Makefiles — just clean code and purposeful automation.

---

## 🧱 Repository Structure

```
NESRV/
├── rtl/ # SystemVerilog source code
│ ├── core/ # Core modules like IFU, ALU, regfile
│ ├── mem/ # Mem blocks
│ └── top.sv # Top-level processor integration
├── sim/ # Verilator testbenches and related scripts
│ ├── testbench.cpp # C++ testbench for Verilator
├── pd/ # Physical design flow (OpenLane)
│ ├── openlane/ # OpenLane design folder for top module
│ │ ├── config.json
│ │ ├── constraints.sdc
│ │ └── ...
├── docs/ # Design documentation and diagrams
│ ├── architecture.md
│ └── img/
├── scripts/ # General utility scripts (build, convert, etc.)
│ └── run_verilator.sh
│ └── run_openlane.sh
├── LICENSE
├── .gitignore
└── README.md
```

---

## ⚙️ Requirements

- **Verilator** (for simulation)
- **OpenLane** (for physical design)
- **Python 3** and **Bash** (for scripts)

---

## 🚀 How to Simulate

Run this from the `sim/` directory:

```bash
cd sim/
./run_verilator.sh
```

## 🧱 How to Run Physical Design

```bash
cd pd/scripts/
./run_openlane.sh
```

## 👨‍💻 Team NES

- N — Nitu Kumari Mahato (@NituMahato2003)
- E — Ekta Singh (@ekta568)
- S — Subham Pal (@Subhampal9)

## 📘 Documentation

Detailed architecture documentation is available in:
```
docs/architecture.md
```
It includes block diagrams, pipeline details, module specs, and ISA notes.

## 🚧 Project Status

* Repository initialized- Done

* Core RTL modules designed- Work going on

* Basic testbench functional

* Simulation passing with sample instructions

* Physical design clean DRC/LVS

* GDS generated and verified
