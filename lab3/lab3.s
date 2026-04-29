default rel

%include "loop.inc"
%include "syscalls.inc"

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
cerr  equ 2
ln    equ 10
space equ 32
O_RDONLY equ 0
BUFFER_SIZE equ 4096

EACCES equ -13
EEXIST equ -2
EISDIR equ -21

section .data
  ; File error segment
  file_error: db "Could not open a file", ln
  file_error_length equ $ - file_error

  ; Wrong parameters error segment  
  parameters_error: db "Given wrongs parameters", ln
  parameters_error_length equ $ - parameters_error   

  ; Existance error
  non_exist_error: db "File not exist", ln
  non_exist_error_length equ $ - non_exist_error   

  ; Is directory error 
  is_dir_error: db "File is directory", ln
  is_dir_error_length equ $ - is_dir_error

  ; Don't have permisions 
  access_error: db "Don't have access to file", ln
  access_error_length equ $ - access_error

section .bss
  read_buffer:  resb BUFFER_SIZE
  write_buffer: resb BUFFER_SIZE 

section .text 
global _start

_start: 
  cmp [rsp], 2
  jne exit_parammeters_error

  ; Opening file and checking it
  call_open [rsp + 16], O_RDONLY 
  
  cmp rax, EEXIST
  je non_exist_error
  
  cmp rax, EACCES
  je exit_access_error

  cmp rax, 0
  jl exit_file_error

  mov file, rax

  call_read file, read_buffer, BUFFER_SIZE  
  mov read_cnt, rax 

  cmp rax, 0
  jl exit_file_error

  xor write_cnt, write_cnt
  xor killer_symbol, killer_symbol

  while read_cnt, a, 0         ; While there is still symbols in the file and no error occured.
    
    xor rbx, rbx               ; File pointer that reads full buffer char by char.
    while rbx, l, read_cnt     ; While end of the buffer was not reached.
    
      if write_cnt, e, BUFFER_SIZE
        call_write cout, write_buffer, BUFFER_SIZE
        xor write_cnt, write_cnt
      fi

      mov char, [read_buffer + rbx]
      if char, e, ln 
        xor killer_symbol, killer_symbol
        mov byte [write_buffer + write_cnt], ln
        inc write_cnt
      elif char, le, space 
        ;if is_word, e, correct_word  cmp rax, EEXIST
  je non_exist_error
  
  cmp rax, EACCES
  je access_error


        ;fi
        mov is_word, not_a_word 
      elif killer_symbol, e, 0
        mov killer_symbol, char
        mov byte [write_buffer + write_cnt], killer_symbol
        inc write_cnt
        mov is_word, correct_word
      elif is_word, e, not_a_word
         
        if char, ne, killer_symbol
          mov is_word, wrong_word
        else
          mov byte [write_buffer + write_cnt], space
          inc write_cnt
          mov [write_buffer + write_cnt], char
          inc write_cnt
          mov is_word, correct_word
        fi
      elif is_word, e, correct_word
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
  call_close file 
  call_exit 0

exit_parammeters_error:
  call_write cerr, parameters_error, parameters_error_length
  call_exit 1 

exit_file_error: 
  call_write cerr, file_error, file_error_length
  call_exit 2

exit_access_error:
  call_write cerr, access_error, access_error_length
  call_exit 3

exit_non_exist_error: 
  call_write cerr, non_exist_error, non_exist_error_length
  call_exit 4

exit_is_dir_error:
  call_write cerr, is_dir_error, is_dir_error_length
  call_exit 5
