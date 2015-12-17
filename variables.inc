  sIniSectionName db 'steamclient',0
  sIniKeyName	  db 'PlayerName',0
  sIniFileName	  db '.\rev.ini',0
  sCmdName	  db 'name',0

  SteamclientDLL     db 'steamclient.dll',0
  SteamclientDLLBase dd 0
  SteamclientDLLSize dd 0
  EngineDLL	     db 'engine.dll',0
  EngineDLLBase      dd 0
  EngineDLLSize      dd 0

  ConCommandList     dd 0
  Cmd_NamePtr	     dd 0
  SteamclientName    dd 0

  NamePattern	 db 0E8h, 0FFh, 0FFh, 0FFh, 0FFh,\
		    0FFh, 77h, 04h,\
		    0FFh, 37h
  CmdListPattern db 75h, 10h,\
		    0A1h, 0FFh, 0FFh, 0FFh, 0FFh,\
		    89h