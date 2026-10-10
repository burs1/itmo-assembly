; Напишите программу, выводящую в stdout строку "Hello, world!"
; и завершающуюся с кодом 0.
;
; https://cs.itmo.ru/courses/51/modules/181/tasks/910

global _start

section .data
message: db "Hello, world!"

section .text
_start:
    mov     eax, 1              ; sys_write
    mov     edi, 1              ; stdout
    mov     rsi, message
    mov     edx, 13
    syscall

    mov     eax, 60             ; sys_exit
    xor     edi, edi            ; код завершения 0
    syscall
