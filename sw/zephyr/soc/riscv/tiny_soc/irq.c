
#include <kernel.h>
#include <device.h>
#include <init.h>
#include <irq.h>

#if defined(CONFIG_MULTI_LEVEL_INTERRUPTS)
#include <irq_nextlevel.h>

static const struct device *dev_pic = 0;

void arch_irq_enable(unsigned int irq) {
	printk("==> arch_irq_irq_enable %d\n", irq);
	irq_enable_next_level(dev_pic, irq);
	printk("<== arch_irq_irq_enable %d\n", irq);
}

void arch_irq_disable(unsigned int irq) {
	printk("arch_irq_irq_disable %d\n", irq);
};

int arch_irq_is_enabled(unsigned int irq) {
	return 0;
}
#endif

void soc_interrupt_init(void) {
#if defined(CONFIG_MULTI_LEVEL_INTERRUPTS)
	dev_pic = device_get_binding(
			DT_LABEL(DT_INST(0, fw_pic)));
#endif
}


#if defined(CONFIG_RISCV_SOC_INTERRUPT_INIT)
#endif

