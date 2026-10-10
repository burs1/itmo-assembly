; Напишите программу, выполняющую пузырьковую сортировку по возрастанию поданного на вход
; массива 32 битных знаковых чисел. Адрес начала массива передан в регистре RDI,
; длина массива - в регистре RCX. Отсортированный массив должен располагаться там же,
; где располагался исходный массив.
;
; https://cs.itmo.ru/courses/51/modules/178/tasks/901
bubble_sort:
    cmp     rcx, 1
    jbe     .done

    dec     rcx
    mov     r8, rcx

.outer:
    mov     r9, rdi
    mov     r10, r8

.inner:
    mov     eax, [r9]
    mov     edx, [r9 + 4]
    cmp     eax, edx
    jle     .no_swap

    mov     [r9], edx
    mov     [r9 + 4], eax

.no_swap:
    add     r9, 4
    dec     r10
    jnz     .inner

    dec     r8
    jnz     .outer

.done:
    ; Не выполнять ret: для пустого массива выполнение заканчивается здесь.

