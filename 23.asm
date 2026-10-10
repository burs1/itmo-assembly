; Напишите программу, перемножающую две матрицы чисел с плавающей точкой
; одинарной точности размером 4x4 при помощи SIMD инструкций и помещающую
; результат в указанную область памяти. Адреса матриц для перемножения
; передаются в регистрах RDI и RSI, адрес памяти для помещения результата
; вычислений - в регистре RDX.
; Число с плавающей точкой одинарной точности занимает 4 байта в памяти.
; Матрицы располагаются в памяти как одномерные массивы (4 элемента по 4
; четырехбайтовых числа первой строки, 4 элемента по 4 четырехбайтовых числа
; второй строки, ...). Итого одна 4x4 матрица занимает в памяти 64 байта.
;
; https://cs.itmo.ru/courses/51/modules/207/tasks/1010

%macro MULT_ROW 2
    movups  xmm0, [rdi + %1]       ; строка матрицы A

    movaps  xmm1, xmm0
    shufps  xmm1, xmm1, 0          ; broadcast A[i][0]
    movups  xmm2, [rsi]
    mulps   xmm1, xmm2

    movaps  xmm4, xmm0
    shufps  xmm4, xmm4, 0x55       ; broadcast A[i][1]
    movups  xmm2, [rsi + 16]
    mulps   xmm4, xmm2
    addps   xmm1, xmm4

    movaps  xmm4, xmm0
    shufps  xmm4, xmm4, 0xaa       ; broadcast A[i][2]
    movups  xmm2, [rsi + 32]
    mulps   xmm4, xmm2
    addps   xmm1, xmm4

    movaps  xmm4, xmm0
    shufps  xmm4, xmm4, 0xff       ; broadcast A[i][3]
    movups  xmm2, [rsi + 48]
    mulps   xmm4, xmm2
    addps   xmm1, xmm4

    movups  [rdx + %2], xmm1       ; сохранить строку результата
%endmacro

    MULT_ROW 0, 0
    MULT_ROW 16, 16
    MULT_ROW 32, 32
    MULT_ROW 48, 48
