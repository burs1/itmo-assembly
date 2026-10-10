; Напишите программу, находящую первое вхождение символа (передается в RSI),
; в строке, адрес которой передан в RDI, и помещающую его индекс
; (индексация начинается с 0) в RAX (если символ не найден, поместите
; в RAX -1). Используйте инструкцию SCAS.
;
; https://cs.itmo.ru/courses/51/modules/207/tasks/1012

    test    sil, sil
    jz      .not_found          ; нулевой байт — конец строки, не символ строки

    mov     al, sil
    xor     ecx, ecx
    cld

.search:
    scasb
    je      .found
    cmp     byte [rdi - 1], 0
    je      .not_found
    inc     rcx
    jmp     .search

.found:
    mov     rax, rcx
    jmp     .done

.not_found:
    mov     rax, -1

.done:
