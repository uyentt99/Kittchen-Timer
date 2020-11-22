;Interrupt table
ORG 0000h 		; entry address for 8051 RESET
	LJMP MAIN 	; move MAIN away from interrupt vector table
ORG 0003h 		; vector address for interrupt 0
	LJMP ISR0 	; jump to ISR0
ORG 0013h 		; vector address for interrupt 1
	LJMP ISR1 	; jump to ISR1
;=================================================================
;Code segment
;=================================================================
ORG 0100h 				; MAIN starts here
MAIN:
	MOV IE, #10000101B 	; enable external interrupts IE0, IE1
	SETB IT0 			; negative edge trigger for interrupt 0
	SETB IT1 			; negative edge trigger for interrupt 1
	MOV dptr,#maled7seg
	MOV R0, #0
	MOV R1, #0
	addbut bit p1.0
	subbut bit p1.1	

CHANGE_NUM:
	JB addbut, ZONE_2   ; if sub button turned 
	INC R0
	ZONE_2:
	JB subbut, SHOW_NUM	; if sub button turned 
	DEC R0
SHOW_NUM:
	MOV A, R0			; move data to A
	RLC A				
	JNC BIGGER10		; continue check bigger than 10
	MOV R0, #0			; reset if smaller than 0
	JMP DISPLAY
BIGGER10:
	MOV A, R0			; move data to A
	CLR C
	SUBB A, #10
	JC DISPLAY			; display if in range 0-9
	MOV R0, #9			; reset to 9
DISPLAY:
	MOV A, R0
	MOVC A,@A+dptr
	MOV P0, A
	
	CJNE R1, #0, DEC_TIME	; if R1=1 decrease time
	CALL DELAY_250ms
	LJMP CHANGE_NUM 
	
DEC_TIME:
	DEC R6
	CJNE R6, #0, DONE_NUM	; if R6>0 not decrease num 
	MOV R6, #240				; R6= 240, delay time = 240*250 = 6000ms = 1 minute
	DEC R0
	DONE_NUM:
	CJNE R0, #0, DONE_BUZZER 	; if R0>0 not turn buzzer
	SETB P0.7 
	DONE_BUZZER:
	CALL DELAY_250ms
	JMP DISPLAY
	
;=================================================================
;Delay
;=================================================================
;deylay 250ms
DELAY_250ms:
	MOV R7, #5
;delay 50m*r7
DELAY_50ms:
	CLR ET0					;disable timer 0 isr
	MOV	TMOD, #01h			; mode 1(16 bits)
	MOV	TH0, #3Ch			; delay 50k cycles
	MOV TL0, #0B0h
	CLR TF0					; clear flag
	SETB TR0				; start timer 0
WAIT_50ms:
	JNB TF0, WAIT_50ms		; wait for flag
	DJNZ R7, DELAY_50ms
	ret
;==================================================================
; ISR0 
;==================================================================
ISR0:
	MOV A,#1 
	XRL A, @R1
	MOV R1, A				; set state
	MOV R6, #240			; R6= 240, delay time = 240*250 = 6000ms = 1 minute
	CLR P0.7				; turn of 
	RETI 					; return from interrupt
;==================================================================
; ISR1 
;==================================================================
ISR1:
	MOV R1, #0				; set state
	MOV R0, #0				; reset number
	CLR P0.7	
	RETI 					; return from interrupt
;==================================================================	
;Common Anode 7SEG-LED numbers
;==================================================================	
maled7seg:
	db	040h,079h,024h,030h,19h,12h,02h,078h,00h,10h	
;==================================================================		
END 						; end of program