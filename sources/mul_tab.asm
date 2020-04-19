; args:
;   1: the table to display
; displays the multiplication table 

%include "module.asm"

section .data
    x db " x ", 0
    equal db " = ", 0
    nl db 10                ; ascii code for new line
    msg db "Please enter an integer between 0 and 9 or a letter.", 10, 0

section .bss
    op1 resq 1
    op2 resq 1
    res resq 1
    temp resq 1

section .text
    global _start

_start:

main:
    ; get args
    pop rax                         ; pop nb args
    cmp rax, 1                      ; there's 1 argument by default : the path to the binarie
    je wrong_arg                    ; if only 1 arg, it means user forgot to enter his arg
    times 2 pop rax                 ; pop path, 1st user arg
    mov al, byte [rax]              ; get 1 char (because rax currently is a pointer)

    ; initialize the two operands with chars representing integer
    mov qword [op1], rax
    mov qword [op2], "0"            
    
    mov rcx, 10                     ; loop counter

    ; main loop
    loop_mul: 
        push rcx                    ; save counter state

        ; cast to int to calculate
        str_to_int op1, 1
        str_to_int op2, 1

        ; calculations 
        inc byte [op2]              ; increment 2nd operand
        mov al, byte [op2]          ; move 2nd operand in al for multiplication
        mul byte [op1]              ; mul al (op2) by op1 to get result   
        mov qword [res], rax        ; put result in res

        ; cast to str to display
        int_to_str op1, temp
        int_to_str op2, temp
        int_to_str res, temp

        ; display
        print op1, 1
        print x, 0
        print op2, 2
        print equal, 0
        print res, 3
        print nl, 1

        ; verifie that we are still in the range we target 
        pop rcx                     ; reset counter
        dec rcx                     ; decrement counter
        jnz loop_mul                ; if counter != 0, continue looping
        jmp end                     ; else finish program

    wrong_arg:
        print msg, 0

    end:
        exit