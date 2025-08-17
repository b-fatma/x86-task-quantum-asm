data segment 
    compt db 18
    ancien_cs dw ?
    ancien_ip dw ?
    msg0 db 10, 13, "**** Debut du quantum de temps logiciel **** $"
    msg1 db "1 sec ecoulee...... $"
    msg2 db "Deroutement fait", 10, 13, "$"
    delai db 1
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
    
    ;lecture de l int 1CH
    ;fonction 35H de l int 21H    E: AH = 35H / AL = 1CH / ES:BX = ancien_cs:ancien_ip
    sauvegarde proc near
    push ds
    mov ax, 351CH
    int 21H
    mov ancien_cs, es
    mov ancien_ip, bx
    pop ds
    ret
    sauvegarde endp
    
    ;insallation de l int 1CH avec la fonction 25H de l int 21H
    ;E: AL = 21H / AH = 1CH / DS:DX = ancien_cs:ancien_ip
    ;on restaure l int 1CH apres l ecoulement de 5 min
    restauration proc near
    push ds
    mov ax, ancien_cs
    mov ds, ax
    mov dx, ancien_ip
    mov ax, 251CH
    int 21H
    pop ds
    ret
    restauration endp
    
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
         push offset msg1
         call near ptr afficherChaine
         mov compt, 18
    fin:
         iret
        
    
    start:
    mov ax, data
    mov ds, ax
    mov ax, pile
    mov ss, ax
    lea sp, tos
    
    ;on sauvegarde l adresse de la routine 1CH avant de faire le deroutement
    call near ptr sauvegarde
    call near ptr deroutement
    
    push offset msg2
    call near ptr afficherChaine
    
    infini:
    push offset msg0
    call near ptr afficherChaine
    
    mov cx,294CH
    ext: mov si,0AF5H
    intern : dec si 
    jnz intern
    loop ext
    
    ;delai est initialise a 15, il se decremente toutes les 20 secondes
    ;quand il s'annule on sort de la boucle
    ;donc le programme va s executer pendant 15*20s, soient 5 min
    dec delai
    jnz infini
    
    ;on remet l int 1CH a son etat initial
    call near ptr restauration

    mov ax, 4C00H
    int 21H
code ends
end start