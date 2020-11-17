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
	
	CJNE R1, #0, DEC_TIME
	
	CALL DELAY_100ms
	LJMP CHANGE_NUM 
	
DEC_TIME:
	DEC R0
	MOV A, R0
	RLC A				
	JNC DONE_BUZZER ; if R0>0 not turn buzzer
	SETB P0.7 
	MOV R0, #0
	DONE_BUZZER:
	CALL DELAY_1M
	JMP DISPLAY
;=================================================================
;Delay
;=================================================================
;deylay 1s
DELAY_1M:
	MOV tmod,#10h
	MOV R6,#6000 ;6000
	JMP DELAY_10ms
	
;delay 1 minute
DELAY_100ms:
	mov tmod,#10h
	mov R6,#10
	JMP DELAY_10ms
;delay 10ms*r6
DELAY_10ms:
	mov th1,#high(-10000)
	mov tl1,#low(-10000)
	setb tr1
	jnb tf1,$
	clr tr1
	clr tf1
	djnz R6,DELAY_10ms
	ret
;==================================================================
; ISR0 
;==================================================================
ISR0:
	MOV A,#1 
	XRL A, @R1
	MOV R1, A				; set state
	CLR P0.7
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
