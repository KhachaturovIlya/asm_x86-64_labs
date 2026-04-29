%define first_sum  r10
%define second_sum r11
%define third_sum  r12

default rel

section .rodata
a: dd 15351
b: dd 11423
c: dq 0x7FFFFFFFFFFFFFFF
d: dw 5341
e: db -32

section .data
ans: dq 0

section .text
global _start

_start: 
  ; Zero precheck 
  
  cmp dword [a], 0     
  je zero_division_error
  
  cmp dword [b], 0 
  je zero_division_error

  cmp word [d], 0  
  je zero_division_error

  cmp byte [e], 0
  je zero_division_error 

  ; Count first sum element: (a * c) / b 
  
  movsxd rax, [a]
    
  mov r8, [c]

  imul rax, r8
  
  jo overflow_error
  
  movsxd r8, [b]
  
  cqo
       
  idiv r8
  
  mov first_sum, rax
  
  ; Count second element: (b * d) / e 
  
  movsx rax, word [d]
  
  imul rax, r8 ; No need to check overflow dword * word < qword
  
  movsx r8, byte [e]
  
  cqo
  
  idiv r8
    
  mov second_sum, rax 

  ; Count third element: (c * c) / (a * d)  
  
  mov rax, [c]
  
  imul rax, rax
  
  jo overflow_error
  
  movsx r8, dword [a] 
  
  cqo
  
  idiv r8
  
  movsx r8, word [d]
  
  cqo
  
  idiv r8

  mov third_sum, rax

  ; Ending programm

  mov [ans], first_sum
  
  add [ans], second_sum
  
  jo overflow_error

  sub [ans], third_sum

  jo overflow_error

  ; Lol, new comment

  mov rax, 60
  xor rdi, rdi
  syscall
  
overflow_error: 
  
  mov rax, 60
  mov rdi, 1
  syscall
  
zero_division_error: 

  mov rax, 60
  mov rdi, 2
  syscall
