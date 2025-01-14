[BITS 16]          ; 16 位实模式代码
org 0x7C00         ; Bootloader 从 0x7C00 开始

start:
    mov si, message
    call print_string

hang:
    jmp hang        ; 死循环

print_string:
    mov ah, 0x0E    ; 设置视频输出功能
.next_char:
    lodsb           ; 取出下一个字符
    cmp al, 0       ; 判断是否结束
    je done         ; 如果是 NULL 结束
    int 0x10        ; 调用 BIOS 中断打印字符
    jmp .next_char  ; 继续处理下一个字符
done:
    ret

message db 'Hello, Bootloader!', 0

times 510-($-$$) db 0   ; 填充到 510 字节
dw 0xAA55               ; 引导扇区标志 