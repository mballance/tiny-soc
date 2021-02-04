/*
 * Copyright (c) 2012-2014 Wind River Systems, Inc.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <zephyr.h>
#include <devicetree.h>
#include <drivers/dma.h>
#include <sys/printk.h>

K_MEM_SLAB_DEFINE(stack_slab, 500, 4, 4);
// K_THREAD_STACK_DEFINE(my_stack_area, 500);

void doit(void *p1, void *p2, void *p3) {
//    printk("Hello from doit\n");
}

static void dma_done(const struct device *dev, void *user_data, uint32_t channel, int status) {
	struct k_sem *sem = (struct k_sem *)user_data;

	k_sem_give(sem);
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

		{
			struct k_sem sem;
			k_sem_init(&sem, 0, 1);

			cfg.user_data = &sem;
			cfg.dma_callback = dma_done;
			cfg.complete_callback_en = 1;

			printk("==> dma_config\n");
			dma_config(dma, 0, &cfg);
			printk("<== dma_config\n");
			printk("==> dma_reload\n");
			dma_reload(dma, 0, src, dst, 16);
			printk("<== dma_reload\n");
			printk("==> dma_start\n");
			dma_start(dma, 0);
			printk("<== dma_start\n");

			printk("==> Wait for DMA\n");
			k_sem_take(&sem, K_FOREVER);
			printk("<== Wait for DMA\n");
		}
	}


	for (i=0; i<16; i++) {
		char *stack;
		struct k_thread *my_thread_data;
		k_mem_slab_alloc(&stack_slab, (void **)&stack, K_FOREVER);
		my_thread_data = (struct k_thread *)stack;
		k_tid_t tid = k_thread_create(my_thread_data, stack,
				500,
				doit,
				0, 0, 0,
				0, 0, K_NO_WAIT);
		printk("--> join\n");
		k_thread_join(my_thread_data, K_FOREVER);
		printk("<-- join\n");
	}
}
