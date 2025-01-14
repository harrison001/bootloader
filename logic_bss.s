section .data
    buffer db 'BCDEF', 0                ; 待扫描的字符串
    result db 'Character not found', 0  ; 未找到字符的消息
    found db 'Character found', 0       ; 找到字符的消息

section .bss
    temp resb 32    ; 分配32字节的临时缓冲区

section .text
    global _start

_start:
    ; 正确设置段寄存器
    mov ax, ds         ; 将 DS 段寄存器加载到 AX
    mov es, ax         ; 将 AX 中的值赋给 ES，确保 ES 指向数据段

    ; 设置用于扫描的指针
    lea edi, [buffer]  ; 使用32位寄存器EDI加载 buffer 的地址
    mov al, 'F'        ; 需要查找的字符是 'F'
    mov ecx, 5         ; 设置需要扫描的字符数（buffer 长度为 5）

    ; 使用 repne scasb 进行字符比较
    repne scasb        ; 比较 AL 和 ES:EDI 的内容

    jz letter_found          ; 如果找到了字符（ZF=1），跳转到 letter_found

    ; 判断是否找到字符
    jecxz not_found    ; 如果 ECX 变为 0，表示未找到，跳转到 not_found
    jmp exit_program   ; 找不到字符时直接跳转到程序结束

letter_found:
    ; 找到字符的处理
    mov eax, 4         ; 系统调用号 (sys_write)
    mov ebx, 1         ; 文件描述符 (1 = stdout)
    mov ecx, found     ; 输出 'Character found'
    mov edx, 17        ; 输出长度为 17 字节
    int 0x80           ; 调用系统中断

    jmp exit_program   ; 跳转到程序结束，避免执行 not_found 分支

not_found:
    ; 未找到字符的处理
    mov eax, 4         ; 系统调用号 (sys_write)
    mov ebx, 1         ; 文件描述符 (1 = stdout)
    mov ecx, result    ; 输出 'Character not found'
    mov edx, 21        ; 输出长度为 21 字节
    int 0x80           ; 调用系统中断

exit_program:
    mov eax, 1         ; 系统调用号 (sys_exit)
    xor ebx, ebx       ; 退出状态码 0
    int 0x80           ; 调用系统中断以退出程序