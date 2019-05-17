;+----------------------------------------------------------------------
;| Title		: myAVR Grundgerüst für ATmega8
;+----------------------------------------------------------------------
;| Funktion		: Sendet ein Byte mit einem Startbit
;| Schaltung	: Taster an PortD2, Signalkabel an PortB0
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
    ldi	r16,0xff
	out	ioDDRB,r16 ; B Output
	ldi	r16,0
	out	ioDDRD,r16 ; D Input
	sbi	ioPORTD,2 ; Pull-Up Widerstand für Taster

	ldi	r17,0b11001011 ; SRC 203 setzen
;------------------------------------------------------------------------
mainloop:
	;Hier den Quellcode eintragen.
    ldi	r16,0
	out	ioPORTB,r16 ; Output auf 0

taster:
	sbic	ioPIND,2
	rjmp	taster ; Abwarten des Tastendrucks

	ldi	r18,0
	mov	r18,r17 ; SRC in BUF kopieren

	ldi	r16,1
	out	ioPORTB,r16 ; Startbit setzen

	ldi	r19,8 ; Counter auf 8

write:
	rcall	wait ; 1ms warten
	rcall	wait

	ldi r16,1
	and r16,r18 ; r16 is 1 if LSB of r18 is 1
	sbrc r16,0 ; if not 0
	sbi	ioPORTB,0 ; set lsb on output
	sbrs r16,0 ; if not 1
	cbi	ioPORTB,0 ; clear lsb on output

	lsr	r18 ; BUF right-shiften
	dec	r19 ; Counter decrementen
	brne	write ; Loop bis Counter 0 ist

	rcall	wait ; 1ms warten
	rcall	wait
	rjmp	mainloop

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
;------------------------------------------------------------------------


