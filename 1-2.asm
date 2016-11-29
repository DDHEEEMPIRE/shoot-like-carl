DATAS SEGMENT
	count	DW	10		;number of numbers to be compared
	number	DB	2,46,71,24,67,89,34,83,34,56	;numbers to be compared
	max		DB	?		;the biggest number
DATAS ENDS
CODES SEGMENT
   		ASSUME CS:CODES, DS:DATAS
START:
	    MOV		AX, DATAS
	    MOV 	DS, AX
	    MOV 	CX, count
	    MOV		SI, OFFSET number
	    MOV		BL, [SI]
	    INC		SI
	    MOV		max, BL
	    DEC		CX
LP:
		MOV		BL, [SI]
		INC		SI
		CMP		max, BL
		JNC		NEXT
		MOV		max, BL
NEXT:	DEC		CX
		JNZ		LP
	    MOV		AH, 4CH
	    INT		21H
CODES ENDS
    END START


