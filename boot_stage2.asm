[BITS 16]          ; 16 位代码模式
org 0x1000         ; 第二阶段 Bootloader 被加载到 0x1000

start:
    ; 设置全局描述符表（GDT）
    cli                 ; 禁用中断
    lgdt [gdt_descriptor]  ; 加载 GDT
    mov eax, cr0
    or eax, 1           ; 设置 PE（保护模式启用位）
    mov cr0, eax        ; 启用保护模式

    ; 跳转到保护模式代码段
    jmp 0x08:pm_start   ; 段选择子 0x08 对应代码段描述符

[BITS 32]          ; 32 位保护模式代码
pm_start:
    mov ax, 0x10        ; 加载数据段选择子 0x10（对应 GDT 中的数据段描述符）
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; 显示保护模式消息
    mov esi, pm_msg
    call print_string_pm

hang:
    jmp hang            ; 无限循环

print_string_pm:
.next_char_pm:
    lodsb               ; 从 [ESI] 读取字符到 AL
    cmp al, 0
    je .done_pm
    mov ah, 0x0E
    int 0x10            ; 使用 BIOS 中断显示字符
    jmp .next_char_pm
.done_pm:
    ret

pm_msg db 'Now in protected mode!', 0

; 全局描述符表（GDT）
gdt_start:
    dw 0xFFFF           ; 空的描述符（0x0000）
    dw 0x0000
    dw 0x0000
    dw 0x0000

    dw 0xFFFF           ; 代码段描述符，段基地址为 0x00000000
    dw 0x0000
    db 0x00
    db 10011010b        ; 代码段，执行、读取、非一致性
    db 11001111b        ; 段限长，4KB 粒度
    db 0x00

    dw 0xFFFF           ; 数据段描述符，段基地址为 0x00000000
    dw 0x0000
    db 0x00
    db 10010010b        ; 数据段，读/写
    db 11001111b        ; 段限长，4KB 粒度
    db 0x00

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

gdt_end:

times 510-($-$$) db 0
dw 0xAA55