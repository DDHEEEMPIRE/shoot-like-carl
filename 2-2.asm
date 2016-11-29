;定义数据段
DSEG 		SEGMENT
NUM 		DW    8072H
DSEG 		ENDS
;定义代码段
CSEG 		SEGMENT
     		ASSUME  CS: CSEG, DS: DSEG
START 		PROC 	FAR
     		PUSH 	DS
    		XOR 	AX, AX 
    		PUSH 	AX     	 		;压入返回地址
    		MOV 	AX, DSEG
    		MOV 	DS, AX	 		;设置数据段地址
    		MOV 	AX, NUM			;X→AX
    		OR  	AX, AX	 		;设置条件标志
    		JNS 	DONE    		;若xdayu0, 转DONE
    		NEG 	AX     	 		;若xxiaoyu0, 求补	得｜X｜
    		MOV 	NUM, AX   		;将X送回原处
DONE:	 	RET
START 		ENDP
CSEG 		ENDS
        	END 	START




