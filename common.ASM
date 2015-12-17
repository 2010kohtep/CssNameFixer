; eax - FileName
proc IsFileExists
  push eax
  call [GetFileAttributes]

  test eax, INVALID_FILE_ATTRIBUTES
  sete al
  ret
endp