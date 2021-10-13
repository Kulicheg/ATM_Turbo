@ECHO OFF
set PRJNAME=_tm
set PRJDEBUG=0
set C_FILES=main.c
set ASM_FILES=
SET ADD_LINK_FILES=
set CONSOLE=TTY
call ..\..\buildiar.bat
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put %PRJNAME%.com /bin/%PRJNAME%.com
"..\..\..\us\emul.exe"