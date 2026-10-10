; Напишите программу, читающую из stdin <= 1024 байт пользовательского ввода,
; печатающую введенную строку в stdout, и завершающуюся с кодом 0.
;
; https://cs.itmo.ru/courses/51/modules/181/tasks/912

global _start

section .bss
buffer: resb 1024

section .text
_start:
    mov     eax, 0              ; sys_read
    xor     edi, edi            ; stdin
    mov     rsi, buffer
    mov     edx, 1024
    syscall

    test    rax, rax
    jle     .exit               ; EOF или ошибка чтения

    mov     r8, rax             ; сколько байт осталось вывести
    mov     rsi, buffer

.write:
    mov     eax, 1              ; sys_write
    mov     edi, 1              ; stdout
    mov     rdx, r8
    syscall

    test    rax, rax
    jle     .exit               ; ошибка или невозможность продолжить
    add     rsi, rax
    sub     r8, rax
    jnz     .write

.exit:
    mov     eax, 60             ; sys_exit
    xor     edi, edi            ; код завершения 0
    syscall
