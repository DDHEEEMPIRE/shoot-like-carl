DSEG   	 	SEGMENT
  n1   			DB  20H  DUP(?)      				;����Դ���ݴ�����
  n2   			DB  20H  DUP(?)      				;����Ŀ�����ݴ�����
DSEG   	 	ENDS

CSEG   	SEGMENT
      		ASSUME 	CS:CSEG, DS:DSEG, ES:DSEG
MAIN   	PROC 		FAR
   			MOV 		BX,DSEG
       		MOV 		DS,BX	          		;Դ��������Ķε�ַ��DS
       		MOV 		ES,BX          			;Ŀ����������Ķε�ַ��ES
;ѭ���ṹ��Դ������������00H��1FH
			MOV			SI,OFFSET  n1
			MOV 		AL,0
       		MOV 		CX,32			;LOOP DE CI SHU
LP:     	MOV 		[SI],AL
       		INC 		AL
       		INC 		SI                      ;��Դ������������32��
       		LOOP 		LP           	 		;�ֽ�����00H,��,1FH
;��*1����¼LOOP   LPָ��ִ�н�������м����н��
;��ָ��ʵ�����ݿ��ƶ�
      		MOV 		SI,OFFSET  n1 			;Դ���������ƫ�Ƶ�ַ��SI
      		MOV 		DI,OFFSET  n2   		;Ŀ�����������ƫ�Ƶ�ַ��DI
      		MOV 		CX,32   		    	;�����ȡ�CX
      		REP 		MOVSB
;��*2����¼��ָ��ִ�к�����н��
			MOV			AH,4CH
			INT			21H
MAIN		ENDP
CSEG   	ENDS
        	END 		MAIN

