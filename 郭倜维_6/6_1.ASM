.386
.model   flat,stdcall
option   casemap:none

WinMain  proto :DWORD,:DWORD,:DWORD,:DWORD
WndProc  proto :DWORD,:DWORD,:DWORD,:DWORD
Display  proto :DWORD

include      menuID.inc

include      windows.inc
include      user32.inc
include      kernel32.inc
include      gdi32.inc
include      shell32.inc

includelib   user32.lib
includelib   kernel32.lib
includelib   gdi32.lib
includelib   shell32.lib

student	     struct
	     myname   db  10 dup(0)
	     chinese  db  0
	     math     db  0
	     english  db  0
	     average  db  0
	     grade    db  0
student      ends

.data
;数据段
ClassName    db       'TryWinClass',0
AppName      db       'Our First Window',0
MenuName     db       'MyMenu',0
DlgName	     db       'MyDialog',0
AboutMsg     db       'I am CS1507 WYT',0
hInstance    dd       0
CommandLine  dd       0
buf	     student  	  <'Zhangsan',96,70,85,0,' '>
	     student 	  <'Wangwu',66,55,76,0,' '>
		 student  	  <'Lisi',88,90,100,0,' '>
		 student  	  <'Xuezha',57,82,74,0,' '>
		 student  	  <'Guotiwei',96,98,100,0,' '>
msg_name     db       'name',0
msg_chinese  db       'chinese',0
msg_math     db       'math',0
msg_english  db       'english',0
msg_average  db       'average',0
msg_grade    db       'grade',0
chinese	     db       2,'50','60','70','80','90'
math	     db       2,'50','60','70','80','90'
english	     db       2,'50','60','70','80','90'
average		 db		  2,'  ','  ','  ','  ','  '

.code
;主程序
Start:	     
         invoke GetModuleHandle,NULL
	     mov    hInstance,eax
	     invoke GetCommandLine
	     mov    CommandLine,eax
	     invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
	     invoke ExitProcess,eax

;窗口主程序
WinMain  proc   hInst:DWORD,hPrevInst:DWORD,CmdLine:DWORD,CmdShow:DWORD
	     LOCAL  wc:WNDCLASSEX
	     LOCAL  msg:MSG
	     LOCAL  hWnd:HWND
             invoke RtlZeroMemory,addr wc,sizeof wc
	     mov    wc.cbSize,SIZEOF WNDCLASSEX
	     mov    wc.style, CS_HREDRAW or CS_VREDRAW
	     mov    wc.lpfnWndProc, offset WndProc
	     mov    wc.cbClsExtra,NULL
	     mov    wc.cbWndExtra,NULL
	     push   hInst
	     pop    wc.hInstance
	     mov    wc.hbrBackground,COLOR_WINDOW+1
	     mov    wc.lpszMenuName, offset MenuName
	     mov    wc.lpszClassName,offset ClassName
	     invoke LoadIcon,NULL,IDI_APPLICATION
	     mov    wc.hIcon,eax
	     mov    wc.hIconSm,0
	     invoke LoadCursor,NULL,IDC_ARROW
	     mov    wc.hCursor,eax
	     invoke RegisterClassEx, addr wc
	     INVOKE CreateWindowEx,NULL,addr ClassName,addr AppName,\
                    WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\
                    CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,\
                    hInst,NULL
	     mov    hWnd,eax
	     INVOKE LoadMenu,hInst,600
	     INVOKE SetMenu,hWnd,eax		 
	     INVOKE ShowWindow,hWnd,SW_SHOWNORMAL
	     INVOKE UpdateWindow,hWnd
	     ;;
MsgLoop:     
		 INVOKE GetMessage,addr msg,NULL,0,0
         cmp    EAX,0
         je     ExitLoop
         INVOKE TranslateMessage,addr msg
         INVOKE DispatchMessage,addr msg
	     jmp    MsgLoop 
ExitLoop:    
		 mov    eax,msg.wParam
	     ret
WinMain      endp

;窗口消息处理程序
WndProc      proc   hWnd:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
	     LOCAL  hdc:HDC
		 .IF    uMsg == WM_DESTROY
				invoke PostQuitMessage,NULL
          .ELSEIF uMsg == WM_KEYDOWN
	       .IF     wParam == VK_F1
              invoke MessageBox,hWnd,addr AboutMsg,addr DlgName,0
	       .ENDIF
        .ELSEIF uMsg == WM_COMMAND
	    .IF     wParam ==1000
		    invoke SendMessage,hWnd,WM_CLOSE,0,0
	    .ELSEIF wParam == 1201
		    invoke Display,hWnd
		.ELSEIF wParam == 1200
		    call CalAverage
	    .ELSEIF wParam == 1900
		    invoke MessageBox,hWnd,addr AboutMsg,addr AppName,0
	    .ENDIF
		
     .ELSE
             invoke DefWindowProc,hWnd,uMsg,wParam,lParam
             ret
     .ENDIF
  	     xor    eax,eax
	     ret
WndProc      endp

;用户处理程序
Display      proc   hWnd:DWORD
             XX     equ  10
             YY     equ  10
			 XX_GAP equ  100
			 YY_GAP equ  30
             LOCAL  hdc:HDC
             invoke GetDC,hWnd
             mov    hdc,eax
             invoke TextOut,hdc,XX+0*XX_GAP,YY+0*YY_GAP,offset msg_name,4
             invoke TextOut,hdc,XX+1*XX_GAP,YY+0*YY_GAP,offset msg_chinese,7
             invoke TextOut,hdc,XX+2*XX_GAP,YY+0*YY_GAP,offset msg_math,4
             invoke TextOut,hdc,XX+3*XX_GAP,YY+0*YY_GAP,offset msg_english,7
             invoke TextOut,hdc,XX+4*XX_GAP,YY+0*YY_GAP,offset msg_average,7
             invoke TextOut,hdc,XX+5*XX_GAP,YY+0*YY_GAP,offset msg_grade,5
;//
             invoke TextOut,hdc,XX+0*XX_GAP,YY+1*YY_GAP,offset buf[0*15].myname,8
             invoke TextOut,hdc,XX+1*XX_GAP,YY+1*YY_GAP,offset chinese+1,chinese
             invoke TextOut,hdc,XX+2*XX_GAP,YY+1*YY_GAP,offset math+1,   math
             invoke TextOut,hdc,XX+3*XX_GAP,YY+1*YY_GAP,offset english+1,english
             invoke TextOut,hdc,XX+4*XX_GAP,YY+1*YY_GAP,offset average+1,2
             invoke TextOut,hdc,XX+5*XX_GAP,YY+1*YY_GAP,offset buf[0*15].grade,1
;//			 
             invoke TextOut,hdc,XX+0*XX_GAP,YY+2*YY_GAP,offset buf[1*15].myname,6
             invoke TextOut,hdc,XX+1*XX_GAP,YY+2*YY_GAP,offset chinese+3,chinese
             invoke TextOut,hdc,XX+2*XX_GAP,YY+2*YY_GAP,offset math+3,   math
             invoke TextOut,hdc,XX+3*XX_GAP,YY+2*YY_GAP,offset english+3,english
             invoke TextOut,hdc,XX+4*XX_GAP,YY+2*YY_GAP,offset average+3,2
             invoke TextOut,hdc,XX+5*XX_GAP,YY+2*YY_GAP,offset buf[1*15].grade,1
;//			 
             invoke TextOut,hdc,XX+0*XX_GAP,YY+3*YY_GAP,offset buf[2*15].myname,4
             invoke TextOut,hdc,XX+1*XX_GAP,YY+3*YY_GAP,offset chinese+5,chinese
             invoke TextOut,hdc,XX+2*XX_GAP,YY+3*YY_GAP,offset math+5,   math
             invoke TextOut,hdc,XX+3*XX_GAP,YY+3*YY_GAP,offset english+5,english
             invoke TextOut,hdc,XX+4*XX_GAP,YY+3*YY_GAP,offset average+5,2
             invoke TextOut,hdc,XX+5*XX_GAP,YY+3*YY_GAP,offset buf[2*15].grade,1
;//
             invoke TextOut,hdc,XX+0*XX_GAP,YY+4*YY_GAP,offset buf[3*15].myname,5
             invoke TextOut,hdc,XX+1*XX_GAP,YY+4*YY_GAP,offset chinese+7,chinese
             invoke TextOut,hdc,XX+2*XX_GAP,YY+4*YY_GAP,offset math+7,   math
             invoke TextOut,hdc,XX+3*XX_GAP,YY+4*YY_GAP,offset english+7,english
             invoke TextOut,hdc,XX+4*XX_GAP,YY+4*YY_GAP,offset average+7,2
             invoke TextOut,hdc,XX+5*XX_GAP,YY+4*YY_GAP,offset buf[3*15].grade,1
;//
             invoke TextOut,hdc,XX+0*XX_GAP,YY+5*YY_GAP,offset buf[4*15].myname,6
             invoke TextOut,hdc,XX+1*XX_GAP,YY+5*YY_GAP,offset chinese+9,chinese
             invoke TextOut,hdc,XX+2*XX_GAP,YY+5*YY_GAP,offset math+9,   math
             invoke TextOut,hdc,XX+3*XX_GAP,YY+5*YY_GAP,offset english+9,english
             invoke TextOut,hdc,XX+4*XX_GAP,YY+5*YY_GAP,offset average+9,2
             invoke TextOut,hdc,XX+5*XX_GAP,YY+5*YY_GAP,offset buf[4*15].grade,1
             ret
Display      endp

;子程序名：CalAverage
CalAverage proc
	    mov cx, 5
	    mov di,0
	    mov esi,0
loopcalc:
		push cx
		mov ax, 0
		MOV AL,2
		ADD ESI,10
		MOV BH,byte ptr buf[ESI]
		MUL BH
		MOV BX,AX
		;语文成绩保存在BH中，BH*AL->AX,语文成绩乘以2，数据转移到BX中
		INC ESI
		MOV AX,0
		MOV AL,byte ptr buf[ESI]
		ADD BX,AX
		;将数学成绩保存在AL中，加上数学成绩，数据放在BX中
		INC ESI
		MOV AX,0
		MOV DX,0
		MOV AL,byte ptr buf[ESI]
		MOV CX,2
		DIV CX
		ADD BX,AX
		;英语成绩在AX中，将英语成绩除以2后，商保存在AX中,余数保存在DX中
		MOV AL,2
		MUL BX
		MOV DX,0
		MOV CX,7
		DIV CX
		INC ESI
		MOV byte ptr buf[ESI],AL

		push ax
		movzx ax,al
		mov bl,10
		div bl
		add ax,3030h
		inc di 
		mov average[di],al
		inc di
		mov average[di],ah
		pop ax
		INC ESI

		CMP al,90
		JAE GRADEA
		CMP al,80
		JAE GRADEB
		CMP al,70
		JAE GRADEC
		CMP al,60
		JAE GRADED
GRADEF:
		MOV byte ptr buf[ESI],'F'
		JMP JUG
GRADEA:
		MOV BYTE PTR buf[ESI],'A'
		JMP JUG
GRADEB:
		MOV BYTE PTR buf[ESI],'B'
		JMP JUG
GRADEC:
		MOV BYTE PTR buf[ESI],'C'
		JMP JUG
GRADED:
		MOV BYTE PTR buf[ESI],'D'
JUG:
		inc esi
		pop cx
		dec cx
	jnz loopcalc
ret
CacAverage endp
             end  Start
