# --- Configuración de Directorios ---
ASM_DIR = Assembler
C_DIR = C
OBJ_DIR = obj

# --- Compiladores y Flags ---
AS = nasm
ASFLAGS = -f elf32 -g
CC = gcc
CCFLAGS = -m32 -fPIC -g -I$(C_DIR)

# --- Objetivos ---
all: setup libgini.so verificador

# Crear carpeta para los .o si no existe
setup:
	mkdir -p $(OBJ_DIR)

# Generar la librería dinámica para Python
libgini.so: $(OBJ_DIR)/operaciones_gini.o $(OBJ_DIR)/procesador_central.o
	$(CC) $(CCFLAGS) -shared -o libgini.so $^

# Compilar el objeto de Assembler
$(OBJ_DIR)/operaciones_gini.o: $(ASM_DIR)/operaciones_gini.asm
	$(AS) $(ASFLAGS) $< -o $@

# Compilar el objeto de C
$(OBJ_DIR)/procesador_central.o: $(C_DIR)/procesador_central.c
	$(CC) $(CCFLAGS) -c $< -o $@

# Ejecutable de prueba para GDB
verificador: $(C_DIR)/verificador_pila.c $(OBJ_DIR)/operaciones_gini.o
	$(CC) $(CCFLAGS) $^ -o verificador

clean:
	rm -rf $(OBJ_DIR) *.so verificador