#include <stdint.h>

extern int _stack_start;
extern int _s_data;
extern int _e_data;
extern int data_load_addr;
extern int _s_bss;
extern int _e_bss;

int main();

void ResetHandler() {

    // Copy .data section from flash to SRAM
    int * start = &_s_data;
    int * data = &data_load_addr;

    while (start < &_e_data) {
        *start++ = *data++;
    }

    // Initialize .bss section with 0's
    start = &_s_bss;

    while (start < &_e_bss) {
        *start++ = 0;
    }

    // Call main()
    main();

}

volatile int vectors[41] __attribute__((section(".vector_core"))) = {
    (int)&_stack_start,             // stack pointer
    (int)&ResetHandler,              // reset handler
    0,                              // non maskable interrupt handler
    0,                              // hard fault handler
    0,                              // reserved
    0,                              // svc handler
    0,                              // reserved
    0,                              // pend sv handler
    0,                              // systick handler
    0,                              // wwdg handler

    0,                              // pvd handler
    0,                              // rtc handler
    0,                              // flash handler
    0,                              // rcc_crs
    0,                              // exti[1:0]
    0,                              // exti[3:2]
    0,                              // exti[15:4]
    0,                              // tsc
    0,                              // dma1_channel1
    0,                              // dma1_channel[3:2]

    0,                              // dma1_channel1[7:4]
    0,                              // adc_comp
    0,                              // lptim1
    0,                              // usart4/usart5
    0,                              // tim2
    0,                              // tim3
    0,                              // tim6_dac
    0,                              // tim7
    0,                              // reserved
    0,                              // tim21

    0,                              // i2c3
    0,                              // tim22
    0,                              // i2c1
    0,                              // i2c2
    0,                              // spi1
    0,                              // spi2
    0,                              // usart1
    0,                              // usart2
    0,                              // LPUART1 + AES +RNG
    0,                              // lcd

    0                              // usb
};
