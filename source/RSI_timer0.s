@;=                                                          	     	=
@;=== RSI_timer0.s: rutinas para mover los elementos (sprites)		  ===
@;=                                                           	    	=
@;=== Programador tarea 2E: aleix.marine@estudiants.urv.cat			  ===
@;=== Programador tarea 2G: cristina.izquierdo@estudiants.urv.cat	  ===
@;=== Programador tarea 2H: albert.canellas@estudiants.urv.cat		  ===
@;=                                                       	        	=

.include "../include/candy2_incl.i"


@;-- .data. variables (globales) inicializadas ---
.data
		.align 2
		.global update_spr
	update_spr:	.hword	0			@;1 -> actualizar sprites
		.global timer0_on
	timer0_on:	.hword	0 			@;1 -> timer0 en marcha, 0 -> apagado
	divFreq0: .hword	5728

@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 2
	divF0: .space	2				@;divisor de frecuencia actual


@;-- .text. c�digo de las rutinas ---
.text	
		.align 2
		.arm

@;TAREAS 2Ea,2Ga,2Ha;
@;rsi_vblank(void); Rutina de Servicio de Interrupciones del retrazado vertical;
@;Tareas 2E,2F: actualiza la posici�n y forma de todos los sprites
@;Tarea 2G: actualiza las metabaldosas de todas las gelatinas
@;Tarea 2H: actualiza el desplazamiento del fondo 3
	.global rsi_vblank
rsi_vblank:
		push {r0-r7,lr}
			
			ldr r2, =update_spr			@;r0=@update_spr
			ldrh r1, [r2]				@;r1=update_spr
			cmp r1, #0
			beq .E						@;Si es 0 (no s'han mogut els sprites), surt
			mov r0, #0x07000000
			ldr r1, =n_sprites
			ldr r1, [r1]
			bl SPR_actualizarSprites	@; sino actualitza els sprites
			mov r1, #0					@; R1=0
			strh r1, [r2]				@; update_spr=0
			.E:
@;Tarea 2Ga
			ldr r4, =update_gel
			ldrb r2, [r4]					@; valor de udate_gel
			cmp r2, #0
			beq .Lfi						@; si es igual a 0, finalitza
			ldr r5, =mat_gel
			mov r1, #0						@;r1=files
		.bucleFil:
			mov r2, #0						@;r2=columnes
		.bucleCol:
			ldrb r6, [r5, #GEL_II]			@;r1=camp ii
			cmp r6, #0
			bgt .L_final					@;si es major que 0, ignorem la posicio
			tst r6, #0x80					@;comparem el bit de signe (1000 0000)
			bne .L_final					@;si es -1, ignorem la posicio
			@;si el camp ii es igual a 0
			mov r6, #10
			strb r6, [r5]					@;reinicialitzem a 10 el camp ii
			ldr r0, =0x06000000				@;r0=direccio base matriu
			@;r1=filas
			@;r2=columnas
			ldrb r3, [r5, #GEL_IM]			@;r3=camp im
			bl fijar_metabaldosa
		.L_final:
			add r2, #1						@;seguent columna
			add r5, #GEL_TAM				@;seguent casella
			cmp r2, #COLUMNS				@;comparem amb el final de columna
			blo .bucleCol
			add r1, #1						@;seguent fila
			cmp r1, #ROWS					@;comparem amb el final de les files
			blo .bucleFil
			mov r0, #0
			strb r0, [r4]					@;desactivem update_gel
		.Lfi:
@;Tarea 2Ha
			ldr r1, =update_bg3
			ldrh r2, [r1]
			cmp r2, #0							@;comparacio de update_bg3
			beq .Ends
			ldr r3, =offsetBG3X					@;guardar despla�ament de offsetBG3X
			ldrh r4, [r3]
			mov r4, r4, lsl #8									
			ldr r3, =0x04000038					@;REG_BG3X 0.8.8	0x04000038 part decimal/ 0400 003C part entera
			strh r4, [r3]
			mov r2, #0
			strh r2, [r1]
			.Ends: 
		pop {r0-r7, pc}




@;TAREA 2Eb;
@;activa_timer0(init); rutina para activar el timer 0, inicializando o no el
@;	divisor de frecuencia seg�n el par�metro init.
@;	Par�metros:
@;		R0 = init; si 1, restablecer divisor de frecuencia original divFreq0
	.global activa_timer0
activa_timer0:
		push {r0, r1, lr}
			cmp r0, #0						@;Si init �s 0 ves al final
			beq .Fi 		
			ldr r0, =divFreq0				@;R0 = @divFreq0
			ldrh r0, [r0]					@;R0 = divfreq0
			ldr r1, =divF0					@;R1 = @divF0
			strh r0, [r1]					@;divF0 = divfreq0
			ldr r1, =0x04000100				@;R1 = @Timer0_data
			rsb r0, r0, #0
			strh r0, [r1]					@;Timer0_data = divfreq0
			.Fi:
			ldr r1, =0x04000102				@;R1 = @Timer0_control
			mov r0, #0xC1
			strh r0, [r1]					@; prescaler=11 (bit 0 i 1)-> f. entrada 32728,5 Hz, Timer IRQ Enable = 1 (bit 6)-> activades interrupcions, Timer Start/Stop = 1 (bit 7)-> activat timer.
			ldr r0, =timer0_on				@;R0 = @timer0_on
			mov r1, #1						@;R1 = 1
			strh r1, [r0]					@;timer0_on = 1 -> els sprites s'estan movent, activem timer 0
			
		pop {r0, r1, pc}


@;TAREA 2Ec;
@;desactiva_timer0(); rutina para desactivar el timer 0.
	.global desactiva_timer0
desactiva_timer0:
		push {r0, r1,lr}
			ldr r0, =timer0_on		@;R0 = @timer0_on
			mov r1, #0				@;R1 = 0
			strh r1, [r0] 			@;Timer0_on = 0
			ldr r0, =0x04000102		@;R0 = @Timer0_control
			mov r1, #0				@;Posem Timer Start/Stop (bit 7)  a 0 (desactiva timer)
			strh r1, [r0]			@;Timer0_control = 0x4300 
		pop {r0, r1,pc}



@;TAREA 2Ed;
@;rsi_timer0(); rutina de Servicio de Interrupciones del timer 0: recorre todas
@;	las posiciones del vector vect_elem y, en el caso que el c�digo de
@;	activaci�n (ii) sea mayor o igual a 0, decrementa dicho c�digo y actualiza
@;	la posici�n del elemento (px, py) de acuerdo con su velocidad (vx,vy),
@;	adem�s de mover el sprite correspondiente a las nuevas coordenadas.
@;	Si no se ha movido ning�n elemento, se desactivar� el timer 0. En caso
@;	contrario, el valor del divisor de frecuencia se reducir� para simular
@;  el efecto de aceleraci�n (con un l�mite).
@;	Cal recordar que vect_elem �s un vector de elements, una estructura formada per 5 hwords:
@;	ii, px, py, vx, vy
	.global rsi_timer0
rsi_timer0:
		push {r0-r7,lr}
			ldr r6, =n_sprites
			ldr r6, [r6]

			mov r4, #0				@;R4 = 0 servir� per a saber si hi ha hagut moviment ja que sempre que n'hi hagi r4=1
			ldr r3, =vect_elem		@;R3 = @vect_elem 
			mov r0, #0				@;R0 = Index despla�ament
			.b:
			ldrh r2, [r3]			@;R2 = ii
			cmp r2, #0				@;si es 0 o -1
			addeq r3, #10			@;suma 10 per a despla�ar el vector
			beq .Endb				@;I ves al final
			tst r2, #0x8000
			addne r3, #10
			bne .Endb
			mov r4, #1				@;Es mour� un element!
			sub r2, #1				@;Si en canvi l'element est� actiu resta 1 a ii
			strh r2, [r3]			@;i guarda'l
			add r3, #2				@;Augmenta l'index en dos (avan�a al seguent hword)
			ldrh r1, [r3]			@;R1 = px
			ldrh r5, [r3, #4]		@;R5 = vx
			cmp r5, #0				@;si vx...
			beq .x
			
			add r1, r5
			@;tst r5, #0x8000
			@;addeq r1, #1			@;Major que 0, suma 1 als pixels
			@;subne r1, #1			@;Menor que 0, resta 1 als pixels
			strh r1, [r3]			@;Guarda contingut R2 = px a on li toca
			 
			.x:
			add r3, #2				@;Augmenta l'index en dos (avan�a al seguent hword)
			ldrh r2, [r3]			@;R2 = py
			ldrh r5, [r3, #4]		@;R5 = vy
			cmp r5, #0				@;si vx...
			beq .y
			add r2, r5
			@;tst r5, #0x8000
			@;addeq r2, #1			@;Major que 0, suma 1 als pixels
			@;subne r2, #1			@;Menor que 0, resta 1 als pixels
			strh r2, [r3]			@;Guarda contingut R2 = px a on li toca
			.y:
			bl SPR_moverSprite		@;Actualitza el moviment de l'sprite
			@; void SPR_moverSprite(int indice, int px, int py)
			add r3, #6				@;Acaba d'avan�ar fins al seg�ent element
			.Endb:
			add r0, #1				@;Suma 1 a l'�ndex
			cmp r0, r6				@;Si l'index no arriba a n_sprites
			bne .b					@;Torna a iterar
			cmp r4, #1				@;Si flag de moviment es 0
			blne desactiva_timer0	@;Desactiva timer 0 per a quan no hi ha moviment
			bne .fin				@;I surt
			ldr r0, =update_spr		@;Sino carrega update_spr=r0
			mov r1, #1				@;R1 = 1
			strh r1, [r0]			@;Activa-la guardant un 1
			ldr r1, =divF0		 	@;R1 = @divf0
			ldrh r0, [r1]			@;R0 = divf0
			cmp r0, #300			@;Si r0 (div freq) menor o igual que 20
			blo .fin				@;Surt
			sub r0, #500				@;i sino resta 1024 (valor a modificar al fer proves)
			strh r0, [r1]			@;Guarda'l
			.fin:
			mov r0,r7
		pop {r0-r7, pc}



.end
