# Informe del Proyecto TP3: Modo Protegido

**Materia:** Sistemas de Computación
**Alumna:** Martina Juri
**Trabajo Práctico:** TP3 – Modo Protegido x86

---

## 1. Introducción teórica

Los procesadores de la familia x86 inician siempre su ejecución en **modo real (Real Mode)** para mantener compatibilidad con arquitecturas anteriores, principalmente con el Intel 8086.

En este modo inicial, el procesador opera en **16 bits**, con capacidades limitadas:

* direccionamiento segmentado básico
* ausencia de protección de memoria
* sin multitarea por hardware
* sin memoria virtual

Para acceder a mayores prestaciones, el procesador debe evolucionar hacia **modo protegido (Protected Mode)**.

Este modo fue introducido a partir del Intel 80286 y mejorado en arquitecturas posteriores.

Las principales ventajas son:

* direccionamiento de 32 bits
* protección entre segmentos
* control de privilegios
* soporte para multitarea
* manejo de excepciones
* posibilidad de memoria virtual

---

## 2. Objetivo del trabajo práctico

El objetivo del trabajo consiste en ejecutar un bootloader en assembler que:

1. inicia en modo real
2. configura la **GDT (Global Descriptor Table)**
3. habilita el bit PE del registro `CR0`
4. realiza el salto a modo protegido
5. prueba la protección de memoria mediante un acceso inválido

---

## 3. Explicación del código implementado

El programa comienza en 16 bits:

```asm
bits 16
org 0x7C00
```

La dirección `0x7C00` corresponde a la ubicación clásica donde BIOS carga el sector de arranque.

### 3.1 Deshabilitación de interrupciones

```asm
cli
```

Se deshabilitan las interrupciones para evitar interrupciones durante la transición crítica entre modos.

### 3.2 Carga de la GDT

```asm
lgdt [descriptor_gdt]
```

Se carga el registro `GDTR`, que contiene:

* dirección base de la GDT
* tamaño total de la tabla

La GDT utilizada posee tres entradas:

* descriptor nulo
* segmento de código
* segmento de datos

### 3.3 Habilitación de modo protegido

```asm
mov eax, cr0
or eax, 0x1
mov cr0, eax
```

Se modifica el bit `PE` (Protection Enable) del registro `CR0`.

Cuando vale 1, el procesador entra en **Protected Mode**.

### 3.4 Salto lejano

```asm
jmp SEL_CODE:pm_entry
```

Este salto es obligatorio porque:

* limpia la cola de prefetch
* actualiza el registro `CS`
* comienza la ejecución en 32 bits

---

## 4. Configuración de segmentos

Una vez en modo protegido se cargan los registros de segmento:

```asm
mov ax, SEL_DATA
mov ds, ax
mov ss, ax
mov es, ax
mov fs, ax
mov gs, ax
```

En este caso:

* `CS = 0x08`
* `DS = 0x10`

Esto coincide con la salida de QEMU:

```text
CS =0008
DS =0010
```

Lo cual verifica que la GDT fue cargada correctamente.

---

## 5. Prueba de protección de memoria

El segmento de datos fue configurado como **solo lectura** mediante:

```asm
db 0x90
```

Luego el código intenta escribir:

```asm
mov [edi], eax
```

sobre la dirección `0x00100000`.

Esto constituye una **violación de permisos**.

---

## 6. Resultado de la ejecución en QEMU

La ejecución en QEMU muestra la transición exitosa a modo protegido.

Se observa:

```text
CR0=00000011
```

Esto confirma que el bit `PE` fue activado.

### Registros observados

```text
CS =0008
DS =0010
CR0=00000011
```

Esto indica:

* ejecución en segmento código
* segmento datos cargado
* modo protegido activo

---

## 7. Excepción generada

El resultado más importante es:

```text
check_exception old: 0xffffffff new 0xd
```

El valor `0x0D` corresponde a una **General Protection Fault (#GP)**.

Es decir, una excepción de protección general.

Esto ocurre porque el programa intenta escribir en un segmento configurado como solo lectura.

Luego aparece:

```text
1: v=08
```

El valor `0x08` corresponde a un **Double Fault**.

Esto sucede porque no se configuró una **IDT válida** para atender la excepción anterior.

La secuencia es:

1. ocurre `#GP`
2. no puede manejarse
3. genera `#DF`

---

## 8. Análisis técnico del resultado

El comportamiento observado es exactamente el esperado.

La secuencia fue:

1. BIOS carga bootloader
2. CPU inicia en modo real
3. se carga GDT
4. se activa PE en CR0
5. se entra en protected mode
6. se intenta escribir en segmento read-only
7. se genera `#GP`
8. al no existir handler válido → `#DF`

Esto verifica correctamente el funcionamiento de:

* segmentación
* permisos
* protección de memoria

---

## 9. Conclusión

La práctica permitió comprender el proceso de transición de los procesadores x86 desde modo real hacia modo protegido.

Se verificó experimentalmente:

* activación de `CR0`
* uso de la GDT
* carga de selectores
* protección por permisos
* generación de excepciones

El resultado obtenido en QEMU coincide con el comportamiento teórico esperado, demostrando la correcta implementación del bootloader y de los mecanismos de protección de memoria del procesador