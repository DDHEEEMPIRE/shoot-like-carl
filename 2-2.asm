;�������ݶ�
DSEG 		SEGMENT
NUM 		DW    8072H
DSEG 		ENDS
;��������
CSEG 		SEGMENT
     		ASSUME  CS: CSEG, DS: DSEG
START 		PROC 	FAR
     		PUSH 	DS
    		XOR 	AX, AX 
    		PUSH 	AX     	 		;ѹ�뷵�ص�ַ
    		MOV 	AX, DSEG
    		MOV 	DS, AX	 		;�������ݶε�ַ
    		MOV 	AX, NUM			;X��AX
    		OR  	AX, AX	 		;����������־
    		JNS 	DONE    		;��xdayu0, תDONE
    		NEG 	AX     	 		;��xxiaoyu0, ��	�ã�X��
    		MOV 	NUM, AX   		;��X�ͻ�ԭ��
DONE:	 	RET
START 		ENDP
CSEG 		ENDS
        	END 	START




