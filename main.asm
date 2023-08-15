section .data
    filename: db '', 0
    append_text: db ',', 0

section .bss
    bssbuf: resb 1024
    file: resb 4

global _start

section .text

_start:
    pop ebx ; argc
    pop ebx ; argv[0]
    mov filename, ebx
    
    ; open file in read-write mode
    mov eax, 5 ; sys_open file with fd in ebx
    mov ebx, filename ; file to be opened
    mov ecx, 2 ; O_RDWR
    int 80h

    cmp eax, 0 ; check if fd in eax > 0 (ok)
    jbe error ; can not open file

    mov ebx, eax ; store new (!) fd of the same file

read_loop:
    ; read from file into bss data buffer
    mov eax, 3 ; sys_read
    mov ecx, bssbuf ; pointer to destination buffer
    mov edx, 1 ; length of data to be read (one byte at a time)
    int 80h

    cmp eax, 0 ; check if end of file reached
    je close

    cmp byte [bssbuf], 10 ; check if newline character reached
    jne read_loop

    ; write append_text to file at current position
    mov eax, 4 ; sys_write
    push ebx ; save fd on stack for sys_lseek
    mov ecx, append_text ;pointer to buffer with data to be written
    mov edx, 5 ; length of data to be written (length of append_text)
    int 80h

    pop ebx ; restore fd in ebx from stack

    jmp read_loop

close:
    mov eax, 6 ; sys_close file
    int 80h

error:
    mov ebx, eax ; exit code
    mov eax, 1 ; sys_exit
    int 80h
