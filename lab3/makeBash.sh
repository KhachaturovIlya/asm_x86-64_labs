#!/bin/bash

mkdir -p build

nasm -g -i ../asm_libs/ -f elf64 lab3.s -o build/lab3.o 

ld build/lab3.o "../asm_libs/bin/print.o" -o build/lab3
