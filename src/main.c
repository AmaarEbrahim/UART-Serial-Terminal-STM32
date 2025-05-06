#include <stdint.h>
#include "stm32l073xx.h"

volatile uint16_t vectors[5] __attribute__((section(".vector_core"))) = {
    0x01,
    0x02,
    0x03,
    0x04,
    0x05
};


int main() {
    while (1) {}

    return 0;
}