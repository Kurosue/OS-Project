# GOAL : Create File ( BIOS Interpret as a bootable disk )

Boot sector is needed because BIOS doesn't know how to load the OS. The boot sector must be placed in a known/ standard location.

To make disk is bootable,the BIOS check the bytes **511** and **512** of the alleged boot sector are `0xAA55`.

Example of the simplest boot sector:
``` 
e9 fd ff 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[ 29 more lines with sixteen zero-bytes each ]
00 00 00 00 00 00 00 00 00 00 00 00 00 00 55 aa 
```

# Simple Boot Sector
two way:
- Write byte manually using binary editor
- Using loop with scripts

```
; Infinite loop (e9 fd ff)
loop:
    jmp loop 
; Fill with 510 zeros minus the size of the previous code
times 510-($-$$) db 0
; Magic number
dw 0xaa55
```

Compiling :
`nasm -f bin boot_sect_simple.asm -o boot_sect_ex.bin`

Run on VM:
`qemu boot_sect_ex.bin`
