.386
.model flat,stdcall
option casemap:none


USE_BRUSH = 1

include		windows.inc
include		kernel32.inc
include		user32.inc
include		gdi32.inc
include		comctl32.inc
include		winmm.inc
include		masm32.inc
include 	\masm32\macros\macros.asm
include		ole32.inc
include 	oleaut32.inc

includelib	kernel32.lib
includelib	user32.lib
includelib	gdi32.lib
includelib 	shell32.lib
includelib	winmm.lib
includelib 	masm32.lib
includelib  oleaut32.lib
includelib  ole32.lib
includelib	comctl32.lib
includelib	comdlg32.lib
includelib	msvcrt.lib

include		pnglib.inc
includelib	pnglib.lib
include 	btnt.inc

include		TextScroller.inc
includelib	TextScroller.lib

include bassmod.inc
includelib bassmod.lib

include aboutbox.asm


DlgProc			PROTO :DWORD,:DWORD,:DWORD,:DWORD
AboutProc		PROTO	:DWORD,:DWORD,:DWORD,:DWORD
GenerateSerial	PROTO :DWORD


.data
include vasha.inc

WindowTitle		db 		"Keygen Template by MrT4ntr4",0
TxtFont		LOGFONT <16,0,0,0,FW_BOLD,0,0,0,DEFAULT_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,DEFAULT_QUALITY, 0,"Consolas">
DefaultName		db 		"mrT4ntr4",0
DefaultSerial	db		"XXXX-XXXX-XXXX-XXXX",0
ScrollerText TCHAR ">> tEAM F5 Experts pr0udly presents : KT v1.0 - *keYgenned by mrT4ntr4* | pr0tecti0n : custom | ",
				"GfX : mrT4ntr4, mihir upadhyaya | SfX : by mrT4ntr4 (inspired by Multani) | ",
				"greetz to Gfxer r0ger for the inspiration through his collection of Keygen Templates, Xylitol for the MASM32 Snippets on his github, ", 
				"F5 Experts memberz and tuts4you forum for keeping the artscene alive ",
				"| My Twitter: @MrT4ntr4 | Team Twitter: @f5_experts | (C) 2o21 <<",0
lfFont			LOGFONT	<14,0,0,0,FW_DONTCARE,0,0,0,DEFAULT_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,\
				DEFAULT_QUALITY	,DEFAULT_PITCH or FF_DONTCARE,'Retro Gaming'>
nFont			dd		1
TooLong			db	"Your name is too long !",0
TooShort		db	"Your name is too short !",0
key1			dd		015h
key2			dd		013h
keyFormat		db		"%d-",0
keyEndFormat 	db		"%d",0


.const
KEYGEN_ICON		equ		200
IDD_KEYGEN		equ		1001
IDC_NAME		equ 	1003
IDC_SERIAL		equ 	1004
IDC_GENERATE    equ		1005
IDC_ABOUT		equ 	1006
IDC_IDCANCEL	equ 	1007
DELAY_VALUE		equ		10
ID_FONT			equ		1337
IDD_ABOUTBOX	equ		2000


.data?
hFont			dd		?
hName			dd		?
hSerial			dd		?
scr				SCROLLER_STRUCT <>
hFontRes		dd		?
ptrFont			dd		?
NameBuffer		db		50  dup(?)
NameLen			dd		?
SerialBuffer	db		50  dup(?)
SerialSection	db		50 	dup(?)


AllowSingleInstance MACRO lpTitle
        invoke FindWindow,NULL,lpTitle
        cmp eax, 0
        je @F
          push eax
          invoke ShowWindow,eax,SW_RESTORE
          pop eax
          invoke SetForegroundWindow,eax
          mov eax, 0
          ret
        @@:
      ENDM


.code
start:
	invoke	GetModuleHandle, NULL
	mov	hInstance, eax
	AllowSingleInstance addr WindowTitle
	invoke InitCommonControls
	invoke	DialogBoxParam, hInstance, IDD_KEYGEN, NULL, ADDR DlgProc, NULL
	invoke	ExitProcess, eax
; -----------------------------------------------------------------------
DlgProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

	.if uMsg==WM_INITDIALOG
		invoke SetWindowText,hWnd,addr WindowTitle
		invoke AnimateWindow,hWnd,1000,AW_BLEND
		invoke LoadIcon,hInstance,KEYGEN_ICON
		
		;init music
		invoke BASSMOD_DllMain, hInstance, DLL_PROCESS_ATTACH,NULL
		invoke BASSMOD_Init, -1, 44100, 0
		invoke BASSMOD_MusicLoad, TRUE, addr xm, 0, 0, BASS_MUSIC_LOOP or BASS_MUSIC_RAMPS or BASS_MUSIC_SURROUND or BASS_MUSIC_POSRESET
		invoke BASSMOD_MusicPlay
		
		;init imagebuttons
		invoke ImageButton,hWnd,15,345,701,701,702,IDC_IDCANCEL
		invoke ImageButton,hWnd,50,345,601,601,602,IDC_ABOUT  ;UP, DOWN, MOVER
		invoke ImageButton,hWnd,340,345,801,801,802,IDC_GENERATE
		
		;set fonts
		invoke CreateFontIndirect,addr TxtFont
		mov hFont,eax
		
		invoke GetDlgItem,hWnd,IDC_NAME
		mov hName,eax
		invoke SendMessage,hName,WM_SETFONT,hFont,1
		invoke SetDlgItemText,hWnd,IDC_NAME,addr DefaultName
		
		invoke GetDlgItem,hWnd,IDC_SERIAL
		mov hSerial,eax
		invoke SendMessage,hSerial,WM_SETFONT,hFont,1
		invoke SetDlgItemText,hWnd,IDC_SERIAL,addr DefaultSerial
		
		;set scroll font with font in resource
		invoke FindResource,NULL,ID_FONT,RT_RCDATA
		mov hFontRes,eax
		invoke LoadResource,NULL,eax
		.if eax
			invoke LockResource,eax
			mov ptrFont,eax
			invoke SizeofResource,NULL,hFontRes
			invoke AddFontMemResourceEx,ptrFont,eax,0,addr nFont
		.endif
		invoke CreateFontIndirect,addr lfFont
		mov scr.scroll_hFont,eax
		
		;init scroller
		m2m scr.scroll_hwnd, hWnd
		mov scr.scroll_text, offset ScrollerText
		mov scr.scroll_x, 200
		mov scr.scroll_y, 7
		mov scr.scroll_width, 350
		mov scr.scroll_textcolor,00106ee8h
		invoke CreateScroller, addr scr
		
		
	.elseif uMsg == WM_LBUTTONDOWN
		invoke  SendMessage,hWnd,WM_NCLBUTTONDOWN,HTCAPTION,lParam
	
	.elseif uMsg == WM_RBUTTONDOWN
		invoke ShowWindow,hWnd,SW_MINIMIZE
		
	.elseif uMsg == WM_CTLCOLORSTATIC ||uMsg == WM_CTLCOLOREDIT
		mov eax, lParam
		invoke SetTextColor, wParam, 000080d6h
		invoke SetBkMode, wParam, TRANSPARENT
		invoke CreateSolidBrush,  00000000h
   	 	ret
   	 	
	.elseif uMsg==WM_COMMAND
		.if wParam==IDC_ABOUT
			invoke DialogBoxParam,0,IDD_ABOUTBOX,hWnd,addr AboutProc,0
		.elseif wParam==IDC_IDCANCEL
			invoke SendMessage,hWnd, WM_CLOSE, NULL, NULL
		.elseif wParam==IDC_GENERATE
			invoke GetDlgItemText,hWnd,IDC_NAME,addr NameBuffer,sizeof NameBuffer
			mov edi, offset NameBuffer
			invoke lstrlen, edi
			.if eax > 20
				invoke SetDlgItemText,hWnd,IDC_SERIAL,addr TooLong
			.elseif eax < 3
				invoke SetDlgItemText,hWnd,IDC_SERIAL,addr TooShort
			.else
				mov NameLen,eax
				invoke GenerateSerial, hWnd
			.endif
		.endif

	.elseif uMsg==WM_CLOSE
		invoke BASSMOD_Free
		invoke BASSMOD_DllMain, hInstance, DLL_PROCESS_DETACH, NULL	
		invoke AnimateWindow,hWnd,300,AW_BLEND+AW_HIDE
		invoke EndDialog, hWnd, 0
		
	.endif
	xor	eax,eax
	ret
DlgProc	endp


GenerateSerial proc hWnd:HWND
	xor ecx, ecx
	xor eax, eax
	mov esi, NameLen
	mov edx, key1
@@:	
	movsx ebx, byte ptr [edi + eax]
	add ebx, edx
	add ecx, ebx
	inc eax
	cmp eax, esi
	jl @b
	invoke wsprintf, addr SerialBuffer, addr keyFormat, ecx
	xor ecx, ecx
	mov eax, ecx
	mov edx, key1

@@:
	movsx ebx, byte ptr [edi + eax]
	imul ebx, edx
	add ecx, ebx
	inc eax
	cmp eax, esi
	jl @b
	invoke wsprintf, addr SerialSection, addr keyFormat, ecx
	invoke lstrcat, addr SerialBuffer, addr SerialSection
	xor ecx, ecx
	mov eax, ecx
	mov edx, key2
@@:
	movsx ebx, byte ptr [edi + eax]
	xor ebx, edx
	add ecx, ebx
	inc eax
	cmp eax, esi
	jl @b
	invoke wsprintf, addr SerialSection, addr keyFormat, ecx
	invoke lstrcat, addr SerialBuffer, addr SerialSection
	xor ecx, ecx
	mov eax, ecx
	mov edx, key2
@@:
	movsx ebx, byte ptr [edi + eax]
	imul ebx, edx	
	add ecx, ebx
	inc eax
	cmp eax, esi
	jl @b
	invoke wsprintf, addr SerialSection, addr keyEndFormat,ecx
	invoke lstrcat, addr SerialBuffer, addr SerialSection
	
	;set final
	invoke SetDlgItemText, hWnd, IDC_SERIAL, addr SerialBuffer
	xor eax, eax
	ret
GenerateSerial EndP



end start
