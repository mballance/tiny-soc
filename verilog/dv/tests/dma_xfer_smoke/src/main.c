/*
 * Copyright (c) 2012-2014 Wind River Systems, Inc.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <zephyr.h>
#include <devicetree.h>
#include <drivers/dma.h>
#include <sys/printk.h>

K_THREAD_STACK_DEFINE(my_stack_area, 500);

void doit(void *p1, void *p2, void *p3) {
    printk("Hello from doit\n");
}

K_MEM_SLAB_DEFINE(my_slab, 64, 16, 4);

void main(void)
{
	int i;
	char tmp[16];
	printk("Hello World! %s\n", CONFIG_BOARD);

	{
		struct device *dma = device_get_binding("dma1");
		struct dma_config cfg;
		uint32_t *src;
		uint32_t *dst;
		k_timeout_t timeout = {0};

		k_mem_slab_alloc(&my_slab, (void **)&src, timeout);
		k_mem_slab_alloc(&my_slab, (void **)&dst, timeout);

		sprintf(tmp, "dma=%p\n", dma);
		printk("Note: %s\n", tmp);

		for (i=0; i<16; i++) {
			src[i] = (i+1);
		}

		printk("==> dma_config\n");
		dma_config(dma, 0, &cfg);
		printk("<== dma_config\n");
		printk("==> dma_reload\n");
		dma_reload(dma, 0, src, dst, 16);
		printk("<== dma_reload\n");
		printk("==> dma_start\n");
		dma_start(dma, 0);
		printk("<== dma_start\n");
	}


	for (i=0; i<16; i++) {
		struct k_thread my_thread_data;
		k_tid_t tid = k_thread_create(&my_thread_data, my_stack_area,
				K_THREAD_STACK_SIZEOF(my_stack_area),
				doit,
				0, 0, 0,
				0, 0, K_NO_WAIT);
		printk("--> join\n");
		k_thread_join(&my_thread_data, K_FOREVER);
		printk("<-- join\n");
	}
}
