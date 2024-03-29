
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

; First query is to get buffer size needed
    mov  qword [rsp + 40], regValueSz
    mov  qword [rsp + 32], 0
    mov  r9,  0
    mov  r8,  0
    mov  rdx, regKey
    mov  rcx, [hReg]
    call [RegQueryValueEx]
    cmp  rax, ERROR_SUCCESS
    jne  registry_close_key

; We need to allocate registry value size + current dir size + 1
    mov  rax, [regValueSz]
    mov  rbx, [currentDirSz]
    add  rax, rbx
    inc  rax

    mov  r9,  PAGE_READWRITE
    mov  r8,  MEM_COMMIT
    mov  rdx, rax
    mov  rcx, 0
    call [VirtualAlloc]
    mov  [regCurrentPath], rax

    mov  qword [rsp + 32], regCurrentPath
    mov  qword [rsp + 40], regValueSz
    mov  r9,  rType
    mov  r8,  0
    mov  rdx, regKey
    mov  rcx, [hReg]
    call [RegQueryValueEx]
    cmp  rax, ERROR_SUCCESS
    jne  registry_cleanup

; Make sure currentPath doesn't exist in path first
    call parse_path_variable
    test rax, rax
    jnz   already_exists

    mov  rdx, regSep
    mov  rcx, regCurrentPath
    call [lstrcat]

    mov  rdx, currentDir
    mov  rcx, regCurrentPath
    call [lstrcat]

    mov  rcx, regCurrentPath
    call [lstrlen]

    inc  rax
    mov  r10, rax

    mov  qword [rsp + 40], r10
    mov  qword [rsp + 32], regCurrentPath
    mov  r9,  REG_SZ
    mov  r8,  0
    mov  rdx, regKey
    mov  rcx, [hReg]
    call [RegSetValueEx]
    cmp  rax, ERROR_SUCCESS
    jne  registry_cleanup

    mov  [regError], 0
    jmp  registry_cleanup

already_exists:

    xor  r9, r9
    mov  r8, existsCaption
    mov  rdx, existsMsg
    xor  rcx, rcx
    call [MessageBoxA]

registry_cleanup:

    mov  r8,  MEM_RELEASE
    mov  rdx, 0
    mov  rcx, [regCurrentPath]
    call [VirtualFree]

registry_close_key:

    mov  rcx, [hReg]
    call [RegCloseKey]

    add rsp, 48
    ret

endp