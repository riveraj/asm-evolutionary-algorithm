section .rodata

header: db "Generation", 0x0


section .text

extern Exit
extern Newline
extern RandomInt
extern StringCopy
extern StringLength
extern StringToInt
extern Tab
extern WriteInt
extern WriteString

extern generate_population
extern print_population
extern update_population

global Fitness
global Mutate


global _start
_start:
    xor         r12, r12

    mov         rdi, [rsp + 0x10]
    xor         rcx, rcx
    xor         rax, rax
	not         rcx
	cld
    repne       scasb
	not         rcx
	dec         rcx
    mov         r14, rcx

    mov         rdi, [rsp + 0x18]
    xor         rcx, rcx
    xor         rax, rax
	not         rcx
	cld
    repne       scasb
	not         rcx
	dec         rcx
    mov         rdi, [rsp + 0x18]
    mov         rsi, rcx
    call        StringToInt

    mov         rdi, [rsp + 0x10]
    mov         rsi, r14
    mov         rdx, rax
    call        generate_population
    mov         r13, rax

    mov         rdi, r13
    mov         rsi, r12
    call        print

    .loop:
        mov         rdi, r13
        mov         rsi, [rsp + 0x10]
        call        update_population
        add         r12, rax
        mov         rdi, r13
        mov         rsi, r12
        mov         rdx, r14
        call        print
        mov         rdx, QWORD [r13 + 0x8]
        movsxd      rdx, DWORD [rdx + 0x4]
        test        rdx, rdx
        jnz         .loop

    mov         rdi, 0x0
    call        Exit


print:
    push        rbp
    mov         rbp, rsp

    push        r12
    push        r13
    push        r14

    mov         r12, rdi
    mov         r13, rsi
    mov         r14, rdx

    mov         rdi, header
    call        WriteString
    call        Tab

    mov         rdi, r13
    call        WriteInt
    call        Newline

    mov         rdi, r12
    mov         rsi, r14
    call        print_population
    call        Newline

    pop         r14
    pop         r13
    pop         r12

    mov         rsp, rbp
    pop         rbp

    ret


; int Fitness(char *src, char *tgt)
; Determine the fitness of the source string when compared to the target
; string.
;
; Fitness is simply the cumulative difference of each corresponding
; character in the two strings (using their ASCII values), squared to ensure that
; all fitness values are positive.
Fitness:
        push    rbp
        mov     rbp, rsp

        push    r12
        push    r13

        mov     r12, rdi
        mov     r13, rsi

        call    StringLength
        mov     rdi, rax

        xor     rsi, rsi

.loop:  mov     al, BYTE [r13]
        inc     r13
        sub     al, BYTE [r12]
        inc     r12
        movsx   rax, al
        imul    rax
        add     rsi, rax
        dec     rdi
        jnz     .loop

        mov     rax, rsi

        pop     r13
        pop     r12

        mov     rsp, rbp
        pop     rbp

        ret


; int Mutate(char *dst, char *src1, char *src2, char *tgt)
; Generate a random mutation of the given sources into the destination buffer
; and return the resulting candidate's fitness value.
;
; A mutation is performed via a random crossover of the given sources followed
; by a random modification of a random character in the string by: adding 1 to
; its ASCII code; subtracting 1 from its ASCII code; or doing nothing.
Mutate:
        push    rbp
        mov     rbp, rsp

        push    r12
        push    r13
        push    r14
        push    r15

        mov     r12, rdi
        mov     r13, rdx
        mov     r14, rcx
        mov     r15, r8

        call    StringCopy

        mov     rdi, r12
        mov     rsi, r13
        mov     rdx, r15
        call    RandomMerge

        mov     rdi, r15
        call    RandomInt
        mov     r13, rax
        mov     rdi, 0x3
        call    RandomInt
        dec     rax
        add     BYTE [r12 + r13], al

        mov     rdi, r12
        mov     rsi, r14
        call    Fitness

        pop     r15
        pop     r14
        pop     r13
        pop     r12

        mov     rsp, rbp
        pop     rbp

        ret


; void RandomMerge(void *dst, void *src)
; Randomly merge the source string with the destination buffer.
;
; The random merge is accomplished by choosing a range at random and copying
; the bytes; within the range from the source into the destination at
; corresponding byte positions.
RandomMerge:
        push    rbp
        mov     rbp, rsp

        push    r12
        push    r13
        push    r14
        push    r15

        mov     r12, rdi
        mov     r13, rsi

        mov     rdi, r13
        call    StringLength
        mov     r14, rax

        mov     rdi, r14
        call    RandomInt
        mov     r15, rax

        mov     rdi, r14
        call    RandomInt
        mov     r14, rax

        sub     rax, r15
        mov     rdx, rax
        sar     rdx, 0x1f
        xor     rax, rdx
        mov     rcx, rax

        cmp     r14, r15
        cmova   r14, r15
        mov     rdi, r12
        mov     rsi, r13
        add     rdi, r14
        add     rsi, r14
        cld
        rep     movsb

        pop     r15
        pop     r14
        pop     r13
        pop     r12

        mov     rsp, rbp
        pop     rbp

        ret
