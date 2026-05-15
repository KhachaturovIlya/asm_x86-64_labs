TARGET = main
CC     = gcc
AS     = nasm
ASFLAGS = -f elf64 -g

MY_CFLAGS = -g -Wall -Wextra -fsanitize=address
LDFLAGS   = -fsanitize=address

override CFLAGS += $(MY_CFLAGS)

all: $(TARGET)

$(TARGET): main.o black_bmp_c.o
	$(CC) main.o black_bmp_c.o -o $(TARGET) $(LDFLAGS)

asm: main.o black_bmp_asm.o
	$(CC) main.o black_bmp_asm.o -o $(TARGET) $(LDFLAGS)

main.o: main.c
	$(CC) $(CFLAGS) -c $< -o $@

black_bmp_c.o: black_bmp.c
	$(CC) $(CFLAGS) -c $< -o $@

black_bmp_asm.o: black_bmp.s
	$(AS) $(ASFLAGS) $< -o $@

clean:
	rm -f main.o black_bmp_c.o black_bmp_asm.o $(TARGET)

re: clean all

re_asm: clean asm

.PHONY: clean all re asm re_asm
