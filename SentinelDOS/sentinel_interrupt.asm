[org 0x100]

start:
    ; 保存当前 INT 9 的中断向量
    mov ax, 0x3509
    int 0x21
    mov word [original_int9_offset], bx
    mov word [original_int9_segment], es

    ; 监控中断向量
    jmp monitor_loop

monitor_loop:
    ; 检查当前 INT 9 中断向量
    mov ax, 0x3509
    int 0x21
    cmp bx, [original_int9_offset]
    jne restore_interrupt
    cmp es, [original_int9_segment]
    jne restore_interrupt
    jmp monitor_loop

restore_interrupt:
    ; 恢复原来的 INT 9
    mov dx, [original_int9_offset]
    mov ax, 0x2509
    int 0x21
    jmp monitor_loop

original_int9_offset dw 0
original_int9_segment dw 0