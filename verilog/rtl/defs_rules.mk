
TINY_SOC_RTLDIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

ifneq (1,$(RULES))

ifeq (,$(findstring $(TINY_SOC_RTLDIR),$(MKDV_INCLUDED_DEFS)))
MKDV_INCLUDED_DEFS += $(TINY_SOC_RTLDIR)

# Include dependent IP
include $(PACKAGES_DIR)/fwrisc/rtl/defs_rules.mk
include $(PACKAGES_DIR)/fwpic/verilog/rtl/defs_rules.mk
include $(PACKAGES_DIR)/fwpit/verilog/rtl/defs_rules.mk
include $(PACKAGES_DIR)/fwuart-16550/verilog/rtl/defs_rules.mk
include $(PACKAGES_DIR)/fwperiph-dma/verilog/rtl/defs_rules.mk
include $(PACKAGES_DIR)/fw-wishbone-interconnect/verilog/rtl/defs_rules.mk

# Include sources 
MKDV_VL_INCDIR += $(TINY_SOC_RTLDIR)
MKDV_VL_SRCS += $(wildcard $(TINY_SOC_RTLDIR)/*.sv)

endif

else # Rules

endif
