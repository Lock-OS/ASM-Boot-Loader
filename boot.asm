bits 16
org  0x7C00

start:
        xor ax, ax
        mov ds, ax
        mov si, msg

.print_char:
        lodsb
        test al, al
        jz   .newline

        call print_char

        call delay
        jmp .print_char

.newline:
        mov al, 0x0D
        call print_char
        mov al, 0x0A
        call print_char
        jmp print_lock_logo

hang:
        jmp $

print_char:
        mov ah, 0x0E
        mov bh, 0
        mov bl, 0x07
        int 0x10
        ret

delay:
        push ax
        push bx
        push cx

        in al, 0x40
        mov ah, 0
        mov cx, ax
        and cx, 0x001F
        add cx, 13

.delay_outer:
        mov bx, 250
.delay_mid:
        mov ax, 12500
.delay_inner:
        dec ax
        jnz .delay_inner

        dec bx
        jnz .delay_mid
        loop .delay_outer

        pop cx
        pop bx
        pop ax
        ret

set_cursor:
        mov ah, 0x02
        mov bh, 0
        int 0x10
        ret

msg     db "Copyright @ Amir Arsalan Yavari", 0
lock_os_text_msg db "Lock OS", 0
stuck_msg db "This OS is locked, so the boot loader can't boot it. You're stuck at it... HeHe.", 0

lock_logo:
        db '    .-\"-.', 0x0D, 0x0A, 0
        db '   / .--. \', 0x0D, 0x0A, 0
        db '  / /    \ \', 0x0D, 0x0A, 0
        db '  | |    | |', 0x0D, 0x0A, 0
        db '  | |.-\"-.|', 0x0D, 0x0A, 0
        db ' ///`.::::.`\', 0x0D, 0x0A, 0
        db '||| ::/  \:: ;', 0x0D, 0x0A, 0
        db '||; ::\__/:: ;', 0x0D, 0x0A, 0
        db " \\\ '::::' /", 0x0D, 0x0A, 0
        db "  `='':-..-'", 0x0D, 0x0A, 0

        db 0 ;

print_lock_logo:
        mov si, lock_logo
        mov dh, 12
.print_lock_line:
        cmp byte [si], 0
        je .write_lock_os_text_after_logo
        
        mov dl, 29
        call set_cursor

.print_lock_char:
        lodsb
        test al, al
        jz .next_lock_line

        cmp al, 0x0D
        je .print_lock_char
        cmp al, 0x0A
        je .print_lock_char

        call print_char
        jmp .print_lock_char

.next_lock_line:
        inc dh
        jmp .print_lock_line

.write_lock_os_text_after_logo:
        mov dh, 16
        mov dl, 33
        call set_cursor

        mov si, lock_os_text_msg
.print_lock_os_text_char:
        lodsb
        test al, al
        jz   .print_stuck_message

        call print_char
        call delay
        jmp .print_lock_os_text_char

.print_stuck_message: 
        mov dh, 23
        mov dl, 0
        call set_cursor

        mov si, stuck_msg
.print_stuck_char_loop:
        lodsb
        test al, al
        jz   hang

        call print_char
        
        jmp .print_stuck_char_loop

        times 510-($-$$) db 0
        dw 0xAA55