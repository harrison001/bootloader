define check_eflags
    set $ef = $eflags
    printf "EFLAGS: 0x%x\n", $ef
    printf "CF = %d\n", ($ef & (1 << 0)) != 0
    printf "PF = %d\n", ($ef & (1 << 2)) != 0
    printf "AF = %d\n", ($ef & (1 << 4)) != 0
    printf "ZF = %d\n", ($ef & (1 << 6)) != 0
    printf "SF = %d\n", ($ef & (1 << 7)) != 0
    printf "OF = %d\n", ($ef & (1 << 11)) != 0
end