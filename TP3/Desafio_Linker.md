## Desafío Linker

### 1. ¿Qué es un linker y qué hace?

Un linker (enlazador) es una herramienta del proceso de compilación que toma uno 
o más archivos objeto (.o) generados por el ensamblador o compilador, y los combina 
para producir un archivo ejecutable final. Sus tareas principales son:

- **Resolución de símbolos:** conecta las referencias a funciones y variables definidas 
  en distintos archivos objeto.
- **Reubicación:** ajusta las direcciones de memoria de instrucciones y datos según 
  la ubicación final que tendrán en memoria.
- **Generación del binario final:** produce el archivo de salida en el formato indicado 
  (en nuestro caso, binario puro con `--oformat binary`).

En el contexto de este TP, el linker toma el archivo objeto `main.o` generado por el 
ensamblador GAS y produce la imagen binaria `main.img` lista para ser ejecutada 
directamente por la BIOS.

---

### 2. Procedimiento realizado

#### 2.1 Clonado del repositorio

Se clonó el repositorio oficial del TP e inicializaron los submódulos:

```bash
git clone https://gitlab.com/sistemas-de-computacion-2021/protected-mode-sdc
cd protected-mode-sdc
git submodule update --init --recursive
```
![alt text](ImagenesLink/Clon_git.png)

El repositorio contiene las siguientes carpetas:

- `00SimpleMBR` — ejemplo de MBR simple
- `01HelloWorld` — ejemplo de Hello World con linker
- `02QemuFiles` — archivos de configuración para QEMU
- `x86-bare-metal-examples` — submódulo con ejemplos de código bare metal

---

#### 2.2 Código fuente

Se trabajó con los archivos de la carpeta `01HelloWorld`. El código fuente `main.S` 
implementa un bootloader en assembler de 16 bits que muestra el mensaje 
"hello world" en pantalla utilizando la interrupción de BIOS `int 0x10`:

```asm
.code16
    mov $msg, %si
    mov $0x0e, %ah
loop:
    lodsb
    or %al, %al
    jz halt
    int $0x10
    jmp loop
halt:
    hlt
msg:
    .asciz "hello world"
```

El script del linker `link.ld` define la estructura del binario final:

```ld
SECTIONS
{
    . = 0x7c00;
    .text :
    {
        __start = .;
        *(.text)
        . = 0x1FE;
        SHORT(0xAA55)
    }
}
```

---

#### 2.3 ¿Qué es la dirección 0x7C00 y por qué es necesaria?

La dirección `0x7C00` es la ubicación fija en memoria donde la BIOS carga el sector 
de arranque (bootloader) al iniciar el sistema. Esta convención existe desde los 
primeros IBM PC y se mantiene por compatibilidad.

Es necesario indicársela al linker porque este debe calcular las direcciones absolutas 
de todos los símbolos del programa. Por ejemplo, en nuestro código el label `msg` 
apunta al string "hello world". Si el linker no sabe que el programa va a estar en 
`0x7C00`, calculará direcciones incorrectas y el programa fallará al intentar acceder 
al string.

En nuestro caso, el linker calculó que `msg` queda en `0x7C0F` 
(`0x7C00 + 0x0F = 0x7C0F`), lo cual se verificó en la comparación objdump vs hd.

---

#### 2.4 Compilación y linkeo

```bash
cd 01HelloWorld
as -g -o main.o main.S
ld --oformat binary -o main.img -T link.ld main.o
```
---

#### 2.5 Ejecución en QEMU

```bash
qemu-system-x86_64 -hda main.img
```

![alt text](ImagenesLink/QEMU_helloworld.jpeg)

La ejecución en QEMU fue exitosa, mostrando el mensaje "hello world" en pantalla 
luego del mensaje "Booting from Hard Disk...".

---

#### 2.6 Comparación objdump vs hd

Se compararon las salidas de ambas herramientas para verificar la ubicación del 
programa dentro de la imagen:

```bash
objdump -b binary -m i8086 -D main.img | head -30
hd main.img | head -20
```
![alt text](ImagenesLink/salida_objdump.png)
![alt text](ImagenesLink/salida_hd.png)


**Análisis de la comparación:**

Ambas herramientas muestran el mismo contenido desde perspectivas distintas:

- `hd` muestra los bytes crudos en hexadecimal tal como están en el archivo binario,
  sin ninguna interpretación.
- `objdump` toma esos mismos bytes y los desensambla, interpretándolos como 
  instrucciones x86.

Los puntos verificados fueron:

- **El programa comienza en el offset 0x00:** el primer byte `0xBE` corresponde a la 
  instrucción `mov $0x7c0f, %si`, confirmando que el código fue colocado al inicio 
  del sector.
- **El string "hello world" está en el offset 0x0F:** los bytes 
  `68 65 6c 6c 6f 20 77 6f 72 6c 64` corresponden exactamente a los caracteres 
  ASCII de "hello world". El linker calculó correctamente la dirección `0x7C0F` 
  (`0x7C00 + 0x0F`).
- **La firma MBR está al final:** `hd` muestra `55 AA` en el offset `0x1FE` 
  (bytes 510-511), confirmando que el linker colocó correctamente la firma de 
  booteo requerida por la BIOS.

---

#### 2.7 ¿Para qué se utiliza la opción --oformat binary?

La opción `--oformat binary` le indica al linker que el archivo de salida debe ser 
un binario puro, es decir, únicamente los bytes del programa sin ningún encabezado 
ni metadata adicional.

Sin esta opción, el linker generaría por defecto un archivo en formato ELF 
(Executable and Linkable Format), que incluye encabezados, tablas de símbolos y 
otras estructuras que el sistema operativo usa para cargar el programa. Sin embargo, 
la BIOS no entiende ELF — ella simplemente lee los primeros 512 bytes del disco y 
los ejecuta directamente. Por eso es imprescindible usar `--oformat binary` para 
obtener una imagen que la BIOS pueda ejecutar.

---

#### 2.8 Grabación en pendrive y prueba en hardware real

La imagen fue grabada en un pendrive Kingston DT 101 G2 utilizando el comando:

```bash
sudo dd if=main.img of=/dev/sdb bs=512 count=1
```

![alt text](ImagenesLink/grabado_pen.png)

Al bootear desde el pendrive en una PC real (Asus VivoBook con Windows 11), 
la BIOS reconoció correctamente el sector de arranque y ejecutó el bootloader. 
Sin embargo, la interrupción de BIOS `int 0x10` utilizada para mostrar texto 
no funcionó en el hardware moderno debido a las restricciones del firmware UEFI, 
que en equipos modernos no implementa completamente las interrupciones de BIOS 
legacy en el modo de compatibilidad. El comportamiento correcto fue verificado 
exitosamente en QEMU.

![alt text](ImagenesLink/pen_to_PC.jpeg)
