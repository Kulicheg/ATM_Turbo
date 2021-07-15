    MODULE Uart
; ЗАМЕНИЛ  установку RTS на RTS+DTR и скорость порта 28800
		macro getqueue
		ld	a, #55	;подать комнаду контроллеру клавиатуры
		in	a, (#0FE)
		ld	a, #0C2	;команда - чтение счетчика буфера приема
		in	a, (#0FE)
		endm

		macro getbyte
		
readyrx:
		ld	a,#55		;подать комнаду контроллеру клавиатуры
		in	a,(#0FE)
		ld	a,#42		;команда - прочесть статус
		in	a,(#0FE)
		bit	 0, a		;Параметры - RD 
		jp z,readyrx			; вернуться если байта нет
		
		ld	a,#55			;подать комнаду контроллеру клавиатуры
		in	a,(#0FE)
		ld	a,#02			;команда - принять байт
		in	a,(#0FE)			; Байт положили в А
		endm


init:
;инициализируем порт
		ld	a, #55		;подать комнаду контроллеру клавиатуры
		in	a,(#0FE)
		ld	a,#0C3		;команда - установить скорость порта
		in	a,(#0FE)
		ld	a,#03		;параметр - установить скорость порта 19200(6) 28800(3)
		in	a,(#0FE)
		ld	a,#55		;подать комнаду контроллеру клавиатуры
		in	a,(#0FE)
		ld	a,#43		;команда - установить статус
		in	a,(#0FE)
		ld	a, #3		;Параметры - убрать RTS (START)
		in	a, (#0FE)

clearbuf		
		push de
		ld e, #0FF
clearbuf2
		ld	a, #55	;подать комнаду контроллеру клавиатуры
		in	a, (#0FE)
		ld	a, #02	;команда - принять байт
		in	a, (#0FE)
		dec e
		jr nz, clearbuf2
		pop de
		ret


read:
		getqueue			;Получили число байт в буфере
		or a				;Неоптимизировано постоянное вколючение и отключение RTS
		call z, startrts	;Если пусто, разрешаем прием
		call stoprts		;Если байт пришел, то говорим СТОП		
		getbyte				;Получаем байт в А


;		call startrts		;Если пусто, разрешаем прием
;		call stoprts		;Если байт пришел, то говорим СТОП		
;		getbyte				;Получаем байт в А





		ret

; Write single byte to UART
; A - byte to write
; BC will be wasted
write: 
		ld  c, a		;В А получаем байт, сораняем его в C
readytx:
		ld	a,#55		;подать комнаду контроллеру клавиатуры
		in	a,(#0FE)
		ld	a,#42		;команда - прочесть статус
		in	a,(#0FE)
		bit	 6, a		;Параметры - TX 
		jp z,readytx			; вернуться если байта нет

		ld	a, #55		;подать комнаду контроллеру клавиатуры
		in	a, (#0FE)
		ld	a, #03		;команда - отправить байт
		in	a, (#0FE)
		ld	a, c		;Параметры - байт для отправки
		in	a, (#0FE)
		ret



stoprts
		ld	a,#55	;подать комнаду контроллеру клавиатуры
		in	a,(#0FE)
		ld	a,#43	;команда - установить статус
		in	a,(#0FE)
		ld	a,0	;Параметры - установить RTS (STOP)
		in	a,(#0FE)
		ret

startrts
		ld	a,#55		;подать комнаду контроллеру клавиатуры
		in	a,(#0FE)
		ld	a,#43		;команда - установить статус
		in	a,(#0FE)
		ld	a, #03		;Параметры - убрать RTS (START)
		in	a, (#0FE)
		ret
delay
		push de
		ld e,0x0FF
delay2

		EX (SP),HL
		EX (SP),HL
		EX (SP),HL
		EX (SP),HL
		EX (SP),HL
		EX (SP),HL
		EX (SP),HL
		EX (SP),HL
		dec e
		jr nz, delay2
		pop de
		ret

    ENDMODULE
