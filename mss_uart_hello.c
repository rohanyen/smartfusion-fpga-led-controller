#include <stdio.h>
#include "mss_uart.h"

int main()
{
    MSS_UART_init(
        &g_mss_uart0,
        MSS_UART_57600_BAUD,
        MSS_UART_DATA_8_BITS | MSS_UART_NO_PARITY | MSS_UART_ONE_STOP_BIT
    );

    MSS_UART_polled_tx_string(
        &g_mss_uart0,
        (const uint8_t*)"Hello World\r\n"
    );

    while(1);

    return 0;
}