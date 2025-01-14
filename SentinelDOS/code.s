; DOS Interrupt Vector Table Protection System
; Author: Harrison
; Purpose: Demonstrate interrupt vector table protection against malicious modification
ORG 100h

; ==============
; Global Variables
; ==============
original_offset    DW ?    ; Store original interrupt vector offset
original_segment   DW ?    ; Store original interrupt vector segment
vector_checksum    DW ?    ; Store checksum for integrity verification
security_signature DW 1337h ; Security signature to verify legitimate changes

; ==============
; Main Program Entry
; ==============
start:
    ; Initialize protection system
    CALL init_protection
    
    ; Install protection handler
    CALL install_protection
    
    ; Display security status
    MOV DX, security_msg
    MOV AH, 09h
    INT 21h
    
    ; Stay resident
    MOV DX, (prog_end - start + 15) >> 4  ; Calculate size in paragraphs
    MOV AH, 31h                           ; DOS TSR function
    INT 21h

; ==============
; Protection Initialization
; ==============
init_protection:
    ; Calculate initial checksum of vector table
    PUSH ES
    XOR AX, AX
    MOV ES, AX
    MOV CX, 256           ; Check all 256 interrupts
    XOR BX, BX           ; Start from interrupt 0
    XOR DX, DX           ; Initialize checksum

calc_checksum:
    ADD DX, WORD [ES:BX] ; Add offset to checksum
    ADD DX, WORD [ES:BX+2] ; Add segment to checksum
    ADD BX, 4
    LOOP calc_checksum
    
    MOV [vector_checksum], DX
    POP ES
    RET

; ==============
; Install Protection Handler
; ==============
install_protection:
    ; Save original INT 65h vector
    MOV AX, 0
    MOV ES, AX
    MOV DI, 65h * 4
    MOV AX, [ES:DI]
    MOV [original_offset], AX
    MOV AX, [ES:DI+2]
    MOV [original_segment], AX

    ; Install our handler
    CLI
    MOV WORD [ES:DI], protection_handler
    MOV AX, CS
    MOV WORD [ES:DI+2], AX
    STI
    RET

; ==============
; Protection Handler
; ==============
protection_handler:
    PUSHF
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH DS
    PUSH ES

    ; Verify interrupt table integrity
    CALL verify_integrity
    
    CMP AX, 0            ; If AX = 0, integrity check passed
    JE handle_normal
    
    ; Handle potential attack
    MOV DX, attack_detected_msg
    MOV AH, 09h
    INT 21h
    
    ; Restore original vectors
    CALL restore_vectors
    JMP handler_exit

handle_normal:
    ; Normal interrupt handling
    CMP AH, 01h
    JE show_welcome
    CMP AH, 02h
    JE show_bitcoin
    JMP show_error

handler_exit:
    POP ES
    POP DS
    POP DX
    POP CX
    POP BX
    POP AX
    POPF
    IRET

; ==============
; Integrity Verification
; ==============
verify_integrity:
    PUSH ES
    XOR AX, AX
    MOV ES, AX
    MOV CX, 256
    XOR BX, BX
    XOR DX, DX

verify_loop:
    ADD DX, WORD [ES:BX]
    ADD DX, WORD [ES:BX+2]
    ADD BX, 4
    LOOP verify_loop
    
    CMP DX, [vector_checksum]
    JE integrity_ok
    
    MOV AX, 1            ; Return 1 if integrity check fails
    POP ES
    RET

integrity_ok:
    XOR AX, AX           ; Return 0 if integrity check passes
    POP ES
    RET

; ==============
; Message Handlers
; ==============
show_welcome:
    MOV DX, welcome_text
    JMP print_and_exit

show_bitcoin:
    MOV DX, bitcoin_text
    JMP print_and_exit

show_error:
    MOV DX, error_text

print_and_exit:
    MOV AH, 09h
    INT 21h
    JMP handler_exit

; ==============
; Data Section
; ==============
security_msg        DB 'Security Protection System Active - Monitoring IVT', 0Dh, 0Ah, '$'
attack_detected_msg DB '! ALERT ! Unauthorized IVT modification detected!', 0Dh, 0Ah, '$'
welcome_text       DB 'Protected System - Welcome to Harrison''s Computing World!', 0Dh, 0Ah, '$'
bitcoin_text       DB 'Protected Bitcoin Key: ABCD989-ERF7899-9989S1323', 0Dh, 0Ah, '$'
error_text         DB 'Protected System - Invalid Operation!', 0Dh, 0Ah, '$'

prog_end:          ; Mark end of program