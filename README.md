# 4-bit ALU Verification Environment (SystemVerilog)

This repository contains a SystemVerilog verification environment for a 4-bit ALU, implemented using an interface-based, class-based testbench (similar in style to UVM, but lightweight).

The project was originally developed and run in EDA Playground and can also be run locally with a simulator such as ModelSim/Questa or VCS.

---

## 1. Design Under Test (DUT)

**Module:** `alu`

**Functionality**

The ALU operates on two 4-bit operands `a` and `b`, controlled by a 2-bit `select` input:

- `select = 2'b00` → `out = a + b`
- `select = 2'b01` → `out = a - b`
- `select = 2'b10` → `out = a * b`
- `select = 2'b11` → `out = a / b`

The following status flags are generated from the result:

- `zero`     – high if `out == 0`
- `sign`     – MSB of `out` (`out[3]`)
- `parity`   – even parity of `out` (`~^out`)
- `carry`    – MSB of the 5-bit result `{carry,out} = operation(a,b)`
- `overflow` – signed overflow for add/sub:
  `overflow = (a[3] & b[3] & ~out[3]) | (~a[3] & ~b[3] & out[3])`

**I/O Ports**

| Signal    | Dir | Width | Description                          |
|-----------|-----|-------|--------------------------------------|
| `a`       | in  | 4     | First operand                        |
| `b`       | in  | 4     | Second operand                       |
| `select`  | in  | 2     | Operation select (00=ADD, 01=SUB, 10=MUL, 11=DIV) |
| `out`     | out | 4     | Operation result (lower 4 bits)      |
| `carry`   | out | 1     | Carry / borrow / extra result bit    |
| `zero`    | out | 1     | 1 if `out == 0`                      |
| `sign`    | out | 1     | Sign bit (MSB) of `out`              |
| `parity`  | out | 1     | Even parity flag of `out`            |
| `overflow`| out | 1     | Signed overflow indicator            |

---

## 2. Verification Architecture

The verification environment follows the structure used in lab:

- **Top-level testbench:** `alu_tb.sv`
  - Generates clock.
  - Instantiates the ALU interface and the DUT.
  - Instantiates the `test` program.

- **Interface:** `alu_interface.sv`
  - Bundles DUT pins: `a`, `b`, `select`, `out`, `zero`, `carry`, `sign`, `parity`, `overflow`.
  - Provides:
    - `task drive_transaction(transaction tr);`
    - `function transaction sample_transaction();`

- **Program / test:** `test.sv`
  - `program test(alu_interface inter);`
  - Creates the `environment` and calls `env.run()`.

- **Environment:** `environment.sv`
  - Connects and controls all verification components:
    - `generator`
    - `driver`
    - `monitor`
    - `reference`
    - `compare`
    - `coverage`
  - Owns the communication queues:
    - `gen2drv` – generator → driver
    - `mon2cmp` – monitor → comparator
    - `mon2cvg` – monitor → coverage

- **Transaction:** `transaction.sv`
  - Fields:
    - Randomized: `a`, `b`, `select`
    - Observed / computed: `out`, `zero`, `carry`, `sign`, `parity`, `overflow`
  - Methods:
    - Constraints on `select` and `b` (avoid most divide-by-zero, but still allow some).
    - `display(string tag)`, `do_copy`, `do_compare`.

- **Generator:** `generator.sv`
  - Randomizes number of transactions.
  - Randomizes each `transaction` and pushes into `gen2drv`.

- **Driver:** `driver.sv`
  - Has a `virtual alu_interface`.
  - At each clock, pops transactions from `gen2drv` and calls `inter.drive_transaction(tr)`.

- **Monitor:** `monitor.sv`
  - Has a `virtual alu_interface`.
  - On each clock edge (with a small delay), calls `inter.sample_transaction()`.
  - Pushes each sampled transaction into:
    - `mon2cmp` (for scoreboard)
    - `mon2cvg` (for coverage)

- **Reference model:** `reference.sv`
  - Golden model of ALU behavior at transaction level.
  - `function transaction process(const ref transaction in_tr);`
    - Recomputes the operation and flags from `a`, `b`, `select`.

- **Comparator (Scoreboard core):** `compare.sv`
  - Contains counters for total / passed / failed transactions.
  - For each `act_tr` in `mon2cmp`:
    - Calls `refm.process(act_tr)` → `exp_tr`.
    - Compares `act_tr` vs `exp_tr` using `do_compare`.
    - Prints detailed ACT vs EXP on mismatches.

- **Coverage:** `coverage.sv`
  - `covergroup alu_covergroup with function sample(transaction tr);`
  - Coverpoints:
    - `select` (operations)
    - ranges of `a` and `b`
    - flags: `zero`, `sign`, `parity`, `carry`, `overflow`
  - Cross coverage:
    - `op_cvp` × operand ranges
    - `op_cvp` × each flag
  - `class coverage` wraps the covergroup and prints functional coverage percentage.

---

## 3. Test Plan (Scenarios)

The testbench uses constrained-random generation plus implicit directed scenarios through constraints. Example scenarios:

1. **Basic arithmetic (ADD/SUB)**
   - Purpose: verify correctness of addition and subtraction for small/mid-range values.
   - Inputs:
     - `select ∈ {0,1}`
     - `a,b` constrained to typical ranges (0–15).
   - Expected:
     - `out` matches `a + b` or `a - b` (4-bit).
     - `carry`, `zero`, `sign`, `parity`, `overflow` follow ALU spec.

2. **Edge and overflow cases (ADD/SUB)**
   - Purpose: exercise boundary values and signed overflow.
   - Inputs focused around extremes:
     - `a,b ∈ {0, 7, 8, 15}`
     - `select ∈ {0,1}`
   - Expected:
     - Carry high on 4-bit overflow.
     - `overflow` high for signed overflow patterns (e.g. positive+positive ⇒ negative).

3. **Multiply/Divide (including divide-by-zero)**
   - Purpose: verify multiplication and division operations.
   - Inputs:
     - `select = 2` with various `a,b`.
     - `select = 3` with `b != 0` and some cases with `b == 0`.
   - Expected:
     - For `b != 0`: `out = a / b`, flags consistent.
     - For `b == 0`: result and flags may be X/undefined; this behavior is observed and documented.

4. **Random regression**
   - Purpose: improve coverage and stress the design.
   - `generator` randomizes `num_trans` and all inputs under constraints.
   - Coverage is sampled on each monitored transaction until target coverage is reached.

---

## 4. Coverage

Functional coverage is implemented by `alu_covergroup`:

- operation coverage (`select`),
- operand value classes (zero, small, mid, max),
- flags (`zero`, `sign`, `parity`, `carry`, `overflow`),
- cross coverage between:
  - operation and operands,
  - operation and each flag.

Coverage is sampled from transactions observed by the monitor (i.e. post-DUT behavior) and summarized at the end of the run:

```text
[COV] Functional coverage = XX.XX %
