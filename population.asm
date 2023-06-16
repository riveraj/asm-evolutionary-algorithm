section .text

extern Newline
extern StringCopy
extern Tab
extern WriteInt

extern CandidatePrint

extern randintp

extern Mutate

extern generate_candidate


global generate_population
; void **generate_population(char *tgt, int strlen, int size)
;
; Generate a population of the given size and a list of addresses to buffers
; containing each candidate in the new population and return a pointer to the
; beginning of the memory segment containing the list. The list is sorted based
; on the candidates' fitness values.
;
; The beginning of this memory segment contains two integers, indicating the
; size of the list and the length of the candidates, respectively.
;
; The list will be stored in the buffer with the following format:
; | size | length | address | address | ... | address |

generate_population:
    push        rbp
    mov         rbp, rsp

    push        r12
    push        r13
    push        r14
    push        r15

    mov         r12, rdi
    mov         r13, rsi
    mov         r14, rdx

    mov         rdi, 0x0
    mov         rax, 0xc
    syscall

    mov         r15, rax
    lea         rdi, [rax + r14 * 0x8 + 0x8]
    mov         rax, 0xc
    syscall

    mov         DWORD [r15], r14d
    mov         DWORD [r15 + 0x4], r13d

    .loop:
        mov         rdi, r12
        mov         rsi, r13
        call        generate_candidate
        mov         QWORD [r15 + r14 * 0x8], rax
        dec         r14
        jnz         .loop

    mov         rdi, r15
    call        sort_population

    mov         rax, r15

    pop         r15
    pop         r14
    pop         r13
    pop         r12

    mov         rsp, rbp
    pop         rbp

    ret


global update_population
; int update_population(void **lst, char *tgt)
;
; Repeatedly create new candidates, through random mutations, and update the
; population by replacing the weakest candidate with a suitable mutation and
; return the number of iterations taken.
;
; A new candidate is created through a crossover mutation of two randomly
; chosen candidates within the population, and compared against the candidate
; in the population with the lowest fitness value. This process is repeated
; until a mutation is found that is has a higher fitness value than the weakest
; candidate.

update_population:
    push        rbp
    mov         rbp, rsp

    push        r12
    push        r13
    push        r14
    push        r15

    movsxd      rdx, DWORD [rdi + 0x4]
    inc         rdx
    sub         rsp, rdx

    mov         r12, rdi
    mov         r13, rsi
    xor         r15, r15

    .loop:
        mov         rdi, r12
        call        random_candidate
        mov         r14, rax
        mov         rdi, r12
        call        random_candidate
        mov         rdi, rsp
        lea         rsi, [r14 + 0x8]
        lea         rdx, [rax + 0x8]
        mov         rcx, r13
        movsxd      r8, DWORD [r12 + 0x4]
        call        Mutate
        movsxd      rdi, DWORD [r12]
        mov         rdi, QWORD [r12 + rdi * 0x8]
        inc         r15
        cmp         eax, DWORD [rdi + 0x4]
        jge         .loop

    movsxd      rdx, DWORD [r12 + 0x4]
    mov         DWORD [rdi], edx
    mov         DWORD [rdi + 0x4], eax
    add         rdi, 0x8
    mov         rsi, rsp
    call        StringCopy

    mov         rdi, r12
    call        sort_population

    mov         rax, r15

    movsxd      rdx, DWORD [r12 + 0x4]
    inc         rdx
    add         rsp, rdx

    pop         r15
    pop         r14
    pop         r13
    pop         r12

    mov         rsp, rbp
    pop         rbp

    ret


global random_candidate
; void *random_candidate(void **lst)
;
; Chooses a candidate from the given population list at random, using the
; uniform product distribution, and return the pointer to that candidate.

random_candidate:
    push        rbp
    mov         rbp, rsp

    push        r12

    mov         r12, rdi

    mov         rdi, 0x1
    movsxd      rsi, DWORD [r12]
    call        randintp
    mov         rax, QWORD [r12 + rax * 0x8]

    pop         r12

    mov         rsp, rbp
    pop         rbp

    ret


global sort_population
; void sort_population(void **lst)
;
; Sort the population list, in increasing order, based on the candidates'
; fitness values.

sort_population:
    push        rbp
    mov         rbp, rsp

    lea         rdx, [rdi + 0x8]

    .outer_loop:
        xor         rax, rax
        movsxd      rcx, DWORD [rdx - 0x8]
        sal         rcx, 0x3
        sub         rcx, 0x8

        .inner_loop:
            mov         rsi, QWORD [rdx + rcx - 0x8]
            movsxd      r8, [rsi + 0x4]
            mov         rdi, QWORD [rdx + rcx]
            movsxd      r9, [rdi + 0x4]
            cmp         r8, r9
            jle         .continue
            mov         QWORD [rdx + rcx - 0x8], rdi
            mov         QWORD [rdx + rcx], rsi
            inc         rax

            .continue:
                sub         rcx, 0x8
                jnz         .inner_loop
                test        rax, rax
                jnz         .outer_loop

    mov         rsp, rbp
    pop         rbp

    ret


global print_population
; void print_population(void **lst)
;
; Print all candidates in the population and their fitness values to STDOUT.

print_population:
    push        rbp
    mov         rbp, rsp

    push        r12
    push        r13
    push        r14

    lea         r12, [rdi + 0x8]
    movsxd      r13, DWORD [rdi]
    mov         r14, 0x1

    .loop:
        mov         rdi, r14
        call        WriteInt
        call        Tab
        mov         rdi, QWORD [r12]
        call        CandidatePrint
        call        Newline
        add         r12, 0x8
        inc         r14
        dec         r13
        jnz         .loop

    pop         r14
    pop         r13
    pop         r12

    mov         rsp, rbp
    pop         rbp

    ret


; int randintp(int min, int max)
;
; Generate and return a random integer in the range (min, max) using the uniform
; product distribution.
;
; In other words, lower values will be more favored, or occur more frequently,
; than higher values in the range.
randintp:
    push        rbp
    mov         rbp, rsp

    sub         rsi, rdi
    xor         rax, rax
    not         eax

    cvtsi2sd    xmm2, rax

    rdrand      eax
    cvtsi2sd    xmm1, rax
    divsd       xmm1, xmm2
    movsd       xmm0, xmm1

    rdrand      eax
    cvtsi2sd    xmm1, rax
    divsd       xmm1, xmm2
    movsd       xmm2, xmm0
    mulsd       xmm1, xmm2

    cvtsi2sd    xmm2, rsi
    mulsd       xmm1, xmm2

    cvtsd2si    rax, xmm1
    add         rax, rdi

    mov         rsp, rbp
    pop         rbp

    ret
