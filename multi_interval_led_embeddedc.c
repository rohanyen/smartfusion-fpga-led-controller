#include "mss_uart.h"

#define APB_LED_REG (*((volatile uint32_t *)0x40050000))

int main()
{
    uint8_t rx_buff;

    MSS_UART_init(&g_mss_uart0, MSS_UART_9600_BAUD, 
                  MSS_UART_DATA_8_BITS | MSS_UART_NO_PARITY | MSS_UART_ONE_STOP_BIT);

    MSS_UART_polled_tx(&g_mss_uart0, (const uint8_t *)"\r\nEnter Choice (1/2/4): ", 24);

    while(1)
    {
        // Poll the UART until a byte is received
        if (MSS_UART_get_rx(&g_mss_uart0, rx_buff, 1) > 0)
        {
            // Convert ASCII character directly to raw integer (e.g., '1' -> 1)
            uint8_t mode = rx_buff - '0';

            // Validate that the number is exactly 1, 2, or 4 using a bitmask
            if (mode == 1 || mode == 2 || mode == 4) 
            {
                APB_LED_REG = mode; // Send raw binary integer to FPGA fabric via APB
                MSS_UART_polled_tx(&g_mss_uart0, (const uint8_t *)"\r\nSuccess!", 10);
            } 
            else 
            {
                MSS_UART_polled_tx(&g_mss_uart0, (const uint8_t *)"\r\nError!", 8);
            }
        }
    }
    return 0;
}
