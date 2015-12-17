format PE GUI 5.0 DLL

include 'win32ax.inc'

entry DllEntryPoint

section '.data' data readable writable
  include 'variables.inc'

section '.code' code readable writable executable

proc DllEntryPoint HinstDLL, fdwReason, lpvReserved
  cmp [fdwReason], DLL_PROCESS_ATTACH
  jne .Exit

  invoke CreateThread, 0, 0, MainThread, 0, 0, 0

  mov eax, 1
.Exit:
  ret
endp

proc Cmd_NameN
  push edi
  push esi

  push ebx ; EBX consists new name
  call [lstrlen]
  mov ecx, eax
  mov esi, ebx
  mov edi, [SteamclientName]
  mov edx, edi ; save for later

  cld
  rep movsb
  mov byte [edi], 0

  push sIniFileName
  push edx
  push sIniKeyName
  push sIniSectionName
  call [WritePrivateProfileStringA]

  pop esi
  pop edi

  jmp [Cmd_NamePtr]
endp

proc MainThread
  call Mem_InsertCall
  call Find_Engine
  call Find_SteamclientName
  dec al
   jnz .DoesntNeed
  call Find_ConCommandList
  call FixNameChanging

.DoesntNeed:
  ret
endp

include 'memory.asm'
include 'searchcode.asm'
include 'strutils.asm'

section '.idata' import data readable writable
  library kernel32, 'kernel32.dll'

  include 'api/kernel32.inc'

section '.reloc' fixups data readable discardable