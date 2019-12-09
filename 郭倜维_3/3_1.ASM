.386
DATA SEGMENT USE16
N EQU 30
BUF DB 'zhangsan',0,0
    DB 100,85,80,?
    DB 'lisi',6 DUP(0)
    DB 80,100,70,?
    DB 'hust',6 DUP(0)
    DB 70,90,66,?
    DB 'informa',3 DUP(0)
    DB 60,70,74,?
    DB N-5 DUP('TempValue',0,80,90,95,?)
    DB 'guotiwei',0,0
    DB 85,85,100,?
TIP1 DB 0AH,0DH,'Please input the student name!$'
TIP2 DB 0AH,0DH,'NO FOUND THE STUDENT!$'
TIP3 DB 0AH,0DH,'INPUT ERROR!$'
TIPE DB 0AH,0DH,'SEE YOU!$'
IN_NAME DB 10
     	DB 0
     	DB 10 DUP(0)
POIN DW 0
DATA ENDS

STACK SEGMENT USE16 STACK
    DB 200 DUP(?)
STACK ENDS

CODE SEGMENT USE16
    ASSUME CS:CODE,DS:DATA,SS:STACK


START:
      MOV AX, DATA 
      MOV DS, AX
	  MOV SI, OFFSET BUF 
	  MOV DI, 30
	  CALL FINDTA
INPUT:
	  LEA DX, TIP1
      MOV AH, 9
	  INT 21H ;输出提示信息"Please input the student name!"
      MOV DL,0AH  
	  MOV AH,2
	  INT 21H
	  MOV DL,0DH
	  MOV AH,2
	  INT 21H		;输出换行回车
	  LEA DX, IN_NAME
	  MOV AH, 10
	  INT 21H ;输入学生姓名到IN_NAME为首址的存储器中
	  MOV BL,IN_NAME+1
	  MOV BH, 0
	  CMP BL, BH
	  JE INPUT ;如果没有输入，则跳回提示信息TIP1处
	  CMP BL, 10
	  JA ERR ;如果超过10个字符的输入，则提示错误
	  CMP BL, 1
	  JE EXITQ	  
	  
	  LEA BP, OFFSET IN_NAME
XZ:   MOV AL,DS:[BP]
      ADD BP,1
      CMP AL,0DH
      JNE XZ
      DEC BP
      MOV AL,0
      XCHG DS:[BP],AL 
	  LEA BP, OFFSET IN_NAME
      ADD BP,2


	  CALL STRCMP

	  CMP AX, 1
	  JE YES
	  JMP NO

YES:  
      MOV SI, OFFSET BUF
	  MOV DH,0
	  IMUL DX, 14
	  ADD SI, DX
	  MOV POIN, SI
	  CALL THERANK
	  JMP INPUT
NO:
      LEA DX, TIP2
      MOV AH, 9
	  INT 21H ;输出提示信息"NO FOUND THE STUDENT!"
      MOV DL,0AH  
	  MOV AH,2
	  INT 21H
	  MOV DL,0DH
	  MOV AH,2
	  INT 21H		;输出换行回车
	  JMP INPUT

STRCMP PROC  ;查找字符串
FIND:	  
	  PUSH SI 
	  PUSH DI
	  PUSH BX
	  MOV DX, 0;学生个数
	  MOV SI, OFFSET BUF
	  MOV DI, OFFSET IN_NAME+2;输入首字母[di+2]
	  MOVZX CX, [IN_NAME+1]
LOOP1:
      MOV AL, [SI]
	  MOV BL, [DI] 
	  CMP AL, BL
	  JNE NOSTUDENT1
	  JMP NEXT
NOSTUDENT1:
	  INC DX
	  CMP DX, N
	  JE NOSTUDENT
	  ADD SI,14;下一个学生
	  MOV DI,OFFSET IN_NAME+2;输入首字母[di+2]
	  JMP LOOP1
NOSTUDENT:
      MOV AX, 0
	  JMP SEXIT

NEXT: 
	  INC DI
	  INC SI
	  DEC CX
	  JZ SAME
	  JMP LOOP1

SAME:
      MOV AX, 1
	  JMP SEXIT

SEXIT: 
	  POP BX
	  POP DI
	  POP SI
	  RET
STRCMP ENDP


FINDTHENAME:
     CALL THERANK

FINDTA PROC   ;计算平均值
AVE: 
	 MOV AL, [SI+10]
	 MOV BL, [SI+11]
	 MOV CL, [SI+12]
	 MOV AH, 0
	 MOV BH, 0
	 MOV CH, 0
	 SAL AX, 2
	 SAL BX, 1
	 ADD AX, BX
	 ADD AX, CX
	 MOV CL, 7  
	 DIV CL ;平均成绩计算规则归纳为（A*4+B*2+C）/7
	 MOV [SI+13], AL
	 ADD SI, 14
	 DEC DI ;控制量DI，将30名学生的平均值计算完
	 JNZ AVE
	 RET
FINDTA ENDP

THERANK PROC   ;判断成绩等级
     PUSH BX
	 MOV BX, POIN
	 MOV AL, DS:[BX+13]
	 CMP AL, 90
	 JAE LOAP1
	 CMP AL, 80
	 JAE LOAP2
	 CMP AL, 70
	 JAE LOAP3
	 CMP AL, 60
	 JAE LOAP4
	 MOV DL, 0AH
	 MOV AH, 2
	 INT 21H
	 MOV DL, 0DH
	 MOV AH, 2
	 INT 21H
	 MOV DL, 46H
	 MOV AH, 2
	 INT 21H
	 JMP NEXT2
LOAP1:	
     MOV DL, 0AH    
	 MOV AH, 2
	 INT 21H
	 MOV DL, 0DH
	 MOV AH, 2
	 INT 21H
	 MOV DL, 41H	;输出A
	 MOV AH, 2
	 INT 21H
	 JMP NEXT2
LOAP2:	
     MOV DL, 0AH
	 MOV AH, 2
	 INT 21H
	 MOV DL, 0DH
	 MOV AH, 2
	 INT 21H
	 MOV DL, 42H	;输出B
	 MOV AH, 2
	 INT 21H
	 JMP NEXT2
LOAP3:	
     MOV DL, 0AH
	 MOV AH, 2
	 INT 21H
	 MOV DL, 0DH
	 MOV AH, 2
	 INT 21H
	 MOV DL, 43H	;输出C
	 MOV AH, 2
	 INT 21H
	 JMP NEXT2
LOAP4:	
     MOV DL, 0AH
	 MOV AH, 2
	 INT 21H
	 MOV DL, 0DH
	 MOV AH, 2
	 INT 21H
	 MOV DL, 44H	;输出D
	 MOV AH, 2
	 INT 21H
	 JMP NEXT2
NEXT2:
	 POP BX
	 RET
THERANK ENDP


EXITQ:
     MOV AL, IN_NAME+2
	 CMP AL,71H ;如果输入q则退出程序
	 JE EXIT
	 CALL STRCMP
	 ; MOV DL,0AH  
	 ; MOV AH,2
	 ; INT 21H
     ; MOV DL,0DH
	 ; MOV AH,2
     ; INT 21H		;输出回车换行

ERR:	
     LEA DX,TIP3
	 MOV AH,9
	 INT 21H		;显示错误信息'INPUT ERROR!'
	 JMP INPUT

EXIT:	
    LEA DX,TIPE
	MOV AH,9
	INT 21H		;显示提示信息'SEE YOU!'
	MOV AH,4CH
	INT 21H

CODE ENDS
     END START