.386  ; 堆栈段
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
   MOV     BH, 0 ; 显示到0号页面
   MOV     DH, 0 ; 显示到0行
   MOV     DL, 0 ; 显示到最后几列
   MOV     BL, 07H ; 显示字符的颜色属性
   MOV     CX, BUF_LEN ; 显示的字符长度
   MOV     AL, 0
   MOV     AH, 13H ; 调用显示字符串的功能
   INT     10H ; 在右上角显示出当前时间
   
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

BEGIN:	
   PUSH	   CS
   POP	   DS
   MOV	   AX, 3508H ; 获取原08H的中断矢量
   INT	   21H
   MOV	   OLD_INT, BX ; 保存中断变量
   MOV	   OLD_INT+2, ES
   MOV	   DX, OFFSET NEW08H
   MOV	   AX, 2508H ; 设置新的08H中断变量
   INT	   21H

NEXT:	
   MOV	   AH, 0 ; 等待按键
   INT	   16H
   CMP	   AL, 'q' ;若按下q键则退出
   JNE	   NEXT
;驻留修改后的中断
   MOV     DX, OFFSET BEGIN+15
   MOV     CL, 4
   SHR     DX, CL
   ADD     DX, 10H    
   MOV     AL, 0
   MOV     AH, 31H
   INT     21H ; 退出

CODE	ENDS
   END	   BEGIN
