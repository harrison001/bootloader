define show_stack
    printf "\n==== Stack Trace ====\n"
    backtrace
    printf "\n==== Frame Details ====\n"

    set $i = 0
    while $i < 10
        frame $i
        printf "\nFrame %d:\n", $i
        info frame
        info args
        info locals
        set $i = $i + 1
    end
    printf "\n==== End of Stack ====\n"
end