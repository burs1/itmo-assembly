; Поменяйте значения регистров RDI и RSI используя только инструкцию XOR.
;
; https://cs.itmo.ru/courses/51/modules/179/tasks/905

    xor     rdi, rsi
    xor     rsi, rdi
    xor     rdi, rsi
