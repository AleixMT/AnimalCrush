@;=                                                         	      	=
@;=== candy1_move: rutinas para contar repeticiones y bajar elementos ===
@;=                                                          			=
@;=== Programador tarea 1E: Aleix.marine@estudiants.urv.cat			  ===
@;=== Programador tarea 1F: yyy.yyy@estudiants.urv.cat				  ===
@;=                                                         	      	=



.include "../include/candy1_incl.i"



@;-- .text. c�digo de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1E;
@; cuenta_repeticiones(*matriz,f,c,ori): rutina para contar el n�mero de
@;	repeticiones del elemento situado en la posici�n (f,c) de la matriz, 
@;	visitando las siguientes posiciones seg�n indique el par�metro de
@;	orientaci�n 'ori'.
@;	Restricciones:
@;		* s�lo se tendr�n en cuenta los 3 bits de menor peso de los c�digos
@;			almacenados en las posiciones de la matriz, de modo que se ignorar�n
@;			las marcas de gelatina (+8, +16)
@;		* la primera posici�n tambi�n se tiene en cuenta, de modo que el n�mero
@;			m�nimo de repeticiones ser� 1, es decir, el propio elemento de la
@;			posici�n inicial
@;	Par�metros:
@;		R0 = direcci�n base de la matriz
@;		R1 = fila 'f'
@;		R2 = columna 'c'
@;		R3 = orientaci�n 'ori' (0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte)
@;	Resultado:
@;		R0 = n�mero de repeticiones detectadas (m�nimo 1)
@;  Variables associades a registres:
@;  	r4 = repeticions de l'element
@;		r5 = tres bits de menys pes del primer element
@;		r6 = Apuntador-> matriu + (i*COLUMNS+j)*4
@;		r7 = tres bits de menys pes de l'element actual
	.global cuenta_repeticiones
cuenta_repeticiones:
		push {r4-r10,lr}
		@;Seccio ENTRADA
		mov r4, #1 					@;r4: repeticions de l'element=1
		mov r10, #COLUMNS 			@;r10 registre temporal per a guardar el valor de la constant COLUMNS
		mla r7, r1, r10, r2 		@;Obtenim a r7 i*COLUMNS + j
		add r6, r7, r0 				@;Obtenim a r6 i*COLUMNS+j+@matriu, obtenint la direcci� a la que apunta el primer element
		ldr r8, [r6]				@;Carreguem a registres el contingut de la posici� actual de la matriu
		and r5, r8, #0x00000007		@;Fem una m�scara, posant tots els bits a 0 excepte els 3 ultims que mantindran el seu valor a r5
		cmp r3, #1					@;comparem ori amb 1
		bgt .Mesgran				@;si es mes gran es 2 o 3 ves a mes gran
		beq .Sud					@;Si es 1 vol dir que ori es sud  i ves a sud
		@;Seccio EST
		.Est:
		cmp r2, #COLUMNS			@;Comparem amb COLUMNS
		bge .Exit					@;Si es mes gran o igual ves a la seccio de sortida
		add r6, #1 					@;Passem al seg�ent element
		add r2, #1					@;Modifiquem l'index sumant 1
		ldr r8, [r6]				@;Carreguem a r8 el contingut de memoria al que apunta r6 (seg�ent element)
		and r7, r8, #0x00000007		@;Tres bits de menys pes de l'element actual
		cmp r5, r7					@;Comparem els tres bits de menys pes de l'element actual amb el primer element
		bne .Exit					@;Si son diferents ves a la seccio exit
		add r4, #1					@;Afegeix repeticio perque son iguals
		b .Est
		.Sud:
		@;Seccio SUD
		cmp r2, #ROWS				@;Comparem amb ROWS
		bge .Exit					@;Si es mes gran o igual ves a la seccio de sortida
		mov r8, #COLUMNS			@;Carreguem el valor de COLUMNS a r8
		add r6, r8		 			@;Passem al seg�ent element
		add r1, #1					@;Modifiquem l'index sumant 1
		ldr r8, [r6]				@;Carreguem a r8 el contingut de memoria al que apunta r6 (seg�ent element)
		and r7, r8, #0x00000007		@;Tres bits de menys pes de l'element actual a r7
		cmp r5, r7					@;Comparem els tres bits de menys pes de l'element actual amb el primer element
		bne .Exit					@;Si son diferents ves a la seccio exit
		add r4, #1					@;Afegeix repeticio perque son iguals
		b .Sud						@;Torna a comen�ar el bucle de recorregut
		.Mesgran:
		cmp r3, #2
		beq .Oest
		@;Seccio NORD
		.Nord:
		cmp r1, #0					@;Comparem amb 0
		ble .Exit					@;Si es mes petit o igual ves a la seccio de sortida
		mov r8, #COLUMNS			@;Carreguem el valor de COLUMNS a r8
		sub r6, r8					@;Passem al seg�ent element
		sub r1, #1					@;Modifiquem l'index restant 1
		ldr r8, [r6]				@;Carreguem a r8 el contingut de memoria al que apunta r6 (seg�ent element)
		and r7, r8, #0x00000007		@;Tres bits de menys pes de l'element actual a r7
		cmp r5, r7					@;Comparem els tres bits de menys pes de l'element actual amb el primer element
		bne .Exit					@;Si son diferents ves a la seccio exit
		add r4, #1					@;Afegeix repeticio perque son iguals
		b .Nord						@;Torna a comen�ar el bucle de recorregut
		.Oest:
		@;Seccio OEST
		cmp r2, #0
		ble .Exit
		sub r6, #1 					@;Passem al seg�ent element
		sub r2, #1					@;Modifiquem l'index restant 1
		ldr r8, [r6]				@;Carreguem a r8 el contingut de memoria al que apunta r6 (seg�ent element)
		and r7, r8, #0x00000007		@;Tres bits de menys pes de l'element actual
		cmp r5, r7					@;Comparem els tres bits de menys pes de l'element actual amb el primer element
		bne .Exit					@;Si son diferents ves a la seccio exit
		add r4, #1					@;Afegeix repeticio perque son iguals
		b .Oest
		@;Seccio EXIT El programa sempre acabara aqui, per tant fem les operacions pertinents de sortida
		.Exit:
		mov r0, r4
		pop {r4-r10, pc}



@;TAREA 1F;
@; baja_elementos(*matriz): rutina para bajar elementos hacia las posiciones
@;	vac�as, primero en vertical y despu�s en sentido inclinado; cada llamada a
@;	la funci�n s�lo baja elementos una posici�n y devuelve cierto (1) si se ha
@;	realizado alg�n movimiento, o falso (0) si est� todo quieto.
@;	Restricciones:
@;		* para las casillas vac�as de la primera fila se generar�n nuevos
@;			elementos, invocando la rutina 'mod_random' (ver fichero
@;			"candy1_init.s")
@;	Par�metros:
@;		R0 = direcci�n base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica se ha realizado alg�n movimiento, de modo que puede que
@;				queden movimientos pendientes. 
	.global baja_elementos
baja_elementos:
		push {lr}
		
		
		pop {pc}



@;:::RUTINAS DE SOPORTE:::



@; baja_verticales(mat): rutina para bajar elementos hacia las posiciones vac�as
@;	en vertical; cada llamada a la funci�n s�lo baja elementos una posici�n y
@;	devuelve cierto (1) si se ha realizado alg�n movimiento.
@;	Par�metros:
@;		R4 = direcci�n base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado alg�n movimiento. 
baja_verticales:
		push {lr}
		
		
		pop {pc}



@; baja_laterales(mat): rutina para bajar elementos hacia las posiciones vac�as
@;	en diagonal; cada llamada a la funci�n s�lo baja elementos una posici�n y
@;	devuelve cierto (1) si se ha realizado alg�n movimiento.
@;	Par�metros:
@;		R4 = direcci�n base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado alg�n movimiento. 
baja_laterales:
		push {lr}
		
		
		pop {pc}



.end
