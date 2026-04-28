; Bootloader x86 - transición de modo real a modo protegido
bits 16
org 0x7C00

boot_start:
    cli
    lgdt [descriptor_gdt]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp SEL_CODE:pm_entry

bits 32
pm_entry:
    mov ax, SEL_DATA
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax
    mov esp, stack_base

    ; intentar escribir en segmento de solo lectura -> genera #GP
    mov edi, 0x00100000
    mov eax, 0x12345678
    mov [edi], eax

    ; si no ocurre fault, mostrar "OK" en pantalla VGA
    mov edi, 0xB8000
    mov ah, 0x0F
    mov al, 'O'
    mov [edi], ax
    add edi, 2
    mov al, 'K'
    mov [edi], ax

loop_halt:
    hlt
    jmp loop_halt

; GDT
descriptor_gdt:
    dw gdt_finish - gdt_begin - 1
    dd gdt_begin

align 8
gdt_begin:
null_descriptor:
    dq 0x0000000000000000

code_descriptor:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0x9A
    db 0xCF
    db 0x00

data_descriptor:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0x90
    db 0xCF
    db 0x00

gdt_finish:

SEL_CODE equ code_descriptor - gdt_begin
SEL_DATA equ data_descriptor - gdt_begin
stack_base equ 0x90000

times 510-($-$$) db 0