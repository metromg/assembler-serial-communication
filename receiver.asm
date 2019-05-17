;+----------------------------------------------------------------------
;| Title		: myAVR Grundgerüst für ATmega8
;+----------------------------------------------------------------------
;| Funktion		: Empfängt ein Byte mit einem Startbit
;| Schaltung	: Taster an PortD2, Signalkabel an PortB0, Grüne LED an PortC0, Rote LED an PortC1
;+----------------------------------------------------------------------
;| Prozessor	: ATmega8
;| Takt		: 3,6864 MHz
;| Sprache       	: Assembler
;| Datum         	: ...
;| Version       	: ...
;| Autor         	: ...
;+----------------------------------------------------------------------
.include	"AVR.H"
;------------------------------------------------------------------------
;Reset and Interrupt vector             ;VNr.  Beschreibung
	rjmp	main	;1   POWER ON RESET
	reti		;2   Int0-Interrupt
	reti		;3   Int1-Interrupt
	reti		;4   TC2 Compare Match
	reti		;5   TC2 Overflow
	reti		;6   TC1 Capture
	reti		;7   TC1 Compare Match A
	reti		;8   TC1 Compare Match B
	reti		;9   TC1 Overflow
	reti		;10  TC0 Overflow
	reti		;11  SPI, STC Serial Transfer Complete
	reti		;12  UART Rx Complete
	reti		;13  UART Data Register Empty
	reti		;14  UART Tx Complete
	reti		;15  ADC Conversion Complete
	reti		;16  EEPROM Ready
	reti		;17  Analog Comparator
	reti		;18  TWI (I²C) Serial Interface
	reti		;19  Store Program Memory Ready
;------------------------------------------------------------------------
;Start, Power ON, Reset
main:	ldi	r16,lo8(RAMEND)
	out	ioSPL,r16
	ldi	r16,hi8(RAMEND)
	out	ioSPH,r16
	;Hier Init-Code eintragen.
	ldi	R16,0
	out	ioDDRB,R16 ; Port B auf Input (Receive)
	out	ioDDRD,R16 ; Port D auf Input (Taster)
	sbi	ioPORTB,0 ; Pull-Up des Receive
	sbi	ioPORTD,2 ; Pull-Up des Tasters
	ldi	R16,0xff
	out	ioDDRC,R16 ; Port C auf Output (LED)

start:
	ldi	R16,0
	out	ioPORTC,R16

startbit:
	sbis ioPINB,0
	rjmp	startbit ; Gehe weiter, sobald Startbit gesetzt ist

	ldi	R18,0 ; Buffer clearen
	rcall	wait ; Wait 1.5ms
	rcall	wait
	rcall	wait
	ldi	R19,8 ; Counter auf 8

read:
	lsr	R18
	sbic	ioPINB,0
	ori	R18,0b10000000 ; Wenn Bit auf der Leitung, dann MSB im Buffer setzen
	rcall	wait ; Wait 1ms
	rcall	wait
	dec	R19 ; Decrement counter
	brne	read ; Loop bis counter = 0
	mov	R17,R18 ; BUF in DEST
	cpi	R17,203
	breq	green
	brne	red

taster:
	sbic	ioPIND,2 ; Warten auf Reset
	rjmp	taster
	rjmp	start

green:
	sbi	ioPORTC,0
	rjmp	taster

red:
	sbi	ioPORTC,1
	rjmp	taster

; 0.5ms
wait:
	ldi	r20,3
	ldi	r21,100
wait1:
	dec	r21
	brne	wait1
	dec	r20
	brne	wait1
	ret