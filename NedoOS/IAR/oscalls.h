#ifndef OSCALLS_H
#define OSCALLS_H

void OS_DROPAPP(unsigned char id);
unsigned long OS_GETAPPMAINPAGES(unsigned char id);

void YIELD(void);
void OS_SETGFX(unsigned char mode);
void OS_CLS(unsigned char color);
void OS_SETCOLOR(unsigned char color);
void OS_PRATTR(unsigned char attribute);
void OS_SETXY(unsigned char x,unsigned char y);
void OS_SETXYW(unsigned int w);
void OS_SETMUSIC(void (*play)(void),unsigned char pg);
void os_initstdio(void);
void print(unsigned char *);
unsigned int OS_GETXY(void);
unsigned char OS_GETATTR(void);


void SETPG32KHIGH(unsigned char page);

unsigned int putf(const char *str);
void putcsi(unsigned char);
void printn(unsigned char *, unsigned int size);
#define PUTCSI(_a) putcsi(_a)
void putcsi2(unsigned int);
#define PUTCSI2(_a,_b) putcsi(_a | (_b<<8))


union APP_PAGES {
	unsigned long l;
	struct{
		unsigned char window_3;
		unsigned char window_2;
		unsigned char window_1;
		unsigned char window_0;
	}pgs;
};
unsigned long OS_GETMAINPAGES(void);
unsigned int OS_GETCONFIG(void);
unsigned int os_reserv_1(void *);
void OS_SCROLLUP(unsigned int xy, unsigned int wh);
unsigned int _low_level_get(void);
char *cgets(char *str);
void conv1251to866(unsigned char * bufer);


void exit(int e);
unsigned char scrredraw(void);	//���� ���������� ��������� �� ������� redraw, 
								//�� ���������� ���������� ���� ������� scrredraw
								//���������� ����������� ������, ������ 0x00
#define MOUSE_BUTTON_BIT_LMB 0x01
#define MOUSE_BUTTON_BIT_RMB 0x02

extern unsigned char errno;
extern unsigned int mouse_yx;
extern unsigned char mouse_x;
extern unsigned char mouse_y;
extern unsigned char mouse_btns;
extern unsigned char t1251to866[128];

#define INK_BLACK      0x00
#define INK_BLUE       0x01
#define INK_RED        0x02
#define INK_MAGENTA    0x03
#define INK_GREEN      0x04
#define INK_CYAN       0x05
#define INK_YELLOW     0x06
#define INK_WHITE      0x07
#define INK_WHITE_BRIGHT      0x47

#define PAPER_BLACK    0x00
#define PAPER_BLUE     0x08
#define PAPER_RED      0x10
#define PAPER_MAGENTA  0x18
#define PAPER_GREEN    0x20
#define PAPER_CYAN     0x28
#define PAPER_YELLOW   0x30
#define PAPER_WHITE    0x38

#endif