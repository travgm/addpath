format PE64 NX GUI 6.0
entry start

    include 'win64a.inc'

    ERROR_SUCCESS = 0x0
    RRF_RT_ANY    = 0x0000ffff

section '.data' data readable writeable
    mutexName      db 'addpath_mutex',0
    shellAction    db 'open',0
    shellProgram   db 'rundll32.exe',0
    shellParams    db 'sysdm.cpl,EditEnvironmentVariables',0
    regSubKey      db 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment',0
    regKey         db 'Path',0
    regSep         db ';',0
    rLength        dd 2048
    hReg           dq ?
    rType          dd ?
    regCurrentPath rb 2048
    currentDir     rb 250
section '.text' code readable executable

    include 'include/registry.inc'

start:

    sub  rsp, 8 * 5
    mov  r8,  mutexName
    xor  rdx, rdx
    xor  rcx, rcx
    call [CreateMutexA]
    cmp  rax, 0
    je   exit_app

    sub  rsp, 32
    mov  rdx, currentDir
    mov  rcx, MAX_PATH
    call [GetCurrentDirectory]
    add  rsp, 32
    cmp  rax, 0
    je   exit_app

    call update_registry

    sub  rsp, 48
    mov  qword [rsp + 40], SW_SHOWNORMAL
    mov  qword [rsp + 32], 0
    mov  r9,  shellParams
    mov  r8,  shellProgram
    mov  rdx, shellAction
    mov  rcx, 0
    call [ShellExecuteA]
    add  rsp, 48

exit_app:

    xor  rcx, rcx
    call [ExitProcess]

section '.idata' import data readable writeable
    library kernel32, 'KERNEL32.DLL', \
            user32,   'USER32.DLL', \
            shell32,  'SHELL32.DLL', \
            advapi32, 'ADVAPI32.DLL'

    import  user32,   MessageBoxA,         'MessageBoxA'
    import  advapi32, RegOpenKeyEx,        'RegOpenKeyExA',\
                      RegCloseKey,         'RegCloseKey',\
                      RegQueryValueEx,     'RegQueryValueExA',\
                      RegSetValueEx,       'RegSetValueExA'
    import  kernel32, ExitProcess,         'ExitProcess',\
                      GetCurrentDirectory, 'GetCurrentDirectoryA',\
                      CreateMutexA,        'CreateMutexA',\
                      lstrcat,             'lstrcatA',\
                      lstrlen,             'lstrlenA'
    import  shell32,  ShellExecuteA,       'ShellExecuteA'