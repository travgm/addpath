
proc parse_path_variable

        sub rsp, 32

        mov rdx, currentDir
        mov rcx, regCurrentPath
        call [StrStrA]

        add rsp, 32
        ret

endp