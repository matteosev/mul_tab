STDIN equ 0
STDOUT equ 1
STDERR equ 2

SYS_READ equ 0
SYS_WRITE equ 1
SYS_EXIT equ 60


; input: 
;   memory address to the first character of string
;   0 if null terminated, else the length of the string
; output: 
;   print string

%macro print 2
    mov rdx, %2             ; move length in rdx
    cmp rdx, 0              ; if 0 means null terminated, so we need to calculate length
    jne %%display           ; if length known jump to display
    mov rax, %1             ; memory address of first character
    mov rdx, 0              ; counter, also the 4th parameter of sys_exit
    %%count_loop:
        inc rax             ; 1 character forward
        inc rdx             ; increment counter
        mov cl, [rax]       ; mov char to cl
        cmp cl, 0           ; compare char with 0
        jne %%count_loop    ; if not equal to 0 continue
    %%display:
        mov rax, STDOUT
        mov rdi, SYS_WRITE
        mov rsi, %1
        syscall
%endmacro


; input: 
;       the address in which put input
;       the length of the input
; output: put the input in the variable

%macro input 2
    mov rax, STDIN
    mov rdi, SYS_READ
    mov rsi, %1
    mov rdx, %2
    syscall
%endmacro


; input 
;       address to a string representing an unsigned integer
;       length of the string
; output
;       integer corresponding to string in given address

; a faire : demander une addresse vers ou enregistrer le int

%macro str_to_int 2
    mov rcx, %2
    dec rcx
    cmp rcx, 0
    je %%one_char
    mov rax, 1              ; multiplicator
    mov rbx, 10
    %%power:
        mul rbx
        loop %%power
    xor rbx, rbx              ; put 0 in rbx
    push rbx                 ; push 0 (futur integer)
    push rax                ; push multiplicator
    mov rsi, %1             ; source string
    mov rcx, %2             ; counter (length of string representing integer)
    mov rax, 0
    mov rbx, 0 
    %%iter_str:
        lodsb
        sub al, 48
        pop rbx             ; pop multiplicator
        mul rbx             ; scale digit
        pop rdx             ; pop sum
        add rax, rdx
        push rax            ; push sum
        mov rdx, 0
        mov rax, rbx
        mov rbx, 10
        div rbx
        push rax            ; push multiplicator
        loop %%iter_str
    times 2 pop rax
    jmp %%end
    %%one_char:
        mov rax, 0
        mov al, byte [%1]
        sub rax, 48
    %%end:
        mov qword [%1], rax
%endmacro


; input: 
;   the address to the string to reverse
;   the address to the reversed string
;   the length of the string to reverse (must be equal to the length of the reversed string)
; output:
;   reverse string and put it in the address to the reversed string

%macro reverse_str 3
    mov rcx, %3                 ; counter equal to string length
    mov rsi, %1                 ; source string
    mov rdi, %2                 ; address to first char of reversed string 
    add rdi, %3                 ; move to last char + 1
    dec rdi                     ; move to last char
    %%rev2:
        mov rax, [rsi]          ; put current char of source string in rax
        mov byte [rdi], al      ; put this char in reversed string
        dec rdi                 ; one char back in reversed string (right to left)
        inc rsi                 ; one char forward in source string (left to right)
        loop %%rev2              ; while rcx != 0, continue
    mov rax, [%2]               ; good string is in temporary var
    mov [%1], rax               ; finish by saving string in the good place
%endmacro


;   input
;       address to an integer (memory must be qword)
;       temporary memory (must be qword too)
;   output
;       a string representing this integer in the given address
;   requirements:
;       memory addresses must be 64 bits long 

%macro int_to_str 2
    mov rax, qword [%1]               ; integer to cast
    cmp rax, 10
    jl %%onechar
    mov rbx, 10                 ; divisor
    mov rcx, 0                  ; loop counter
    %%div_loop:
        mov rdx, 0              ; clear rdx
        div rbx                 ; divide rax by rbx
        add rdx, 48             ; cast remainder to char
        push rdx                ; push char
        inc rcx                 ; increment loop counter
        test rax, rax           ; test if rax = 0
        jne %%div_loop          ; if yes stop, else repeat
    mov rbx, rcx
    mov rcx, 0                  ; new counter
    %%replace_loop:
        pop rax                 ; pop digit
        mov byte [%2 + rcx], al      ; place digit
        inc rcx                 ; increment counter
        cmp rcx, rbx            ; compare counter to nb of digit
        jl %%replace_loop       ; if counter < nb of digit, continue
    mov rax, qword [%2]
    jmp %%end
    %%onechar:
        add rax, 48
    %%end:
        mov qword [%1], rax
%endmacro


; input: nothing
; output: exit program without error

%macro exit 0
    mov rax, 60     ; sys_exit
    mov rdi, 0      ; value to return at end of program (0 - no error)
    syscall
%endmacro