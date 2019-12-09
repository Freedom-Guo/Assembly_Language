     NAME YLT
     EXTRN FUN3:NEAR,FUN4:FAR
     PUBLIC BUF,MENU,BUFB,CHENGJI,COUNT
.386                    ;编写者：云乐天 同组同学：郭倜维

DATA   SEGMENT USE16 PARA PUBLIC 'D1'
       N EQU 5
       BUF DB 16 DUP(0)
           DB   N-1 DUP(16 DUP(0))
       BUF1 DB 10
            DB ?
            DB 10 DUP(0)
       MENU DB '    1 Scanf students information',0DH,0AH
            DB '    2 Calculate the average',0DH,0AH
            DB '    3 Computing rankings',0DH,0AH
            DB '    4 Printf school report',0DH,0AH
            DB '    5 Exit',0DH,0AH 
            DB '    Please select(1-5):','$'
      A DB 0
      TISHI1 DB 'Input error',0DH,0AH,'$'
      TISHI2 DB 0DH,0AH,'Input name:$'
      TISHI3 DB 0DH,0AH,'Input grade:$'
      TISHI4 DB 0DH,0AH,'Input to complete ! ',0DH,0AH,'$'
      TISHI5 DB 0DH,0AH,'Input error ! ',0DH,0AH,'$'
      TISHI6 DB 0DH,0AH,'Calculate complete ! ',0DH,0AH,'$'
      TISHI7 DB 0DH,0AH,'Please input the student name and perfromance!',0DH,0AH,'$'
      TISHI8 DB 0DH,0AH,'Rankings success!',0DH,0AH,'$'
      TISHI9 DB 0DH,0AH,'Printf end!',0DH,0AH,'$'
      TUICHU DB 0DH,0AH,'Thank you for using this system!',0DH,0AH,'$'
      CRLF   DB 0DH,0AH,'$'
      BUFB DB 16 DUP(0)
      CHENGJI DB 'Name  Chinese  Math/English/AVG/RANK',0DH,0AH,'$'
      COUNT DB 5 
DATA ENDS

STACK SEGMENT USE16 PARA STACK 'STACK'
       DB 2000 DUP(0)
STACK ENDS
CODE SEGMENT USE16 PARA PUBLIC 'CODE'
     ASSUME DS:DATA,ES:DATA,SS:STACK,CS:CODE
START:
      MOV AX,DATA
      MOV DS,AX
      MOV ES,AX
      WRITE MACRO A          ;9号系统调用宏定义
            LEA DX,A
            MOV AH,9
            INT 21H
            ENDM
      READ  MACRO B           ;10号系统调用宏定义
            LEA DX,B
            MOV AH,10
            INT 21H
            ENDM
  
   T0: WRITE CRLF
       WRITE MENU
       READ BUF1
       MOV AL,BUF1+2
       CMP AL,'0'             ;判断跳转到相应的功能子函数
       JLE T1
       SUB AL,31H
       JE GN1
       DEC AL
       JE GN2
       DEC AL
       JE GN3
       DEC AL
       JE GN4
       DEC AL
       JE GN5
   T1: WRITE TISHI1         ;输入有误，回到菜单输出
       JMP T0
  GN1: 
       WRITE CRLF
       CALL FUN1
      JMP T0
  GN2: 
       WRITE CRLF
       CALL FUN2
       JMP T0
  GN3: 
       WRITE CRLF
       CALL FUN3
       WRITE TISHI8
       JMP T0
  GN4:
       WRITE CRLF
       CALL FUN4
       WRITE TISHI9
       JMP T0

  GN5: WRITE TUICHU
       MOV AH,4CH
       INT 21H

FUN1  PROC NEAR
      PUSH BP
      MOV A,31H
      MOV BP,0
 STA:
      MOV DL,A
      MOV AH,2
      INT 21H

      WRITE TISHI2   ;输入学生姓名
      READ BUF1
	  MOV BL,BUF1+1
	  MOV BH,0                   ;取输入的实际字符个数->BX
	  MOV BYTE PTR BUF1+2[BX],'$';在输入串尾补$
	  LEA SI,BUF1+2
	  LEA DI,BUF[BP]
	  INC BX
	  MOV CX,BX
	  CLD 
	  REP MOVSB
	  MOV DI,0
	  ADD BP,9    ;不能随便动SP,ESP的值,SP是堆栈专用指针
    T15: 
      WRITE TISHI3  ;输入学生成绩
      READ BUF1
	  MOV BL,BUF1+1
	  MOV BH,0
	  MOV SI,0
	  MOV AX,0
	T12:
	  MOV CL,BUF1+2[SI]
    T13:
	  CMP CL,'0'
	  JNAE ERR
	T14:
	  CMP CL,'9'
	  JA ERR
	  SUB CL,30H
	  MOV CH,0
	  IMUL AX,10
	  ADD AX,CX
	  INC SI
	  CMP SI,BX
	  JL T12
	  INC BP
	  MOV DS:[BP],AL
	  INC DI
	  CMP DI,3
	  JL T15
	  JMP T16
 ERR:
	  WRITE TISHI5
	  JMP T15
 T16:
      WRITE CRLF
	  INC A
	  ADD BP,4
	  CMP A,36H
	  JL STA 
	  WRITE TISHI4
	  POP BP
	  RET
FUN1  ENDP

FUN2   PROC FAR
       MOV EDI,0              
       MOV ESI,0                
   T21:
       MOV BL,BUF[ESI+10]
       MOV BH,0
       SAL BX,2
       MOV AL,[ESI+11]
       MOV AH,0
       SAL AX,1
       ADD BX,AX
       MOV AL,[ESI+12]
       MOV AH,0
       ADD AX,BX
       CWD
       MOV CX,7
       IDIV CX
       MOV BUF[ESI+13],AL
       ADD ESI,16
       INC EDI
       CMP EDI,N
       JL T21  
       WRITE TISHI6           
      RET
FUN2  ENDP

CODE ENDS
     END START