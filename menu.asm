MY_DATA SEGMENT
	x   db  ?
	y   dw  ?
	z   dd  ?
	msgMenu db "Menu",0dh,0ah,"1)Op1   4)Op4",0dh,0ah,"2)Op2   5)Salir",0dh,0ah,"3)Op3",0dh,0ah,'$'
	msgError db 0dh,0ah,"Solo ingrese opciones validas",0dh,0ah,'$'
	msgOp1 db 0dh,0ah,"Auto fantastico",0dh,0ah,'$'
	msgOp2 db 0dh,0ah,"Choque",0dh,0ah,'$'
	msgOp3 db 0dh,0ah,"Opcion 3",0dh,0ah,'$'
	msgOp4 db 0dh,0ah,"Opcion 4",0dh,0ah,'$'
	msgLimpiar db 0ah,0dh,'$'
	direccion dw offset bop1,offset bop2,offset bop3,offset bop4,offset fin
	clave db  "Clave"
	almacen db  5 dup(?)
	msPassword db  0dh,0ah,"Ingrese la constraseña:",0dh,0ah,'$'
	msIncorrecta db  0dh,0ah,"Clave incorrecta",0dh,0ah,'$'
	msError db  0dh,0ah,"Se exediñ de los intentos posibles",0dh,0ah,'$'
	msBienvenida db  0dh,0ah,"Bienvenido al sistema",0dh,0ah,'$'
	tabla1 db 81h,42h,24h,18h,18h,24h,42h,81h
	vel1 dw 0f00h
	vel2 dw 0f00h
;	vel3 dw 0f00h
;	vel4 dw 0f00h

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

start: 	mov ax,MY_DATA      ;Inicializa DS
	mov ds,ax
	mov ax,MY_EXTRA     ;Inicializa ES
	mov es,ax
	mov ax,MY_STACK     ;Inicializa SS
	mov ss,ax
	mov sp,offset top   ;Inicializa SP

; Instrucciones para el calulo de la contraseña Contraseña
; Parte a
	mov cx,03h
aciclo:	push cx
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
	pop cx
	mov dx,offset msIncorrecta
	push cx
	call mostrarMsg
	mov cx,0f00h
	call delay
	call limpiar
	pop cx
	loop aciclo

	mov dx,offset msError
	call mostrarMsg
	mov cx,0f00h
	call delay
	call fin

asigue:	mov dx,offset msBienvenida
	call mostrarMsg
	mov cx,0f00h
	call delay

; Intrucciones para el menu
; Parte b
menu:	call limpiar
	mov ah,09h
	mov dx,offset msgMenu
	int 21h
	mov ah,01
	int 21h
	mov bx,0
	mov bl,al
	sub bl,31h
	cmp bl,04h
	ja error
	sal bx,1
	call limpiar
	call [offset direccion+bx]
	jmp menu

bop1:	mov dx,offset msgOp1
	mov bx,[vel1]
	call mostrarMsg
	call auto
	mov [vel1],bx
	ret

bop2:	mov dx,offset msgOp2
	mov bx,[vel2]
	call mostrarMsg
	call choque
	mov [vel2],bx
	ret

bop3:	mov dx,offset msgOp3
	call mostrarMsg
	mov cx,0fffh
	call delay
	ret

bop4:	mov dx,offset msgOp4
	call mostrarMsg
	mov cx,0fffh
	call delay
	ret


; Instrucciones para mostrar el mensaje de error.
error:	mov ah,09
	mov dx,offset msgError
	int 21h
	jmp menu

; Instrucciones para limpiar la pantalla.
; Parte c
limpiar:mov cx,23
cbucle:	mov ah,09h
	mov dx,offset msgLimpiar
	int 21h
	loop cbucle
	ret

; Intrucciones para mostrar un mensaje en la pantalla, hay que pasar
;la direccion del mensaje en dx.
mostrarMsg:
	mov ah,09h
	int 21h
	ret

; Intrucciones para comparar las contraseñas.
; Parte d
compare:mov bx,offset clave
	mov cx,05h
	mov di,offset almacen
dciclo:	mov al,[di]
	cmp al,[bx]
	jnz dretorno
	inc bx
	inc di
	dec cx
	jnz dciclo
dretorno:ret

; Intrucciones para mostrar en la pantalla un patron dependiendo del valor
;que contenga al.
; Parte e
output: mov cx,08h
eciclo:	push cx
	mov dl,'_'
	rol al,1
	jnc esigue
	mov dl,'*'
esigue:	mov ah,06h
	push ax
	int 21h
	pop ax
	pop cx
	loop eciclo
	push ax
	mov dl,0dh
	mov ah,06h
	int 21h
	pop ax
	ret

; Instrucciones para pausar el programa, hay que cargar cx previamente.
; Parte f
delay:	call esPrecionada
	jnz fsigue
	loop delay
fsigue:	ret

; Instrucciones para ver si una tecla es precionada de ser
;precionada se saldra de la secuencia con el al=1 a menos
;que se precine las teclas arriba y abajo que aumenta la
;velocidad o la disminuye respectivamente.
; Parte g
esPrecionada:
	mov ah,06
	mov dl,0ffh
	int 21h
	jz gsetAl
	mov ah,06
	mov dl,0ffh
	int 21h
	cmp al,48h
	jnz gsigue
	cmp bx,0100h
	je gsalir
	sub bx,0100h
	jmp gsalir
gsigue:	cmp al,50h
	jnz gsalir
	cmp bx,0f00h
	je gsalir
	add bx,0100h
	jmp gsalir
gsetAl:	mov al,1
gsalir:	ret

;secuencia del auto fantastico
;Parte h
auto:	mov al,80h
	mov cx,8
hciclo1:push ax
	call output
	mov cx,bx
	call delay
	cmp al,0
	jz hfin
	pop ax
	shr al,1
	jnz hciclo1

	mov al,01h
hciclo2:push ax
	call output
	mov cx,bx
	call delay
	cmp al,0
	jz hfin
	pop ax
	shl al,1
	jnz hciclo2
	jmp auto
hfin:	pop ax
	ret


; Secuencia de choque
; Parte i
choque:	mov cx,8
	mov di,0
iciclo:	push cx
	mov al,[di + offset tabla1]
	call output
	mov cx,bx
	call delay
	cmp al,0
	jz ifin
	inc di
	pop cx
	loop iciclo
	jmp choque
ifin:	pop cx
	ret



fin:	mov ah,4ch
	mov al,00
	int 21h

MY_CODE ENDS
;
	end start
