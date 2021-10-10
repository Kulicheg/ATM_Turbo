
	MODULE ERRNOMOD
	PUBLIC errno
	RSEG	NO_INIT
errno:
	defs 1
	ENDMOD
	
	MODULE MYGETCHAR
	PUBLIC getchar
	EXTERN _low_level_get
	RSEG CODE
getchar:
	call _low_level_get
	or a
	jr z,getchar
	ld l,a
	ld h,0
	ret	
	ENDMOD
	
	MODULE OS_RESERV_1
	PUBLIC os_reserv_1
	#include "sysdefs.asm"
	RSEG CODE
os_reserv_1:
	push bc
	push ix
	push iy
    ld c,CMD_RESERV_1
	call BDOS
	pop iy
	pop ix
	pop bc
	ret	
	ENDMOD
	
	MODULE SCRREDRAW
	PUBLIC scrredraw
	RSEG CODE
scrredraw:
	xor a
	ret	
	ENDMOD

	MODULE OSLOWGET
	PUBLIC bdosgetkey
	EXTERN scrredraw,exit,YIELD
	#include "sysdefs.asm"
	RSEG CODE
bdosgetkey:
	push de
	push bc
	push ix
	push iy
	ld c,CMD_YIELD
	call BDOS
	rst 0x08
	cp key_esc
	jp z,exit
	cp key_redraw
	call z,scrredraw
	ld l,a
	ld h,0
	pop iy
	pop ix
	pop bc
	pop de
	ret
	ENDMOD
    
	MODULE conv1251to866
	PUBLIC conv1251to866, t1251to866
	RSEG CODE
conv1251to866:	;DE-string
	push de
ploop:
	ld a,(de)
	or a
	jr z,pexit
	cp 128
	jr c,asci
	add a,low(t1251to866-128)
	ld l,a
	ld a,0
	adc a,high(t1251to866-128)
	ld h,a
	ld a,(hl)
	ld (de),a
asci:
	inc de
	jr ploop
pexit:
	pop de
	ret
	RSEG	CONST
t1251to866:
	DEFB 0x3F, 0x3F, 0x27, 0x3F, 0x22, 0x3A, 0xC5, 0xD8, 0x3F, 0x25, 0x3F, 0x3C, 0x3F, 0x3F, 0x3F, 0x3F 
	DEFB 0x30, 0x3F, 0x27, 0x27, 0x22, 0x22, 0x07, 0x2D, 0x2D, 0x54, 0x3F, 0x3E, 0x3F, 0x3F, 0x3F, 0x3F 
	DEFB 0xFF, 0xF6, 0xF7, 0x3F, 0xFD, 0x3F, 0xB3, 0x15, 0xF0, 0x63, 0xF2, 0x3C, 0xBF, 0x2D, 0x52, 0xF4 
	DEFB 0xF8, 0x2B, 0x3F, 0x3F, 0x3F, 0xE7, 0x14, 0xFA, 0xF1, 0xFC, 0xF3, 0x3E, 0x3F, 0x3F, 0x3F, 0xF5 
	DEFB 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x8A, 0x8B, 0x8C, 0x8D, 0x8E, 0x8F 
	DEFB 0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0x9A, 0x9B, 0x9C, 0x9D, 0x9E, 0x9F 
	DEFB 0xA0, 0xA1, 0xA2, 0xA3, 0xA4, 0xA5, 0xA6, 0xA7, 0xA8, 0xA9, 0xAA, 0xAB, 0xAC, 0xAD, 0xAE, 0xAF 
	DEFB 0xE0, 0xE1, 0xE2, 0xE3, 0xE4, 0xE5, 0xE6, 0xE7, 0xE8, 0xE9, 0xEA, 0xEB, 0xEC, 0xED, 0xEE, 0xEF
	ENDMOD
	
	MODULE YIELD
	PUBLIC YIELD
	#include "sysdefs.asm"
	RSEG CODE
YIELD:
	push bc
	push de
	push ix
	push iy
	ld c,CMD_YIELD
	call BDOS
	pop iy
	pop ix
	pop de
	pop bc
	ret
	ENDMOD
	
	MODULE SETMUSIC
	PUBLIC OS_SETMUSIC
	#include "sysdefs.asm"
	RSEG CODE
OS_SETMUSIC:	;DE - proc_ptr, A - ?
	ld h,d
	ld l,e
	ld a,c
    ex af,af'
	push ix
	push iy
	ld c,CMD_SETMUSIC	;hl=muzaddr (0x4000..0x7fff), a=muzpg
	call BDOS
	pop iy
	pop ix
	ret
	ENDMOD
	
	MODULE OSGETCONFIG
	PUBLIC OS_GETCONFIG
	#include "sysdefs.asm"
	RSEG CODE
OS_GETCONFIG:
    push bc
	ld c,CMD_GETCONFIG
	push de
	push ix
	push iy
	call BDOS
	pop iy
	pop ix
	pop de
    pop bc
	ret
	ENDMOD

MODULE GETMAINPAGES
 PUBLIC OS_GETMAINPAGES,OS_GETAPPMAINPAGES
    EXTERN errno
 #include "sysdefs.asm"
 RSEG CODE
OS_GETAPPMAINPAGES:
    ld c,CMD_GETAPPMAINPAGES
    jr l1
OS_GETMAINPAGES:
 ld c,CMD_GETMAINPAGES
l1
 push de
 push ix
 push iy
 call BDOS
 ld b,d ;out: d,e,h,l=pages in 0000,4000,8000,c000, c=flags, a=error
 ld c,e
 pop iy
 pop ix
 pop de
    LD (errno), a
 ret
 ENDMOD

	MODULE SETPG32KHIGH
	PUBLIC SETPG32KHIGH
	#include "sysdefs.asm"
	RSEG CODE
SETPG32KHIGH:
	push bc
	push ix
	push iy
	ld a,e
	rst 0x28
	pop iy
	pop ix
	pop bc
	ret
	ENDMOD
	
	MODULE MAIN_ARGS
	PUBLIC main_args
	RSEG CODE
main_args
	ld hl,args
	ld de,0x0080
get_cmd_args_l2
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl
	dec de
get_cmd_args_l
	inc de
	ld a,(de)
	or a
	jr z,get_cmd_args_end
	cp ' '
	jr nz,get_cmd_args_l
	xor a
	ld (de),a
skipspaces
	inc de
	ld a,(de)
	or a
	jr z,get_cmd_args_end
	cp ' '
	jr nz,get_cmd_args_l2
	jr skipspaces
get_cmd_args_end:
	ld bc,args
	sbc hl,bc
	ex de,hl
	srl e
	ret
	RSEG	NO_INIT
args:
	defs 32
	ENDMOD


	MODULE OSDROPAPP
	PUBLIC OS_DROPAPP
	#include "sysdefs.asm"
	RSEG CODE
OS_DROPAPP:	;e=id ; hl=result
	ld c,CMD_DROPAPP
	push ix
	push iy
	call BDOS
	pop iy
	pop ix
	ret
	ENDMOD




	
	MODULE	my_im2
	PUBLIC	my_im2_init
	RSEG	INTJP
	DEFS 3
	RSEG	INTTABLE
	DEFS 257
	RSEG	CODE
my_im2_init
	di
	ld a,0xc3
	ld (SFB(INTJP)),a
	ld (SFB(INTJP)+1),de
	ld a,HIGH(SFB(INTTABLE))
	ld i,a
	inc a
	ld hl,SFB(INTTABLE)-1
tloop
	inc hl
	ld (hl),HIGH(SFB(INTJP))
	cp h
	jr nz,tloop
	im 2
	ret
	END
	