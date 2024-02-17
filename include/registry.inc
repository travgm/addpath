
proc update_registry

    sub  rsp, 48
    mov  rcx, HKEY_LOCAL_MACHINE
    mov  rdx, regSubKey
    mov  r8,  0
    mov  r9,  KEY_ALL_ACCESS
    mov  qword [rsp + 32], hReg
    call [RegOpenKeyEx]
    cmp  rax, ERROR_SUCCESS
    jne  exit_app

    sub  rsp, 48
    mov  qword [ rsp + 32], regCurrentPath
    mov  qword [ rsp + 40], rLength
    mov  r9,  rType
    mov  r8,  0
    mov  rdx, regKey
    mov  rcx, [hReg]
    call [RegQueryValueEx]
    add  rsp, 48
    cmp  rax, ERROR_SUCCESS
    jne  exit_app

    sub  rsp, 48
    mov  rdx, regSep
    mov  rcx, regCurrentPath
    call [lstrcat]
    add  rsp, 32
    sub  rsp, 32
    mov  rdx, currentDir
    mov  rcx, regCurrentPath
    call [lstrcat]
    add  rsp, 32
    sub  rsp, 32
    mov  rcx, regCurrentPath
    call [lstrlen]
    add  rsp, 32

    inc  rax
    mov  r10, rax

    sub  rsp, 40
    mov  qword [rsp + 40], r10
    mov  qword [rsp + 32], regCurrentPath
    mov  r9,  REG_SZ
    mov  r8,  0
    mov  rdx, regKey
    mov  rcx, [hReg]
    call [RegSetValueEx]
    add  rsp, 40
    cmp  rax, ERROR_SUCCESS
    jne  exit_app
    ret

endp