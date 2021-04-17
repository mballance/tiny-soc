
#include <stdint.h>
#include "baremetal_support.h"
#include "uart_bfm.h"


int main() {
	volatile uint32_t *uart = (volatile uint32_t *)0x40002000;

	// Configure the UART
	{
		uart[3] = (uart[3] | 0x80); // Enable access to the counters
		uart[0] = 5;
		uart[1] = 0;
		uart[3] = (uart[3] & ~0x80); // Disable access to the counters
	}

	// Configure the UART BFM
	uart_bfm_config(0, 5, 8);

	// Tell the BFM to expect 20 bytes
	uart_bfm_rx_bytes_incr(0, 10, 20);

	// Now, send 20 bytes in
	{
		uint32_t i;
		for (i=0; i<20; i++) {
			// Wait for the THR to be empty
			while ((uart[5] & 0x40) == 0) { ; }

			uart[0] = 10+i;
		}
	}

	// Tell the BFM to generate 20 bytes
	uart_bfm_tx_bytes_incr(0, 10, 20);

	// Now, read those bytes in
	{
		uint32_t i, data;
		for (i=0; i<20; i++) {
			// Wait for the THR to be empty
			while ((uart[5] & 0x01) == 0) { ; }

			data = uart[0];
		}
	}

}
