#include "gdt.h"

// Defining the Global Descriptor Table (GDT) in memory
struct GlobalDescriptorTable gdt;

// Defining the GDTR (Global Descriptor Table Register)
struct GDTR _gdt_gdtr;

/**
 * Helper function to set a segment descriptor.
 * This will set the base, limit, type, and other flags for a descriptor.
 * @param descriptor Pointer to the segment descriptor to modify
 * @param base Base address of the segment
 * @param limit Limit (size) of the segment
 * @param type Type flags for the segment (e.g., code, data)
 * @param non_system Flag for system segment (0 for non-system)
 */
static void set_segment_descriptor(struct SegmentDescriptor *descriptor, uint32_t base, uint32_t limit, uint8_t type, uint8_t non_system) {
    descriptor->segment_low = limit & 0xFFFF;
    descriptor->base_low = base & 0xFFFF;
    descriptor->base_mid = (base >> 16) & 0xFF;
    descriptor->type_bit = type;
    descriptor->non_system = non_system;

    // For 64-bit (long mode) GDT, the limit must be specified in 4KB chunks and the 64-bit flag needs to be set.
    // Set the high limit, and other flags if needed for your system.
}

/**
 * Initializes the GDT.
 * It will fill the GDT with the necessary segments for kernel code and data, and setup the GDTR.
 */
void init_gdt() {
    // Setting up the null descriptor (index 0)
    set_segment_descriptor(&gdt.table[0], 0, 0, 0, 0);

    // Setting up the kernel code segment (index 1)
    set_segment_descriptor(&gdt.table[1], 0, 0xFFFFFFFF, 0xA, 0);  // 0xA for executing and readable, non-system

    // Setting up the kernel data segment (index 2)
    set_segment_descriptor(&gdt.table[2], 0, 0xFFFFFFFF, 0x2, 0);  // 0x2 for writable, non-executable, non-system

    // Set the GDTR with the address of our GDT and its size
    _gdt_gdtr.size = sizeof(gdt) - 1;  // GDT size in bytes - 1
    _gdt_gdtr.address = &gdt;

    // Load the GDT using the LGDT instruction
    // Note: This is a platform-specific instruction and needs to be executed in assembly.
    load_gdt(&_gdt_gdtr);
}

/**
 * Assembly function to load the GDT.
 * This function will load the GDTR into the CPU using the `lgdt` instruction.
 * It will also update the segment selectors.
 */
extern void load_gdt(struct GDTR *gdtr);

/**
 * Optionally, you can implement more segment descriptors here
 * for other purposes such as TSS, LDT, etc.
 */

