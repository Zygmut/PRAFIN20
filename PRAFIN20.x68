*-----------------------------------------------------------
* Title      : PRAFIN20
* Written by : Mateu Segui Vives, Ruben Palmer Perez
* Date       : 20/05/2020
* Description: Emulador de la PS-ECI
*-----------------------------------------------------------
    ORG $1000
EPROG: DC.W $8810,$400A,$E00D,$688E,$9000,$4003,$E00D,$6804
       DC.W $6FFD,$48A4,$495B,$E00D,$C009,$4020,$A012,$0000
       DC.W $0004,$0003,$0000
EIR:   DC.W 0 ;eregistro de instruccion
EPC:   DC.W 0 ;econtador de programa
ET0:   DC.W 0 ;eregistro T0
ET1:   DC.W 0 ;eregistro T1
ER2:   DC.W 0 ;eregistro R2
ER3:   DC.W 0 ;eregistro R3
ER4:   DC.W 0 ;eregistro R4
ER5:   DC.W 0 ;eregistro R5
EB6:   DC.W 0 ;eregistro B6
EB7:   DC.W 0 ;eregistro B7
ESR:   DC.W 0 ;eregistro de estado (00000000 00000ZNC)


START:
    CLR.W EPC

FETCH:
    ;--- IFETCH: INICIO FETCH
        ;*** En esta seccion debeis introducir el codigo necesario para cargar
        ;*** en el EIR la siguiente instruccion a ejecutar, indicada por el EPC
	    ;*** y dejar listo el EPC para que apunte a la siguiente instruccion
	
        MOVE.W EPC, A0
        ADD.W A0,A0     
        MOVE.W EPROG(A0),EIR
        ADDQ.W #1,EPC

    ;--- FFETCH: FIN FETCH
    
    ;--- IBRDECOD: INICIO SALTO A DECOD
        ;*** En esta seccion debeis preparar la pila para llamar a la subrutina
        ;*** DECOD, llamar a la subrutina, y vaciar la pila correctamente,
        ;*** almacenando el resultado de la decodificacion en D1

        SUBQ.W #2, SP 
        MOVE.W EIR,-(SP) 
        JSR DECOD
        ADDQ.W #2,SP
	MOVE.W (SP)+,D1

    ;--- FBRDECOD: FIN SALTO A DECOD
    
    ;--- IBREXEC: INICIO SALTO A FASE DE EJECUCION
        ;*** Esta seccion se usa para saltar a la fase de ejecucion
        ;*** NO HACE FALTA MODIFICARLA

    MULU #6,D1
    MOVEA.L D1,A1
    JMP JMPLIST(A1)
JMPLIST:
    JMP EEXIT 
    JMP ECOPY 
    JMP EADD 
    JMP ESUB 
    JMP EAND 
    JMP ENOT 
    JMP ESTC 
    JMP ELOA 
    JMP ELOAI 
    JMP ESTO 
    JMP ESTOI 
    JMP EBRI 
    JMP EBRC 
    JMP EBRZ    

    ;--- FBREXEC: FIN SALTO A FASE DE EJECUCION
    
    ;--- IEXEC: INICIO EJECUCION
        ;*** En esta seccion debeis implementar la ejecucion de cada einstr.

EEXIT:
	SIMHALT 
	
ECOPY:
	JSR GET_B 
	JSR GET_C 
	MOVE.W (A1),D1
	MOVE.W D1, (A2)
	JSR FLAGSNC
	BRA FETCH

EADD:
	JSR GET_A 
	JSR GET_B 
	JSR GET_C 
	MOVE.W (A0),D0
	MOVE.W (A1),D1
	ADD.W D0,D1
	JSR FLAGS
	MOVE.W D1,(A2)
	BRA FETCH

ESUB:
	JSR GET_A 
	JSR GET_B 
	JSR GET_C 
	MOVE.W (A0),D0 
	MOVE.W (A1),D1 
	NEG.W D1
	ADD.W D0,D1
	JSR FLAGS
	MOVE.W D1,(A2)
	BRA FETCH

EAND:
	JSR GET_A 
	JSR GET_B 
	JSR GET_C 
	MOVE.W (A0),D0
	MOVE.W (A1),D1
	AND.W D0,D1
	JSR FLAGSNC
	MOVE.W D1,(A2)
	BRA FETCH

ENOT:
	JSR GET_C 
	MOVE.W (A2),D0
	NOT.W D0
	JSR FLAGSNC
	MOVE.W D0,(A2)
	BRA FETCH
	
ESTC:
	JSR GET_K 
	JSR GET_C 
	MOVE.W D2,(A2)
	JSR FLAGSNC
	BRA FETCH

ELOA: 
	JSR GET_I 
	MOVE.W EIR, D2
	AND.W #$00FF, D2 ;Sacar M 
	MOVE.W D2,A3
	ADD.W A3,A3
	MOVE.W EPROG(A3),(A4)
	JSR FLAGSNC
	BRA FETCH

ELOAI:
	JSR GET_J 
	MOVE.W (A4),A4
	ADD.W A4,A4
	MOVE.W EPROG(A4),ET0
	JSR FLAGSNC
	BRA FETCH

ESTO:
	JSR GET_I
	MOVE.W EIR, D2
	AND.W #$00FF, D2
	MOVE.W D2,A3
	ADD.W A3,A3
	MOVE.W (A4),EPROG(A3)
	BRA FETCH

ESTOI:
	JSR GET_J 
	MOVE.W (A4),A4
	ADD.W A4,A4
	MOVE.W (ET0),EPROG(A4)
	BRA FETCH

EBRI:
	MOVE.W EIR, D2
	AND.W #$00FF, D2
	MOVE.W D2,EPC
	BRA FETCH

EBRC:
	MOVE.W ESR, D3
	BTST #0, D3 ;Test flag C
	BEQ FETCH 
	MOVE.W EIR, D2
	AND.W #$00FF, D2
	MOVE.W D2,EPC
	BRA FETCH

EBRZ:
	MOVE.W ESR, D3
	BTST #2, D3 ;Test flag C
	BEQ FETCH 
	MOVE.W EIR, D2
	AND.W #$00FF, D2
	MOVE.W D2,EPC
	BRA FETCH

    ;--- FEXEC: FIN EJECUCION

    ;--- ISUBR: INICIO SUBRUTINAS
        ;*** Aqui debeis incluir las subrutinas que necesite vuestra solucion
        ;*** SALVO DECOD, que va en la siguiente seccion

;Con respecto a los flags hemos decidido hacer la siguiente accion:
;Una subrutina para calcular los flags Z & N y otra únicamente para
;el flag C. De esta manera para actualizar todos los flags actuali-
;zaremos Z&N y luego actualizaremos Z 

FLAGSNC:
	MOVE.W SR, D5  
	MOVE.W D5, D6 
	AND.W #4,D5   ;Flag Z
	AND.W #8,D6   ;Flag N
	LSR.W #2,D6   
	OR.W D5,D6    
	MOVE.W D6,ESR 
	RTS

FLAGS:
	MOVE.W SR, D7
	JSR FLAGSNC
	AND.W #1,D7 ;Flag C
  	OR.W D7,D6  ;D6 <- ESR con Z & N
    	MOVE.W D6,ESR
    	RTS

GET_A: ;Pone en el registro A0 la dirección del operando a

	MOVE.W #$1C0, D4		
	AND.W EIR, D4
	LSR #6,D4
	JSR REGDEC
	MOVE.W A4,A0
	RTS	

GET_B: ;Pone en el registro A1 la dirección del operando b

	MOVE.W #$38, D4	
	AND.W EIR, D4
	LSR #3, D4
	JSR REGDEC
	MOVE.W A4,A1
	RTS

GET_C: ;Pone en el registro A2 la dirección del operando c

	MOVE.W #$7, D4	
	AND.W EIR, D4
	JSR REGDEC
	MOVE.W A4,A2
	RTS

GET_K: ;Pone en el registro D2 el valor k con extensión

    	MOVE.W #$7F8, D4	
	AND.W EIR, D4
	LSR #3, D4
	EXT.W D4
	MOVE.W D4,D2
	RTS

GET_M: ;Pone en el registro D2 el valor M

	MOVE.W EIR,D2
	AND.W #$00FF,D2
	RTS	

GET_I: ;Pone en el registro A4 la dirección de T1 o T0

	BTST #11, EIR ;Mirar si es T1 o T0
	BEQ RT0
RT1:	
	LEA.L ET1,A4
	RTS
RT0:
	LEA.L ET0,A4
	RTS

GET_J: ;Pone en el registro A4 la dirección de B6 o B7

	BTST #11, EIR ;Mirar si es B6 o B7
	BEQ RB6
RB7:	
	LEA.L EB7,A4
	RTS
RB6:
	LEA.L EB6,A4
	RTS
	
REGDEC: ;Decodifica los 3 bits menos significativos 
	;del registro D4 para determinar que 
	;registro emulado es

	BTST.L #2,D4
	BEQ R0
R1:
	BTST.L #1,D4
	BEQ R10
R11:
	BTST.L #0,D4
	BEQ R110
R111: ;EB7
	LEA.L EB7,A4
	RTS
R110: ;EB6
	LEA.L EB6,A4
	RTS	
R10:
	BTST.L #0,D4
	BEQ R100
R101: ;ER5
	LEA.L ER5,A4
	RTS
R100: ;ER4
	LEA.L ER4,A4
	RTS
R0:
	BTST.L #1,D4
	BEQ R00
R01:
	BTST.L #0,D4
	BEQ R010
R011: ;ER3
	LEA.L ER3,A4
	RTS		
R010: ;ER2
	LEA.L ER2,A4
	RTS
R00:
	BTST.L #0,D4
	BEQ R000
R001: ;ET1
	LEA.L ET1,A4
	RTS
R000: ;ET0
	LEA.L ET0,A4
	RTS

    ;--- FSUBR: FIN SUBRUTINAS

    ;--- IDECOD: INICIO DECOD
        ;*** Tras la etiqueta DECOD, debeis implementar la subrutina de 
        ;*** decodificacion, que debera ser de libreria, siguiendo la interfaz
        ;*** especificada en el enunciado

DECOD:
	BTST.B #7,4(SP)
	BEQ IN0
IN1:
	BTST.B #6,4(SP)
	BEQ IN10
IN11:
	BTST.B #5,4(SP)
	BEQ IN110
IN1110: ;BRZ
	MOVE.W #13,6(SP)		
	RTS
IN110:
	BTST.B #4,4(SP)
	BEQ IN1100
IN1101: ;BRC
	MOVE.W #12,6(SP)
	RTS
IN1100: ;BRI
	MOVE.W #11,6(SP)
	RTS
IN10:
	BTST.B #5,4(SP)
	BEQ IN100
IN101:
	BTST.B #4,4(SP)
	BEQ IN1010
IN1011: ;STOI
	MOVE.W #10,6(SP)
	RTS
IN1010: ;STO
	MOVE.W #9,6(SP)
	RTS
IN100:
	BTST.B #4,4(SP)
	BEQ IN1000
IN1001: ;LOAI
	MOVE.W #8,6(SP)
	RTS
IN1000: ;LOA
	MOVE.W #7,6(SP)
	RTS
IN0:
	BTST.B #6,4(SP)
	BEQ IN00
IN01:
	BTST.B #5,4(SP)
	BEQ IN010
IN0110: 
	BTST.B #3,4(SP)
	BEQ IN01100
IN01101: ;STC
	MOVE.W #6,6(SP)
	RTS
IN01100: ;NOT
	MOVE.W #5,6(SP)
	RTS
IN010:
	BTST.B #4,4(SP)
	BEQ IN0100
IN0101:
	BTST.B #3,4(SP)
	BEQ IN01010
IN01011: ;AND
	MOVE.W #4,6(SP)
	RTS
IN01010: ;SUB
	MOVE.W #3,6(SP)
	RTS
IN0100:
	BTST.B #3,4(SP)
	BEQ IN01000
IN01001: ;ADD
	MOVE.W #2,6(SP)
	RTS
IN01000: ;COPY
	MOVE.W #1,6(SP)
	RTS
IN00: ;EXIT
	MOVE.W #0,6(SP)
	RTS	

    ;--- FDECOD: FIN DECOD
	
    END START
