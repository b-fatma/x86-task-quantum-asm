data segment 
    compt db 91
    msg1 db "Tache$"
    msg2 db " est en cours d execution ",10,13,"$"
    msg3 db 10,13,"$"
    msg0 db "Deroutement fait", 10,10,13, "$"
    cpt db 1
data ends

pile segment stack
    dw 128 dup(?)
    tos label word
pile ends

code segment
    assume cs: code, ds: data, ss: pile
    
    ;procedure qui affiche la chaine de caractere dont l offset a ete empile avant d appeler la procedure
    ;fonction 9 de l int 21H    E: AH = 9 / DX = offset chaine
    afficherChaine proc
    push bp
    mov bp, sp
    mov dx, [bp+4]
    mov ah, 9h
    int 21h
    pop bp
    ret 2
    afficherChaine endp
    
    ;procedure qui affiche l entier empile avant d appeler la procedure
    ;fonction 2 de l int 21H    E: AH = 2 / DL = code ascii correspondant a l entier
    afficherDecimal proc
    push bp
    mov bp, sp
    mov ax, [bp+4]
    add al, 30h ;on rajoute 30 pour obtenir le code ascii
    mov dl, al
    mov ah, 2h
    int 21h
    pop bp
    ret 2
    afficherDecimal endp
    
    
    ;la procedure d affichage 
    affichage proc near
    mov ax, data
    mov ds, ax
    
    ;affichage de la chaine    Tache 
    push offset msg1
    call near ptr afficherChaine
    
    mov al, cpt ;cpt contient le numero de la tache
    xor ah, ah
    push ax
    ;affichage du numero de la tache 
    call near ptr afficherDecimal
    
    ;affichage de la chaine   est en cours d execution
    push offset msg2
    call near ptr afficherChaine
    
    ;mise a jour de cpt
    cmp cpt,4
    je b
    inc cpt           ;si cpt est different de 4, on l incremente
    jmp fin1
    
    b:                ;sinon:
    mov cpt,1h        ;on reinitialise cpt
    push offset msg3  ;on affiche un saut de ligne
    call near ptr afficherChaine
    
    fin1: 
    ret
    affichage endp
    
    
    ;procedure qui fait le deroutement de l int 1CH
    ;fonction 25H de l int 21H qui installe un vecteur un vecteur d int
    ;E: AL = 21H / AH = 1CH / DS:DX = adresse de la nouvelle routine 
    deroutement proc near
    push ds
    mov ax, seg new
    mov ds, ax
    mov dx, offset new
    mov ax, 251CH
    int 21H
    pop ds
    ret
    deroutement endp
    
    ;la routine de deroutement
    new: 
         dec compt
         jnz fin
         call near ptr affichage ;appel a la procedure chaque 5 secondes
         mov compt, 91           ;on utilise compt pour controler les delais
    fin:
         iret
        
    
    start:
    mov ax, data
    mov ds, ax
    mov ax, pile
    mov ss, ax
    lea sp, tos
    
    call near ptr deroutement
    
    push offset msg0
    call near ptr afficherChaine
      
    infini:
    jmp infini
    
    mov ax, 4C00H
    int 21H
code ends
end start