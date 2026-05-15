section .text
global black_bmp

; Not need to create stack frame, no stack
black_bmp:
  push r12

  ; Count and storing in rax row_size
  mov   rax, rdx
  imul  rax, rsi
  add   rax, 3
  ; To speed up could replace witn and to inv of 2
  shr   rax, 2
  shl   rax, 2

  mov   r8,  0
y_loop:

  mov   r9,  0
x_loop:

  ; Calculate pixel adress
  mov   r10,   rdi
  mov   r11,   r8
  imul  r11,   rax
  lea   r10,   [r10 + r11]
  mov   r11,   r9
  imul  r11,   rsi
  lea   r10,   [r10 + r11]

  movzx r12,   byte [r10]     ; r12 - max collour
  cmp   r12b,  [r10 + 1]
  jae   skip_1
  mov   r12b,  [r10 + 1]
skip_1:
  cmp   r12b,  [r10 + 2]
  jae   skip_2
  mov   r12b,  [r10 + 2]
skip_2:
  mov   r11b,  r12b           ; r11 - new collour power (now storing max)

  movzx r12,   byte [r10]     ; r12 - min collour
  cmp   r12b,  [r10 + 1]
  jbe   skip_3
  mov   r12b,  [r10 + 1]
skip_3:
  cmp   r12b,  [r10 + 2]
  jbe   skip_4
  mov   r12b,  [r10 + 2]
skip_4:
  movzx r11d,  r11b
  movzx r12d,  r12b
  add   r11d,  r12d
  shr   r11d,  1

  ; Find new collour, now need to apply new value
  mov   [r10],      r11b
  mov   [r10 + 1],  r11b
  mov   [r10 + 2],  r11b

  inc   r9
  cmp   r9, rdx
  jl    x_loop

  inc   r8
  cmp   r8, rcx
  jl    y_loop

  pop   r12

  ret
