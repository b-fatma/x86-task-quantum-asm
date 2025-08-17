data segment 
    compt db 91
    ancien_cs dw ?
    ancien_ip dw ?
    msg1 db "Tache$"
    msg2 db " est en cours d execution ",10,13,"$"
    msg3 db 10,13,"$"
    msg0 db "Deroutement fait", 10,10,13, "$"
    cpt db 1
    delai db 15
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
    add al, 30h
    mov dl,al
    mov ah,2h
    int 21h
    pop bp
    ret 2
    afficherDecimal endp
    
    ;la procedure d affichage
    affichage proc near
    mov ax, data
    mov ds, ax 
    push offset msg1
    call near ptr afficherChaine
    mov al,cpt
    xor ah,ah
    push ax
    call near ptr afficherDecimal
    push offset msg2
    call near ptr afficherChaine
    cmp cpt,4
    je b
    inc cpt
    jmp fin1
    b:
    dec delai ;la variable delai se decremente toutes les 20secondes quand cpt = 4
    mov cpt,1h
    push offset msg3
    call near ptr afficherChaine
    fin1: 
    ret
    affichage endp
    
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
         call near ptr affichage
         mov compt, 91
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
    
    push offset msg0
    call near ptr afficherChaine
      
    infini:
    cmp delai, 0
    jne infini ;on ne boucle que si delai est different de 0 pour que l execution s arrete apres 5 min
    
    ;on remet l int 1CH a son etat initial
    call near ptr restauration
    
    mov ax, 4C00H
    int 21H
code ends
end start