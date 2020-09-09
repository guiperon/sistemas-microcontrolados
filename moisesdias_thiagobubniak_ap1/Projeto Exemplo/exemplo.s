; Exemplo.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; 12/03/2018

; -------------------------------------------------------------------------------
        THUMB                        ; Instru��es do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declara��es EQU - Defines
;<NOME>         EQU <VALOR>

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
;NUMEROS	DCB		19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
;NUMEROS		DCB		203,237,193,43,211,3,203,5,127,157,237,241,19,0
		; Se alguma fun��o do arquivo for chamada em outro arquivo	
        EXPORT Start                ; Permite chamar a fun��o Start a partir de 
			                        ; outro arquivo. No caso startup.s								
		; Se chamar alguma fun��o externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; fun��o <func>

; -------------------------------------------------------------------------------
; Fun��o main()
INICIO_LISTA EQU 0x20000000
INICIO_LISTA_PRIMOS EQU 0x20000100
Start  
; Comece o c�digo aqui <======================================================
	LDR R0, =NUMEROS				; R0 aponta para o in�cio da lista desordenada
	MOV R1, #INICIO_LISTA			; R1 aponta para o endere�o inicial para armazenar os primos
	MOV R3, #0						; R3 vai apontar para o fim da lista de numeros na RAM
	MOV R7, #0						; R7 vai apontar para o fim da lista de primos
	
popular_ram
	LDRB R2, [R0], #1				; carrega um elemento da lista desordenada em R2 e itera o ponteiro da lista
	CMP R2, #0						; compara o numero que veio da lista desordenada com zero
	BEQ fim_popular_ram				; se R2 = 0, o ultimo elemento, termina de popular a RAM
	MOV R3, R1						; guarda o endere�o do ultimo numero salvo na RAM
	STRB R2, [R1], #1				; salva o numero da lista desordenada numa posi��o da RAM e itera o ponteiro da RAM
	B popular_ram
	
fim_popular_ram
	MOV R0, #INICIO_LISTA			; R0 guarda a posi��o inicial dos numeros na RAM
	;MOV R1, #INICIO_LISTA_PRIMOS	; R1 guarda a posi��o inicial dos numeros primos que ser�o salvos
	ADD R1, R0, #0x100				; R1 guarda a posi��o inicial dos numeros primos que ser�o salvos
	CMP R3, #0						; se R3 for zero, nenhum numero foi colocado na lista inicial na RAM
	BEQ fim
	
filtrar_primos
	CMP R0, R3						; se R0, que aponta para a fila for maior que R3, que � o fim da fila, vai para o sort
	BHI fim_filtrar_primos
	LDRB R2, [R0], #1				; coloca em R2 o primeiro elemento da lista de numeros e itera o ponteiro
	CMP R2, #2						; se o numero for <= 2, n�o � primo, escolher o pr�ximo
	BLS filtrar_primos
	MOV R5, #2						; R5 vai ser usado para dividir o candidato a primo, at� R5 ser maior que R4/2
	UDIV R4, R2, R5					; R4 guarda metade do numero que vai ser checado se � primo

checar_primo
	UDIV R6, R2, R5
	MLS R6, R6, R5, R2				; R6 guarda o resto da divis�o do candidato a primo (R2) por R5
	CMP R6, #0		
	BEQ filtrar_primos				; se o resto da divis�o por R5 for zero, n�o � primo
	ADD R5, R5, #1					; itera R5 at� R5 > R4
	CMP R4, R5
	BHI checar_primo
	MOV R7, R1						; guarda o endere�o do ultimo primo armazenado na lista de primos
	STRB R2, [R1], #1				; se R2 n�o � divis�vel por qualquer numero entre 2 e R2/2, ele � primo
	B filtrar_primos
	
fim_filtrar_primos
	;MOV R0, #INICIO_LISTA_PRIMOS	; R0 guarda a posi��o inicial da lista de primos
	MOV R0, #INICIO_LISTA			; R0 guarda a posi��o inicial da lista de primos
	ADD R0, R0, #0x100
	MOV R1, R0						; R1 vai guardar uma refer�ncia para o in�cio da lista de primos

bubble_sort
	CMP R0, R7						; compara se R7 j� chegou no come�o da lista
	BEQ fim
	MOV R2, R0						; guarda uma refer�ncia para o primeiro elemento da compara��o
	LDRB R3, [R0], #1				; pega um elemento da lista de primos e itera o ponteiro
	LDRB R4, [R0]					; pega o proximo elemento sem iterar
	
	CMP R3, R4
	
	ITTE HI							; se R3 for maior que R4:
		STRBHI R3, [R0]				; troca a posi��o de R3 e R4, os dois elementos da compara��o do bubble sort
		STRBHI R4, [R2]
		NOPLS
		
	CMP R0, R7						; checa se R0 j� chegou no fim da fila de primos
	
	ITTE EQ							; se R0 chegou no fim da fila:
		MOVEQ R0, R1				; reseta o in�cio da fila
		SUBEQ R7, R7, #1			; remove um �ndice do ponteiro do fim da fila
		NOPNE
	B bubble_sort
		
fim
	NOP
NUMEROS		DCB		193,63,176,127,43,19,211,3,203,5,21,127,206,245,157,237,241,105,252,19,0

    ALIGN                           ; garante que o fim da se��o est� alinhada 
    END                             ; fim do arquivo
