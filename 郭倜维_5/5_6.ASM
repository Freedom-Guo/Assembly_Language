.386
; 堆栈段
STACK SEGMENT USE16 STACK
   DB 200 DUP(0)
STACK ENDS
; 代码段
CODE SEGMENT USE16
   ASSUME CS:CODE, DS:CODE, SS:STACK
; 新的 INT08H 使用的变量
   COUNT   DB   18 ; “滴答”计数
   HOUR    DB   ?,?,':' ; 时的ASCII码
   MIN     DB   ?,?,':' ; 分的ASCII码
   SEC     DB   ?,?  ; 秒的ASCII码
   BUF_LEN = $ - HOUR ; 计算显示信息长度
   CURSOR  DW   ? ; 原光标位置
   OLD_INT DW   ?,? ; 原INT08H的中断矢量
   MESSAGE1 DB   0DH, 0AH, 'PRESS ANY KEY TO RETURN', 0DH, 0AH, 0DH, 0AH, '$' ;提示返回信息
   TIP  DB   0DH, 0AH, 'PLEASE SELECT:   ' ; 提示输入信息
           DB   0DH, 0AH, '              1. Sinple display chars'
		   DB   0DH, 0AH, '              2. New 8 interupt, and restore when return'
		   DB   0DH, 0AH, '              3. New 8 interupt, and residule when return'
		   DB   0DH, 0AH, '$'
	SELECT_ITEM  DB  0

NEW08H PROC FAR
   PUSHF 
   CALL DWORD PTR CS:OLD_INT
   DEC     CS:COUNT ; 倒计数
   JZ      DISP ; 计满18次，转到时钟显示
   IRET ;为计满，中断返回

DISP:  
   MOV     CS: COUNT, 18
   STI ;开中断
   PUSHA ; 保护现场，将所有十六位寄存器入栈
   PUSH    DS
   PUSH    ES
   MOV     AX, CS ; 将DS、ES指向CS
   MOV     DS, AX
   MOV     ES, AX
  
   CALL    GET_TIME ;获取当前时间
   
   MOV     BH, 0
   MOV     AH, 3
   INT     10H
   
   MOV     CURSOR, DX ; 保存原光标位置
   MOV     BP, OFFSET HOUR ; ES:[BP]指向显示信息的起始地址
   MOV     BH, 0 ;显示到0号页面
   MOV     DH, 0 ; 显示到0行
   MOV     DL, 0 ; 显示到0列
   MOV     BL, 07H ; 显示字符的颜色属性
   MOV     CX, BUF_LEN ; 显示的字符长度
   MOV     AL, 0
   MOV     AH, 13H ; 调用显示字符串的功能
   INT     10H ; 在zuo上角显示出当前时间
   
   MOV     BH, 0 ;对0号页面记性操作
   MOV     DX, CURSOR ; 恢复原来的光标位置
   
   MOV     AH, 2 ;设置光标位置的功能号
   INT     10H ;还原光标位置
   POP     ES
   POP     DS
   POPA  ;恢复现场
   IRET  ;中断返回
NEW08H  ENDP

GET_TIME  PROC ; 取时间子程序，从RT/CMOS RAM 中取得时分秒并转换成ASCII码存放在对应的变量中
   PUSHA
   
   MOV     AL, 4 ; 时的偏移地址是4 分的偏移地址是2 秒的偏移地址是0
   OUT     70H, AL ; 设定将要访问的单元是偏移地址为4的“时”的信息
   JMP     $+2 ; 延时
   IN      AL, 71H ; 读取时的信息
   MOV     AH, AL
   AND     AL, 0FH ; 前四位取0，后四位保留
   SHR     AH, 4
   ADD     AX, 3030H ; 转换成ASCII码
   XCHG    AH, AL
   MOV     WORD PTR HOUR, AX ; 将时保存到HOUR变量指示的前两个字节中
   
   MOV     AL, 2
   OUT     70H, AL
   JMP     $+2
   IN      AL, 71H ; 读取分的信息
   MOV     AH, AL
   AND     AL, 0FH
   SHR     AH, 4
   ADD     AX, 3030H
   XCHG    AH, AL
   MOV     WORD PTR MIN, AX	; 保存到MIN变量指示的前两个字节中
   
   MOV     AL, 0
   OUT     70H, AL
   JMP     $+2
   IN      AL, 71H ; 读取秒的信息
   MOV     AH, AL
   AND     AL, 0FH
   SHR     AH, 4
   ADD     AX, 3030H
   XCHG    AH, AL
   MOV     WORD PTR SEC, AX
   POPA
   RET
GET_TIME ENDP

DELAY  PROC ; 延时程序段
   PUSH    ECX
   MOV     ECX, 0
L1:   
   INC     ECX
   CMP     ECX, 0600000H
   JB      L1
   POP     ECX
   RET
DELAY  ENDP

GET_SET_INTR8_ADDRESS  PROC ; 获取原来8号中断的中断程序的入口地址
   MOV     AX, 3508H
   INT     21H 
   MOV     OLD_INT, BX ; 设置新的8号中断处理程序的入口地址
   MOV     OLD_INT+2, ES
   INT     21H
   RET
GET_SET_INTR8_ADDRESS  ENDP

RESTORE_INT8_RETURN PROC ; 将中断处理程序的入口地址复原
   LDS     DX, DWORD PTR OLD_INT
   MOV     AX, 2508H
   INT     21H
   MOV     AH, 4CH
   INT     21H
RESTORE_INT8_RETURN ENDP

RESIDULE_INTR8   PROC ; 将新的中断处理程序驻留内存
   MOV     DX, OFFSET DELAY+15 ; 驻留时计算所需空间
   MOV     CL, 4
   SHR     DX, CL
   ADD     DX, 10H
   MOV     AL, 0
   MOV     AL, 31H
   INT     21H
RESIDULE_INTR8 ENDP

;主程序开始
BEGIN:
   PUSH    CS
   POP     DS
   
   LEA     DX, TIP
   MOV     AH, 9
   INT     21H

   MOV     AH, 1
   INT     21H

   MOV     SELECT_ITEM, AL

   LEA     DX, MESSAGE1
   MOV     AH, 9
   INT     21H

   CMP     SELECT_ITEM, '1'
   JZ      DISP_CHARS

   CALL    GET_SET_INTR8_ADDRESS

DISP_CHARS:
   MOV     DL, 30H
LOOP_DISP:
   MOV     AH, 2
   INT     21H

   CALL    DELAY

   MOV     AH, 0BH
   INT     21H
   CMP     AL, 0
   JNZ     EXIT
   INC     DL
   CMP     DL, 200
   JNZ     CONTINUE
   MOV     DL, 30H
CONTINUE:
   JMP     LOOP_DISP

EXIT:
   CMP     SELECT_ITEM, '1'
   JZ      EXIT1
   CMP     SELECT_ITEM,'3'
   JZ      EXIT3

   JMP     EXIT2

EXIT1:
   MOV     AH, 4CH
   INT     21H

EXIT2:
   CALL   RESTORE_INT8_RETURN 

EXIT3:
   CALL    RESIDULE_INTR8

CODE  ENDS
   END    BEGIN 
