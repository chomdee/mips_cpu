# 🧠 MIPS 5-Stage Pipeline (IF–ID–EX–MEM–WB)

A **MIPS 32-bit 5-stage pipelined CPU** implemented in Verilog, newly updated with **Coprocessor 0 (CP0) and Exception Handling** to support OS-level operations.

**Branch:** `main` (with data forwarding, untaken branch prediction, and trap dispatcher)

---

## 🚀 v2.0 Update: Exception Handling & Coprocessor 0 (CP0)
Hardware exception handling logic has been added to support OS-level control, along with rigorous pipeline data hazard debugging.

### 🛠 Key Implementations
* **Coprocessor 0 (CP0):** Added `Cause`, and `EPC` registers to manage OS states and exception reasons (`cp0.v`).
* **Software Trap Dispatcher (Raw Machine Code):** Designed so that the hardware only routes the PC to a temporary common handler (`0x0030`) upon exception.
  * *Future Plan:* The handler address is planned to be updated to the MIPS standard kernel exception vector (`0x80000180`) in future iterations.
  * *Implementation:* Instead of relying on an external assembler, the routing and branching logic is currently hardcoded directly in raw machine code (Hex) acting as a "human assembler" with inline comments (e.g., `401B6800 // mfc0 $k1, $13 (Cause)`). 
* **System Instructions:** Added decoding and datapath routing for `mfc0`, `mtc0`, and `eret`.
* **Synchronous Exception Test:** Successfully simulated a `div` divide-by-zero trap, routed it to a specific handler, and safely returned to the user program (`PC+4`) via `eret`.

* **Reference:** For the full raw machine code implementation and layout of this exception test, please refer to the **`dvibyzero_with_exc.hex`** file.


---

## 🏗️ Pipeline Overview
> **※ Note:** The diagram below represents the **v1.0 Base Architecture** (pure ALU/Branch pipeline). The current v2.0 includes additional CP0 blocks and PC multiplexing routing for exception (`eret`) handling built on top of this foundation.

![Pipeline Diagram](pipeline_diagram.png)

---

## ⚙️ Features

- **Classic 5 pipeline stages:** IF → ID → EX → MEM → WB  
- **Exception Handling & CP0:** Supports hardware traps and kernel routing.
- **Branch decision** handled in the **EX** stage  
  → Misprediction causes a **2-cycle flush** (IF/ID and ID/EX)  
- **Data forwarding** between EX/MEM/WB stages to reduce stalls  
- **Testbench** dumps VCD waveform and data memory contents automatically  
- **Modular design:** each unit (ALU, control, hazard, forwarding, cp0, etc.) is implemented in a separate file  

---

## 📜 Supported Instructions (Subset)

| Type | Instructions |
|------|---------------|
| **ALU** | `add`, `addi`, `sub`, `and`, `or`, `nor`, `slt`, `sll`, `div` |
| **Memory** | `lw`, `sw` |
| **Branch** | `beq` |
| **System (CP0)**| `mfc0`, `mtc0`, `eret` |

---

## 💾 Initialization & Memory

- **Register file (`reg_file.v`)** - Contains predefined register values for easier testing.  
  - You can modify initial values directly inside `reg_file.v`.

- **Instruction memory** - Loads programs from `program.hex` using `$readmemh` in `instr_mem.v`. 
  - Example files: `program1.hex`, `program2.hex`, `program3.hex`, `test_cp0.hex`, `test_cp0_2.hex`, `divbyzero_with_exc.hex`  
  - Human-readable decoded versions: `program1.txt`, `program2.txt`, `program3.txt` (in `memory/` folder)
  - **Please implement this in `instr_mem.v`.**

- **Data memory** - Dumped automatically to `memory_dump.hex` at the end of simulation via `$writememh`.

---

## 🚀 Build & Run

```bash
make         # build with iverilog
make run     # run with vvp
make wave    # open VCD file with GTKWave
make clean   # remove build artifacts
```

### 💡 Engineering Note: 

🔗 **Detailed Notes:** [](여기에_티스토리_해당글_링크_붙여넣기)