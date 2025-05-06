MEMORY {
    SRAM (rw) : ORIGIN = 0x20000000, LENGTH = 20K 
    FLASH (rw) : ORIGIN = 0x08000000, LENGTH = 192K
}

SECTIONS {
    .text : {
        _s_text = .;
        KEEP(*(.vector_core))
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
    .bss : {
        . = ALIGN(4);
        _s_bss = .;
        *(.bss)
        *(.bss*)
        _e_bss = .;
    } > SRAM
}