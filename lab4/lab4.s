default rel

extern fopen
extern fclose
extern printf
extern fprintf
extern scanf
extern exit
extern cos

%define acc   xmm4
%define ans   xmm3
%define x     xmm2
%define elem  xmm1
%define n     r14
%define file  r13

section .data
x_invite: db "Enter x: ", 0
acc_invite: db "Enter calculationa accuracy: ", 0

int_input_format: db "%d%c", 0
double_input_format: db "%lf%c", 0

lib_ans_format:     db "(Lib):     cos(%.3lf)^2 = %.10lf", 10, 0
counted_ans_format: db "(Counted): cos(%.3lf)^2 = %.10lf", 10, 0

write_elem_format: db "%d: %.10lf", 10, 0 

write_path:  db "./files/row.txt", 0
open_format: db "w", 0

one_double: dq  1.0
minus_one_double: dq -1.0
mul_step:   dq -4.0
second_double: dq 2.0
pi: dq 3.14159265358979323846

wrong_input_error_msg: db "Wrong input fotmat was given!", 10, 0
incorrect_input_error_msg: db "Incorrect input was given!", 10, 0
file_error_msg: db "Error with file opening!", 10, 0

section .bss

x_buffer: resq 1
raw_x_buffer: resq 1
acc_buffer: resq 1
ans_buffer: resq 1
elem_buffer: resq 1
char_buffer: resb 1

section .text
global main

main:
  push rbp
  mov rbp, rsp
  push r13
  push r14

  ; Opening file for writing 
  mov rdi, write_path
  mov rsi, open_format
  call fopen

  test rax, rax
  jz .file_error

  mov file, rax

  ; Start input reading
  ; Read x value
  mov rdi, x_invite
  xor rax, rax
  call printf

  mov rdi, double_input_format
  mov rsi, x_buffer
  mov rdx, char_buffer
  xor rax, rax
  call scanf

  test rax, rax
  jz .wrong_input

  cmp byte [char_buffer], 10
  jne .wrong_input

  ; Read acc value
  mov rdi, acc_invite
  xor rax, rax
  call printf

  mov rdi, double_input_format
  mov rsi, acc_buffer
  mov rdx, char_buffer
  xor rax, rax
  call scanf

  test rax, rax
  jz .wrong_input

  cmp byte [char_buffer], 10
  jne .wrong_input

  movsd x,   [x_buffer]
  movsd [raw_x_buffer], x
  movsd acc, [acc_buffer]

  xorpd xmm6, xmm6
  ucomisd acc, xmm6

  jle .incorrect_input

  ; Finish reading, ready to calculations
  ; Preparing x, by divisioning on Pi
  movsd xmm0, x
  divsd xmm0, [pi]
  cvtsd2si rax, xmm0
  cvtsi2sd xmm0, rax
  mulsd xmm0, [pi]
  subsd x, xmm0

  movsd [x_buffer], x

  ; Count first 2 elem

  mov rdi, file
  mov rsi, write_elem_format
  mov rdx, 1
  mov rax, 1
  movsd xmm0, [one_double]
  call fprintf

  movsd x, [x_buffer]

  mov rdi, file
  mov rsi, write_elem_format
  mov rdx, 2
  mov rax, 1
  movsd xmm0, [minus_one_double]
  mulsd xmm0, x
  mulsd xmm0, x
  call fprintf

  movsd x, [x_buffer]
  movsd ans, [one_double]

  movsd elem, [minus_one_double]
  mulsd elem, x
  mulsd elem, x

  addsd ans, elem
  mov n, 2

  movsd [ans_buffer], ans
  movsd [elem_buffer], elem

  .calc_loop:
    ; Save previous elem state
    mulsd elem, [mul_step]
    mulsd elem, x
    mulsd elem, x

    cvtsi2sd xmm0, n
    mulsd xmm0, [second_double]
    divsd elem, xmm0
    addsd xmm0, [minus_one_double]
    divsd elem, xmm0

    addsd ans, elem
    add n, 1

    movsd [ans_buffer],  ans
    movsd [elem_buffer], elem

    mov rdi, file
    mov rsi, write_elem_format
    mov rdx, n
    mov rax, 1
    movsd xmm0, elem
    call fprintf

    movsd ans,  [ans_buffer]
    movsd elem, [elem_buffer]
    movsd x,    [x_buffer]
    movsd acc,  [acc_buffer]

    movsd xmm5, elem
    xorpd xmm6, xmm6
    ucomisd xmm5, xmm6
    jae .dif_pos
    mulsd xmm5, [minus_one_double]

  .dif_pos:
    ucomisd xmm5, acc
    ja .calc_loop

.ans:
  mov rdi, counted_ans_format
  movsd xmm0, [raw_x_buffer]
  movsd xmm1, ans
  mov rax, 2
  call printf

  movsd xmm0, [raw_x_buffer]
  call cos
  mulsd xmm0, xmm0

  mov rdi, lib_ans_format
  movsd xmm1, xmm0
  movsd xmm0, [raw_x_buffer]
  mov rax, 2
  call printf

  mov rdi, file
  call fclose

  mov rdi, 0
  jmp .exit

.wrong_input:
  mov rdi, wrong_input_error_msg 
  call printf

  mov rdi, 1
  jmp .exit

.incorrect_input:
  mov rdi, incorrect_input_error_msg
  call printf

  mov rdi, 2
  jmp .exit

.file_error: 
  mov rdi, file_error_msg
  call printf

  mov rdi, 3
  jmp .exit

.exit:
  pop r14
  pop r13
  pop rbp

  call exit
