@;=                                                               		=
@;=== candy1_combi.s: rutinas para detectar y sugerir combinaciones   ===
@;=                                                               		=
@;=== Programador tarea 1G: albert.canellas@estudiants.urv.cat				  ===
@;=== Programador tarea 1H: albert.canellas@estudiants.urv.cat				  ===
@;=                                                             	 	=



.include "../include/candy1_incl.i"



@;-- .text. c�digo de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1G;
@; hay_combinacion(*matriz): rutina para detectar si existe, por lo menos, una
@;	combinaci�n entre dos elementos (diferentes) consecutivos que provoquen
@;	una secuencia v�lida, incluyendo elementos en gelatinas simples y dobles.
@;	Par�metros:
@;		R0 = direcci�n base de la matriz de juego
@;	Resultado:
@;		R0 = 1 si hay una secuencia, 0 en otro caso
	.global hay_combinacion
hay_combinacion:
		push {r1-r12,lr}
				mov r4, r0						;@*Moviment horitzontal guardar direcio base
				mov r3, #ROWS					;@dim de files
				mov r12, #COLUMNS				;@dim de columnes
				mov r0, #0						;@variable que controla si s'ha trobat una combinacio
				mov r1, #0						;@r1=files , inicialitza a 0 per fer totes les files en el mov. hor
				mov r2, #0						;@r2=columnes,
				sub r12, #1						;@c<columns-1
			.Lwhilef1:
				cmp r1, r3						;@comprovar condicio f<rows === es  igual a aixo f<rows?????
				bge .Lfinwhilef1				;@saltar a final del while de files
				cmp r0, #6						;@comprovar que no s'hagi trobat ja una combinacio
				beq .Lfi
				.Lwhilec1:
					cmp r2, r12
					bge .Lfinwhilec1
					cmp r0, #6
					beq .Lfinwhilec1
					mul r5, r1 ,r3
					add r5, r2					;@r5=despla�ament(rows*f+c)
					ldrb r6, [r4, r5]			;@r6= tipus de gelatina actual
					cmp r6, #0
					beq .Lif1
					cmp r6, #7
					beq .Lif1
					cmp r6, #15
					beq .Lif1					;@comparacio amb llocs especials
					add r5, #1
					ldrb r8, [r4, r5]			;@r8= tipus gelatina seguent			
					and r7, r6, #0x00000007		;@r7 mascara per comparar el bits de les gelatines (gelatina actual)
					and r11, r8, #0x00000007	;@r11=mascara per comparar (gelatina seguent)
					cmp r7, r11
					beq .Lgeligual
					cmp r8, #0
					beq .Lif1
					cmp r8, #7
					beq .Lif1
					cmp r8, #15
					beq .Lif1	 				;@comparacio amb gelatina seguent amb llocs especials
					strb r6, [r4, r5]			;@mov de gelatina actual a r9=actual
					sub r5, #1					;@mov de gelatina seguent a r10=seguent
					strb r8, [r4, r5]
					.Lgeligual:
					bl detectar_orientacion
					cmp r0, #6
					bne .Lfi					;@si e trobat combinacio ves al final
					add r2, #1					;@c+1
					bl detectar_orientacion
					sub r2, #1
					cmp r0, #6
					bne .Lfi					;@si e trobat combinacio ves al final
					.Lif1:
					add r2, #1
					b .Lwhilec1
				.Lfinwhilec1:
				add r1, #1
				b .Lwhilef1
			.Lfinwhilef1:	
				mov r1, #0						;@!*Moviment vertical*! r1=files , inicialitza a 0 per fer totes les files en el mov. hor
				mov r2, #0						;@r2=columnes, r1=files 
				mov r3, #ROWS					;@dim de files
				mov r12, #COLUMNS				;@dim de columnes
				add r12, #1	
				sub r3, #1						;@c<rows-1
			.Lwhilef2:
				cmp r1, r3						;@comprovar condicio f<rows === es  igual a aixo f<rows?????
				bge .Lfinwhilef2				;@saltar a final del while de files
				cmp r0, #6						;@comprovar que no s'hagi trobat ja una combinacio
				bne .Lfi
				.Lwhilec2:
					cmp r2, r12
					bge .Lfinwhilec2
					cmp r0, #6
					bne .Lfinwhilec2
					mul r5, r1 ,r3
					add r5, r2					;@r5=despla�ament(rows*f+c)
					ldrb r6, [r4, r5]			;@r6= tipus de gelatina actual
					cmp r6, #0
					beq .Lif2
					cmp r6, #7
					beq .Lif2
					cmp r6, #15
					beq .Lif2					;@comparacio amb llocs especials
					add r5, r3					;@+row al despla�ament per anar a la seguent fila
					ldrb r8, [r4, r5]			;@!*comen�a punt 3*! r8= tipus gelatina seguent			
					and r7, r6, #0x00000007		;@r7 mascara per comparar el bits de les gelatines (gelatina actual)
					and r11, r8, #0x00000007	;@r11=mascara per comparar (gelatina seguent)
					cmp r7, r11
					beq .Lgeligual2
					cmp r8, #0
					beq .Lif2
					cmp r8, #7
					beq .Lif2
					cmp r8, #15
					beq .Lif2	 				;@comparacio amb gelatina seguent amb llocs especials		strb r6, [r4, r5]	,mov r9, r6
					strb r6, [r4, r5]					;@mov de gelatina actual a r9=actual				sub r5,r3			,mov r10, r8	
					sub r5, r3					;@mov de gelatina seguent a r10=seguent						strb r8, [r4, r5]	,mov r6, r10
					strb r8, [r4, r5]			;@																			,mov r8, r9
					.Lgeligual2:
					bl detectar_orientacion		;@
					cmp r0, #6
					bne .Lfi					;@si e trobat combinacio ves al final
					add r1, #1					;@f+1
					bl detectar_orientacion
					sub r1, #1
					cmp r0, #6
					bne .Lfi					;@si e trobat combinacio ves al final
					.Lif2:
					add r2, #1
					b .Lwhilec2
				.Lfinwhilec2:
				add r1, #1
				b .Lwhilef2
			.Lfinwhilef2:	
			
		.Lfi:									;@final final 
		cmp r0, #6
		beq .Lcanv
		mov r0, #1
		b .Lfinal
		.Lcanv:
		mov r0, #0
		.Lfinal:
		pop {r1-r12,pc}



@;TAREA 1H;
@; sugiere_combinacion(*matriz, *sug): rutina para detectar una combinaci�n
@;	entre dos elementos (diferentes) consecutivos que provoquen una secuencia
@;	v�lida, incluyendo elementos en gelatinas simples y dobles, y devolver
@;	las coordenadas de las tres posiciones de la combinaci�n (por referencia).
@;	Restricciones:
@;		* se supone que existe por lo menos una combinaci�n en la matriz
@;			 (se debe verificar antes con la rutina 'hay_combinacion')
@;		* la combinaci�n sugerida tiene que ser escogida aleatoriamente de
@;			 entre todas las posibles, es decir, no tiene que ser siempre
@;			 la primera empezando por el principio de la matriz (o por el final)
@;		* para obtener posiciones aleatorias, se invocar� la rutina 'mod_random'
@;			 (ver fichero "candy1_init.s")
@;	Par�metros:
@;		R0 = direcci�n base de la matriz de juego
@;		R1 = direcci�n del vector de posiciones (char *), donde la rutina
@;				guardar� las coordenadas (x1,y1,x2,y2,x3,y3), consecutivamente.
	.global sugiere_combinacion
sugiere_combinacion:
		push {lr}
		
		
		pop {pc}




@;:::RUTINAS DE SOPORTE:::



@; generar_posiciones(vect_pos,f,c,ori,cpi): genera las posiciones de sugerencia
@;	de combinaci�n, a partir de la posici�n inicial (f,c), el c�digo de
@;	orientaci�n 'ori' y el c�digo de posici�n inicial 'cpi', dejando las
@;	coordenadas en el vector 'vect_pos'.
@;	Restricciones:
@;		* se supone que la posici�n y orientaci�n pasadas por par�metro se
@;			corresponden con una disposici�n de posiciones dentro de los l�mites
@;			de la matriz de juego
@;	Par�metros:
@;		R0 = direcci�n del vector de posiciones 'vect_pos'
@;		R1 = fila inicial 'f'
@;		R2 = columna inicial 'c'
@;		R3 = c�digo de orientaci�n;
@;				inicio de secuencia: 0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte
@;				en medio de secuencia: 4 -> horizontal, 5 -> vertical
@;		R4 = c�digo de posici�n inicial:
@;				0 -> izquierda, 1 -> derecha, 2 -> arriba, 3 -> abajo
@;	Resultado:
@;		vector de posiciones (x1,y1,x2,y2,x3,y3), devuelto por referencia
generar_posiciones:
		push {lr}
		
		
		pop {pc}



@; detectar_orientacion(f,c,mat): devuelve el c�digo de la primera orientaci�n
@;	en la que detecta una secuencia de 3 o m�s repeticiones del elemento de la
@;	matriz situado en la posici�n (f,c).
@;	Restricciones:
@;		* para proporcionar aleatoriedad a la detecci�n de orientaciones en las
@;			que se detectan secuencias, se invocar� la rutina 'mod_random'
@;			(ver fichero "candy1_init.s")
@;		* para detectar secuencias se invocar� la rutina 'cuenta_repeticiones'
@;			(ver fichero "candy1_move.s")
@;		* s�lo se tendr�n en cuenta los 3 bits de menor peso de los c�digos
@;			almacenados en las posiciones de la matriz, de modo que se ignorar�n
@;			las marcas de gelatina (+8, +16)
@;	Par�metros:
@;		R1 = fila 'f'
@;		R2 = columna 'c'
@;		R4 = direcci�n base de la matriz
@;	Resultado:
@;		R0 = c�digo de orientaci�n;
@;				inicio de secuencia: 0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte
@;				en medio de secuencia: 4 -> horizontal, 5 -> vertical
@;				sin secuencia: 6 
detectar_orientacion:
		push {r3,r5,lr}
		
		
		pop {r3,r5,pc}



.end
