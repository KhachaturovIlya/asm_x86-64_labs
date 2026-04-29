%define ROWS_COUNT 4
%define COLUMNS_COUNT 5
%define COLUMN_OFFSET COLUMNS_COUNT * 4
  
  matrix: 
    db ROWS_COUNT
    db COLUMNS_COUNT
    align 4
  matrix_data:
    dd 5,   52, -5,   25,  -12
    dd 32,  44, -334, 324, -11
    dd -25, 24, 43,   34,  3
    dd 53,  44, 34,   24,  4
  matrix_end:
