section .data

CANDIDATE_DNA: equ 0x8
CANDIDATE_FITNESS: equ 0x4


section .text

extern Tab
extern RandomString
extern RandomInt
extern StringCopy
extern StringLength
extern WriteInt
extern WriteString

extern Fitness

global CandidatePrint


global generate_candidate
; void *generate_candidate(char *tgt, int strlen)
;
; Generate a candidate and return a pointer to the beginning of the memory
; segment containing the new candidate.
;
; A candidate consists of a random string of the given length and its fitness
; value as compared to the target. Each candidate is also prefixed with its
; string length.
;
; The candidate will be stored in the buffer with the following format:
; | length | fitness | string |

generate_candidate:
    push        rbp
    mov         rbp, rsp

    push        r12
    push        r13

    mov         r12, rdi

    mov         rdi, 0x0
    mov         rax, 0xc
    syscall

    mov         r13, rax
    lea         rdi, [r13 + rsi + 0x9]
    mov         rax, 0xc
    syscall

    mov         DWORD [r13], esi

    lea         rdi, [r13 + CANDIDATE_DNA]
    call        RandomString

    lea         rdi, [r13 + CANDIDATE_DNA]
    mov         rsi, r12
    call        Fitness
    mov         DWORD [r13 + CANDIDATE_FITNESS], eax

    mov         rax, r13

    pop         r13
    pop         r12

    mov         rsp, rbp
    pop         rbp

    ret


; int CandidateCompare(void *this, void *other)
; Compare two candidates via their fitness values and return a negative integer
; if this candidate has the lower fitness value; zero if both candidates have
; the same fitness values; or a positive integer if this candidate has the higher
; fitness value.
CandidateCompare:
        push    rbp
        mov     rbp, rsp

        mov     rax, [rdi + CANDIDATE_FITNESS]
        sub     rax, [rsi + CANDIDATE_FITNESS]

        mov     rsp, rbp
        pop     rbp

        ret


; void CandidatePrint(void *this)
; Print a candidate along with its fitness value to standard output.
CandidatePrint:
        push    rbp
        mov     rbp, rsp

        push    r12

        mov     r12, rdi

        movsxd  rdi, DWORD [r12 + CANDIDATE_FITNESS]
        call    WriteInt
        call    Tab
        lea     rdi, [r12 + CANDIDATE_DNA]
        call    WriteString

        pop     r12

        mov     rsp, rbp
        pop     rbp

        ret
