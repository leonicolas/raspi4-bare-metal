SRC_DIR   = src
BUILD_DIR = build
C_FILES   = $(wildcard $(SRC_DIR)/*.c)
O_FILES   = $(patsubst $(SRC_DIR)/%,$(BUILD_DIR)/%,$(C_FILES:.c=.o))
GCC_FLAGS = -Wall -O2 -ffreestanding -nostdinc -nostdlib -nostartfiles

all: clean kernel8.img

init:
	mkdir -p $(BUILD_DIR)

boot.o:
	aarch64-linux-gnu-gcc-10 $(GCC_FLAGS) -c $(SRC_DIR)/boot.s -o $(BUILD_DIR)/boot.o

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	aarch64-linux-gnu-gcc-10 $(GCC_FLAGS) -c $< -o $@

kernel8.img: init boot.o $(O_FILES)
	aarch64-linux-gnu-ld -nostdlib -nostartfiles $(BUILD_DIR)/boot.o $(O_FILES) -T link.ld -o $(BUILD_DIR)/kernel8.elf
	aarch64-linux-gnu-objcopy -O binary $(BUILD_DIR)/kernel8.elf $(BUILD_DIR)/kernel8.img

clean:
	rm $(BUILD_DIR)/* > /dev/null 2> /dev/null || true
