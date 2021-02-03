VERILOG_COMMON_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
TINY_SOC_DIR := $(abspath $(VERILOG_COMMON_DIR)/../..)
PACKAGES_DIR := $(TINY_SOC_DIR)/packages

ZEPHYR_BASE := $(PACKAGES_DIR)/zephyr
export ZEPHYR_BASE

PATH:=$(PACKAGES_DIR)/python/bin:$(PATH)
export PATH

DV_MK := $(shell PATH=$(PACKAGES_DIR)/python/bin:$(PATH) python -m mkdv mkfile)


ifneq (1,$(RULES))

include $(TINY_SOC_DIR)/verilog/rtl/defs_rules.mk
include $(TINY_SOC_DIR)/sw/defs_rules.mk

MKDV_PYTHONPATH += $(VERILOG_COMMON_DIR)/python

include $(DV_MK)
else # Rules

include $(DV_MK)
endif


