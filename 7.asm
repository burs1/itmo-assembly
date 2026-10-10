mov     eax, eax      ; RAX = zero-extended EAX
mov     ebx, ebx      ; RBX = zero-extended EBX
imul    rax, rbx      ; RAX = EAX * EBX (произведение помещается в 64 бита)
xor     edx, edx      ; делимое для div rcx — RDX:RAX
mov     ecx, 10
div     rcx            ; остаток в RDX
