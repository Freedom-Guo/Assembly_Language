MODEL SMALL
.CODE
PUBLIC _rank
_rank PROC NEAR
    PUSH BP
    MOV BP, SP
    PUSH SP
    PUSH SI
    PUSH DI
    MOV SI, [BP+4] ; SI指向当前处理的学生
    MOV DI, 0 ; 用来控制比较循环
    MOV CX, 0
    MOV DX, 0 ; CX、DX表示当前处理的是第几个学生，也用来控制计算名次的循环次数
    MOV AX, 0 ; 存放比当前学生分数高的人数
    MOV BL, 0 ; 存放当前学生的分数
LOP1:
    MOV AX, 0
    MOV CX, 0
    MOV DI, [BP+4];  MOV DI,SI
    MOV BX, [SI+16]
LOP2:
    CMP [DI+16], BX
    JBE X1
    ADD AX, 1
X1:
    ADD DI, 20
    ADD CX, 1
    CMP CX, 5
    JNE LOP2
    ADD AX, 1
    MOV [SI+18], AX
    ADD SI, 20
    ADD DX, 1
    CMP DX, 5
    JNE LOP1
;计算排名的功能结束
QUIT2:
    POP DI
    POP SI
    POP SP
    POP BP
RET
_rank ENDP
END

RET
FUN3 ENDP