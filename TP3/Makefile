ASM = nasm
ASMFLAGS = -f bin

TARGET = bootloader.img
SRC = modoprotegido.asm

QEMU = qemu-system-i386
QEMUFLAGS = -fda $(TARGET) -boot a -no-reboot -d int

all: $(TARGET)

$(TARGET): $(SRC)
	$(ASM) $(ASMFLAGS) -o $(TARGET) $(SRC)

run: all
	$(QEMU) $(QEMUFLAGS)

clean:
	rm -f $(TARGET)

.PHONY: all run clean 