# Compiler & linker
ASM           = nasm
LIN           = ld
CC            = gcc

# Directories
SOURCE_FOLDER = src
OUTPUT_FOLDER = bin

ISO_NAME      = OS2024
STORAGE_FILE  = storage

# Flags
WARNING_CFLAG = -Wall -Wextra -Werror
DEBUG_CFLAG   = -ffreestanding -fshort-wchar -g
STRIP_CFLAG   = -nostdlib -fno-stack-protector -nostartfiles -nodefaultlibs -ffreestanding
CFLAGS        = $(DEBUG_CFLAG) $(WARNING_CFLAG) $(STRIP_CFLAG) -m32 -c -I$(SOURCE_FOLDER)
AFLAGS        = -f elf32 -g -F dwarf
LFLAGS        = -T $(SOURCE_FOLDER)/linker.ld -melf_i386

# Find all C and ASM files
C_SOURCES    = $(wildcard $(SOURCE_FOLDER)/*.c)
ASM_SOURCES  = $(wildcard $(SOURCE_FOLDER)/*.s)
OBJ_FILES    = $(patsubst $(SOURCE_FOLDER)/%.c, $(OUTPUT_FOLDER)/%.o, $(C_SOURCES)) \
               $(patsubst $(SOURCE_FOLDER)/%.s, $(OUTPUT_FOLDER)/%.o, $(ASM_SOURCES))

# Kernel Compilation
kernel: $(OBJ_FILES)
	@echo Linking object files...
	@$(LIN) $(LFLAGS) $(OBJ_FILES) -o $(OUTPUT_FOLDER)/kernel

$(OUTPUT_FOLDER)/%.o: $(SOURCE_FOLDER)/%.c
	@echo Compiling $<...
	@$(CC) $(CFLAGS) $< -o $@

$(OUTPUT_FOLDER)/%.o: $(SOURCE_FOLDER)/%.s
	@echo Assembling $<...
	@$(ASM) $(AFLAGS) $< -o $@

# ISO Image Creation
iso: kernel
	@mkdir -p $(OUTPUT_FOLDER)/iso/boot/grub
	@cp $(OUTPUT_FOLDER)/kernel $(OUTPUT_FOLDER)/iso/boot/
	@cp other/grub1 $(OUTPUT_FOLDER)/iso/boot/grub/
	@cp $(SOURCE_FOLDER)/menu.lst $(OUTPUT_FOLDER)/iso/boot/grub/
	@grub-mkrescue -o $(ISO_NAME).iso $(OUTPUT_FOLDER)/iso/

# Run with QEMU
run: iso
	@qemu-system-i386 -cdrom $(ISO_NAME).iso -m 128M

# Run with QEMU and Debugging Enabled
debug: iso
	@qemu-system-i386 -cdrom $(ISO_NAME).iso -m 128M -s -S

# Clean Build Files
clean:
	@rm -rf $(OUTPUT_FOLDER)/*.o $(OUTPUT_FOLDER)/kernel $(ISO_NAME).iso
