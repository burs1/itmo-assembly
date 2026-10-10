; В регистре RDI передан адрес нуль-терминированной строки.
; Поместите результат инвертирования этой строки по адресу, переданному в регистре RSI.
;
; https://cs.itmo.ru/courses/51/modules/178/tasks/902
xor     rcx, rcx

; Найти длину строки
.find_end:
    cmp     byte [rdi + rcx], 0
    je      .found_end
    inc     rcx
    jmp     .find_end

.found_end:
    test    rcx, rcx
    jz      .empty

    dec     rcx

; Копировать символы с конца строки
.copy:
    mov     al, [rdi + rcx]
    mov     [rsi], al
    inc     rsi

    test    rcx, rcx
    jz      .terminate
    dec     rcx
    jmp     .copy

.empty:
.terminate:
    mov     byte [rsi], 0
