data segment 
    compt db 18
    msg0 db 10, 13, "**** Debut du quantum de temps logiciel **** $"
    msg1 db "1 sec ecoulee...... $"
    msg2 db "Deroutement fait", 10, 13, "$"
data ends

pile segment stack
    dw 128 dup(?)
    tos label word
pile ends

code segment
    assume cs: code, ds: data, ss: pile
    
    ;procedure qui affiche la chaine de caractere dont l offset a ete empile avant d appeler la procedure
    ;fonction 9 de l int 21H    E: AH = 9 / DX = offset chaine
    afficherChaine proc near
    push bp
    mov bp, sp
    mov dx, [bp+4]
    mov ah, 9h 
    int 21h
    pop bp
    ret 2
    afficherChaine endp
    
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
         ;affichage de la chaine 1 sec ecoulee avec la procedure afficherChaine
         push offset msg1
         call near ptr afficherChaine
         mov compt, 18 ;la routine s execute chaque 18*55ms, a peu pres chaque seconde
    fin:
         iret
        
    
    start:
    mov ax, data
    mov ds, ax
    mov ax, pile
    mov ss, ax
    lea sp, tos
    
    call near ptr deroutement ;appel a la procedure de deroutement
    
    push offset msg2
    call near ptr afficherChaine ;affichage de la chaine Deroutement fait
    
    ;le quantum logiciel
    infini:
    
    push offset msg0
    call near ptr afficherChaine ;affichage de la chaine **** Debut du quantum de temps logiciel ****
    
    ;2 boucles imbriquees pour realiser un delai de 20 secondes
    mov cx,294CH
    ext: mov si,0AF5H
    intern : dec si 
    jnz intern
    loop ext
    
    jmp infini

    mov ax, 4C00H
    int 21H
code ends
end start