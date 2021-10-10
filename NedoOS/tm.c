
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <intrz80.h>
#include <terminal.c>
#define COMMANDLINE 0x0080

struct process
{
		unsigned char nomer;
		unsigned char name[32];
		unsigned char window_0;
		unsigned char window_1;
		unsigned char window_2;
		unsigned char window_3;
}table[16];


void initall(void)
{
unsigned char c1;
for (c1 = 1; c1 < 16; c1++)
{

		table[c1].nomer    = 0;
		table[c1].window_0 = 0;
		table[c1].window_1 = 0;
		table[c1].window_2 = 0;
		table[c1].window_3 = 0;
		
		for (c2 = 0; c2 < 32; c2++)
		{
		table[c1].name[c2] = 0;
		}	
}
}

C_task main (int argc, char *argv[]) 
{
unsigned char  loop=1;

	while(loop)
{
int procnum, prccount;
unsigned char c1, c2, pgbak;
unsigned char procname;
union APP_PAGES main_pg;


initall();
os_initstdio();	


main_pg.l = OS_GETMAINPAGES();
pgbak = main_pg.pgs.window_3;

prccount = 0;
for (c1 = 1; c1 < 16; c1++)
{
	main_pg.l = OS_GETAPPMAINPAGES(c1);
	
	if (errno == 0)
		{
		table[c1].nomer    = c1;
		table[c1].window_0 = main_pg.pgs.window_0;
		table[c1].window_1 = main_pg.pgs.window_1;
		table[c1].window_2 = main_pg.pgs.window_2;
		table[c1].window_3 = main_pg.pgs.window_3;
		prccount++;
		SETPG32KHIGH(table[c1].window_0);
		memcpy(table[c1].name, (char*)(0xc080), 31);
		SETPG32KHIGH(pgbak);
	}
	else 
	{
		table[c1].nomer    = 0;
		table[c1].window_0 = 0;
		table[c1].window_1 = 0;
		table[c1].window_2 = 0;
		table[c1].window_3 = 0;
		table[c1].name[0] = '\0';
	}
}





	BOX(12, 4, 58,1, 41);
	AT(36,4);
	ATRIB(33);
	puts("TASK MANAGER");
	BOX(20, 5, 50,prccount, 43);
c2=1;
for (c1 = 1; c1 < 16; c1++)
{
	if  (table[c1].nomer != 0)
	{
		AT(12,5 + c2-1);
		ATRIB(30);
		putdec(table[c1].nomer);
		putchar('.');
		puts(table[c1].name);
				
		
		AT(55,5 + c2-1);
		putdec(table[c1].window_0);
		putchar('.');
		putdec(table[c1].window_1);
		putchar('.');
		putdec(table[c1].window_2);
		putchar('.');
		putdec(table[c1].window_3);
		c2++;
	}	
}
	AT (28, 19);
	ATRIB(35);
	puts(" Select process number ");

	procname = getchar();
	if 	(procname > '0' && procname < '9')
	{
	procnum = procname - '0';
	OS_DROPAPP (procnum);
	initall();
	BOX(12, 4, 58,prccount + 2, 40);
	}
	else
	{
	loop = 0;
	}
}

	return 0;
}   

