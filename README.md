# digital-design-verilog

Verilog RTL implementations of a **16-bit Parameterized ALU** and an **FSM Digital Security Lock**, each with self-checking testbenches and GTKWave simulation waveforms.

---

## Repository Structure

```
digital-design-verilog/
├── ALU/
│   ├── code/
│   │   └── alu.v                  # ALU RTL design
│   ├── testbench/
│   │   └── alu_tb.v               # Self-checking random testbench
│   ├── waveform/
│   │   ├── ALUwaveform1.png
│   │   ├── ALUwaveform2.png
│   │   └── ALUwaveform3.png
│   └── README.md                  # Detailed ALU documentation
├── FSM/
│   ├── code/
│   │   └── fsmcodedetector.v      # FSM RTL design
│   ├── testbench/
│   │   └── fsmcodedetector_tb.v   # Structured task-based testbench
│   ├── waveform/
│   │   └── fsm_sim.vcd            # GTKWave simulation dump
│   └── FSMREADME.md               # Detailed FSM documentation
└── README.md
```

---

## Projects

### 1 — 16-bit Parameterized ALU

> Full documentation: [`ALU/README.md`](ALU/README.md)

A combinational Arithmetic Logic Unit implemented in Verilog HDL. The data-path width is controlled by a single `parameter width = 16`, so the entire design scales to any bit-width without touching the core logic.

#### Supported Operations

| ALUControl | Operation | Expression              | Description                        |
|------------|-----------|-------------------------|------------------------------------|
| `3'b000`   | ADD       | `{C, Z} = X + Y`        | Extended addition with carry out   |
| `3'b001`   | SUB       | `{C, Z} = X + (~Y + 1)` | Two's complement subtraction       |
| `3'b010`   | AND       | `Z = X & Y`             | Bitwise AND                        |
| `3'b011`   | OR        | `Z = X \| Y`            | Bitwise OR                         |
| `3'b100`   | SLT       | `Z = (X < Y) ? 1 : 0`  | Signed set-less-than               |
| `3'b101`   | MUL       | `{Z_high, Z} = X * Y`  | Full 32-bit signed multiplication  |

#### Port List

| Signal     | Direction | Width          | Description                          |
|------------|-----------|----------------|--------------------------------------|
| `X`        | input     | 16-bit signed  | First operand                        |
| `Y`        | input     | 16-bit signed  | Second operand                       |
| `ALUControl` | input   | 3-bit          | Selects the operation                |
| `Z`        | output    | 16-bit         | Primary result / lower MUL bits      |
| `Z_high`   | output    | 16-bit         | Upper 16 bits of MUL result          |
| `C`        | output    | 1-bit          | Carry out (ADD / SUB)                |
| `Zero`     | output    | 1-bit          | High when `Z == 0`                   |
| `S`        | output    | 1-bit          | Sign flag — MSB of result            |
| `P`        | output    | 1-bit          | Even parity of result                |
| `Overflow` | output    | 1-bit          | Signed overflow (ADD / SUB only)     |

#### Simulation Waveforms

![ALU Simulation Waveform 1](ALU/waveform/ALUwaveform1.png)
![ALU Simulation Waveform 2](ALU/waveform/ALUwaveform2.png)
![ALU Simulation Waveform 3](ALU/waveform/ALUwaveform3.png)

#### How to Simulate

```bash
# Compile
iverilog -o alu_sim.out ALU/code/alu.v ALU/testbench/alu_tb.v

# Run simulation
vvp alu_sim.out

# View waveform
gtkwave ALU/waveform/alu_sim.vcd
```

---

### 2 — FSM Digital Security Lock

> Full documentation: [`FSM/FSMREADME.md`](FSM/FSMREADME.md)

A synchronous Finite State Machine that grants access only when a specific 5-button sequence is entered correctly. Built with the professional 3-block FSM structure (state register · next-state logic · output logic) and two independent security features.

#### Unlock Sequence

```
s  →  r  →  b  →  g  →  r
```

Any incorrect press resets progress. After **3 wrong attempts** the FSM locks permanently until a synchronous reset is applied. Additionally, **8 clock cycles of inactivity** automatically returns the FSM to the initial state.

#### State Diagram

| State    | Encoding | Meaning                  | Correct Input | Next State |
|----------|----------|--------------------------|---------------|------------|
| S0       | `3'b000` | Initial / Reset          | `s` only      | S1         |
| S1       | `3'b001` | `s` detected             | `r` only      | S2         |
| S2       | `3'b010` | `s→r` detected           | `b` only      | S3         |
| S3       | `3'b011` | `s→r→b` detected         | `g` only      | S4         |
| S4       | `3'b100` | `s→r→b→g` detected       | `r` only      | S5         |
| S5       | `3'b101` | SUCCESS                  | `s` → restart | S1         |
| LOCKED   | `3'b110` | Permanently locked       | reset only    | S0         |

#### Port List

| Signal        | Direction | Description                                   |
|---------------|-----------|-----------------------------------------------|
| `clk`         | input     | Clock signal                                  |
| `reset`       | input     | Synchronous reset — returns FSM to S0         |
| `s, r, g, b`  | input     | Button inputs                                 |
| `a`           | output    | High whenever any button is pressed           |
| `unlock`      | output    | High when the correct sequence is detected    |

#### Simulation Results

```
Test 1: Correct sequence      → PASS
Test 2: Lockout after 3 wrong → PASS
Test 3: Reset escapes lockout → PASS
==========================================
PASSED : 3
FAILED : 0
ALL TESTS PASSED
==========================================
```

#### How to Simulate

```bash
# Compile
iverilog -o fsm_sim.out FSM/code/fsmcodedetector.v FSM/testbench/fsmcodedetector_tb.v

# Run simulation
vvp fsm_sim.out

# View waveform
gtkwave FSM/waveform/fsm_sim.vcd
```

---

## Tools Used

| Tool | Version | Purpose |
|------|---------|---------|
| [Icarus Verilog](https://steveicarus.github.io/iverilog/) | v12 | Compilation and simulation |
| [GTKWave](https://gtkwave.sourceforge.net/) | v3.3 | Waveform analysis |
| VS Code + Verilog-HDL extension | — | Development |

---

## Skills Demonstrated

- **RTL design in Verilog HDL** — synthesizable combinational and sequential logic
- **Parameterized design** — single `parameter` scales all signal widths automatically
- **Signed arithmetic** — two's complement subtraction, signed comparison, full-width signed multiplication
- **Status flag logic** — Carry, Zero, Sign, Overflow, and Parity using reduction operators
- **3-block FSM architecture** — clean separation of state memory, next-state logic, and output logic
- **Input validation** — exact one-button guards prevent false triggers from simultaneous presses
- **Verification methodology** — self-checking random testbench (ALU) and structured task-based testbench (FSM) with pass/fail reporting and VCD waveform dumps
