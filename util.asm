section .data

ASCII_PRINTABLE_MAX: equ 0x7f
ASCII_PRINTABLE_MIN: equ 0x20
ASCII_NEWLINE: equ 0xa
ASCII_TAB: equ 0x9
STDOUT: equ 0x1
SYS_EXIT: equ 0x3c
SYS_WRITE: equ 0x1


section .text

global Exit
global Newline
global RandomChar
global RandomInt
global RandomString
global StringCopy
global StringLength
global StringReplace
global StringToInt
global Tab
global WriteInt
global WriteString


; void Exit(int status)
; Exit the process with the given status.
Exit:
        push    rbp
        mov     rbp, rsp

        mov     rax, SYS_EXIT
        syscall


; void Newline()
; Write the newline character to standard output.
Newline:
        push    rbp
        mov     rbp, rsp

        push    ASCII_NEWLINE
        mov     rdi, rsp
        call    WriteString

        mov     rsp, rbp
        pop     rbp

        ret


; char RandomChar()
; Generate and return a random printable character.
RandomChar:
        push    rbp
        mov     rbp, rsp

        mov     rdi, ASCII_PRINTABLE_MAX - ASCII_PRINTABLE_MIN
        call    RandomInt
        add     rax, ASCII_PRINTABLE_MIN

        mov     rsp, rbp
        pop     rbp

        ret


; int RandomInt(unsigned int max)
; Generate and return a random 32-bit unsigned integer in the range (0, max].
RandomInt:
        push    rbp
        mov     rbp, rsp

        rdrand  rax
        xor     rdx, rdx
        div     rdi
        mov     rax, rdx

        mov     rsp, rbp
        pop     rbp

        ret


; void RandomString(char *dst, unsigned int len)
; Write a random string of the given length to the destination buffer.
RandomString:
        push    rbp
        mov     rbp, rsp

        push    r12
        push    r13

        mov     r12, rdi
        mov     r13, rsi

        add     r12, r13
        mov     BYTE [r12], 0x0
        dec     r12

.loop:  call    RandomChar
        mov     BYTE [r12], al
        dec     r12
        dec     r13
        jnz     .loop

        pop     r13
        pop     r12

        mov     rsp, rbp
        pop     rbp

        ret


; void StringCopy(char *dst, char *src)
; Copy the source string to the destination buffer.
StringCopy:
        push    rbp
        mov     rbp, rsp

        push    r12
        push    r13

        mov     r12, rdi
        mov     r13, rsi

        mov     rdi, r13
        call    StringLength
        inc     rax

        mov     rdi, r12
        mov     rsi, r13
        mov     rcx, rax
        cld
        rep     movsb

        pop     r13
        pop     r12

        mov     rsp, rbp
        pop     rbp

        ret


; int StringLength(char *str)
; Return the length of a null-terminated string.
StringLength:
        push    rbp
        mov     rbp, rsp

        xor     rax, rax
        xor     rcx, rcx
	    not     rcx
	    cld
        repne   scasb
	    not     rcx
	    dec     rcx
        mov     rax, rcx

        mov     rsp, rbp
        pop     rbp

        ret


; void StringReplace(char *dst, char *src, unsigned int start, unsigned int end)
; Replaces the range [start, end) in the destination string with characters
; from the source string.
StringReplace:
        push    rbp
        mov     rbp, rsp

        add     rdi, rdx
        sub     rcx, rdx
        cld
        rep     movsb

        mov     rsp, rbp
        pop     rbp

        ret


; int StringToInt(char *str)
; Convert a string representation of a decimal to a 32-bit unsigned integer.
StringToInt:
        push    rbp
        mov     rbp, rsp

        push    r12

        mov     r12, rdi

        call    StringLength
        mov     rdi, rax

        xor     rax, rax
        mov     rsi, 0xa

.loop:  mul     rsi
        movsx   rdx, BYTE [r12]
        inc     r12
        sub     rdx, 0x30
        add     rax, rdx
        dec     rdi
        jnz     .loop

        pop     r12

        mov     rsp, rbp
        pop     rbp

        ret


; void Tab()
; Write the tab character to standard output.
Tab:
        push    rbp
        mov     rbp, rsp

        push    ASCII_TAB
        mov     rdi, rsp
        call    WriteString

        mov     rsp, rbp
        pop     rbp

        ret


; void WriteInt(unsigned int num)
; Write a 32-bit unsigned integer as a decimal to standard out.
WriteInt:
        push    rbp
        mov     rbp, rsp

        sub     rsp, 0xb

        mov     rax, rdi
        mov     rsi, 0xa
        lea     rdi, [rsp + 0xa]
        mov     BYTE [rdi], 0x0

.loop:  xor     rdx, rdx
        div     rsi
        add     rdx, 0x30
        dec     rdi
        mov     BYTE [rdi], dl
        test    rax, rax
        jnz     .loop

        call    WriteString

        add     rsp, 0xb

        mov     rsp, rbp
        pop     rbp

        ret


; void WriteString(char *str)
; Write a null-terminated string to standard output.
WriteString:
        push    rbp
        mov     rbp, rsp

        push    r12

        mov     r12, rdi

        call    StringLength

        mov     rdi, STDOUT
        mov     rsi, r12
        mov     rdx, rax
        mov     rax, SYS_WRITE
        syscall

        pop     r12

        mov     rsp, rbp
        pop     rbp

        ret
