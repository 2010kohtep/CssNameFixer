; eax - CmdName
; edx - Callback
proc HookCmd
  mov ecx, [ConCommandList]
  test ecx, ecx
  jnz .A
   xor eax, eax
   ret
 
.A:
  push edi
  push esi
  push ebx
  mov ebx, edx
  mov esi, [ecx] ; cmd list
  mov edi, eax ; searching cmd
  jmp .B
.D:
  mov esi, [esi + 4] ; next cmd
  test esi, esi
  jz .C
 
.B:
   mov eax, [esi + 12]
   mov edx, edi
   call StrComp
   test eax, eax
    jz .E
  jmp .D
.C:
  xor eax, eax
  jmp .F
 
.E:
  cmp dword [esi + 64], 0
  jnz .J
   add esi, 4
.J:
  mov eax, [esi + 64]
  mov [esi + 64], ebx
.F:
  pop ebx
  pop esi
  pop edi

  ret
endp

proc Find_ConCommandList
  push 8
  push CmdListPattern
  mov eax, [EngineDLLSize]
  push eax
  mov eax, [EngineDLLBase]
  push eax
  call FindPattern_Internal

  test eax, eax
  jz .Exit
    mov eax, [eax + 3]
    mov [ConCommandList], eax
.Exit:
  ret
endp

proc Find_Steamclient
  mov eax, SteamclientDLL
  push eax
  call [GetModuleHandleA]

  mov [SteamclientDLLBase], eax
  call GetModuleSize
  mov [SteamclientDLLSize], eax

  ret
endp

proc Find_SteamclientName
  push 10
  push NamePattern
  mov eax, [EngineDLLSize]
  push eax
  mov eax, [EngineDLLBase]
  push eax
  call FindPattern_Internal

  test eax, eax
  jz .Exit
   inc eax
   mov edx, eax
   mov edx, [edx]
   lea eax, [eax + edx + 5]
   mov eax, [eax]
   mov eax, [eax + 4]
   mov eax, [eax]
   mov eax, [eax + 28]
   mov eax, [eax + 12]
   mov [SteamclientName], eax
.Exit:
  setnz al
  ret
endp

proc Find_Engine
  mov eax, EngineDLL
  push eax
  call [GetModuleHandleA]

  mov [EngineDLLBase], eax
  call GetModuleSize
  mov [EngineDLLSize], eax

  ret
endp

proc FixNameChanging
  lea eax, [sCmdName]
  lea edx, [Cmd_NameN]
  call HookCmd

  mov [Cmd_NamePtr], eax
  ret
endp