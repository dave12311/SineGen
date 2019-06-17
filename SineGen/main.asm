;
; SineGen.asm
;
; Created: 6/15/2019 10:38:10 PM
; Author : David Horvath
;
.include "tn25def.inc"

.def temp=r16
.def phase_acc=r17

.equ resolution=0x14

.org 0x0000
rjmp start

.org 0x000B
rjmp TIM0_COMPB_ISR

.org 0x000F
start:
	;Setup stack
    ldi temp, low(RAMEND)
	out SPL, temp

	;Set X pointer to the begining of the array
	ldi XH, high(0x0060)
	ldi XL, low(0x0060)

	;Load sine data to SRAM
	ldi temp, 0xa
	st X+, temp
	ldi temp, 0xd
	st X+, temp
	ldi temp, 0x10
	st X+, temp
	ldi temp, 0x12
	st X+, temp
	ldi temp, 0x14
	st X+, temp
	ldi temp, 0x14
	st X+, temp
	ldi temp, 0x14
	st X+, temp
	ldi temp, 0x12
	st X+, temp
	ldi temp, 0x10
	st X+, temp
	ldi temp, 0xd
	st X+, temp
	ldi temp, 0xa
	st X+, temp
	ldi temp, 0x7
	st X+, temp
	ldi temp, 0x4
	st X+, temp
	ldi temp, 0x2
	st X+, temp
	ldi temp, 0x0
	st X+, temp
	ldi temp, 0x0
	st X+, temp
	ldi temp, 0x0
	st X+, temp
	ldi temp, 0x2
	st X+, temp
	ldi temp, 0x4
	st X+, temp
	ldi temp, 0x7
	st X+, temp

	;Set X pointer to the begining of the array
	ldi YH, high(0x0060)
	ldi YL, low(0x0060)

	;Setup output
	ldi temp, 0x2
	out DDRB, temp

	;Set max number of timer cycles
	ldi temp, resolution
	out OCR0A, temp

	;Set first value
	lds temp, 0x0060
	out OCR0B, temp

	;Set interrupt for OCR0B
	ldi temp, 0x8
	out TIMSK, temp

	;Setup timer
	ldi temp, 0x23
	out TCCR0A, temp
	ldi temp, 0x9
	out TCCR0B, temp

	;Enable interrupts
	sei

	;Loop
loop:
	rjmp loop

TIM0_COMPB_ISR:
	ld temp, Y+
	inc phase_acc
	out OCR0B, temp
	cpi phase_acc, resolution
	breq reset
	reti

reset:
	ldi YH, high(0x0060)
	ldi YL, low(0x0060)
	ldi phase_acc, 0
	reti