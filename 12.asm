; Условие: в RDI и RSI переданы позиции битов n1 и n2 (n1, n2 <= 63).
; Проверить биты RDX на этих позициях.
; Если оба бита равны 1, поместить в RAX 1, иначе — 0.
;
; https://cs.itmo.ru/courses/51/modules/179/tasks/903

    mov     rax, rdx
    mov     rcx, rdi
    shr     rax, cl
    and     eax, 1            ; бит n1 в AL

    mov     r8, rdx
    mov     rcx, rsi
    shr     r8, cl
    and     r8d, 1            ; бит n2 в R8B

    and     eax, r8d          ; 1 только если оба бита равны 1
