MKDV_MK := $(abspath $(lastword $(MAKEFILE_LIST)))
TEST_DIR := $(dir $(MKDV_MK))
MKDV_TOOL ?= questa
RISCV_CC ?= riscv32-unknown-elf-gcc

MKDV_VL_SRCS += $(TEST_DIR)/tiny_soc_tb.sv
TOP_MODULE = tiny_soc_tb

MKDV_TIMEOUT ?= 4ms

MKDV_PLUGINS += cocotb pybfms
PYBFMS_MODULES += generic_sram_bfms riscv_debug_bfms

MKDV_TEST ?= zephyr.dma_xfer_smoke


#SW_IMAGE ?= $(MKDV_RUNDIR)/hello_world/zephyr/zephyr.elf
#SW_IMAGE ?= $(MKDV_RUNDIR)/print_ex/zephyr/zephyr.elf
ifeq (,$(SW_IMAGE))
    ifneq (,$(findstring zephyr,$(subst ., ,$(MKDV_TEST))))
	SW_IMAGE = $(MKDV_RUNDIR)/$(subst .,_,$(subst zephyr.,,$(MKDV_TEST)))/zephyr/zephyr.elf
    endif
endif
MKDV_COCOTB_MODULE = tiny_soc_tests.initram

VLSIM_CLKSPEC += clock=10ns
VLSIM_OPTIONS += -Wno-fatal

#SW_IMAGE ?= $(MKDV_RUNDIR)/memtest.elf
#MKDV_COCOTB_MODULE = tiny_soc_tests.asmtest

MKDV_RUN_DEPS += $(SW_IMAGE)
MKDV_RUN_ARGS += +sw.image=$(SW_IMAGE)

include $(TEST_DIR)/../common/defs_rules.mk

RULES := 1

# ZEPHYR_MODULES += $(PACKAGES_DIR)/fwpit/sw

$(MKDV_RUNDIR)/%/zephyr/zephyr.elf : $(ZEPHYR_BASE)/samples/%/src/main.c
	rm -rf $*
	mkdir $*
	cd $* ; ZEPYHR_BASE=$(ZEPHYR_BASE) cmake $(abspath $(^)/../..) \
                -DBOARD=tiny_soc_brd \
                -DBOARD_ROOT=$(TINY_SOC_DIR)/sw/zephyr \
                -DSOC_ROOT=$(TINY_SOC_DIR)/sw/zephyr \
                -DDTS_ROOT=$(TINY_SOC_DIR)/sw/zephyr \
                -DCMAKE_C_FLAGS="-DSIMULATION_MODE -march=rv32i" \
		-DZEPHYR_MODULES=$(PACKAGES_DIR)/fwpit/sw
	cd $* ; $(MAKE)
	
ZEPHYR_DTS_ROOT += $(TINY_SOC_DIR)/sw/zephyr
ZEPHYR_DTS_ROOT += $(ZEPHYR_MODULES)

$(MKDV_RUNDIR)/%/zephyr/zephyr.elf : $(TEST_DIR)/tests/%/src/main.c
	rm -rf $(MKDV_RUNDIR)/$*
	mkdir $(MKDV_RUNDIR)/$*
	cd $(MKDV_RUNDIR)/$* ; ZEPYHR_BASE=$(ZEPHYR_BASE) cmake $(abspath $(^)/../..) \
                -DBOARD=tiny_soc_brd \
                -DBOARD_ROOT=$(TINY_SOC_DIR)/sw/zephyr \
                -DSOC_ROOT=$(TINY_SOC_DIR)/sw/zephyr \
                -DDTS_ROOT="$(subst $(eval) ,;,$(ZEPHYR_DTS_ROOT))" \
                -DCMAKE_C_FLAGS="-DSIMULATION_MODE -march=rv32i" \
				-DZEPHYR_MODULES="$(subst $(eval) ,;,$(ZEPHYR_MODULES))"
	cd $(MKDV_RUNDIR)/$* ; $(MAKE)

#		-DVERBOSE=true --debug-output --trace \
#		-DZEPHYR_EXTRA_MODULES=$(ZEPHYR_EXTRA_MODULES)

$(MKDV_RUNDIR)/%.elf : $(TEST_DIR)/%.S
	$(Q)$(RISCV_CC) -o $@ $^ -march=rv32i \
		-static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles \
		-T$(TEST_DIR)/unit.ld


include $(TEST_DIR)/../common/defs_rules.mk
