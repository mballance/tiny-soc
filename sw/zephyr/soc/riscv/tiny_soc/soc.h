/*
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef INCLUDED_TINY_SOC_H
#define INCLUDED_TINY_SOC_H

#include <devicetree.h>
#include "../tiny_soc/soc_common.h"

/* lib-c hooks required RAM defined variables */
#define RISCV_RAM_BASE    DT_SRAM_BASE_ADDR_ADDRESS
#define RISCV_RAM_SIZE    DT_SRAM_SIZE

#endif /* INCLUDED_TINY_SOC_H */
