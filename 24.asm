; Напишите программу, копирующую нуль-терминированную строку по адресу RSI
; в память по адресу RDI. Используйте LODSB и STOSB.
;
; https://cs.itmo.ru/courses/51/modules/207/tasks/1011

    cld

.copy:
    lodsb
    stosb
    test    al, al
    jnz     .copy
