; Напишите код, умножающий число, переданное в регистре RDI на 13.
; Запрещено использовать LEA / любые арифметические операции.
; Результат должен остаться в регистре RDI.
;
; https://cs.itmo.ru/courses/51/modules/179/tasks/908

    mov     r8, rdi
    mov     r9, rdi
    shl     r9, 2              ; 4 * RDI
    mov     r10, rdi
    shl     r10, 3             ; 8 * RDI
    mov     rax, r8            ; начальное значение суммы

; Сложение через XOR и переносы, без арифметических инструкций
    mov     r11, r9
.add_four:
    mov     rcx, rax
    and     rcx, r11
    xor     rax, r11
    shl     rcx, 1
    mov     r11, rcx
    test    r11, r11
    jnz     .add_four

    mov     r11, r10
.add_eight:
    mov     rcx, rax
    and     rcx, r11
    xor     rax, r11
    shl     rcx, 1
    mov     r11, rcx
    test    r11, r11
    jnz     .add_eight

    mov     rdi, rax
