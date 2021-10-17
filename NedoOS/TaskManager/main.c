
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
  unsigned char nomer2;
  unsigned char name[32];
  unsigned char used;
  unsigned char window_0;
  unsigned char window_1;
  unsigned char window_2;
  unsigned char window_3;
} table[17];

int procnum, prccount;
unsigned char c1, c2, pgbak, freemem, sysmem, usedmem, curpos;
unsigned char procname;
union APP_PAGES main_pg;

void redraw(void)
{
unsigned char c3;

  BOX(12, 4, 54, 1, 41);
  AT(33, 4);
  ATRIB(33);
  puts("TASK MANAGER");
  BOX(15, 5, 40, prccount, 43);
  BOX(12, 5 + prccount, 54, 1, 40);
  ATRIB(43);

  for (c3 = 0; c3 < prccount; c3++)
  {
    AT(12, 5 + c3);
    if (c3 == curpos - 1) {
      ATRIB(33);
      ATRIB(40);
    } else  {
      ATRIB(30);
      ATRIB(43);
    }
    putdec(table[c3].nomer);
    putchar('.');
    puts(table[c3].name);
    AT(50, 5 + c3);
    printf("%u  ", table[c3].used);
    AT(55, 5 + c3);
    printf("%X.", table[c3].window_0);
    printf("%X.", table[c3].window_1);
    printf("%X.", table[c3].window_2);
    printf("%X",  table[c3].window_3);

  }

  BOX(12, 5 + prccount, 54, 1, 41);
  AT(12, 5 + prccount);
  ATRIB(33);
  printf("    Free:%u pages     Used:%u pages  Sys:%u pages", freemem, usedmem, sysmem);

  putchar('\r');
  putchar('\n');

}
void filltable(void)
{
  unsigned char c3, c4;
  main_pg.l = OS_GETMAINPAGES();
  pgbak = main_pg.pgs.window_3;
  prccount = 0;
  for (c3 = 0; c3 < 16; c3++)
  {
    c4 = c3 + 1;
	main_pg.l = OS_GETAPPMAINPAGES(c4);

    if (errno == 0)
    {
    
      table[prccount].nomer    = c4;
      table[c3].nomer2         = prccount;
      table[prccount].window_0 = main_pg.pgs.window_0;
      table[prccount].window_1 = main_pg.pgs.window_1;
      table[prccount].window_2 = main_pg.pgs.window_2;
      table[prccount].window_3 = main_pg.pgs.window_3;
      SETPG32KHIGH(table[prccount].window_0);
      memcpy(table[prccount].name, (char*)(0xc000 + COMMANDLINE), 31);
	prccount++;
	}
	else
	{
	table[c3].nomer2   = 0;
	}
	table[c3].used     = 0;
  }

  SETPG32KHIGH(pgbak);

  freemem = 0;
  sysmem  = 0;
  usedmem = 0;
  for ( c2 = 0; c2 < 255; c2++)
  {
    unsigned char owner;
    owner = OS_GETPAGEOWNER(c2);
    if (owner == 0)
    {
      freemem++;
    }
    else

      if (owner == 255)
      {
        sysmem++;
      }
      else
      {
        table[table[owner-1].nomer2].used++;
        usedmem++;
      }
  }
}

void killapp(unsigned char  id)
{
	
    OS_DROPAPP (id);
	BOX(12, 4, 58, prccount + 2, 40);
	filltable();
	
}

C_task main (int argc, char *argv[])
{
  unsigned char  loop = 1;
  curpos = 1;
  os_initstdio();
  filltable();
  redraw();
  while (loop)
  {
    procname = getchar();

    if  (procname > '0' && procname < '9')
    {
     procname = procname - '0';
	 killapp(procname);
    }
    else if (procname == '\e')
    {
      loop = 0;
    }

    if  (procname == 'q'  || procname == 'Q') {curpos--;}
    if  (procname == 'a'  || procname == 'A'){curpos++;}
	if  (procname == '\n' || procname == 'd'){killapp(table[curpos-1].nomer);}
    if (curpos < 1) {curpos = prccount;}
    if (curpos > prccount) {curpos = 1;}
	redraw();
  }
  return 0;
}
