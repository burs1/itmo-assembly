; Напишите функцию для подсчета суммы элементов массива, соответствующую
; сигнатуре int array_sum(int *array, int size); соглашение о вызове -
; x86_64 System V.
;
; https://cs.itmo.ru/courses/51/modules/180/tasks/907
global array_sum

section .text

array_sum:
    xor     eax, eax
    test    esi, esi
    jle     .done

.loop:
    add     eax, [rdi]
    add     rdi, 4
    dec     esi
    jnz     .loop

.done:
    ret
