MY_DATA SEGMENT
        x   db  ?
        y   dw  ?
        z   dd  ?
        msgMenu         db      "Menu",0dh,0ah,"1)Op1   4)Op4",0dh,0ah,"2)Op2   5)Salir",0dh,0ah,"3)Op3",0dh,0ah,'$'
        msgError        db      0dh,0ah,"Solo ingrese opciones validas",0dh,0ah,'$'
        msgOp1          db      0dh,0ah,"AutoFantastico",0dh,0ah,'$'
        msgOp2          db      0dh,0ah,"Choque",0dh,0ah,'$'
        msgOp3          db      0dh,0ah,"Opcion 3",0dh,0ah,'$'
        msgOp4          db      0dh,0ah,"Opcion 4",0dh,0ah,'$'
        msgLimpiar      db      0ah,0dh,'$'
        msgGuia         db      0dh,0ah,"Flecha arriba:Aumenta velocidad",0dh,0ah,"Flecha abajo:Disminuye velocidad",0dh,0ah,"Cualquier otra tecla:salir",0dh,0ah,'$'
        direccion       dw      offset op1,offset op2,offset op3,offset op4,offset fin
        clave           db      "Clave"
        almacen         db      5 dup(?)
        msPassword      db      0dh,0ah,"Ingrese la constraseña:",0dh,0ah,'$'
        msIncorrecta    db      0dh,0ah,"Clave incorrecta",0dh,0ah,'$'
        msError         db      0dh,0ah,"Se exedió de los intentos posibles",0dh,0ah,'$'
        msBienvenida    db      0dh,0ah,"Bienvenido al sistema",0dh,0ah,'$'
        tabla           db      81h,42h,24h,18h,18h,24h,42h,81h
        vel1            dw      0100h
        vel2            dw      0100h
        max1            dw      0100h
        min1            dw      0012h
        salto           dw      0011h
MY_DATA ENDS
;
MY_EXTRA SEGMENT
        alpha db  ?
        beta  dw  ?
        gamma dd  ?
MY_EXTRA ENDS
;
MY_STACK SEGMENT
        dw  100 dup(?)
top     equ this word
MY_STACK ENDS
;
MY_CODE SEGMENT

  ASSUME CS:MY_CODE,DS:MY_DATA
  ASSUME ES:MY_EXTRA,SS:MY_STACK
        ORG 100H
;
start:
  mov ax,MY_DATA      ;Inicializa DS
        mov ds,ax
        mov ax,MY_EXTRA     ;Inicializa ES
        mov es,ax
        mov ax,MY_STACK     ;Inicializa SS
        mov ss,ax
        mov sp,offset top   ;Inicializa SP
;
;Metodo que se encarga de pedir la constrasenia
;al usuario
;a
        mov cx,03h
aciclo: push cx
        mov cx,05h
        mov dx,offset msPassword
        call mostrarMsg 
        mov bx,offset almacen   
aingreso:mov ah,06h
        mov dl,0ffh
        int 21h
        jz aingreso
        mov [bx],al
        inc bx
        mov ah,06h
        mov dl,2ah
        int 21h
        loop aingreso
        call compare
        jz asigue
        mov dx,offset msIncorrecta
        call mostrar
        call limpiar
        pop cx
        loop aciclo
        mov dx,offset msError
        call mostrar
        call fin
asigue: mov dx,offset msBienvenida
        call mostrar
;
;Menu que se muestra al usuario con las opciones pertinentes
menu:   call limpiar
        mov dx,offset msgMenu
        call mostrarMsg
        mov ah,01
        int 21h
        mov bx,0
        mov bl,al
        sub bl,31h
        cmp bl,04h
        ja  msig
        sal bx,1
        push bx
        mov dx,offset msgGuia
        call [bx+offset direccion]
        jmp menu
msig:   mov dx,offset msgError
        call mostrar
        jmp menu
;
;Autofantastico
op1:    call mostrarMsg
        mov dx,offset msgOp1
        call mostrarMsg
        call autof
        ret
;Choque
op2:    call mostrarMsg
        mov dx,offset msgOp2
        call mostrarMsg
        mov di,offset tabla
        mov si,offset vel2
        mov cx,08h
        call mosSec
        ret
;
op3:    mov dx,offset msgOp3
        call mostrar
        ret
;
op4:    mov dx,offset msgOp4
        call mostrar
        ret
;
;
;Metodo que termina la ejecucion del programa
fin:    mov ah,4ch
        mov al,00h
        int 21h
;
;Metodo que se encarga de mostrar en pantalla
;el mensaje que se pase por dl, y luego esperar
;un rato
mostrar:mov ah,09h
        int 21h
        mov cx,0ffffh
        call delay
        mov cx,00d0h
        call delay
        ret
;
;Metodo que se encarga de limpiar la pantalla
;b
limpiar:mov cx,22
bciclo: mov ah,09h
        mov dx,offset msgLimpiar
        int 21h
        loop bciclo
        ret
;
;Metodo que muestra el mensaje pasado por dx
;sin retardo
mostrarMsg:     mov ah,09h
                int 21h
                ret
;
;Metodo que se encarga de comparar la clave
;con la ingresada por el usuario
;c
compare:mov bx,offset clave
        mov cx,05h
        mov di,offset almacen
cciclo: mov al,[di]
        cmp al,[bx]
        jnz cret
        inc bx
        inc di
        dec cx
        jnz cciclo
cret:   ret
;
;Metodo que se encarga de mostrar una secuencia por tabla.
;El inicio de la secuencia a mostrar se pasa por di,la 
;velocidad correspondiente por si, y el tamanio de la
;tabla por cx
;Letra:d
mosSec: mov bx,00h
        push cx
dciclo: mov al,[di+bx]
        push cx
        push bx
        call output
        mov bx,[si]           
        call delay      
        mov [si],bx          
        cmp al,01h
        jz dret
        pop bx
        pop cx                        
        inc bx
        loop dciclo
        pop cx
        jmp mosSec
dret:   pop bx
        pop cx
        pop cx
        ret
;
;Metodo que se encarga de mostrar por pantalla el numero
;pasado por al, de la forma '__*__' por ejemplo
;e
output: mov cx,08h
ebucle: push cx
        mov dl,2ah
        rol al,01h
        jc  euno
        mov dl,'_'
euno:   mov ah,06h
        push ax
        int 21h
        pop ax
        pop cx
        loop ebucle
        mov dl,0dh
        mov ah,06h
        int 21h
        ret         
;
;Metodo que se encarga de generar un delay de la velocidad
;que se le pase por bx(bucle interno).Se repite 14 veces el bucle
;interno. Si se selecciona la flecha hacia arriba diminuye la 
;velocidad, si se selecciona la flecha hacia abajo 
;la aumenta, sin pasarse de los limites que son:
;min1,max1, realizando modificaciones iguales a salto
;g
delay:  mov cx,0eh
gciclo: push cx
        mov cx,bx
gciclo1:push bx
        call sens
        pop bx
        cmp al,48h
        jnz gotro
        cmp bx,[min1]   
        je glup
        sub bx,[salto]
        cmp cx,[salto]
        jbe gahead
        sub cx,[salto]               
gahead: jmp glup
gotro:  cmp al,50h
        jnz  gotro1
        cmp bx,[max1]
        je glup
        add bx,[salto]
        jmp glup
gotro1: cmp al,01h      
        jz gret
glup:   loop gciclo1
        pop cx
        loop gciclo
        ret
gret:   pop cx
        ret
;
;Funcion que lee el teclado y manda por al  01h si se desea
;salir, o el valor de la flecha correspondiente si se desea 
;modificar la velocidad.Se envia 00h si no se toco nada.
;e
sens:   mov ah,06h
        mov dl,0ffh
        int 21h
        jnz esigue 
        mov al,00h
        jmp eret
esigue: or al,00h
        jnz eOut
        mov ah,06h
        mov dl,0ffh
        int 21h
        cmp al,48h
        jz  eret
        cmp al,50h
        jz eret
eOut:   mov al,01h
eret:   ret
;
;Metodo que muestra por algoritmo
;la secuencia del auto fantastico
;f
autof:  mov al,80h
fciclo: push ax
        call output
        mov bx,[vel1]
        call delay
        mov [vel1],bx
        cmp al,01h
        jz fret
        pop ax
        shr al,1h
        cmp al,01h
        jnz fciclo
fciclo1:push ax
        call output
        mov bx,[vel1]
        call delay
        mov [vel1],bx
        cmp al,01h
        jz fret
        pop ax
        shl al,1h
        cmp al,80h
        jnz fciclo1
        jz autof  
fret:   pop ax
        ret
MY_CODE ENDS
;
        end start
