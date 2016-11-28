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
	divFreq0: .hword	-358			@;divisor de frecuencia inicial para timer 0


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
		push {lr}
			ldr r0, =update_spr
			ldrh r1, [r0]
			cmp r1, #0
			beq .End
			bl SPR_actualizarSprites
			mov r0, #0
			strh r0, [r0]
			@;Aqu� acaba la meva funci�, tots els registres estan lliures.
@;Tarea 2Ga


@;Tarea 2Ha
	
			ldr r1, =update_bg3
			ldr r2, [r1]
			cmp r2, #0
			beq .Lfi2ha
			ldr r3, =offsetBG3X
			ldr r4, [r3]
			@;.type U32.F32 r4 {, #8}			@;format coma fixe 0.8.8 ??????
			ldr r3, =0x04000038					@;REG_BG3X --> 0.20.8	/	REG_BG3PA, REG_BG3PB, REG_BG3PC i REG_BG3PD --> 0.8.8
			strb r5, [r3]
			mov r2, #0
			str r2, [r1]
			.Lfi2ha:	
			.End:
		pop {pc}




@;TAREA 2Eb;
@;activa_timer0(init); rutina para activar el timer 0, inicializando o no el
@;	divisor de frecuencia seg�n el par�metro init.
@;	Par�metros:
@;		R0 = init; si 1, restablecer divisor de frecuencia original divFreq0
	.global activa_timer0
activa_timer0:
		push {r0, r1, lr}
			cmp r0, #0			@;Si init �s 0 ves al final
			beq .Fi 		
			ldr r0, =divFreq0
			ldrh r0, [r0]					@;R0 = divfreq0 r0???
			ldr r1, =divF0					
			strh r0, [r1]					@; divF0=divfreq0
			ldr r1, =0x04000100			@;Timer0_data
			orr r0, #0xC30000				@; prescaler=11 -> f. entrada 32728,5 Hz, activades interrupcions, activat timer
			str r0, [r1]					@;Guardem als dos resgistres de control
			ldr r0, =timer0_on
			mov r1, #1
			str r1, [r0]					@;Activem timer0_on
			.Fi:
		pop {r0, r1, pc}


@;TAREA 2Ec;
@;desactiva_timer0(); rutina para desactivar el timer 0.
	.global desactiva_timer0
desactiva_timer0:
		push {r0, r1,lr}
			ldr r0, =timer0_on
			mov r1, #0
			str r1, [r0] 			@;Deactivem timer0_on
			ldr r0, =0x04000102		@;Timer0_control
			ldrh r1, [r0]
			bic r1, #128			@;Posem bit 7 a 0 (desactiva timer)
			strh r1, [r0]			@;Guardem al registre de control
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
		push {r0-r5,lr}
			mov r4, #0				@;R4 = 0 servir� per a saber si hi ha hagut moviment ja que sempre que n'hi hagi r4=1
			ldr r3, =vect_elem		@;R3 = @vect_elem 
			mov r0, #0				@;R0 = Index despla�ament
			.b:
			ldrh r2, [r3]			@;R2 = ii
			cmp r2, #0				@;si es 0 o -1
			addle r3, #10			@;suma 10 per a despla�ar el vector
			ble .Endb				@;I ves al final
			mov r4, #1				@;Es mour� un element!
			sub r2, #1				@; Si en canvi l'element esst� actiu resta 1 a ii
			strh r2, [r3]			@;i guarda'l
			add r3, #2				@;Augmenta l'index en dos (avan�a al seguent hword)
			ldrh r1, [r0]			@; R1 = px
			ldrh r5, [r0, #4]		@; R5 = vx
			cmp r5, #0				@; si vx o vy...
			addgt r1, #1			@;Major que 0, suma 1 als pixels
			sublt r1, #1			@;Menor que 0, resta 1 als pixels (per a vy no s'executar� mai aquesta instrucci�)
			strh r1, [r0]			@;Guarda contingut r2 (px o py) a on li toca
			add r3, #2				@;Augmenta l'index en dos (avan�a al seguent hword)
			ldrh r2, [r0]			@; R2 = py
			ldrh r5, [r0, #4]		@; R3 = vy
			cmp r5, #0				@; si vy...
			addgt r2, #1			@;Major que 0, suma 1 als pixels
			strh r2, [r0]			@;Guarda contingut r2 (px o py) a on li toca
			bl SPR_moverSprite		@;Actualitza el moviment de l'sprite
			add r3, #4				@;Acaba d'avan�ar fins al seg�ent element
			.Endb:
			add r1, #1				@;Suma 1 a l'�ndex
			cmp r1, #127			@;Si l'index no es 127
			beq .b					@;Torna a iterar
			cmp r4, #1				@;Si flag de moviment es 0
			blne desactiva_timer0	@;Desctiva timer 0 per a quan no hi ha moviment
			bne .End				@;I surt
			ldr r0, =update_spr		@;Sino carrega update_spr=r0
			mov r1, #1
			strh r1, [r0]			@;Activa-la guardant un 1
			ldr r1, =0x04000100 	@;carreguem la direcci� de timer0 data
			ldrh r0, [r1]			@;Carrega el divisor de freq
			cmp r0, #-128			@;Si r0 (div freq) menor que -128
			bge .End
			add r0, #10			@;Suma 10 (valor a modificar al fer proves), aix� disminuir� el valor del div_fre, ja que es negatiu
			strh r0, [r1]			@;Guarda'l
			.End
		
		pop {r0-r5, pc}



.end
