
TINY_SOC_SWDIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PACKAGES_DIR := $(abspath $(TINY_SOC_SWDIR)/../packages)

ifneq (1,$(RULES))

ifeq (,$(findstring $(TINY_SOC_SWDIR),$(MKDV_INCLUDED_DEFS)))
MKDV_INCLUDED_DEFS += $(TINY_SOC_SWDIR)
include $(PACKAGES_DIR)/fwperiph-dma/sw/defs_rules.mk
include $(PACKAGES_DIR)/fwrisc/sw/defs_rules.mk
include $(PACKAGES_DIR)/fwpic/sw/defs_rules.mk
include $(PACKAGES_DIR)/fwpit/sw/defs_rules.mk
endif

else # Rules

endif
