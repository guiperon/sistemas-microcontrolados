; main.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; Ver 1 19/03/2018
; Ver 2 26/08/2018
; Este � um projeto template.


; -------------------------------------------------------------------------------
        THUMB                        ; Instru��es do tipo Thumb-2
; -------------------------------------------------------------------------------
		
; Declara��es EQU - Defines
;<NOME>         EQU <VALOR>
; ========================
; Defini��es de Valores


; -------------------------------------------------------------------------------
; �rea de Dados - Declara��es de vari�veis
		AREA  DATA, ALIGN=2
		; Se alguma vari�vel for chamada em outro arquivo
		;EXPORT  <var> [DATA,SIZE=<tam>]   ; Permite chamar a vari�vel <var> a 
		                                   ; partir de outro arquivo
;<var>	SPACE <tam>                        ; Declara uma vari�vel de nome <var>
                                           ; de <tam> bytes a partir da primeira 
                                           ; posi��o da RAM		

; -------------------------------------------------------------------------------
; �rea de C�digo - Tudo abaixo da diretiva a seguir ser� armazenado na mem�ria de 
;                  c�digo
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma fun��o do arquivo for chamada em outro arquivo	
        EXPORT Start                ; Permite chamar a fun��o Start a partir de 
			                        ; outro arquivo. No caso startup.s
									
		; Se chamar alguma fun��o externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; fun��o <func>
		IMPORT  PLL_Init
		IMPORT  SysTick_Init
		IMPORT  SysTick_Wait1ms			
		IMPORT  GPIO_Init
		IMPORT 	PortJ_Input
		IMPORT 	Port_Output
		; ****************************************
		; Importar as fun��es declaradas em outros arquivos
		; ****************************************


; -------------------------------------------------------------------------------
; Fun��o main()
Start  		
	BL PLL_Init                  ;Chama a subrotina para alterar o clock do microcontrolador para 80MHz
	BL SysTick_Init              ;Chama a subrotina para inicializar o SysTick
	BL GPIO_Init                 ;Chama a subrotina que inicializa os GPIO
; ****************************************
; Fazer as demais inicializa��es aqui.
; ****************************************
	
	;INICALIZANDO VARIAVEIS
	MOV R4, #2_00001000 	;estado inicial passeio do caveleiro
	MOV R5, #0				;dire��o passeio do caveleiro: 0=direita, 1=esquerda
	MOV R6, #0				;guarda o tipo da execu��o 0=cavaleiro, 1=contador
	MOV R7, #0				;registrador do contador
	MOV R8, #1000			;velocidade inicial
	
MainLoop
; ****************************************
; Escrever c�digo o loop principal aqui. 
; ****************************************

	MOV R0, R8
	PUSH {LR}
	BL SysTick_Wait1ms
	POP {LR}
	BL checar_inputs
	BL acender_leds
	
	B MainLoop
	
checar_inputs
	PUSH {LR}
	BL PortJ_Input
	POP {LR}
	ANDS R1, R0, #2_00000001	;checa se o bot�o para mudar o tipo de execu��o foi pressionado
	IT EQ
	EOREQ R6, R6, #1			;muda o tipo de execu��o
	
	ANDS R1, R0, #2_00000010	;checa se o bot�o para mudar a velocidade foi pressionado
	BNE fim_checar_inputs
	
	CMP R8, #1000				;ajusta a velocidade dependendo da velocidade atual
	ITT EQ
	MOVEQ R8, #500
	BEQ fim_checar_inputs
	
	CMP R8, #500
	ITT EQ
	MOVEQ R8, #200
	BEQ fim_checar_inputs
	
	CMP R8, #200
	IT EQ
	MOVEQ R8, #1000

fim_checar_inputs
	BX LR
	
	
acender_leds
	CMP R6, #0					;checa se o tipo da execu��o � passo cavaleiro
	ITE EQ
	MOVEQ R0, R4
	MOVNE R0, R7
	
	PUSH {LR}
	BL Port_Output
	POP {LR}

	CMP R6, #1					;Checa se o modo de execu��o � o contador e vai para branch conta_bin�ria
	BEQ conta_binaria

	;l�gica do passeio do cavaleiro
	CMP R5, #0
	ITE EQ
	LSREQ R4, #1
	LSLNE R4, #1

	CMP R4, #2_00000001			;se o cavaleiro estiver no limite da direita muda a dire��o
	IT EQ
	MOVEQ R5, #1

	CMP R4, #2_00001000			;se o cavaleiro estiver no limite da esquerda muda a dire��o		
	IT EQ
	MOVEQ R5, #0
	B fim_acender_leds
	
	
conta_binaria					;l�gica do contador
	ADD R7, #1
	CMP R7, #16
	IT EQ
	MOVEQ R7, #0
	
fim_acender_leds
	
	BX LR


; -------------------------------------------------------------------------------------------------------------------------
; Fim do Arquivo
; -------------------------------------------------------------------------------------------------------------------------	
    ALIGN                        ;Garante que o fim da se��o est� alinhada 
    END                          ;Fim do arquivo
