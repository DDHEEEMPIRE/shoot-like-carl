DSEG   	 	SEGMENT
  n1   			DB  20H  DUP(?)      				;定义源数据串区域
  n2   			DB  20H  DUP(?)      				;定义目的数据串区域
DSEG   	 	ENDS

CSEG   	SEGMENT
      		ASSUME 	CS:CSEG, DS:DSEG, ES:DSEG
MAIN   	PROC 		FAR
   			MOV 		BX,DSEG
       		MOV 		DS,BX	          		;源数据区域的段地址→DS
       		MOV 		ES,BX          			;目的数据区域的段地址→ES
;循环结构向源串区存入数据00H—1FH
			MOV			SI,OFFSET  n1
			MOV 		AL,0
       		MOV 		CX,32			;LOOP DE CI SHU
LP:     	MOV 		[SI],AL
       		INC 		AL
       		INC 		SI                      ;在源数据区中置入32个
       		LOOP 		LP           	 		;字节数据00H,…,1FH
;（*1）记录LOOP   LP指令执行结束后的中间运行结果
;串指令实现数据块移动
      		MOV 		SI,OFFSET  n1 			;源数据区域的偏移地址→SI
      		MOV 		DI,OFFSET  n2   		;目的数据区域的偏移地址→DI
      		MOV 		CX,32   		    	;串长度→CX
      		REP 		MOVSB
;（*2）记录串指令执行后的运行结果
			MOV			AH,4CH
			INT			21H
MAIN		ENDP
CSEG   	ENDS
        	END 		MAIN

