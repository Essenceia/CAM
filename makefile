BUILD_DIR := build

# verilator lint flags
LINT_FLAGS += -Wall -Wpedantic -Wno-GENUNNAMED -Wno-LATCH -Wno-IMPLICIT
LINT_FLAGS +=$(if $(wip),-Wno-UNUSEDSIGNAL)

# iverilog build flags
BUILD_FLAGS +=-Wall -g2012 $(if $(assert),-gassertions) -gstrict-expr-width
BUILD_FLAGS +=$(if $(debug),-DDEBUG) 
CAM:= cam.v

lint:
	verilator --lint-only $(LINT_FLAGS) $(CAM)

# Build commands.

build:
	iverilog $(BUILD_FLAGS) -s crc_tb -o $(BUILD_DIR)/crc_tb tb.sv hdl/slicing_crc.sv 
	vvp $(BUILD_DIR)/crc_tb
