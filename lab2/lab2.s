default rel

%ifndef SORT_ASCENDING
  %define SORT_ASCENDING 1
%endif 

%define offset r8
%define step   r11

%include "../asm_libs/loop.s"     ; Import loop macro 
%include "../asm_libs/syscalls.s" ; Import syscalls.macro

section .rodata
  ascending: db SORT_ASCENDING

section .data 
  tmp: db 0

  %include MATRIX_FILE  ; Inserting out matrix

  COLUMNS_ARRAY:
    %assign i 0 
    %rep COLUMNS_COUNT
      db i 
      %assign i i+1 
    %endrep

  align 4

  SUM_ARRAY: times COLUMNS_COUNT dq 0 

section .text
global _start

_start:
  ; Parameters precheck

  mov r9, COLUMNS_COUNT
  test r9, r9
  jz wrong_parameters_error

  mov r9, ROWS_COUNT
  test r9, r9
  jz wrong_parameters_error

  ; Accumulating sums of columns 

  mov rcx, COLUMNS_COUNT
  while rcx, a, 0 

    ; Getting column sorted position from array 
    lea r9, [rcx - 1]
    mov r9b, [COLUMNS_ARRAY + r9]
    movzx r9, r9b

    mov rdx, ROWS_COUNT
    while rdx, a, 0
      
      ; Counting offset
      mov offset, matrix_data
      
      lea r10, [rdx - 1]
      imul r10, COLUMN_OFFSET 
       
      lea offset, [offset + r10] 
      lea offset, [offset + r9 * 4]

      ; Saving from wrong memmory adressing
      cmp offset, matrix_end
      jae wrong_parameters_error

      ; Adding sum
      mov eax, [offset]    
      cdqe 
      add [SUM_ARRAY + r9 * 8], rax

      dec rdx
    endwhile

    dec rcx
  endwhile

  ; All registers are free
  ; Finish accumulating, start sorting 
  ; Preparing step
  mov step, COLUMNS_COUNT
  shr step, 1

  while step, a, 0 
    mov rcx, step    ; rcx = i 
    
    while rcx, l, COLUMNS_COUNT
      mov r8,  [SUM_ARRAY + rcx * 8] ; Saving tmp for swaping SUM_ARRAY 
      mov r9b, [COLUMNS_ARRAY + rcx] ; Saving tmp for swaping COLUMNS_ARRAY

      mov rbx, rcx   ; rbx = j

      mov rdx, rbx   ; Preparing
      sub rdx, step  ; offset

      mov rdi,  [SUM_ARRAY + rdx * 8] 
      mov r10b, [COLUMNS_ARRAY + rdx]

      while_and 
        check_and rbx, ae, step
        
        %if SORT_ASCENDING == 1
          check_and rdi, g, r8
        %else  
          check_and rdi, l, r8 
        %endif
      
      do 
        mov [SUM_ARRAY + rbx * 8], rdi  
        mov [COLUMNS_ARRAY + rbx], r10b

        sub rbx, step
        sub rdx, step 
        
        mov rdi, [SUM_ARRAY + rdx * 8]
        mov r10b, [COLUMNS_ARRAY + rdx]
      endwhile

      mov [SUM_ARRAY + rbx * 8], r8
      mov [COLUMNS_ARRAY + rbx], r9b

      inc rcx
    endwhile
    
    shr step, 1
  endwhile

exit: 
  call_exit 0

wrong_parameters_error: 
  call_exit 1

overflow_error: 
  call_exit 2
