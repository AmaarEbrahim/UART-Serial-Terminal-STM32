MEMORY {
    SRAM (rw) : ORIGIN = 0x20000000, LENGTH = 20K 
    FLASH (rw) : ORIGIN = 0x08000000, LENGTH = 192K
}

SECTIONS {
    .vector_core : {
        KEEP(*(.vector_core))
    } > FLASH
    .text : {
        _s_text = .;
        *(.text)
        _e_text = .;
    } > FLASH
    .rodata : {
        . = ALIGN(4);
        _s_rodata = .;
        *(.rodata)
        *(.rodata*)
        _e_rodata = .;
    } > FLASH
    .data : {
        . = ALIGN(4);
        _s_data = .;
        *(.data)
        *(.data*)
        _e_data = .;
    } > SRAM AT> FLASH
    data_load_addr = LOADADDR(.data);
    .bss : {
        . = ALIGN(4);
        _s_bss = .;
        *(.bss)
        *(.bss*)
        _e_bss = .;
    } > SRAM

    _stack_start = ORIGIN(SRAM) + LENGTH(SRAM);
}