; eax - Str1
; edx - Str2
proc StrComp
  push edi
  push esi
  mov edi, edx
  mov esi, eax
  mov ecx, -1
  xor eax, eax
  repne scasb
  not ecx
  mov edi, edx
  xor edx, edx
  repe cmpsb
  mov al, [esi - 1]
  mov dl, [edi - 1]
  sub eax, edx
  pop esi
  pop edi
  ret
endp