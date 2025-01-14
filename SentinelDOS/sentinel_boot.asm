[org 0x7c00]
    jmp short start
    nop
    
    ; 完整的BPB和引导扇区数据
    db "FRDOS5.1"      ; 系统ID
    dw 512             ; 扇区大小
    db 1               ; 簇大小
    dw 1               ; 保留扇区
    db 2               ; FAT数
    dw 224             ; 根目录项
    dw 2880            ; 扇区总数
    db 0xf0            ; 介质描述符
    dw 9               ; FAT大小
    dw 18              ; 每磁道扇区数
    dw 2               ; 磁头数
    dd 0               ; 隐藏扇区
    dd 0               ; 大分区扇区数
    db 0               ; 驱动器号
    db 0               ; 保留
    db 0x29            ; 扩展引导标志
    dd 0xffffffff      ; 卷序列号
    db "NO NAME    "   ; 卷标
    db "FAT12   "      ; 文件系统类型

start:
    cli
    mov ax, 0x07c0
    mov ds, ax
    xor ax, ax
    mov ss, ax
    mov sp, 0x7c00
    sti
    mov [bootdrv], dl
    mov ah, 0
    int 0x13
    jc error
    mov ax, 0x0050
    mov es, ax
    xor bx, bx
    mov ah, 2
    mov al, 1
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, [bootdrv]
    int 0x13
    jc error
    mov dl, [bootdrv]
    jmp 0x0050:0

error:
    mov si, errmsg
    call print
    xor ah, ah
    int 0x16
    int 0x19

print:
    lodsb
    or al, al
    jz done
    mov ah, 0x0e
    mov bx, 7
    int 0x10
    jmp print
done:
    ret

bootdrv db 0
errmsg  db "Error loading DOS", 13, 10, 0

    times 510-($-$$) db 0
    dw 0xaa55