MKDV_MK := $(abspath $(lastword $(MAKEFILE_LIST)))
SYNTH_DIR := $(dir $(MKDV_MK))
MKDV_TOOL ?= icestorm

TOP_MODULE = tiny_soc

#QUARTUS_FAMILY ?= "Cyclone V"
#QUARTUS_DEVICE ?= 5CGXFC7C7F23C8
QUARTUS_FAMILY ?= "Cyclone 10 LP"
QUARTUS_DEVICE ?= 10CL025YE144A7G

include $(SYNTH_DIR)/../common/defs_rules.mk

RULES := 1

include $(SYNTH_DIR)/../common/defs_rules.mk

