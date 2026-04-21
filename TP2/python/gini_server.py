import ctypes
import os
from msl.loadlib import Server32

# Buscamos la librería libgini.so de forma robusta.
# Como este archivo está en 'python/', subimos un nivel para encontrarla en la raíz.
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
LIB_PATH = os.path.join(BASE_DIR, '..', 'libgini.so')

class GiniServer32(Server32):
    """
    Servidor de 32 bits encargado de cargar la biblioteca compartida (ELF 32-bit)
    y exponer sus métodos a la capa de 64 bits.
    """
    def __init__(self, host, port, **kwargs):
        # Cargamos la librería usando la convención de llamadas 'cdll' (estándar en C/Linux)
        print(f"-> [GiniServer32] Cargando biblioteca desde: {LIB_PATH}")
        super().__init__(LIB_PATH, 'cdll', host, port)

        # --- Definición de Prototipos (Para que C/ASM reciban bien los datos) ---

        # En C se llama: float sumar_uno(float v)
        self.lib.sumar_uno.argtypes = [ctypes.c_float]
        self.lib.sumar_uno.restype = ctypes.c_float

        # En C se llama: float promedio(float a, float b)
        self.lib.promedio.argtypes = [ctypes.c_float, ctypes.c_float]
        self.lib.promedio.restype = ctypes.c_float

        # En C se llama: float multiplicar(float a, float b)
        self.lib.multiplicar.argtypes = [ctypes.c_float, ctypes.c_float]
        self.lib.multiplicar.restype = ctypes.c_float

        # En C se llama: float dividir(float a, float b)
        self.lib.dividir.argtypes = [ctypes.c_float, ctypes.c_float]
        self.lib.dividir.restype = ctypes.c_float

        # En C se llama: int procesar_gini_final(float valor_gini)
        # Esto llama a la rutina de Assembler
        self.lib.procesar_gini_final.argtypes = [ctypes.c_float]
        self.lib.procesar_gini_final.restype = ctypes.c_int

        print("-> [GiniServer32] Configuración de funciones finalizada con éxito.")

    # --- Métodos expuestos al Cliente (Capa 64 bits) ---

    def sumar_uno(self, valor):
        return self.lib.sumar_uno(valor)

    def promedio(self, a, b):
        return self.lib.promedio(a, b)

    def multiplicar(self, a, b):
        return self.lib.multiplicar(a, b)

    def dividir(self, a, b):
        if b == 0:
            raise ValueError("Error: División por cero en el servidor de 32 bits.")
        return self.lib.dividir(a, b)

    def procesar_gini_final(self, valor_gini):
        """Llama a la rutina de C que a su vez invoca al Assembler"""
        print(f"-> [GiniServer32] Procesando GINI: {valor_gini}")
        resultado = self.lib.procesar_gini_final(valor_gini)
        return resultado