/*
 * Copyright (c) 2012-2014 Wind River Systems, Inc.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <zephyr.h>
#include <sys/printk.h>

void doit(const char *name) {
    printk("doit: %s\n", name);
}

void main(void)
{
	int i;
	char tmp[16];
	printk("Hello World! %s\n", CONFIG_BOARD);

	for (i=0; i<16; i++) {
		sprintf(tmp, "%02d", i);
		doit(tmp);
	}
}
