; Напишите функцию, вычисляющую n-ное число фибоначчи, соответствующую
; сигнатуре int fib(int n); соглашение о вызове - x86_64 System V.
;
; https://cs.itmo.ru/courses/51/modules/180/tasks/909
global fib

section .text

fib:
    test    edi, edi
    jle     .zero

    xor     eax, eax            ; F(0)
    mov     edx, 1              ; F(1)
    mov     ecx, edi

.loop:
    mov     r8d, eax
    add     eax, edx
    mov     edx, r8d
    dec     ecx
    jnz     .loop

    ret

.zero:
    xor     eax, eax
    ret
