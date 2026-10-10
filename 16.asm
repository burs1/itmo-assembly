; Напишите функцию сложения двух чисел, соответствующую сигнатуре
; int add_numbers(int a, int b); соглашение о вызове - x86_64 System V.
;
; https://cs.itmo.ru/courses/51/modules/180/tasks/906
global add_numbers

section .text

add_numbers:
    mov     eax, edi
    add     eax, esi
    ret
