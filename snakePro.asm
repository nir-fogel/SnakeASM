IDEAL
MODEL small
STACK 100h
DATASEG

;----------------------------------------------------------
; Written By Nir Fogel
; for the cyber 30% bagrut's project 
; At Zichron Yaakov HighSchool
; Tichon Hamoshava
; Using Barak Gonen Book as Reference
;-----------------------------------------------------------
; snakepro - for snake project:
; Waiting for WASD keys and moving the snake accordingly
; W-up ; A -left ; S - down; D - right
; ESC finishing the game
; Overlapping is not allowed - for example, 
; if snake is moving up, only left and right is allowed
; Algorithm - moving the snake head according the direction
; deleting the tail after finding the tail direction
;------------------------------------------------------------

; --------------------------
; Your variables here
; --------------------------
;Array:
Array db 255 dup(?)
placeInArr	dw ?

;Apple:
xApple		dw ?
yApple		dw ?
appleCntr	db 0 ; counter for apples that the snake ate for skipping delete tail

;Snake:
xHead		dw ?
yHead		dw ?
xTail		dw ?
yTail		dw ?
Hdirection	db ? ; head direction
Tdirection	db ? ; tail direction
snakeLen	db ?
cntr		dw ? ; temp for the number of sqrs that need to draw at the brggining (DrawSnake)

;Borders:
borderColor db ?
xBorder		dw ?
yBorder		dw ?
BORDER_X_LIMIT	equ 58 ; number of borders line in each west/east border
BORDER_Y_LIMIT	equ 10 ; number of borders line in each north/south border

cntrLines 	db ? ; lines for sqrDraw
cntrColumns db ? ; columns for sqrDraw

gameFlag	db 0
columnNum	db ? ; (calculate)
lineNum		db ? ; (calculate)


;Directions:
UP		equ 1
LEFT	equ 2
DOWN	equ 3
RIGHT	equ 4

;Colors
BLACK		equ 0
BLUE		equ 1
GREEN		equ 2
LIGHTBLUE 	equ 3
RED			equ 4
PURPLE 		equ 5
ORANGE 		equ 6
WHITE		equ 7

;Settings:
MAX_Y_LINES		equ 199 ; 200
MAX_X_COLUMNS 	equ 319 ; 320
SNAKE_LEN		equ 3
SNAKE_X_START	equ BORDER_X_LIMIT
SNAKE_Y_START	equ BORDER_Y_LIMIT+SQUARE_WIDTH*7
DELAY_CNTR		equ 30
SQUARE_LEN equ 12 ; x axis, max 13 (18 if not square)
SQUARE_WIDTH equ 12 ; y axis, max 13
APPLE_COLOR equ RED
SNAKE_COLOR equ GREEN

;Sounds:
C4  equ	011DBh
B4  equ	0FE8h
E4  equ	0E2Ah
G4  equ 0BE3h
A4b equ 0B3Bh
A4  equ 0A97h
B4b equ 0A00h
B4  equ 974h
C5  equ	08E9h
D5  equ	07F0h
E5  equ	712h
F5  equ	06ADh


;Messages:
PressKeyMsg		db 'Press key to start....',13,10,'$'

WASDKeyMSG 		db '			Press WASD keys to switch direction:',13,10
				db '			####################################',13,10
				db '			#  W - Up            S - DOWN      #',13,10
				db '			#  A - LEFT          D - RIGHT     #',13,10
				db '			####################################',13,10,'$'

GameOverMsg		db '														',13,10
				db ' @@@@@@\   @@@@@@\  @@\      @@\ @@@@@@@@\      		',13,10
				db '@@  __@@\ @@  __@@\ @@@\    @@@ |@@  _____|     		',13,10
				db '@@ /  \__|@@ /  @@ |@@@@\  @@@@ |@@ |           		',13,10
				db '@@ |@@@@\ @@@@@@@@ |@@\@@\@@ @@ |@@@@@\         		',13,10
				db '@@ |\_@@ |@@  __@@ |@@ \@@@  @@ |@@  __|     			',13,10
				db '@@ |  @@ |@@ |  @@ |@@ |\@  /@@ |@@ |           		',13,10
				db '\@@@@@@  |@@ |  @@ |@@ | \_/ @@ |@@@@@@@@\      		',13,10
				db ' \______/ \__|  \__|\__|     \__|\________|     		',13,10
				db 13,10
				db 13,10
				db '				 @@@@@@\  @@\    @@\ @@@@@@@@\ @@@@@@@\  ',13,10
				db '				@@  __@@\ @@ |   @@ |@@  _____|@@  __@@\ ',13,10
				db '				@@ /  @@ |@@ |   @@ |@@ |      @@ |  @@ |',13,10
				db '				@@ |  @@ |\@@\  @@  |@@@@@\    @@@@@@@  |',13,10
				db '				@@ |  @@ | \@@\@@  / @@  __|   @@  __@@< ',13,10
				db '				@@ |  @@ |  \@@@  /  @@ |      @@ |  @@ |',13,10
				db '				 @@@@@@  |   \@  /   @@@@@@@@\ @@ |  @@ |',13,10
				db '				 \______/     \_/    \________|\__|  \__|',13,10,'$'

snake_txt		db '												 	  	',13,10
				db ' @@@@@@\  @@\   @@\  @@@@@@\  @@\   @@\ @@@@@@@@\  		',13,10
				db '@@  __@@\ @@@\  @@ |@@  __@@\ @@ | @@  |@@  _____|   	',13,10
				db '@@ /  \__|@@@@\ @@ |@@ /  @@ |@@ |@@  / @@ |         	',13,10
				db '\@@@@@@\  @@ @@\@@ |@@@@@@@@ |@@@@@  /  @@@@@\       	',13,10
				db ' \____@@\ @@ \@@@@ |@@  __@@ |@@  @@<   @@  __|      	',13,10
				db '@@\   @@ |@@ |\@@@ |@@ |  @@ |@@ |\@@\  @@ |         	',13,10
				db '\@@@@@@  |@@ | \@@ |@@ |  @@ |@@ | \@@\ @@@@@@@@\    	',13,10
				db ' \______/ \__|  \__|\__|  \__|\__|  \__|\________| 		',13,10
				db 13,10
				db '	                           @@@@@@\   @@@@@@\  @@\      @@\ @@@@@@@@\ ',13,10
				db '	                          @@  __@@\ @@  __@@\ @@@\    @@@ |@@  _____|',13,10
				db '	                          @@ /  \__|@@ /  @@ |@@@@\  @@@@ |@@ |      ',13,10
				db '	                          @@ |@@@@\ @@@@@@@@ |@@\@@\@@ @@ |@@@@@\    ',13,10
				db '	                          @@ |  @@ |@@ |  @@ |@@ |\@  /@@ |@@ |      ',13,10
				db '	                          @@ |  @@ |@@ |  @@ |@@ |\@  /@@ |@@ |      ',13,10
				db '	                          \@@@@@@  |@@ |  @@ |@@ | \_/ @@ |@@@@@@@@\ ',13,10
				db '	                           \______/ \__|  \__|\__|     \__|\________|',13,10
				db 13,10,'$'
				
FinalMSG 		db 'Thank you for playing :-)',13,10
				db 'Written by Nir Fogel',13,10,'$'

CODESEG
; ------------------------
; Your code here 
; start with the procedures
; before: start: Label
;--------------------------

include 'snakeAct.asm'	; all the snake project procedures

;---------------------------
;Main CODESEG
;---------------------------
start:
	mov ax, @data
	mov ds, ax
	
	;print menu screen
	mov dx, offset snake_txt
	mov ah, 9h
	int 21h
	mov dx, offset WASDKeyMsg
	mov ah, 9h
	int 21h
	
	;press any key to continue
	mov dx, offset PressKeyMsg
	mov ah, 9h
	int 21h

	;read char - answer is in al
	;sub al, '0' ; char to int
	mov ah, 1
	int 21h
	
	;Graphic mode
	mov ax, 13h
	int 10h

	call DrawBoarders
	call DrawSnake
	call RandomApple	; generate first apple
	
WaitForKEY:
	call HeadDirection ; calculating the next head pixel to draw
	call TailDirection ; calculating the next tail pixel to delete
	call MoveSnake ;  move the snake according the head and tail

	cmp [gameFlag], 0
	je CONTINUE
	jmp GAME_OVER
CONTINUE:
	;--------------------------------------
	;BIOS
	; preffered method since BIOS
	; is not blocking the SW while waiting
	; for the user to press Key
	; Example:Use BIOS int 16h ports to
	; read WASD keys data, until ESC pressed
	;--------------------------------------
	mov ah, 1
	Int 16h
	jz WaitForKEY ; no key pressed
	; key pressed - so call int 16 with ah code 0
	; al holding the Key ASCII and ah the scan code
	; do what you planned - related to the key
	mov ah, 0
	int 16h
	;Check which key pressed - small leters
	cmp al, 'w'
	je W_PRESSED
	cmp al, 's'
	je S_PRESSED
	cmp al, 'a'
	je A_PRESSED
	cmp al, 'd'
	je D_PRESSED
	;Check which key pressed - big leters
	cmp al, 'W'
	je W_PRESSED
	cmp al, 'S'
	je S_PRESSED
	cmp al, 'A'
	je A_PRESSED
	cmp al, 'D'
	je D_PRESSED

	
	jmp ESCPressed
	;Overlapping Not allowed
	;Meaning if LEFT, RIGHT in not allowed
W_PRESSED:
	cmp [Hdirection], DOWN ;Overlapping Not allowed
	je ESCPressed
	mov [Hdirection], UP ; W pressed - direction is UP
	jmp ESCPressed
S_PRESSED:
	cmp [Hdirection], UP ;Overlapping Not allowed
	je ESCPressed
	mov [Hdirection], DOWN
	jmp ESCPressed
A_PRESSED:
	cmp [Hdirection], RIGHT ;Overlapping Not allowed
	je ESCPressed
	mov [Hdirection], LEFT
	jmp ESCPressed	
D_PRESSED:
	cmp [Hdirection], LEFT ;Overlapping Not allowed
	je ESCPressed
	mov [Hdirection], RIGHT
	jmp ESCPressed		
	
ESCPressed:
	cmp ah, 1h ; is ESC pressed - via scan code table ?
	je GAME_OVER
	jmp WaitForKEY
	
GAME_OVER:

	call MarioSound
	;Back to text mode - default
	mov ah, 0
	mov al, 2
	int 10h
	
	; print game over
	mov dx, offset GameOverMsg
	mov ah, 9
	int 21h
	
	;print final message
	mov dx, offset FinalMSG
	mov ah, 9
	int 21h
	
	mov cx, DELAY_CNTR
GAME_MSG1:
	call DelayProc
	loop GAME_MSG1
	
exit:
	mov ax, 4c00h
	int 21h
END start