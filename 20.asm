; Напишите программу, выполняющую execve("/bin/sh", "-c cat flag.txt", 0)
; и завершающуюся с кодом 0.
;
; https://cs.itmo.ru/courses/51/modules/181/tasks/911

global _start

section .data
shell:  db "/bin/sh", 0
option: db "-c", 0
command: db "cat flag.txt", 0

argv:   dq shell, option, command, 0

section .text
_start:
    mov     eax, 59             ; sys_execve
    mov     rdi, shell
    mov     rsi, argv
    xor     edx, edx            ; envp = NULL
    syscall

    ; Если execve завершился ошибкой, выйти с кодом 0
    mov     eax, 60             ; sys_exit
    xor     edi, edi
    syscall
