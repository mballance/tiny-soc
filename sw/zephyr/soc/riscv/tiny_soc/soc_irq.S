/*
 * Copyright (c) 2018 Matthew Ballance <matt.ballance@gmail.com>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

/*
 * common interrupt management code for FWRISC SOCs
 */
#include <kernel_structs.h>
#include <offsets.h>
#include <toolchain.h>
#include <linker/sections.h>
#include <soc.h>

/* exports */
//GTEXT(__soc_handle_irq)

/*
 * SOC-specific function to handle pending IRQ number generating the interrupt.
 * Exception number is given as parameter via register a0.
 *
 * FWRISC doesn't currently support interrupts, so this is stubbed out
 */
//SECTION_FUNC(exception.other, __soc_handle_irq)
	/* NOP */

	/* Return */
//	li a0, 1
//	jalr x0, ra

/*
 * __soc_is_irq is defined as .weak to allow re-implementation by
 * SOCs that does not truely follow the riscv privilege specification.
 */
WTEXT(__soc_is_irq)

/*
 * SOC-specific function to determine if the exception is the result of a
 * an interrupt or an exception
 * return 1 (interrupt) or 0 (exception)
 *
 */
SECTION_FUNC(exception.other, __soc_is_irq)
	// mcause
	csrr a0, mcause
	srli a0, a0, 31
	jalr x0, ra

