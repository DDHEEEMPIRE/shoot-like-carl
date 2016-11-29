DATAS SEGMENT
	number		DB	100 DUP(?)		;numbers to be calculated
	sum			DW	?				;result
DATAS ENDS
CODES SEGMENT
    		ASSUME	CS: CODES, DS: DATAS
START:
		    MOV 	AX, DATAS
		    MOV		DS, AX
		    MOV		SI, OFFSET number
    		MOV		AL, 0
    		MOV		CX, 100
LP1:     	MOV 	[SI], AL
	   		INC 	AL
	   		INC 	SI
	   		LOOP 	LP1
		    MOV		SI, OFFSET number
	   		MOV		AX, 0
	   		MOV		CX, 100
	   		MOV		BH, 0
LP2:		MOV		BL, [SI]
			ADD		AX, BX
			INC		SI
			LOOP	LP2
			MOV		sum, AX
		    MOV AH,4CH
		    INT 21H
CODES ENDS
    END START


