# Makefile
# ---- tools ----
IVERILOG ?= iverilog
VVP      ?= vvp
GTKWAVE  ?= gtkwave

# ---- settings ----
TOP      ?= cpu_tb                 
BUILD    ?= build
TARGET   ?= cpu_tb.out
VCD      ?= $(strip build/cpu_tb.vcd)              
IFLAGS   ?= -Wall                  

# ---- sources ----
TB   := cpu_tb.v
SRCS := cpu.v instr_mem.v data_mem.v reg_file.v ctrl_alu.v branch_adder.v \
        pipe_ex_mem.v pipe_id_ex.v pipe_if_id.v instr_decoder.v ctrl_main.v \
        pipe_mem_wb.v alu32.v sext16to32.v forwarding_unit.v hazard_detection_unit.v \
		mux_flush.v mux_operand1.v mux_operand2.v


# ---- rules ----
.PHONY: all run wave clean help

all: $(BUILD)/$(TARGET)

$(BUILD)/$(TARGET): $(SRCS) $(TB) | $(BUILD)
	$(IVERILOG) $(IFLAGS) -o $@ -s $(TOP) $(TB) $(SRCS)

$(BUILD):
	mkdir -p $(BUILD)

run: all
	$(VVP) $(BUILD)/$(TARGET)

wave: run
	@vcd="$(strip $(VCD))"; \
	if [ -f "$$vcd" ]; then \
	  $(GTKWAVE) "$$vcd"; \
	else \
	  echo "VCD '$$vcd' not found. Make sure your testbench dumps it."; \
	fi


clean:
	rm -rf $(BUILD) *.vcd

help:
	@echo "make            # build"
	@echo "make run        # execute simulation (vvp)"
	@echo "make wave       # open VCD with GTKWave"
	@echo "make clean      # delete"
