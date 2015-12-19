; eax - Addr
; edx - NewFunc
proc Absolute
  add eax, [edx]
  add eax, 4
  ret
endp

; eax - NewFunc
; edx - Addr
proc Relative
  sub eax, edx
  sub eax, 4
  ret
endp

; eax - Address
proc GetModuleSize
  add eax, [eax + 3Ch]
  mov eax, [eax + 50h]
  ret
endp

proc FindPattern_Internal SearchStart, SearchSize, Pattern, PatternSize
  push esi
  push edi
  push ebx

  mov edi, [SearchStart]
  mov edx, [SearchSize]
  mov eax, [Pattern]
  mov al, byte [eax]
  inc [Pattern]
  dec [PatternSize]

.Next:
  mov ecx, edx
  repne scasb
  jne .NotFound

  mov edx, ecx
  mov ecx, [PatternSize]
  mov esi, [Pattern]
  mov ebx, edi

.Cont:
  repe cmpsb
  je .Found

  cmp byte [esi - 1], 0FFh
  je .Cont

  mov edi, ebx
  jmp .Next

.NotFound:
  mov ebx, 1

.Found:
  lea eax, [ebx - 1]

  pop ebx
  pop edi
  pop esi
  ret
endp

; eax - SearchStart
; edx - SearchSize
; ecx - Address
proc FindRefCallAddr
  test eax, eax
  jz .ExitE
  test edx, edx
  jz .Exit
  test ecx, ecx
  jz .Exit

  push edi
  push ebx

  mov edi, eax
  xchg edx, ecx
  sub edx, 4
  mov al, 0E8h

.Cont:
  repne scasb
  jne .NotFound

  mov ebx, edx
  sub ebx, edi
  cmp dword [edi], ebx
  je .Found

  add edi, 4
  sub ecx, 4
  jmp .Cont

.NotFound:
  mov edi, 1

.Found:
  lea eax, [edi - 1]

  pop ebx
  pop edi

.ExitE:
  xor eax, eax
.Exit:
  ret
endp

; eax - PModule
; edx - oldFunc
; ecx - newFunc
proc HookEveryRefCall
  test edx, edx
  jz .Exit
  test ecx, ecx
  jz .Exit

  push esi ; Base
  push edi ; Size
  push ebx ; OldFunc
  push ebp ; NewFunc
  push 0   ; Result

  mov esi, [eax]
  mov edi, [eax + 4]
  mov ebx, edx
  mov ebp, ecx

.Loop:
  mov eax, esi
  mov edx, edi
  mov ecx, ebx
  call FindRefCallAddr
  test eax, eax
    jz .Break

  mov edx, ebp
  call Mem_InsertCall

  inc dword [esp]
  jmp .Loop

.Break:
  pop eax
  pop ebp
  pop ebx
  pop edi
  pop esi

.Exit:
  xor eax, eax
.ExitE:
  ret
endp

; eax - Addr
; edx - Protect
; ecx - Size
proc Mem_SetProtect
  push esp ; OldProtect
  push esp
  push edx
  push ecx
  push eax
  call [VirtualProtect]

  pop eax
  ret
endp

; eax - Ptr
; edx - ValueL32
; ecx - ValueH32
proc Mem_WriteInt64
  test eax, eax
  jz .Exit

  push ebx
  push edi
  push esi

  mov ebx, eax
  mov edi, edx
  mov esi, ecx

  mov edx, PAGE_EXECUTE_READWRITE
  mov ecx, 8
  call Mem_SetProtect

  mov dword [ebx], edi
  mov dword [ebx + 4], esi

  xchg eax, edx
  mov eax, ebx
  mov ecx, 8
  call Mem_SetProtect

  pop esi
  pop edi
  pop ebx

.Exit:
  ret
endp

; eax - Ptr
; edx - Value
proc Mem_WriteLong
  test eax, eax
  jz .Exit

  push ebx
  push edi

  mov ebx, eax
  mov edi, edx

  mov edx, PAGE_EXECUTE_READWRITE
  mov ecx, 4
  call Mem_SetProtect

  mov dword [ebx], edi

  mov edx, eax
  mov eax, ebx
  mov ecx, 4
  call Mem_SetProtect

  pop edi
  pop ebx

.Exit:
  ret
endp

; eax - Ptr
; dx - Value
proc Mem_WriteWord
  test eax, eax
  jz .Exit

  push ebx
  push edi

  mov ebx, eax
  mov edi, edx

  mov edx, PAGE_EXECUTE_READWRITE
  mov ecx, 2
  call Mem_SetProtect

  mov word [ebx], di

  mov edx, eax
  mov eax, ebx
  mov ecx, 2
  call Mem_SetProtect

  pop edi
  pop ebx

.Exit:
  ret
endp

; eax - Ptr
; dl - Value
proc Mem_WriteByte
  test eax, eax
  jz .Exit

  push ebx
  push edi

  mov edi, eax
  mov ebx, edx

  push esp ; OldProtect
  push esp
  push PAGE_EXECUTE_READWRITE
  push 1
  push edi
  call VirtualProtect

  mov byte [edi], bl

  push dword [esp]
  push 1
  push edi
  call VirtualProtect

  pop edi
  pop ebx

.Exit:
  ret
endp

; eax - Ptr
; edx - Jmp
proc Mem_InsertJump
  test eax, eax
  jz .Exit

  push ebx
  mov bl, 0E9h

  push esi
  push edi

  mov edi, eax
  mov esi, edx

  mov edx, PAGE_EXECUTE_READWRITE
  mov ecx, 5
  call Mem_SetProtect

  sub esi, edi
  sub esi, 5
  mov byte [edi], bl
  mov dword [edi + 1], esi

  xchg edx, eax
  mov eax, edi
  mov ecx, 5
  call Mem_SetProtect

  pop edi
  pop esi
  pop ebx

.Exit:
  ret
endp

; eax - Ptr
; edx - Call
proc Mem_InsertCall
  test eax, eax
  jz .Exit

  push ebx
  mov bl, 0E8h

  lea ecx, [Mem_InsertJump + 8]
  jmp ecx
.Exit:
  ret
endp