%ifndef PRINT_PROTECT
%define PRINT_PROTECT

global print_signed_number, print_nl, print_space

%include "loop.inc"

section .rodata

nl:    db 10 ; '\n'
space: db 32 ; ' '
zero:  db 48 ; '0'

section .bss

buffer: resb 64
endbuffer:

section .text

print_signed_number: 
  test rdi, rdi
  jnz .good_start

  mov rax, 1
  mov rdi, 1
  mov rsi, zero
  mov rdi, 1

.good_start: 
  mov rax, rdi
  xor rcx, rcx
  
  mov r8, rax

  mov rsi, 10
  mov rdi, endbuffer
  
  while rax, ne, 0
    dec rdi

    cqo
    idiv rsi
    test rdx, rdx
    jns .positive
    neg rdx

.positive: 
    add rdx, 48 ; transform to char
     
    mov [rdi], dl
    inc rcx
  endwhile

  test r8, r8
  jns .positive_num
  
  dec rdi
  mov [rdi], 45  ; Write '-' 
  inc rcx

.positive_num:

  mov rax, 1
  mov rdi, 1
  
  mov rsi, endbuffer
  sub rsi, rcx 
  
  mov rdx, rcx
  
  syscall

.end:
  ret

print_nl: 
  mov rax, 1
  mov rdi, 1
  mov rsi, nl
  mov rdx, 1

  syscall
  ret 

print_space:
  mov rax, 1
  mov rdi, 1
  mov rsi, space
  mov rdx, 1

  syscall
  ret

%endif
