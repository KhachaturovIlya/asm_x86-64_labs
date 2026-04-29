default rel

%include "loop.inc"
%include "syscalls.inc"
%include "print.inc"

%define write_cnt rbp
%define read_cnt  r12
%define is_word   r13b 
%define killer_symbol r14b
%define file r15

%define char r10b

wrong_word   equ 2
correct_word equ 1
not_a_word   equ 0

cout  equ 1
ln    equ 10
space equ 32
O_RDONLY equ 0
BUFFER_SIZE equ 4096

section .bss
  read_buffer:  resb BUFFER_SIZE
  write_buffer: resb BUFFER_SIZE 

section .text 
global _start

_start: 
  cmp [rsp], 2
  jne wrong_parammeters_error

  ; Opening file and checking it
  call_open [rsp + 16], O_RDONLY  
  cmp rax, 0
  jl wrong_parammeters_error
  mov file, rax

  call_read file, read_buffer, BUFFER_SIZE  
  mov read_cnt, rax

  xor write_cnt, write_cnt
  xor killer_symbol, killer_symbol

  while read_cnt, a, 0         ; While there is still symbols in the file and no error ocured.
    
    xor rbx, rbx               ; File pointer that reads full buffer char by char.
    while rbx, l, read_cnt     ; While end of the buffer was not reached.
    
      if write_cnt, e, BUFFER_SIZE
        call_write cout, write_buffer, BUFFER_SIZE
        xor write_cnt, write_cnt
      fi

      if byte [read_buffer + rbx], e, ln 
        xor killer_symbol, killer_symbol
        mov byte [write_buffer + write_cnt], ln
        inc write_cnt
      elif byte [read_buffer + rbx], le, space
        if is_word, e, correct_word
          mov byte [write_buffer + write_cnt], space
          inc write_cnt
        fi
        mov is_word, not_a_word 
      elif killer_symbol, e, 0
        mov killer_symbol, [read_buffer + rbx]
        mov byte [write_buffer + write_cnt], killer_symbol
        inc write_cnt
        mov is_word, correct_word
      elif is_word, e, not_a_word
        mov char, [read_buffer + rbx]
        
        if char, ne, killer_symbol
          mov is_word, wrong_word
        else
          mov [write_buffer + write_cnt], char
          inc write_cnt
          mov is_word, correct_word
        fi
      elif is_word, e, correct_word
        mov char, [read_buffer + rbx]
        mov [write_buffer + write_cnt], char 
        inc write_cnt
      fi

      inc rbx 
    endwhile 
  
    call_read file, read_buffer, BUFFER_SIZE  
    mov read_cnt, rax
  endwhile

  call_write cout, write_buffer, write_cnt

exit: 
  call_exit 0

wrong_parammeters_error:
  call_exit 1 

