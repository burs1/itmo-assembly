mov     eax, dword [rdi]  ; первое число
mov     ecx, dword [rsi]  ; второе число
mov     edx, eax
add     eax, ecx          ; EAX = сумма
sub     edx, ecx          ; EDX = разность (первое − второе)
