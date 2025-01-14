[BITS 16]          ; 16 位实模式
org 0x7C00         ; BIOS 将启动扇区加载到 0x7C00

start:
    cli                 ; 禁用中断
    xor ax, ax
    mov ds, ax          ; 数据段寄存器设为 0x0000
    mov es, ax          ; 额外段寄存器设为 0x0000

    ; 显示欢迎消息
    mov si, welcome_msg
    call print_string

    ; 从磁盘读取第二阶段 Bootloader 到内存地址 0x1000
    mov bx, 0x1000      ; 目标地址是 0x1000
    mov dl, [boot_drive]
    call load_stage2    ; 调用加载函数

    ; 跳转到第二阶段 Bootloader
    jmp 0x1000

hang:
    jmp hang            ; 进入无限循环，防止继续执行

; 打印字符串函数
print_string:
    mov ah, 0x0E        ; BIOS 中断 0x10, 功能号 0x0E 用于显示字符
.next_char:
    lodsb               ; 从 [SI] 加载字符到 AL 寄存器
    cmp al, 0           ; 检查是否是 NULL 终止符
    je .done
    int 0x10            ; 调用 BIOS 中断显示字符
    jmp .next_char      ; 继续处理下一个字符
.done:
    ret

; 从磁盘读取第二阶段 Bootloader
load_stage2:
    mov ah, 0x02        ; BIOS 读扇区功能
    mov al, 3           ; 读取 3 个扇区
    mov ch, 0           ; 磁道号
    mov dh, 0           ; 磁头号
    mov cl, 2           ; 扇区号（第2个扇区开始）
    int 0x13            ; 调用 BIOS 中断读取磁盘
    jc error            ; 如果出现错误，跳转到错误处理
    ret

error:
    mov si, err_msg     ; 显示错误消息
    call print_string
    jmp hang

welcome_msg db 'Stage 1 Bootloader loaded!', 0
err_msg db 'Error loading Stage 2', 0
boot_drive db 0        ; 保存启动盘的 BIOS 驱动器号

times 510-($-$$) db 0   ; 填充到 510 字节
dw 0xAA55               ; 启动扇区标志