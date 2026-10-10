lea     eax, [eax + eax*4]    ; EAX = EAX * 5 (по модулю 2^32)
lea     eax, [eax + ebx*8]    ; EAX = EAX + EBX * 8 (по модулю 2^32)
