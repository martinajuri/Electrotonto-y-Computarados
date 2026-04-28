import sys
import datetime
from msl.loadlib import Client64
from servicios import consultar_indice_gini
import os

class PuenteCalculoASM(Client64):
    """
    Esta clase actúa como puente entre Python 64-bits y la lógica de 32-bits.
    """
    def __init__(self):
        # Obtenemos la ruta absoluta de la carpeta 'python'
        actual_dir = os.path.dirname(os.path.abspath(__file__))
        # El archivo del servidor se llama gini_server.py
        server_path = os.path.join(actual_dir, 'gini_server.py')
        
        print(f"-> Iniciando servidor desde: {server_path}")
        
        super().__init__(
            module32=server_path, # Pasamos la ruta completa al archivo
            append_sys_path=actual_dir
        )

    def ejecutar_operacion(self, operacion, *args):
        """Método genérico para llamar al servidor 32 bits"""
        return self.request32(operacion, *args)

def bitacora_operaciones(tarea, entrada, salida):
    """Registra los cálculos en un archivo local"""
    fecha = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open("bitacora_gini.log", "a") as log:
        log.write(f"[{fecha}] Op: {tarea} | In: {entrada} | Out: {salida}\n")

def mostrar_menu():
    print("\n" + "="*30)
    print(" SISTEMA DE PROCESAMIENTO GINI")
    print("="*30)
    print("1. Consultar Banco Mundial y Procesar")
    print("0. Salir")
    return input("Seleccione una opción: ")

if __name__ == "__main__":
    try:
        cliente = PuenteCalculoASM()
    except Exception as e:
        print(f"Fallo al iniciar puente 32/64 bits: {e}")
        sys.exit(1)

    while True:
        op = mostrar_menu()
        if op == "0": break
        
        try:
            if op == "1":
                iso = input("Código ISO del país (ej. ARG): ").upper()
                valor = consultar_indice_gini(iso)
                if valor:
                    resultado = cliente.ejecutar_operacion('procesar_gini_final', float(valor))
                    print(f"\nResultado final (ASM): {resultado}")
                    bitacora_operaciones("GINI_API_ASM", valor, resultado)
            
        except Exception as e:
            print(f"Error en el proceso: {e}")