macro pascal proc, [arg]
{
 common
  if ~ arg eq
   pushd arg
 common
  end if
  call proc
}

macro register proc, [arg1, arg2, arg3, stack]		      ;  call REGISTER procedure
{
  common

  if ~ arg1 eq
   mov eax, arg1
  end if

  if ~ arg2 eq
   mov edx, arg2
  end if

  if ~ arg3 eq
   mov ecx, arg3
  end if

  if ~ stack eq
   pushd stack
  end if

  call proc
}