#include <stdio.h>

/* * Prototipos de funciones externas (vienen del archivo .asm)
 * Usamos "extern" para decirle al compilador de C que estas 
 * funciones se definirán en otro lado.
 */
extern float sumar_uno_asm(float valor);
extern float promedio_asm(float a, float b);
extern float multiplicar_asm(float a, float b);
extern float dividir_asm(float a, float b);
extern int procesar_gini_asm(float valor_gini);

// --- Funciones que expone la librería para ser llamadas desde Python ---

float sumar_uno(float v) { return sumar_uno_asm(v); }

float promedio(float a, float b) { return promedio_asm(a, b); }

float multiplicar(float a, float b) { return multiplicar_asm(a, b); }

float dividir(float a, float b) {
    if (b == 0) return 0.0f; // Validación básica de seguridad
    return dividir_asm(a, b);
}

/*
 * Esta función cumple el requerimiento del TP:
 * Recibe el float de la API y llama a la rutina ASM 
 * para transformarlo y sumarle uno.
 */
int procesar_gini_final(float valor_gini) {
    printf("[C] Recibido float: %f. Invocando rutina ASM...\n", valor_gini);
    return procesar_gini_asm(valor_gini);
}