; ---------------------------------------------------------
; Módulo: operaciones_gini.asm
; Arquitectura: x86 (32 bits)
; Descripción: Implementación de cálculos matemáticos usando
;              la FPU y convención de llamadas por stack.
; ---------------------------------------------------------

global sumar_uno_asm
global promedio_asm
global multiplicar_asm
global dividir_asm
global procesar_gini_asm

section .data
    float_dos dd 2.0  ; Constante para el promedio

section .text

; --- Función: Sumar 1.0 a un Float ---
sumar_uno_asm:
    push ebp
    mov ebp, esp
    fld dword [ebp + 8]   ; Cargamos el parámetro en el stack FPU (st0)
    fld1                  ; Cargamos la constante 1.0 en st0 (desplaza el anterior a st1)
    faddp st1, st0        ; Sumamos st0 + st1, resultado en st0
    pop ebp
    ret

; --- Función: Promedio de dos Floats ---
promedio_asm:
    push ebp
    mov ebp, esp
    fld dword [ebp + 8]   ; Carga 'a'
    fadd dword [ebp + 12] ; Suma 'b' directamente a st0
    fdiv dword [float_dos]; Divide st0 por 2.0
    pop ebp
    ret

; --- Función: Multiplicar dos Floats ---
multiplicar_asm:
    push ebp
    mov ebp, esp
    fld dword [ebp + 8]
    fmul dword [ebp + 12] ; Multiplicación simplificada
    pop ebp
    ret

; --- Función: Dividir dos Floats ---
dividir_asm:
    push ebp
    mov ebp, esp
    fld dword [ebp + 8]
    fdiv dword [ebp + 12]
    pop ebp
    ret

; --- Función Requerida: Conversión y +1 Entero ---
procesar_gini_asm:
    push ebp
    mov ebp, esp
    
    ; 1. Cargar float
    fld dword [ebp + 8]
    
    ; 2. Reservar espacio local y convertir a entero
    sub esp, 4
    fistp dword [esp]     ; Convierte st0 a entero y lo guarda en el stack local
    
    ; 3. Mover a registro de retorno y aplicar lógica
    pop eax               ; Sacamos el valor convertido a EAX
    inc eax               ; Requisito: Sumar uno (+1) al índice
    
    mov esp, ebp
    pop ebp
    ret