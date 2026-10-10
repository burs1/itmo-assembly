; Напишите программу, читающую из stdin названия двух файлов
; (на вход подаются имена файлов в виде filename_1\nfilename2\n),
; меняющую местами содержимое этих файлов, и завершающуюся с кодом 0.
; Гарантируется, что каждый из файлов <= 65535 байт.
;
; https://cs.itmo.ru/courses/51/modules/181/tasks/913

global _start

section .bss
name1:   resb 4096
name2:   resb 4096
bytebuf: resb 1
data1:   resb 65535
data2:   resb 65535

section .text
_start:
    mov     rdi, name1
    call    read_name
    mov     rdi, name2
    call    read_name

    ; Открыть оба файла для чтения и записи
    mov     eax, 2              ; sys_open
    mov     rdi, name1
    mov     esi, 2              ; O_RDWR
    xor     edx, edx
    syscall
    test    rax, rax
    js      exit
    mov     r12, rax

    mov     eax, 2
    mov     rdi, name2
    mov     esi, 2
    xor     edx, edx
    syscall
    test    rax, rax
    js      exit
    mov     r13, rax

    ; Прочитать содержимое обоих файлов
    mov     rdi, r12
    mov     rsi, data1
    call    read_file
    mov     r14, rax

    mov     rdi, r13
    mov     rsi, data2
    call    read_file
    mov     r15, rax

    ; Очистить оба файла
    mov     eax, 77             ; sys_ftruncate
    mov     rdi, r12
    xor     esi, esi
    syscall

    mov     eax, 77
    mov     rdi, r13
    xor     esi, esi
    syscall

    ; Переместить файловые указатели в начало
    mov     eax, 8              ; sys_lseek
    mov     rdi, r12
    xor     esi, esi            ; offset = 0
    xor     edx, edx            ; SEEK_SET
    syscall

    mov     eax, 8
    mov     rdi, r13
    xor     esi, esi
    xor     edx, edx
    syscall

    ; Записать содержимое второго файла в первый
    mov     rdi, r12
    mov     rsi, data2
    mov     rdx, r15
    call    write_file

    ; Записать содержимое первого файла во второй
    mov     rdi, r13
    mov     rsi, data1
    mov     rdx, r14
    call    write_file

    mov     eax, 3              ; sys_close
    mov     rdi, r12
    syscall

    mov     eax, 3
    mov     rdi, r13
    syscall

exit:
    mov     eax, 60             ; sys_exit
    xor     edi, edi
    syscall

; Читает имя файла до пробела, перевода строки или конца ввода.
; Вход: RDI — адрес буфера.
read_name:
    mov     r9, rdi
    xor     r8, r8

.read_char:
    xor     eax, eax            ; sys_read
    xor     edi, edi            ; stdin
    mov     rsi, bytebuf
    mov     edx, 1
    syscall
    test    rax, rax
    jle     .name_done

    cmp     byte [bytebuf], 32  ; пробел
    je      .name_done
    cmp     byte [bytebuf], 10  ; перевод строки
    je      .name_done

    mov     al, [bytebuf]
    mov     [r9 + r8], al
    inc     r8
    jmp     .read_char

.name_done:
    mov     byte [r9 + r8], 0
    ret

; Вход: RDI — файловый дескриптор, RSI — буфер.
; Выход: RAX — количество прочитанных байт.
read_file:
    mov     r8, rdi
    mov     r9, rsi
    xor     r10, r10

.read_more:
    xor     eax, eax            ; sys_read
    mov     rdi, r8
    lea     rsi, [r9 + r10]
    mov     rdx, 65535
    sub     rdx, r10
    syscall
    test    rax, rax
    jle     .read_done

    add     r10, rax
    cmp     r10, 65535
    jb      .read_more

.read_done:
    mov     rax, r10
    ret

; Вход: RDI — файловый дескриптор, RSI — буфер, RDX — длина.
write_file:
    mov     r8, rdi
    mov     r9, rsi
    mov     r10, rdx

.write_more:
    test    r10, r10
    jz      .write_done

    mov     eax, 1              ; sys_write
    mov     rdi, r8
    mov     rsi, r9
    mov     rdx, r10
    syscall
    test    rax, rax
    jle     .write_done

    add     r9, rax
    sub     r10, rax
    jmp     .write_more

.write_done:
    ret
