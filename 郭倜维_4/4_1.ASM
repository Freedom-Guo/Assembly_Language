NAME GTW
EXTRN BUF:BYTE,BUFB:BYTE,COUNT:BYTE,CHENGJI:BYTE
PUBLIC FUN3,FUN4

.386
DATA SEGMENT USE16 PARA PUBLIC 'D1'
DATA ENDS

STACK SEGMENT USE16 PARA STACK 'STACK'
      DB 2000 DUP(0)
STACK ENDS

CODE SEGMENT USE16 PARA PUBLIC 'CODE'
     ASSUME DS:DATA,ES:DATA,SS:STACK,CS:CODE

START:
     MOV AX, DATA
     MOV DS, AX
     MOV ES, AX
     
	 WRITE MACRO A          ;9号系统调用宏定义
     LEA DX, A
     MOV AH,9
     INT 21H
     ENDM
	  
FUN3 PROC NEAR
     MOV SI, 0;SI指向当前处理的学生
     MOV DI, 0;用来控制比较循环
     MOV CX, 0
     MOV DX, 0;CX、DX表示当前处理的是第几个学生，也用来控制计算名次的循环次数
     MOV AX, 0;存放比当前学生分数高的人数
     MOV BL, 0;存放当前学生的分数
LOP1:
     MOV AX, 0
     MOV CX, 0
     MOV DI, 0
     MOV BL, BUF[SI+13]
LOP2:
     CMP BUF[DI+13], BL
     JBE X1
     ADD AX, 1
X1:
     ADD DI, 16
     ADD CX, 1
     CMP CX, 5
     JNE LOP2
     ADD AX, 1 
     MOV BUF+14[SI], AL 
     ADD SI,16
     ADD DX,1
     CMP DX,5
     JNE LOP1
;计算排名的功能结束
     RET
     FUN3 ENDP

FUN4 PROC FAR
;输出成绩单的程序开始
     MOV AX, DATA
     MOV DS, AX
     MOV ES, AX
     WRITE CHENGJI;输出成绩单提示
     MOV COUNT, 5
     MOV SI, 0
LOP3:
     MOV DX, SI     ;9号调用输出姓名
     MOV AH, 9 
     INT 21H     
     MOV DL, 20H
     MOV AH, 2
     INT 21H
     MOV CX, 4     ;CX保存待转换的4个成绩个数
     MOV DI, 10
     ADD DI, SI
LOPA:
     MOV AL, [DI]
     MOV AH, 0
     MOV DX, 16
     CALL F2T10
     MOV DL, '/'
     MOV AH,2
     INT 21H;显示'/'
     ADD DI, 1
     DEC CX
     JNE LOPA          ;LOPA是用来输出4个成绩
LOP5:
     MOV  CX, 1
     MOV  DI, 14
     ADD  DI, SI
     MOV  AX, [DI]
     MOV  DX, 16
     CALL F2T10
     MOV DL, '/'
     MOV AH, 2
     INT 21H

     MOV DL,0AH
     MOV AH,2
     INT 21H
     ADD SI,16
     DEC COUNT
     JNE LOP3   ;输出成绩单的程序结束
     RET
FUN4 ENDP

     MOV AH,4CH
     INT 21H

F2T10 PROC FAR
     PUSH CX
     PUSH EBX
     PUSH SI
     LEA SI, BUFB
     CMP DX, 32
     JE B
     MOVSX EAX,AX
B:
     OR EAX, EAX
     JNS PL
     NEG EAX
     MOV BYTE PTR [SI], '-'
     INC SI
PL:
     MOV EBX, 10
     CALL RADIX
     MOV BYTE PTR [SI], '$'
     LEA DX,BUFB
     MOV AH,9
     INT 21H
     POP SI
     POP EBX
     POP CX
     RET
F2T10 ENDP

RADIX PROC
     PUSH CX
     PUSH EDX
     XOR CX, CX
LP1:
     XOR EDX, EDX
     DIV EBX
     PUSH DX
     INC CX
     OR EAX, EAX
     JNZ LP1
LP2:
     POP AX
     CMP AL, 10
     JB  L1
     ADD AL, 7
L1:
     ADD AL, 30H
     MOV [SI], AL
     INC SI
     LOOP LP2
     POP EDX
     POP CX
     RET
RADIX ENDP
CODE ENDS
     END START
