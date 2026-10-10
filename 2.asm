section .data
    text db "0123456789ABCDEFGHIJKLMNOPQRSTUV", 0

section .text
    global _start
_start:
    ; На входе: RDI = n, 0 <= n <= 31
    lea     rax, [rel text]        ; RAX = адрес строки
    movzx   ebx, byte [rax + rdi]  ; RBX = код символа с индексом n

