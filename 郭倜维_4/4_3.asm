MODEL SMALL
.CODE
PUBLIC _rank
_rank PROC NEAR
    PUSH BP
    MOV BP, SP
    PUSH SP
    PUSH SI
    PUSH DI
    MOV SI, [BP+4] ; SIָ��ǰ�����ѧ��
    MOV DI, 0 ; �������ƱȽ�ѭ��
    MOV CX, 0
    MOV DX, 0 ; CX��DX��ʾ��ǰ������ǵڼ���ѧ����Ҳ�������Ƽ������ε�ѭ������
    MOV AX, 0 ; ��űȵ�ǰѧ�������ߵ�����
    MOV BL, 0 ; ��ŵ�ǰѧ���ķ���
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
;���������Ĺ��ܽ���
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