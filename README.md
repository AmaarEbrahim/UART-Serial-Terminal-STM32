# Overview
I am writing a UART library for the STM32L073 microcontroller. The only vendor code I am using for this project is code from Arm's CMSIS-Device and Core libraries. I am writing the linker script, startup file, and Makefile myself so I can gain more hands on experience with them. I'd like to become more familiar with the way code is built and run on a microcontroller, and I think relying on vendor-provided software can sometimes get in the way of that.

Here are some things I want to showcase in this project:
1. A basic, functioning UART library that can print characters to a serial terminal
2. A custom linker script 
3. A custom startup file
4. A custom Makefile
5. Custom scripts to interact with the microcontroller through OpenOCD
6. Things I have learned while working on the project explained in clear, concise English.

# Credits
Big thanks to [OurEmbeddeds](https://ourembeddeds.github.io/). I made use of some code from two of their articles: "Armv7 Startup (2) - Linker Script" and "Armv7 Startup" for my linker script and startup file.

# ARM Header Files
I am using header files from ARM's CMSIS-Device and Core libraries. ST has those header files online in a couple of their GitHub repositories. These links take you to the repos I found the header files in:
1. https://github.com/STMicroelectronics/STM32CubeL0 (Core)
2. https://github.com/STMicroelectronics/cmsis-device-l0 (CMSIS-Device)

# Makefiles

Makefile cheatsheet: https://devhints.io/makefile

Certain Makefile errors used to confuse me. One error that I got a lot was "make: *** No rule to make target '{dependency}', needed by '{target}'.  Stop."
My Makefile would usually look something like this (the @echo was something else):
```Makefile
all: %.o
	@echo $@

%.o: %.c
	@echo $@
```
Output:
```
make: *** No rule to make target '%.o', needed by 'all'.  Stop.
```
I used to think that in the above example, the rule for the dependency %.o existed since it was written out as a target with dependencies and a body. I thought that the rule was still valid because the %'s would act as wildcard characters to capture all of the .o and .c files.
But in reality, my mental model for how %'s affected targets and dependencies was wrong, and this was causing me to write invalid rules that Make would ignore, hence the error.

I didn't understand that (1) rule targets and dependencies don't expand with the % character, and (2) rules are supposed to operate on one file at a time.

Regarding the first point, when %.o is a dependency of all, Make will try to find a rule that is literally called "%.o". In the example above, %.o is defined, so Make would navigate 
to that rule after it sees the target all. Make will then notice that %.o has a dependency -- %.c -- and it will try to find a rule for it. But, a rule for %.c does not exist. So, Make will consider the rule for %.o to be invalid, ignore it, and will throw the error "make: *** No rule to make target '%.o', needed by 'all'.  Stop.".

If %.o didn't depend on %.c, Make wouldn't have an issue. Try the following code yourself:
```Makefile
all: %.o
	@echo $@

%.o:
	@echo $@
```
Output:
```
%.o
all
```
Here, %.o doesn't depend on a nonexistent rule, so Make will not ignore %.o and throw an error saying that %.o does not exist.

Now onto my second point. Although targets and dependencies don't expand with the % character, targets with the % character can still "match" to dependencies. When they match,
they only match to one file at a time. The following example shows this:
```Makefile
all: main2.o main3.o
	@echo $@

%.o:
	@echo $@
```
Output:
```
main2.o
main3.o
all
```
Here, main2.o and main3.o match to %.o because the % captures the strings "main2" and "main3". Each dependency runs the target rule one at a time. 

Quick word of caution: Make will not run rules for dependencies that already exist as files in the folder. So, for example, if main2.o was an existing file, Make would not run %.o for main2.o.

I think it is best to think of rules as special types of subroutines... They have names (the target name). They can take in no paramaters (the equivalent of not using %), or they can take in one parameter (happens when using %), and the parameter has a datatype -- it is a string with no spaces. And, they can perform tasks (the body of the rule).

Other neat features of Makefiles:
```Makefile
SRCS=$(wildcard src/*.c)
OBJS=$(patsubst src/%.c, obj/%.o, $(SRCS))
```

It seems like wildcard and patsubst are "functions". Arguments are passed in as comma-delimited values. You can use * to capture all values in a path. You can use % as a parameter
name. 

# Linker Script
The linker script has two segments: FLASH and SRAM. Here's how my linker script defines these two regions
```ld
MEMORY {
    SRAM (rw) : ORIGIN = 0x20000000, LENGTH = 20K 
    FLASH (rw) : ORIGIN = 0x08000000, LENGTH = 192K
}
```
The origin and length come from the datasheet and reference manual.

My linker script also creates four sections: .text, .rodata, .data, and .bss. The .text section is filled by the vector table and code. Here is how I define it:
```ld
SECTIONS {
    .text : {
        _s_text = .;
        KEEP(*(.vector_core))
        *(.text)
        _e_text = .;
    } > FLASH

	...

}
```
KEEP makes sure that the linker doesn't discard a section even if symbols within the section don't get used.

To help my startup file copy over the .data section from flash to SRAM, the following line is in the linker script:
```ld
data_load_addr = LOADADDR(.data);
```
This above line stores the address that the .data section gets loaded to (ie. in flash), allowing my startup file to locate the beginning of where it must copy from.

Additionally, there is a line in the linker script that stores the initial value of the stack pointer:
```ld
_stack_start = ORIGIN(SRAM) + LENGTH(SRAM);
```
It creates a variable that points to the very top of SRAM. My startup file sets _stack_start as the first element of the vector table.