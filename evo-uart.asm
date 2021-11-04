; This driver works with 16c550 uart that's support AFE
    module Uart
; Make init shorter and readable:-)
    macro outp port, value

	ld b, port
	ld c, #EF
    ld a, value
	out (port), a
	endm

; Internal port constants
RBR_THR equ #F8
IER		equ	#F9
IIR_FCR	equ	#FA
LCR		equ	#FB
MCR		equ	#FC
LSR		equ	#FD
MSR		equ	#FE
SR		equ	#FF

init:
	push bc
    outp MCR,     #0d  // Assert RTS
    outp IIR_FCR, #87  // Enable fifo 8 level, and clear it
    outp LCR,     #83  // 8n1, DLAB=1
    outp RBR_THR, #03  // 115200 (divider 1)
    outp IER,     #00  // (divider 0). Divider is 16 bit, so we get (#0002 divider)
    outp LCR,     #03 // 8n1, DLAB=0
    outp IER,     #00 // Disable int
    outp MCR,     #2f // Enable AFE
	pop bc
    ret
    
; Flag C <- Data available
isAvailable:
	ld a, LSR
	in a, (#EF)
    rrca
    ret

; Non-blocking read
; Flag C <- is byte was readen
; A <- byte
read:
    ld a, LSR
	in a, (#EF)
    rrca
    ret nc
    ld a, RBR_THR
	in a, (#EF)
    scf 
    ret

; Tries read byte with timeout
; Flag C <- is byte read
; A <- byte
readTimeout:
    ld b, 10
.wait
    call isAvailable : jr c, read
    halt
    djnz .wait
    or a
    ret

; Blocking read
; A <- Byte
readB:
    ld a, LSR
	in a, (#EF)
    rrca
    jr nc, readB
    ld a, RBR_THR
	in a, (#EF)
    ret

; A -> byte to send
write:
    push af
.wait
    ld a, LSR
	in a, (#EF)
    and #20
    jr z, .wait
    pop af
    ld a, RBR_THR 
	out (#EF), a
    ret

    endmodule
