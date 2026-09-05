#include "mss_uart.h"

#define APB_LED_REG  (*((volatile uint32_t *)0x40050000))

int main() {
    uint8_t rx_buff[1];
    uint8_t rx_size;

    // Initialize UART 9600 baud 8N1
    MSS_UART_init(&g_mss_uart0, MSS_UART_9600_BAUD,
                  MSS_UART_DATA_8_BITS | MSS_UART_NO_PARITY | MSS_UART_ONE_STOP_BIT);

    // Send prompt
    MSS_UART_polled_tx(&g_mss_uart0, "Enter Choice (1/2/4): ", 22);

    // Wait for input
    while(1) {
        rx_size = MSS_UART_get_rx(&g_mss_uart0, rx_buff, sizeof(rx_buff));
        if(rx_size > 0) break;
    }

    // Write to FPGA via APB
    APB_LED_REG = rx_buff[0];

    return 0;
}
