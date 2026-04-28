; Bootloader x86 - transición de modo real a modo protegido
; Inicio en 16 bits (Real Mode)
bits 16
org 0x7C00

boot_start:
    cli                     ; se deshabilitan interrupciones

    ; cargar la tabla de descriptores globales
    lgdt [descriptor_gdt]

    ; activar Protected Mode seteando el bit PE de CR0
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax

    ; salto largo para recargar CS y continuar en 32 bits
    jmp SEL_CODE:pm_entry


; ==============================
; Código en Protected Mode
; ==============================
bits 32
pm_entry:
    ; inicialización de registros de segmento
    mov ax, SEL_DATA
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax

    ; inicialización del stack pointer
    mov esp, stack_base

    ; prueba de acceso a segmento de solo lectura
    mov edi, 0x00100000
    mov eax, 0x12345678
    mov [edi], eax          ; debería generar excepción

    ; si no ocurre fault, escribir mensaje en video
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


; ==============================
; Definición de la GDT
; ==============================

descriptor_gdt:
    dw gdt_finish - gdt_begin - 1
    dd gdt_begin

align 8
gdt_begin:

null_descriptor:
    dq 0x0000000000000000

; segmento de código
code_descriptor:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0x9A
    db 0xCF
    db 0x00

align 8
; segmento de datos de solo lectura
data_descriptor:
    dw 0xFFFF
    dw 0x0000
    db 0x10
    db 0x90
    db 0xCF
    db 0x00

gdt_finish:

; selectores
SEL_CODE equ code_descriptor - gdt_begin
SEL_DATA equ data_descriptor - gdt_begin

; stack
stack_base equ 0x90000

; firma de booteo
times 510-($-$$) db 0
dw 0xAA55