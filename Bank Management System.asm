display macro p1
    mov dx, offset p1
    mov ah, 9
    int 21h
endm

newline macro
    mov dl, 10
    mov ah, 2
    int 21h
    mov dl, 13
    mov ah, 2
    int 21h
endm

.model small
.stack 100h
.data 

    msg1 db 'szabist $'
    msg2 db 'please enter your password: $'
    msg3 db 10, 13, 'password is correct$'
    msg4 db 10, 13, 'invalid password, try again', 10, 13, '$'
    
    username1 db 'abc $'
    password1 db 'SZABIST $'
    
    username2 db 'xyz $'
    password2 db 'PASS123 $'
       
    username db 'abc $'
    prompt1 db 'please enter your username: $'
    prompt2 db 10, 13, 'username is correct$'
    prompt3 db 10, 13, 'invalid username, try again', 10, 13, '$'
    inputmsg db 'enter your choice from above menu: $'
    welcome_msg db 'bank management system$'
    menu_msg db 10, 13, '1. check balance', 10, 13, '2. deposit', 10, 13, '3. withdraw', 10, 13, '4. exit$'
    bal_msg db 10, 13, 'current balance: $'
    dep_msg db 10, 13, 'enter deposit amount (3 digits): $'
    with_msg db 10, 13, 'enter withdrawal amount (3 digits): $'
    insuf_msg db 10, 13, 'insufficient balance!$'
    success_msg db 10, 13, 'transaction successful!$' 
    optionmsg db 'want to continue (press c) or exit (press e)? $'
    error_msg db 'invalid input! please try again.', '$'
    balance dw 500
    temp dw ?

.code
main proc
    mov ax, @data
    mov ds, ax

    display welcome_msg
    newline
    display menu_msg

    again:
    newline
    display prompt1
    mov cx,3
    mov si,Offset username1
    mov di,Offset username2
    xor bx, bx 
    
    L2:
    mov ah,7
    int 21h
    mov bl,al
    mov dl,al
    mov ah,2
    int 21h
    cmp [si],bl
    je L2_continue
    cmp [di],bl
    je L2_continue2
    jmp incorrect
    
    L2_continue:
    inc si
    loop L2
    mov bx, 1 
    display prompt2
    jmp start_user1
    
    L2_continue2:
    inc di
    loop L2
    mov bx, 2 
    display prompt2
    jmp start_user2

incorrect:
    display prompt3
    jmp again 
    
start_user1:
    newline
    display msg2
    mov si,Offset password1
    mov cx,7
    call check_password
    jmp compare
   
start_user2:
    newline
    display msg2
    mov si,Offset password2
    mov cx,7
    call check_password
    jmp compare

compare: 
    newline
    display inputmsg
    mov ah, 1
    int 21h

    cmp al, '1'
    je check_balance
    cmp al, '2'
    je deposit
    cmp al, '3'
    je withdraw
    cmp al, '4'
    je exit
    jmp compare

check_balance: 
    newline
    display bal_msg
    mov ax, balance
    call display_num
    jmp validation

deposit:
    newline
    display dep_msg
    call input_num
    cmp ax, -1
    je invalid_input_deposit
    mov bx, balance
    add bx, ax
    mov balance, bx
    display success_msg
    jmp validation

withdraw: 
    newline
    display with_msg
    call input_num
    cmp ax, -1
    je invalid_input_withdraw
    mov temp, ax
    mov bx, balance
    cmp bx, temp
    jl insufficient
    sub bx, temp
    mov balance, bx
    display success_msg
    jmp validation

insufficient:  
    newline
    display insuf_msg
    jmp validation

invalid_input_deposit:
    newline
    display error_msg
    jmp deposit

invalid_input_withdraw:
    newline
    display error_msg
    jmp withdraw

validation:
    newline
    newline
    display optionmsg
    mov ah, 1
    int 21h
    cmp al, 'c'
    je menu
    cmp al, 'e'
    je exit
    jmp validation

menu:
    newline
    display menu_msg
    jmp compare

exit:
    mov ah, 4ch
    int 21h

main endp

input_num proc
    xor ax, ax

input_hundreds:
    mov ah, 1
    int 21h
    cmp al, '0'
    jl error
    cmp al, '9'
    jg error
    sub al, '0'
    mov bl, 100
    mul bl
    mov bx, ax

input_tens:
    mov ah, 1
    int 21h
    cmp al, '0'
    jl error
    cmp al, '9'
    jg error
    sub al, '0'
    mov cl, 10
    mul cl
    add bx, ax

input_ones:
    mov ah, 1
    int 21h
    cmp al, '0'
    jl error
    cmp al, '9'
    jg error
    sub al, '0'
    xor ah, ah
    add bx, ax
    mov ax, bx
    ret

error:
    mov ax, -1
    ret

input_num endp

display_num proc
    mov bx, 10
    mov cx, 0

divide:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz divide

display:
    pop dx
    add dl, '0'
    mov ah, 2
    int 21h
    loop display
    ret

display_num endp


check_password proc
    L1:
    mov ah,7
    int 21h
    mov bl,al
    mov dl,'*'
    mov ah,2
    int 21h
    cmp [si],bl
    jne incorrect1
    inc si
    loop L1
    display msg3
    ret
  
incorrect1:
    display msg4
    jmp again
check_password endp

end main