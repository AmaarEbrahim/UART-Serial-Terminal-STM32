LD_SCRIPT=linker_script.ld
OUT_DIR=./build
OUT_NAME=executable.out
SRC_DIR=./src
MAP_NAME=output.map

CORE_INCLUDE_PATH=./external/stm32l0/core/include/
DEVICE_INCLUDE_PATH=./external/stm32l0/device/include/

C_FLAGS=-march=armv6 -nostdlib -I${CORE_INCLUDE_PATH} -I${DEVICE_INCLUDE_PATH} -O0
LD_FLAGS=${C_FLAGS} -T${LD_SCRIPT} -Wl,-Map=${OUT_DIR}/${MAP_NAME}

SRCS=$(wildcard ${SRC_DIR}/*.c)
OBJS=$(patsubst ${SRC_DIR}/%.c, ${OUT_DIR}/%.o, $(SRCS))

.PHONY:
	clean

all: ${OBJS}
	arm-none-eabi-gcc ${LD_FLAGS} $^ -o ${OUT_DIR}/${OUT_NAME}
	@mkdir ${OUT_DIR}/reports
	arm-none-eabi-readelf ${OUT_DIR}/${OUT_NAME} -S > ${OUT_DIR}/reports/sections.txt
	arm-none-eabi-readelf ${OUT_DIR}/${OUT_NAME} -l > ${OUT_DIR}/reports/segments.txt
	arm-none-eabi-readelf ${OUT_DIR}/${OUT_NAME} -s > ${OUT_DIR}/reports/symbols.txt
	hexdump ${OUT_DIR}/${OUT_NAME} -C > ${OUT_DIR}/reports/hexdump.txt


${OUT_DIR}/%.o: ${SRC_DIR}/%.c
	arm-none-eabi-gcc -c ${C_FLAGS} $^ -o $@


clean:
	rm -r ./build/*
