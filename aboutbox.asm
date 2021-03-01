_words_ struct			
  char	CHAR	?		
  x		DWORD	?		
  y		DWORD	?		
  ex		DWORD	?		
  ey		DWORD	?		
  pcount	BYTE	?
_words_ ends


IFDEF USE_JPG			
	USE_IMAGE = 1			
ELSEIFDEF USE_BMP			
	USE_IMAGE = 1		
ENDIF					


.const
	aWidth			equ	400	
	aHeight			equ	200	

	aStandartDelayTime	equ	4800	

	aStartXPos			equ	30	
	aStartYPos			equ	10	

.data

	ahDC			dd	0	
	ahBmp			dd	0	
	
	IFDEF USE_BRUSH			
		ahBrush	dd	0	
	ENDIF
	
	ahFont 		dd	0	
  
	aWnd			dd	0	
	aMainDC		dd	0	
						

	IFDEF USE_IMAGE			
		ahBitmap	dd	0	
		ahBitmapDC	dd	0
	ENDIF

	aThread		dd	0	

	awords 		dd	0	

	aGlobalStop		BOOL	FALSE	

	aDelayTime		dd	0	
	
	aRandSeed		dd	0	
	
	aStartPos		dd	0	
	aEndPos		dd	0	
	astrLen		dd	0	


	szaFontName		db	"Terminal", 0			
	szaTitle		db	"ab0utb0x", 0	
	
	szaText	db	13,13,13,13						
			db	"  >>>     tEAM F5 Experts    <<<  ",13,13	
			db	"             PRESENTS             ",13
			db	" ",8
			db  13,13,13
			db	"     tARGEt : KT v1.0",13
			db  "    CracKeR : mrT4ntr4",13
			db	" pr0tecti0n : custom ",13
			db	"   rls date : o 1 . o 3 . 2 o 2 1",13
			db  "     Music  : Vasha",8
			db  13,13,13,13,13
			db	"        greetz fly out 2 :",13
			db  " ",8
			db  13,13,13
			db	"  s4r................[F5 Experts]",13
			db	"  xusheng............[F5 Experts]",13
			db  "  towel..............[F5 Experts]",13
			db  "  mrT4ntr4...........[F5 Experts]",13
			db  "  alxbl..............[F5 Experts]",13
			db	" ",8
			db  13,13,13
			db  "  X3eRo0.............[F5 Experts]",13		
			db  "  x0r19x91...........[F5 Experts]",13
			db  "  aventador..........[F5 Experts]",13
			db  "  zed-zahir..........[F5 Experts]",13
			db  "  Shad3..............[F5 Experts]",13
			db  " ",8
			db  13,13,13
			db  "  dns................[F5 Experts]",13
			db  "  Mr.Un1k0d3r........[F5 Experts]",13
			db  "  archercreat........[F5 Experts]",13
			db  "  shreyansh26........[F5 Experts]",13
			db  "  Jochen_............[F5 Experts]",13
			db  " ",8
			db  13,13,13
			db	" but also : ",13,13
			db  "  r0ger.....................[PRF]",13
			db  "  Xylitol...................[RED]",13
			db  "  Ufo-Pu55y.................[SnD]",13
			db	"  Goppit.................[Arteam]",13
			db  " ",8
			db  13,13,13,13,13
			db  " and also some tuts4you members !",13
			db  " ",8
			db  13,13,13
			db  " sh0ut 0ut 2 :",13,13
			db  "- [Multani] for music inspiration",13
			db  "- [mihir upadhyaya] for illustration",13
			db  "- [UfO-Pu55y] for the BASSMOD lib",13			
			db  "- [x0man] for this ab0ut temp",8
			db	13,13,13
			db  "          || Contact ||    ",13,13
			db  "      Twitter :  @MrT4ntr4 ",13
			db  "      Github  :  mrT4ntr4  ",13
			db  " ",8
			db  13,13,13
			db  "       || Team Contact ||    ",13,13
			db  "     Twitter :  @f5_experts  ",13
			db  13,13,13
			db  "   #f5_experts  <<est. 2o20>> ",8,0

.code

TopXY proc wDim:DWORD, sDim:DWORD

    shr sDim, 1      ; divide screen dimension by 2
    shr wDim, 1      ; divide window dimension by 2
    mov eax, sDim
    sub eax, wDim

    ret

TopXY endp

GetLinesCount proc
	
	push ecx
	push edx
	
	xor eax, eax
	xor ecx, ecx
	mov edx, offset szaText

	.repeat
		
		.if (byte ptr [edx + ecx] == 8)
			inc eax
		.endif

		inc ecx
	.until ecx >= astrLen
	
	pop edx
	pop ecx

	ret
GetLinesCount endp

SEPos proc

	push ecx
	push edx
	
	mov ecx, aStartPos
	mov edx, offset szaText
	
	.repeat
		
		.if (byte ptr [edx + ecx] == 8)
			mov aEndPos, ecx
			jmp @ex
		.endif

	inc ecx
	.until ecx > astrLen
	
	
@ex:	pop edx
	pop ecx
	
	ret
SEPos endp

Init_Proc proc

	mov aGlobalStop, FALSE
	
	push aStandartDelayTime
	pop aDelayTime

	invoke GetDC, aWnd
	mov aMainDC, eax
	
	invoke CreateCompatibleDC, 0
	mov ahDC, eax

	; creating bitmap using ahDC
	invoke CreateBitmap, aWidth, aHeight, 1, 32, NULL
	mov ahBmp, eax

	; creating font
  	invoke CreateFont, 12, 8, 0, 0, 400, 0, 0, 0,
					DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
					DEFAULT_QUALITY, DEFAULT_PITCH, addr szaFontName
	mov ahFont, eax

	; assign ahDC with other variables
	invoke SelectObject, ahDC, ahBmp
	invoke SelectObject, ahDC, ahFont
	
	; set the color of the text
	;f2c511
	;invoke SetTextColor, ahDC, 00106ee8h
	invoke SetTextColor, ahDC, 0011c5f2h
	
	;...and the color of the background
	IFDEF USE_BRUSH
		invoke CreateSolidBrush, 00000000h
		mov ahBrush, eax
		
		invoke SelectObject, ahDC, eax
	ENDIF
	
	; you can either set the JPG/BMP image as a background for this aboutbox , just to make sure it has the same dimensions as the aboutbox's.
	IFDEF USE_IMAGE
	
		IFDEF USE_JPG
			invoke BitmapFromResource, 0, 550
		ELSEIFDEF USE_BMP
			invoke GetModuleHandle, 0
			invoke LoadBitmap, eax, 550
		ENDIF
	
	mov ahBitmap, eax
	
	invoke CreateCompatibleDC, NULL
	mov ahBitmapDC, eax
	
	invoke SelectObject, ahBitmapDC, ahBitmap
	
	ENDIF
	
	invoke SetBkMode, ahDC, TRANSPARENT

	invoke lstrlen, addr szaText
	mov astrLen, eax

	inc eax

	imul eax, sizeof _words_
	
	invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, eax
	mov awords, eax

	ret
Init_Proc endp

Free_Proc proc

	IFDEF USE_IMAGE
		invoke DeleteObject, ahBitmap
		invoke DeleteDC, ahBitmapDC
	ELSEIFDEF USE_BRUSH
		invoke DeleteObject, ahBrush
	ENDIF

	invoke DeleteObject, ahBmp
	invoke DeleteObject, ahFont
		
	invoke DeleteDC, ahDC
	invoke DeleteDC, aMainDC
	
	invoke GlobalFree, awords

	ret
Free_Proc endp

Resort_Words proc
LOCAL xPos:DWORD, yPos:DWORD
	
	push aStartXPos
	pop xPos
	
	push aStartYPos
	pop yPos
	
	xor ecx, ecx
	mov ebx, offset szaText
	mov edi, awords
	
	assume edi : ptr _words_

	.repeat
		mov al, byte ptr [ebx + ecx]
		mov byte ptr [edi].char, al

		push xPos
		pop [edi].ex
		
		push yPos
		pop [edi].ey

		push aHeight
		pop [edi].x

		push yPos
		pop [edi].y

		mov [edi].pcount, 0
		
		add xPos, 10
		
		.if al == 13	
			push aStartXPos
			pop xPos
			
			add yPos, 14	

		.elseif al == 8	
			push aStartXPos
			pop xPos
			
			push aStartYPos
			pop yPos

		.endif
		
		add edi, sizeof _words_
		inc ecx
		
	.until ecx >= astrLen
	
	assume edi : ptr nothing
	
	ret
Resort_Words endp

;---------------------------------------

Draw proc
LOCAL aLinesCount	: DWORD	
LOCAL aLineNumber	: DWORD	
LOCAL await:BOOL			
LOCAL aNextLine:BOOL		
LOCAL aChangeDelayTime:BOOL	


	call GetLinesCount
	mov aLinesCount, eax

	mov aLineNumber, 1
	mov aStartPos, 0
	call SEPos
	
	push aStandartDelayTime
	pop aDelayTime

	assume edi : ptr _words_	
	mov edi, awords
	
	.repeat
	
		IFDEF USE_IMAGE
			invoke BitBlt, ahDC, 0, 0, aWidth, aHeight, ahBitmapDC, 0, 0, SRCCOPY
		ELSE
			invoke Rectangle, ahDC, 0, 0, aWidth, aHeight
		ENDIF
		
		mov await, TRUE
		
		mov edi, awords
		mov ecx, aStartPos

		mov eax, ecx
		imul eax, sizeof _words_
		add edi, eax

		.repeat
		
		.if aGlobalStop == TRUE
			jmp @@ex
		.endif

		
		.if [edi].char != 13 && [edi].char != 8
			
				push ecx	
				push edi

				invoke TextOut, ahDC, [edi].x, [edi].y, addr [edi].char, 1
				
				pop edi 
				pop ecx
		.endif
					
			mov eax, [edi].x
			.if eax != [edi].ex
				
				mov eax, [edi].x
				.if eax < [edi].ex
					inc [edi].x
				.else
					dec [edi].x
				.endif
				
			.endif
			
			mov eax, [edi].y
			.if eax != [edi].ey
			
				mov eax, [edi].y
				.if eax < [edi].ey
					inc [edi].y
				.else
					dec [edi].y
				.endif
				
			.endif
			
			mov eax, [edi].x
			mov edx, [edi].y				
			.if (eax != [edi].ex) || ( edx != [edi].ey)
				mov await, FALSE	
			.endif
				
			
			inc ecx
			add edi, sizeof _words_
			
		.until (ecx >= aEndPos) || (ecx >= astrLen)
		
		invoke BitBlt, aMainDC, 0, 0, aWidth, aHeight, ahDC, 0, 0, SRCCOPY
				

			.if await == TRUE
			
				mov aNextLine, TRUE
				mov aChangeDelayTime, TRUE

				push edi
				push ecx
				
				invoke GetTickCount
				mov ecx, eax
				

				.repeat
				.if aGlobalStop
					jmp @@ex
				.endif
					
					push ecx
					invoke BitBlt, aMainDC, 0, 0, aWidth, aHeight, ahDC, 0, 0, SRCCOPY
					invoke GetTickCount
					pop ecx
					
					sub eax, ecx
					
				.until eax >= aDelayTime
				
				mov edi, awords
				mov ecx, aStartPos
				
				mov eax, ecx
				imul eax, sizeof _words_
				add edi, eax

				inc [edi].pcount

				.if ( [edi].pcount != 2)
					mov aNextLine, FALSE
				.endif

				.if ([edi].pcount != 1)
					mov aChangeDelayTime, FALSE
				.endif
			
				.repeat
					.if aGlobalStop == TRUE
						jmp @@ex
					.endif
					
					push aHeight
					pop [edi].ey	
					
					add edi, sizeof _words_					
					inc ecx
				.until (ecx >= aEndPos) || (ecx >=astrLen)

				pop ecx
				pop edi
								
				.if aNextLine == TRUE					
					inc aLineNumber
					
					push aStandartDelayTime
					pop aDelayTime
					
					push aEndPos
					pop aStartPos
					
					inc aStartPos
					
					call SEPos
				.endif
				
				.if aChangeDelayTime
					xor eax, eax
					mov aDelayTime, eax
				.endif
						
				mov eax, aLinesCount
				.if aLineNumber > eax

					mov aLineNumber, 1	
					mov aStartPos, 0		

					push aStandartDelayTime
					pop aDelayTime
					
					call Resort_Words
					call SEPos
				.endif

			.endif
	
	.until aGlobalStop == TRUE
	
	@@ex:
	
	mov aGlobalStop, FALSE

	xor eax, eax
	ret
Draw endp

AboutProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
LOCAL x
LOCAL y

	mov eax, uMsg
	.if eax == WM_INITDIALOG
			
		push hWnd
		pop aWnd
		
		invoke GetSystemMetrics, SM_CXSCREEN
		invoke TopXY, aWidth, eax
		mov x, eax
		
		invoke GetSystemMetrics, SM_CYSCREEN
		invoke TopXY, aHeight, eax
		mov y, eax
		
		invoke SetWindowPos, hWnd, 0, x, y, aWidth, aHeight, SWP_SHOWWINDOW
		
		invoke SetWindowText, hWnd, addr szaTitle
		call Init_Proc
		
		call Resort_Words

		invoke CreateThread, NULL, 0, addr Draw, 0, 0, addr aThread

	.elseif eax == WM_LBUTTONDOWN
		invoke SendMessage, hWnd, WM_NCLBUTTONDOWN, HTCAPTION, 0
				
	.elseif eax == WM_RBUTTONUP		
		invoke SendMessage, hWnd, WM_CLOSE, 0, 0

	.elseif eax == WM_CLOSE
	
		mov aGlobalStop, TRUE
		
		.repeat
			invoke Sleep, 1
		.until aGlobalStop == FALSE
		
		call Free_Proc

		invoke EndDialog, hWnd, 0
		
	.endif
	
	xor eax, eax
	ret
AboutProc endp
