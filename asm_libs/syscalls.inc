%ifndef SYSCALLS_PROTECT
%define SYSCALLS_PROTECT

%macro call_exit 1
  mov rdi, %1
  mov rax, 60 
  syscall
%endmacro

%macro call_open 2
  mov rdi, %1
  mov rsi, %2
  mov rax, 2
  syscall
%endmacro

%macro call_close 1
    mov rdi, %1
    mov rax, 3
    syscall
%endmacro

%macro call_read 3
  mov rdi, %1
  mov rsi, %2
  mov rdx, %3
  mov rax, 0
  syscall
%endmacro

%macro call_write 3
  mov rdi, %1
  mov rsi, %2
  mov rdx, %3
  mov rax, 1
  syscall
%endmacro

%endif
