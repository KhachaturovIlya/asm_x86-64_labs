%ifndef LOOP_PROTECT
%define LOOP_PROTECT

%macro while 3
  %push while_context
  %$begin:
    cmp %1, %3
    j%-2 %$end
%endmacro

%macro while_and 0
  %push while_context
  %$begin: 
%endmacro

%macro endwhile 0
    jmp %$begin
  %$end:
  %pop while_context
%endmacro

%macro check_and 3
  cmp %1, %3
  j%-2 %$end
%endmacro

%macro do 0
%endmacro

%macro if 3 
  %push if_context
  %assign %$if_counter 0
  cmp %1, %3
  j%-2 %$nif_0
%endmacro

%macro elif 3
  jmp %$end_if
  %$nif_%[%$if_counter]:
  %assign %$if_counter %$if_counter + 1
  cmp %1, %3
  j%-2 %$nif_%[%$if_counter]
%endmacro

%macro else 0
  jmp %$end_if
  %$nif_%[%$if_counter]:
  %assign %$if_counter %$if_counter + 1
%endmacro

%macro fi 0 
  %$nif_%[%$if_counter]:
  %$end_if: 
  %pop if_context
%endmacro

%endif
