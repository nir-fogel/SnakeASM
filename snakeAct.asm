;**************************
;snakeAct-snake actions:
;the procedures of snakePro
;**************************

;-----------------------------
;DelayProc - do nothing (mov ax to itself 65000 times)
;-----------------------------
proc DelayProc
	push ax 
	push bx 
	push cx
	push dx

	mov cx, 65000
	
DellayLabel:
	mov ax,ax
	loop DellayLabel
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp DelayProc
;----------------------------------------------
;DelayMusic - do nothing (for the music tuning)
;----------------------------------------------
proc DelayMusic
	push ax 
	push bx 
	push cx
	push dx

	mov cx, 55134
	
DellayLabelMusic:
	mov ax,ax
	loop DellayLabelMusic
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp DelayMusic

;-----------------------------------------------
; DrawBoarders - drawing the borders of the game
;-----------------------------------------------
proc DrawBoarders
	push ax
	push bx
	push cx
	push dx
	
	mov [borderColor], WHITE ; set the border color
	mov [yBorder], 0
	mov [xBorder], 0
NORTH_BORDER:
	mov cx, [xBorder] ; X position
	mov dx, [yBorder] ; Y position
	mov bh, 0h
	mov al, [borderColor]
	mov ah,0Ch
	int 10h
	;loop north
	inc [xBorder]
	cmp [xBorder], MAX_X_COLUMNS
	jb NORTH_BORDER
	
	mov [xBorder], 0
	inc [yBorder]
	cmp [yBorder], BORDER_Y_LIMIT
	jb NORTH_BORDER
	
	mov [yBorder], MAX_Y_LINES
	mov [xBorder], 0

SOUTH_BORDER:	
	mov cx, [xBorder] ; X position
	mov dx, [yBorder] ; Y position
	mov bh, 0h
	mov al, [borderColor]
	mov ah,0Ch
	int 10h
	;loop south
	inc [xBorder]
	cmp cx, MAX_X_COLUMNS
	jb SOUTH_BORDER
	
	mov [xBorder], 0
	dec [yBorder]
	cmp [yBorder], MAX_Y_LINES-BORDER_Y_LIMIT
	ja SOUTH_BORDER
	
	mov [yBorder], 0
	mov [xBorder], 0
WEST_BORDER:	
	mov cx, [xBorder] ; X position
	mov dx, [yBorder] ; Y position
	mov bh, 0h
	mov al, [borderColor]
	mov ah,0Ch
	int 10h
	;loop west
	inc [yBorder]
	cmp [yBorder], MAX_Y_LINES
	jb WEST_BORDER
	
	mov [yBorder], 0
	inc [xBorder]
	cmp [xBorder], BORDER_X_LIMIT
	jb WEST_BORDER
	
	mov [yBorder], 0
	mov [xBorder], MAX_X_COLUMNS
EAST_BORDER:	
	mov cx, [xBorder] ; X position
	mov dx, [yBorder] ; Y position
	mov bh, 0h
	mov al, [borderColor]
	mov ah,0Ch
	int 10h
	;loop east
	inc [yBorder]
	cmp dx, MAX_Y_LINES
	jb EAST_BORDER
	
	mov [yBorder], 0
	dec [xBorder]
	cmp [xBorder], MAX_X_COLUMNS-BORDER_X_LIMIT
	ja EAST_BORDER
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp DrawBoarders
;-----------------------------------------------
; DrawSnake - drawing the snake at the beginning
; and making the first initialization
;-----------------------------------------------
proc DrawSnake
	push ax
	push bx
	push cx
	push dx

	mov [yTail], SNAKE_Y_START
	mov [xTail], SNAKE_X_START
	mov [snakeLen], SNAKE_LEN

	xor bx,bx
	mov bl, [snakeLen]
	inc bl
	mov [cntr], bx
	
	push SNAKE_COLOR	;push Color
	push [xTail] 		;RECT0_X_START
	push SQUARE_LEN 	;RECT0_LEN
	push [yTail]		;RECT0_Y_START
	push SQUARE_WIDTH	;RECT0_WIDTH
	call DrawSquare
	
SNAKE_SIZE:
	; enter the direction to the array
	push [xTail]	;push x [bp+4]
	push [yTail]	;push y [bp+2]
	call CallculatePlace
	mov bx, [placeInArr]
	mov [byte ptr offset Array + bx], RIGHT 
	
	; draw snake
	add [xTail], SQUARE_LEN
	push SNAKE_COLOR	;push Color
	push [xTail] 		;RECT0_X_START
	push SQUARE_LEN 	;RECT0_LEN
	push [yTail]		;RECT0_Y_START
	push SQUARE_WIDTH	;RECT0_WIDTH
	call DrawSquare
	dec [cntr]
	cmp [cntr], 0

	ja SNAKE_SIZE
	
	; enter the direction to the array (to the head)
	push [xTail]	;push x [bp+4]
	push [yTail]	;push y [bp+2]
	call CallculatePlace
	mov bx, [placeInArr]
	mov [byte ptr offset Array + bx], RIGHT 

	mov [Hdirection], RIGHT	; set the default direction
	mov [Tdirection], RIGHT	;       of the snake
	
	mov ax, [xTail]
	mov [xHead], ax	; set xHead
	mov ax, [yTail]
	mov [yHead], ax	;set yHead
	
	mov [xTail], SNAKE_X_START	; reset xTail to where he start
	mov [yTail], SNAKE_Y_START	; reset yTail to where he start
	
	

	;delete tail - first time
	push BLACK				;push Color
	push [xTail] 	;RECT0_X_START
	push SQUARE_LEN 	;RECT0_LEN
	push [yTail]		;RECT0_Y_START
	push SQUARE_WIDTH	;RECT0_WIDTH
	call DrawSquare
	

	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp DrawSnake
;----------------------------------------
;DrawSquare- drawing square by
;parameters given in stack (5 parameters)
;----------------------------------------
proc DrawSquare
	mov bp, sp
	push bp
	push ax
	push bx
	push cx
	push dx
	
	mov al,  [bp+2]		;-- RECT1_WIDTH parameter (last push)
	mov [cntrLines], al ; can mov directly to cntrLines ?
	mov dx,  [bp+4]		;-- RECT1_Y_START parameter

SQUARE_LINES:
	mov al, [bp+6] 		;-- RECT1_LEN parameter
	mov [cntrColumns], al
	mov cx, [bp+8]  	;-- RECT1_X_START
	;mov cx, RECT1_X_START ; X position
	mov bh,0h
	mov al, [bp+10] 	;-[bp+12]- color parameter
SQUARE_COLUMNS:
	mov ah,0Ch
	int 10h
	inc cx
	dec [cntrColumns]
	cmp [cntrColumns], 0
	ja SQUARE_COLUMNS
	inc dx
	dec [cntrLines]
	cmp [cntrLines], 0
	ja SQUARE_LINES

	pop dx
	pop cx
	pop bx
	pop ax
	pop bp

	;push COLOR [bp + 10]
	;push X_START [bp + 8]
	;push LENGTH [bp + 6]
	;push Y_START [bp +4]
	;push WIDTH [bp+2]
	
	;call DrawSquare

	ret 10 ; plus 2 per each parameter
endp DrawSquare
;------------------------------------------------------------
;CallculatePlace - calculates the place of the square (0-254)
;------------------------------------------------------------
proc CallculatePlace
	mov bp, sp
	push bp
	push ax
	push bx
	push cx
	push dx
	
	xor ax, ax
	mov al, [bp+4] ;x
	sub ax, BORDER_X_LIMIT
	mov bl, SQUARE_WIDTH
	div bl 		; answer in al
	mov [columnNum], al
	
	xor ax, ax
	mov al, [bp+2]	;y
	sub ax, BORDER_Y_LIMIT
	mov bl, SQUARE_LEN
	div bl 		; answer in al
	mov [lineNum], al
	
	mov bl, 17
	mul bl
	add al, [columnNum]
	
	mov [placeInArr], ax
	
	
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	
	;push x [bp+4]
	;push y [bp+2]
	;call CallculatePlace
	
	ret 4 ; plus 2 for each parameter
endp CallculatePlace
;--------------------------------
;RandomApple - mades random apple
;--------------------------------
proc RandomApple
	push ax
	push bx
	push cx
	push dx
	
GET_APPLE_Y:	
	mov ah, 0
	int 1Ah
	
	mov ax,dx
	xor dx, dx
	mov cx, 15
	div cx ; answer in dx
	
	xor ax, ax
	mov al, 12
	mov bl, dl
	mul bl
	
	add ax, BORDER_Y_LIMIT
	mov [yApple], ax

GET_APPLE_X:
	mov ah, 0
	int 1Ah
	
	mov ax,dx
	xor dx, dx
	mov cx, 17
	div cx ; answer in dx
	
	xor ax, ax
	mov al, 12
	mov bl, dl
	mul bl
	
	add ax, BORDER_X_LIMIT
	mov [xApple], ax

	;check if apple isnt in the snake body or border
	mov bh,0h
	mov cx, [xApple] ; X position
	mov dx, [yApple] ; Y position
	mov ah,0Dh
	int 10h ; return al the pixel value read
	cmp al, SNAKE_COLOR
	je GET_APPLE_Y
	cmp al, [borderColor]
	je GET_APPLE_Y
	
	;draw apple
	push APPLE_COLOR	;push RED
	push [xApple]		;push RECT0_X_START
	push SQUARE_LEN		;push RECT0_LEN
	push [yApple]		;push RECT0_Y_START
	push SQUARE_WIDTH	;push RECT0_WIDTH
	
	call DrawSquare

	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp RandomApple
;---------------------------------------------------------
; AppleSound - Playing the sound of the snake eating apple
;---------------------------------------------------------
proc AppleSound
	push ax
	push bx
	push cx
	push dx
	
	in al, 61h
	or al, 00000011b	; open speakers
	out 61h, al
	
	mov al, 0B6h
	out 43h, al
	
	mov ax, 047B4h   ;091A6h
	out 42h, al
	mov al, ah
	out 42h, al
	
	call DelayProc
	call DelayProc

	
	in al, 61h
	and al, 11111100b	; close speakers
	out 61h, al
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp AppleSound
;-----------------------------------------------
; MarioSound - Playing the sound of the end game
;-----------------------------------------------
proc MarioSound
	push ax
	push bx
	push cx
	push dx
	
	push B4
	call PlayEighth
	call DelayMusic
	
	push F5
	call PlayEighth
	call DelayMusic

	call DelayMusic
	call DelayMusic
	call DelayMusic

	push F5
	call PlayEighth
	call DelayMusic
	
	push F5
	call PlayTriola
	call DelayMusic
	
	push E5
	call PlayTriola
	call DelayMusic
	
	push D5
	call PlayTriola
	call DelayMusic
	
	push C5
	call PlayEighth
	call DelayMusic
	
	push E4
	call PlayEighth
	call DelayMusic
	
	call DelayMusic
	call DelayMusic
	call DelayMusic
	
	push E4
	call PlayEighth
	call DelayMusic
	
	push C4
	call PlayQuarter
	call DelayMusic
;-----------------------	
	mov cx, 6
Break1:
	call DelayMusic
	loop Break1
;-----------------------	
	
	push C5
	call PlayEighth
	call DelayMusic
	
	mov cx, 6
Break2:
	call DelayMusic
	loop Break2

	push G4
	call PlayEighth
	call DelayMusic	
	
	mov cx, 6
Break3:
	call DelayMusic
	loop Break3
	
	push E4
	call PlayQuarter
	call DelayMusic
	
	push A4
	call PlayTriola
	call DelayMusic
	
	push B4
	call PlayTriola
	call DelayMusic
	
	push A4
	call PlayTriola
	call DelayMusic
	
	push A4b
	call PlayTriola
	call DelayMusic
	
	push B4b
	call PlayTriola
	call DelayMusic
	
	push A4b
	call PlayTriola
	call DelayMusic
	
	push G4
	call PlayFull
	call DelayMusic
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp MarioSound
;------------------------------------
; PlayFull - play note in rate of 4/4
;------------------------------------
proc PlayFull
	mov bp, sp
	push bp
	push ax
	push bx
	push cx
	push dx
	
	in al, 61h
	or al, 00000011b	; open speakers
	out 61h, al
	
	mov al, 0B6h	;enable change note
	out 43h, al
	
	mov ax, [bp+2]
	out 42h, al
	mov al, ah
	out 42h, al		; make sound
	
	mov cx, 24
DelayFull:
	call DelayMusic
	loop DelayFull
	
	in al, 61h
	and al, 11111100b	; close speakers
	out 61h, al
	
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 2
endp PlayFull
;---------------------------------------
; PlayQuarter - play note in rate of 1/4
;---------------------------------------
proc PlayQuarter
	mov bp, sp
	push bp
	push ax
	push bx
	push cx
	push dx
	
	in al, 61h
	or al, 00000011b	; open speakers
	out 61h, al
	
	mov al, 0B6h	;enable change note
	out 43h, al
	
	mov ax, [bp+2]
	out 42h, al
	mov al, ah
	out 42h, al		; make sound
	
	mov cx, 6
DelayQuarter:
	call DelayMusic
	loop DelayQuarter

	in al, 61h
	and al, 11111100b	; close speakers
	out 61h, al
	
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 2
endp PlayQuarter
;--------------------------------------
; PlayEighth - play note in rate of 1/8
;--------------------------------------
proc PlayEighth
	mov bp, sp
	push bp
	push ax
	push bx
	push cx
	push dx
	
	in al, 61h
	or al, 00000011b	; open speakers
	out 61h, al
	
	mov al, 0B6h	;enable change note
	out 43h, al
	
	mov ax, [bp+2]
	out 42h, al
	mov al, ah
	out 42h, al		; make sound
	
	call DelayMusic
	call DelayMusic
	call DelayMusic
	
	in al, 61h
	and al, 11111100b	; close speakers
	out 61h, al
	
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 2
endp PlayEighth
;--------------------------------------
; PlayTriola - play note in rate of 1/3
;--------------------------------------
proc PlayTriola
	mov bp, sp
	push bp
	push ax
	push bx
	push cx
	push dx
	
	in al, 61h
	or al, 00000011b	; open speakers
	out 61h, al
	
	mov al, 0B6h	;enable change note
	out 43h, al
	
	mov ax, [bp+2]
	out 42h, al
	mov al, ah
	out 42h, al		; make sound
	
	call DelayMusic
	call DelayMusic
	call DelayMusic
	call DelayMusic
	
	in al, 61h
	and al, 11111100b	; close speakers
	out 61h, al
	
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 2
endp PlayTriola
;-----------------------------------------------
; HeadDirection - calculate the head next square
;-----------------------------------------------
proc HeadDirection
	push ax
	push bx
	push cx
	push dx

	cmp [Hdirection], UP
	je HEAD_UP
	cmp [Hdirection], DOWN
	je HEAD_DOWN
	cmp [Hdirection], LEFT
	je HEAD_LEFT
	cmp [Hdirection], RIGHT
	je HEAD_RIGHT

HEAD_UP:
	sub [yHead], SQUARE_WIDTH
	jmp HEAD_DONE
HEAD_DOWN:
	add [yHead], SQUARE_WIDTH
	jmp HEAD_DONE
HEAD_LEFT:
	sub [xHead], SQUARE_LEN
	jmp HEAD_DONE
HEAD_RIGHT:
	add [xHead], SQUARE_LEN
	jmp HEAD_DONE

HEAD_DONE:
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp HeadDirection

;-----------------------------------------
; CheckTailDir - find the tail direction.
; Algorithm: the Array represents all
; of the places that the snake can be (0-254),
; in each place there is the value of the 
; direction of the snake, check the value
; and change by that the Tdirection
;------------------------------------------ 
proc CheckTailDir
	push ax
	push bx
	push cx
	push dx

	push [xTail]	;push x [bp+4]
	push [yTail]	;push y [bp+2]
	call CallculatePlace
	
	mov bx, [placeInArr]
	cmp [byte ptr offset Array + bx], RIGHT
	je TAIL_TO_RIGHT
	cmp [byte ptr offset Array + bx], LEFT
	je TAIL_TO_LEFT
	cmp [byte ptr offset Array + bx], DOWN
	je TAIL_TO_DOWN
	cmp [byte ptr offset Array + bx], UP
	je TAIL_TO_UP	

TAIL_TO_RIGHT:
	mov [Tdirection], RIGHT
	jmp TAIL_TO_DONE
TAIL_TO_LEFT:
	mov [Tdirection], LEFT
	jmp TAIL_TO_DONE
TAIL_TO_DOWN:
	mov [Tdirection], DOWN
	jmp TAIL_TO_DONE
TAIL_TO_UP:
	mov [Tdirection], UP

TAIL_TO_DONE:	
; delete the direction from the array
	mov [byte ptr offset Array + bx], 0 
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp CheckTailDir
;-----------------------------------------------
; TailDirection - calculate the next Tail square
;-----------------------------------------------
proc TailDirection
	push ax
	push bx
	push cx
	push dx
	
	cmp [appleCntr], 0 ; if the snake ate apple, skip the calculation
	je CONT_TAIL_DIRECTION
	jmp TAIL_DONE
CONT_TAIL_DIRECTION:
	call CheckTailDir

	cmp [Tdirection], UP
	jne TDIRECTION_NOT_UP
	jmp TAIL_UP
TDIRECTION_NOT_UP:
	cmp [Tdirection], DOWN
	jne TDIRECTION_NOT_DOWN
	jmp TAIL_DOWN
TDIRECTION_NOT_DOWN:
	cmp [Tdirection], LEFT
	jne TDIRECTION_NOT_LEFT
	jmp TAIL_LEFT
TDIRECTION_NOT_LEFT:
	jmp TAIL_RIGHT

TAIL_UP:
	sub [yTail], SQUARE_WIDTH
	
	;check if tail went into border (north border)
	mov bh,0h
	mov cx, [xTail] ; X position
	mov dx, [yTail] ; Y position
	add dx, SQUARE_WIDTH-1 
	mov ah,0Dh
	int 10h ; return al the pixel value read
	cmp al, [borderColor]
	je END_UP
	;check for north border
	
	push [xTail]	;push x [bp+4]
	push [yTail]	;push y [bp+2]
	call CallculatePlace
	
	mov bx, [placeInArr]
	cmp [byte ptr offset Array + bx], UP
	jne END_UP
	jmp TAIL_DONE
END_UP:
	add [yTail], SQUARE_WIDTH
	call CheckSurround
	jmp TAIL_DONE

TAIL_DOWN:
	add [yTail], SQUARE_WIDTH
	
	;check if tail went into border
	mov bh,0h
	mov cx, [xTail] ; X position
	mov dx, [yTail] ; Y position
	mov ah,0Dh
	int 10h ; return al the pixel value read
	cmp al, [borderColor]
	je END_DOWN
	
	push [xTail]	;push x [bp+4]
	push [yTail]	;push y [bp+2]
	call CallculatePlace
	
	mov bx, [placeInArr]
	cmp [byte ptr offset Array + bx], DOWN
	jne END_DOWN
	jmp TAIL_DONE
END_DOWN:
	sub [yTail], SQUARE_WIDTH
	call CheckSurround
	jmp TAIL_DONE
	
TAIL_LEFT:
	sub [xTail], SQUARE_LEN
	
	;check if tail went into border
	mov bh,0h
	mov cx, [xTail] ; X position
	mov dx, [yTail] ; Y position
	mov ah,0Dh
	int 10h ; return al the pixel value read
	cmp al, [borderColor]
	je END_LEFT
	;check for north border
	dec dx ; dec yTail
	int 10h ; return al the pixel value read
	cmp al, [borderColor]
	je END_LEFT
	
	push [xTail]	;push x [bp+4]
	push [yTail]	;push y [bp+2]
	call CallculatePlace
	
	mov bx, [placeInArr]
	cmp [byte ptr offset Array + bx], LEFT
	jne END_LEFT
	jmp TAIL_DONE
END_LEFT:
	add [xTail], SQUARE_LEN
	call CheckSurround
	jmp TAIL_DONE
	
TAIL_RIGHT:
	add [xTail], SQUARE_LEN

	;check if tail went into border	
	mov bh,0h
	mov cx, [xTail] ; X position
	mov dx, [yTail] ; Y position
	mov ah,0Dh
	int 10h ; return al the pixel value read
	cmp al, [borderColor]
	je END_RIGHT
	;check for north border
	dec dx ; dec yTail
	int 10h ; return al the pixel value read
	cmp al, [borderColor]
	je END_RIGHT
	
	push [xTail]	;push x [bp+4]
	push [yTail]	;push y [bp+2]
	call CallculatePlace
	
	mov bx, [placeInArr]
	cmp [byte ptr offset Array + bx], RIGHT
	jne END_RIGHT
	jmp TAIL_DONE

END_RIGHT:
	sub [xTail], SQUARE_LEN
	call CheckSurround
	jmp TAIL_DONE
TAIL_DONE:
	mov [appleCntr], 0

	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp TailDirection
;-------------------
;CheckSurround - called if the next tail square isnt 
;    have the same direction value of the Tdirection
;Algorithm: check the surround for the same direction
;    value in relation to the tail last position
;    (square above-UP, square below-DOWN, square right-RIGHT, square left-LEFT)
;-------------------
proc CheckSurround
	push ax
	push bx
	push cx
	push dx
	
SUROUND_UP:
	sub [yTail], SQUARE_WIDTH
	
	mov bh,0h
	mov cx, [xTail] ; X position
	mov dx, [yTail] ; Y position
	add dx, SQUARE_WIDTH-1
	mov ah,0Dh
	int 10h ; return al the pixel value read
	cmp al, [borderColor]
	je SUROUND_DOWN
	
	push [xTail]	;push x [bp+4]
	push [yTail]	;push y [bp+2]
	call CallculatePlace
	mov bx, [placeInArr]
	cmp [byte ptr offset Array + bx], UP
	je CHANGE_UP
	jmp SUROUND_DOWN
CHANGE_UP:
	mov [Tdirection], UP
	jmp SUROUND_END
	
SUROUND_DOWN:
	add [yTail], SQUARE_WIDTH
	add [yTail], SQUARE_WIDTH
	
	mov bh,0h
	mov cx, [xTail] ; X position
	mov dx, [yTail] ; Y position
	mov ah,0Dh
	int 10h ; return al the pixel value read
	cmp al, [borderColor]
	je SUROUND_LEFT
	
	push [xTail]	;push x [bp+4]
	push [yTail]	;push y [bp+2]
	call CallculatePlace
	mov bx, [placeInArr]
	cmp [byte ptr offset Array + bx], DOWN
	je CHANGE_DOWN
	jmp SUROUND_LEFT
CHANGE_DOWN:
	mov [Tdirection], DOWN
	jmp SUROUND_END

SUROUND_LEFT:
	sub [yTail], SQUARE_WIDTH
	sub [xTail], SQUARE_LEN
	
	mov bh,0h
	mov cx, [xTail] ; X position
	mov dx, [yTail] ; Y position
	mov ah,0Dh
	int 10h ; return al the pixel value read
	cmp al, [borderColor]
	je SUROUND_RIGHT
	
	push [xTail]	;push x [bp+4]
	push [yTail]	;push y [bp+2]
	call CallculatePlace
	mov bx, [placeInArr]
	cmp [byte ptr offset Array + bx], LEFT
	je CHANGE_LEFT
	jmp SUROUND_RIGHT
CHANGE_LEFT:
	mov [Tdirection], LEFT
	jmp SUROUND_END
	
SUROUND_RIGHT:
	add [xTail], SQUARE_LEN
	add [xTail], SQUARE_LEN
	mov [Tdirection], RIGHT
SUROUND_END:
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp CheckSurround

;----------------------------------------
; MoveSnake - drawing the head and 
; deleting the tail - one square at a time
;----------------------------------------
proc MoveSnake
	push ax
	push bx
	push cx
	push dx

	cmp [Hdirection], UP	
	je CHECK_UP ; because the index point of each square is top left corner
	
	cmp [Hdirection], LEFT
	je CHECK_LEFT ; because the index point of each square is top left corner
	
	jmp CHECK_ELSE ; for right and down is same
	
CHECK_UP:
	; check up *border*
	sub [yHead], SQUARE_WIDTH-1
	; Read dot color
	; and check if the snake hit border
	mov bh,0h
	mov cx, [xHead] ; X position
	mov dx, [yHead] ; Y position
	mov ah,0Dh
	int 10h ; return al the pixel value read
	
	cmp al, [borderColor]
	je EXIT_FLAG1
	add [yHead], SQUARE_WIDTH-1

CLOSE_CHECK1_BORDER:
	;check up *snake*
	; Read dot color
	; and check if the snake hit himself
	mov bh,0h
	mov cx, [xHead] ; X position
	mov dx, [yHead] ; Y position
	mov ah,0Dh
	int 10h ; return al the pixel value read
	cmp al, SNAKE_COLOR
	je EXIT_FLAG1
	;check if snake ate apple
	mov bh,0h
	mov cx, [xHead] ; X position
	mov dx, [yHead] ; Y position
	mov ah,0Dh
	int 10h ; return al the pixel value read
	cmp al, APPLE_COLOR
	jne MOVE_TAIL

	jmp	ATE_APPLE

CHECK_LEFT:
	add [xHead], SQUARE_LEN-1
	; Read dot color
	; and check if the snake hit himself/border
	mov bh,0h
	mov cx, [xHead] ; X position
	mov dx, [yHead] ; Y position
	mov ah,0Dh
	int 10h ; return al the pixel value read
	cmp al, SNAKE_COLOR
	je EXIT_FLAG1
	cmp al, [borderColor]
	je EXIT_FLAG1
	;check if snake ate apple
	mov bh,0h
	mov cx, [xHead] ; X position
	mov dx, [yHead] ; Y position
	mov ah,0Dh
	int 10h ; return al the pixel value read
	cmp al, APPLE_COLOR
	jne CLOSE_CHECK2
	sub [xHead], SQUARE_LEN-1
	jmp	ATE_APPLE
CLOSE_CHECK2:	
	sub [xHead], SQUARE_LEN-1
	jmp MOVE_TAIL

EXIT_FLAG1:		; placed here to prevent jump out of range
	inc [gameFlag]
	jmp END_MOVE_PROC
	
	CHECK_ELSE:
	; Read dot color
	; and check if the snake hit himself/border
	mov bh,0h
	mov cx, [xHead] ; X position
	mov dx, [yHead] ; Y position
	mov ah,0Dh
	int 10h ; return al the pixel value read
	cmp al, SNAKE_COLOR
	je EXIT_FLAG1
	cmp al, [borderColor]
	je EXIT_FLAG1
	;check if snake ate apple
	mov bh,0h
	mov cx, [xHead] ; X position
	mov dx, [yHead] ; Y position
	mov ah,0Dh
	int 10h ; return al the pixel value read
	cmp al, APPLE_COLOR
	je ATE_APPLE
	
MOVE_TAIL:
	;delete tail
	push BLACK			;push Color
	push [xTail] 		;RECT0_X_START
	push SQUARE_LEN 	;RECT0_LEN
	push [yTail]		;RECT0_Y_START
	push SQUARE_WIDTH	;RECT0_WIDTH
	call DrawSquare
	
	jmp MOVE_HEAD

ATE_APPLE:
	inc [appleCntr]
	call AppleSound
	call RandomApple ; if snake ate apple make new apple and jump the delete tail action

MOVE_HEAD:
	; draw head
	push SNAKE_COLOR		;[snakeColor]
	push [xHead] 	;RECT0_X_START
	push SQUARE_LEN 	;RECT0_LEN
	push [yHead]		;RECT0_Y_START
	push SQUARE_WIDTH	;RECT0_WIDTH
	call DrawSquare
	
	; enter the head direction to the array
	push [xHead]	;push x [bp+4]
	push [yHead]	;push y [bp+2]
	call CallculatePlace
	mov bx, [placeInArr]
	mov al, [Hdirection]
	mov [byte ptr offset Array + bx], al
	
END_MOVE_PROC:	
	call DelayProc
	call DelayProc
	call DelayProc
	call DelayProc

	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp MoveSnake