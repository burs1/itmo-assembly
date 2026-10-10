movsxd  rax, eax
movsxd  rbx, ebx

lea     rdx, [rax + rax*2]   ; RDX = EAX * 3
lea     rcx, [rbx + rbx]     ; RCX = EBX * 2
sub     rdx, rcx             ; RDX = EAX*3 - EBX*2
