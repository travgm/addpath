format PE64 NX GUI 6.0
entry start

    include 'win64a.inc'

    ERROR_SUCCESS        = 0x0
    ERROR_ALREADY_EXISTS = 0xB7
    RRF_RT_ANY           = 0x0000ffff

    IDR_ICON             = 17

section '.data' data readable writeable

    mutexName      db 'addpath_mutex',0
    shellAction    db 'open',0
    shellProgram   db 'rundll32.exe',0
    shellParams    db 'sysdm.cpl,EditEnvironmentVariables',0
    regSubKey      db 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment',0
    regKey         db 'Path',0
    regSep         db ';',0
    existsCaption  db 'addpath',0
    existsMsg      db 'Current directory already exists in system path!',0

section '.bss' readable writeable

    regError       db 1
    currentDir     rb MAX_PATH
    regValueSz     dq ?
    hReg           dq ?
    currentDirSz   dq ?
    rType          dd ?
    regCurrentPath dq ?

section '.text' code readable executable

    include 'include/registry.inc'
    include 'include/parser.inc'

start:
    sub  rsp, 40

    mov  rcx, 0
    call [GetModuleHandleA]

    mov  rdx, IDR_ICON
    mov  rcx, rax
    call [LoadIconA]

    mov  r8,  mutexName
    xor  rdx, TRUE
    xor  rcx, rcx
    call [CreateMutexA]

    call [GetLastError]
    cmp  rax, ERROR_ALREADY_EXISTS
    je   exit_app

    mov  rdx, currentDir
    mov  rcx, MAX_PATH
    call [GetCurrentDirectory]
    cmp  rax, 0
    je   exit_app
    mov  [currentDirSz], rax

    call update_registry
    cmp  [regError], 0
    jne  exit_app

    mov  qword [rsp + 40], SW_SHOWNORMAL
    mov  qword [rsp + 32], 0
    mov  r9,  shellParams
    mov  r8,  shellProgram
    mov  rdx, shellAction
    mov  rcx, 0
    call [ShellExecuteA]

exit_app:

    xor  rcx, rcx
    call [ExitProcess]

section '.idata' import data readable writeable
    library kernel32, 'KERNEL32.DLL', \
            shell32,  'SHELL32.DLL', \
            shlwapi,  'SHLWAPI.DLL',\
            user32,   'USER32.DLL',\
            advapi32, 'ADVAPI32.DLL'

    import  advapi32, RegOpenKeyEx,        'RegOpenKeyExA',\
                      RegCloseKey,         'RegCloseKey',\
                      RegQueryValueEx,     'RegQueryValueExA',\
                      RegSetValueEx,       'RegSetValueExA'
    import  kernel32, ExitProcess,         'ExitProcess',\
                      GetCurrentDirectory, 'GetCurrentDirectoryA',\
                      CreateMutexA,        'CreateMutexA',\
                      VirtualAlloc,        'VirtualAlloc',\
                      VirtualFree,         'VirtualFree',\
                      GetLastError,        'GetLastError',\
                      GetModuleHandleA,    'GetModuleHandleA',\
                      lstrcat,             'lstrcatA',\
                      lstrlen,             'lstrlenA'
    import  shell32,  ShellExecuteA,       'ShellExecuteA'
    import  shlwapi,  StrStrA,             'StrStrA'
    import  user32,   MessageBoxA,         'MessageBoxA',\
                      LoadIconA,           'LoadIconA'

section '.rsrc' resource data readable

    directory RT_VERSION,    version,\
              RT_ICON,       icons,\
              RT_GROUP_ICON, group_icons

    resource icons, 1, LANG_NEUTRAL, icon_data

    resource group_icons, IDR_ICON, LANG_NEUTRAL, main_icon

    resource version, 1, LANG_NEUTRAL, vinfo

    versioninfo vinfo,\
                VOS__WINDOWS32, VFT_APP, VFT2_UNKNOWN,\
                LANG_ENGLISH+SUBLANG_DEFAULT,0,\
                'FileDescription','Adds executing path to the system environment path variable',\
                'LegalCopyright','(C) 2024 Travis Montoya',\
                'ProductName', 'addpath',\
                'FileVersion','1.1',\
                'ProductVersion','1.1'

    icon main_icon, icon_data, 'resources/addpath.ico'