# Guía de Instalación y Configuración - TP#2

Este proyecto integra **Python (64-bits)**, **C (32-bits)** y **Assembler (32-bits)**. Debido a esta arquitectura híbrida, es fundamental seguir estos pasos para configurar el entorno correctamente.

## 1. Dependencias del Sistema (Linux/Ubuntu)

Primero, instalamos las herramientas de compilación y el soporte para ejecutar código de 32 bits en sistemas de 64 bits.

```bash
# Actualizar repositorios
sudo apt update

# Herramientas de compilación y ensamblador
sudo apt install build-essential nasm gcc-multilib g++-multilib python3-venv python3-full

# Habilitar arquitectura de 32 bits (i386)
sudo dpkg --add-architecture i386
sudo apt update

# Librerías de sistema de 32 bits necesarias para msl-loadlib
sudo apt install zlib1g:i386 libstdc++6:i386 libc6:i386
```

## 2. Configuración del Entorno Virtual (Python)
Para evitar errores de "externally-managed-environment", trabajaremos con un entorno virtual (venv).

```bash
# Crear el entorno virtual en la raíz del proyecto
python3 -m venv venv

# Activar el entorno
source venv/bin/activate

# Instalar librerías necesarias
pip install requests msl-loadlib
```

## 3. Compilación
El proyecto utiliza un Makefile para orquestar la compilación de las diferentes capas. Desde la raíz de TP2, ejecuta:

```bash

make clean
make
```

Esto generará la librería libgini.so y el ejecutable de prueba verificador.
## 4. Ejecución de la Aplicación
Asegúrate de tener el entorno virtual activo (source venv/bin/activate) y ejecuta:

```bash
python3 python/interfaz_calculo.py
```


## 5. Pruebas y Debugging (Para el Informe)
Para capturar la evidencia del Stack Frame requerida en el trabajo práctico:
Ejecutar GDB con el verificador: gdb ./verificador
Poner breakpoint: break procesar_gini_asm
Correr: run
Ver registros y pila: layout asm, info registers, x/4xw $ebp+8
## 6. Estructura del Proyecto
/Assembler: Rutinas matemáticas en .asm (x86).
/C: Wrappers y verificador de pila en C.
/python: Interfaz, cliente 64-bit y servidor 32-bit.
libgini.so: Librería compartida generada por el Makefile.

