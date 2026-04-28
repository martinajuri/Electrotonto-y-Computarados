#include <stdio.h>

// Prototipo de la función que queremos auditar en GDB
extern int procesar_gini_asm(float valor_gini);

int main() {
    float entrada_ejemplo = 45.3f;
    int salida_asm;

    printf("=== Laboratorio de Pila (GDB) ===\n");
    printf("1. Valor float de entrada: %f\n", entrada_ejemplo);

    /* * Instrucción crítica para el informe:
     * Aquí ocurre el paso de parámetros de C a ASM.
     * En x86_64, el float irá al registro XMM0.
     */
    salida_asm = procesar_gini_asm(entrada_ejemplo);

    printf("2. Valor entero devuelto por ASM: %d\n", salida_asm);
    printf("=================================\n");

    return 0;
}