MODEL SMALL
.CODE
PUBLIC _avg
_avg PROC NEAR
     PUSH BP
     MOV  BP, SP
     PUSH SP
     PUSH SI
     PUSH DI
     MOV  DI, 5              
     MOV  SI, [BP+4] ;这里SI指向data的地址                
T21:
     MOV BX, [SI+10]
     SAL BX, 2
     MOV AX, [SI+12]
     SAL AX, 1
     ADD BX, AX
     MOV AX, [SI+14]
     ADD AX, BX
     CWD
     MOV CX, 7
     IDIV CX
     MOV [SI+16], AL
     ADD SI, 20
     DEC DI
     JNE T21

QUIT:
     POP DI
     POP SI
     POP SP
     POP BP
RET
_avg ENDP
END

  