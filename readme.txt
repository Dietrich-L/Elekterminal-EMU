TTY9600 Elekterminal Emulator

This program emulates the ELEKTERMINAL published by the magazine ELEKTOR in november/december 1978.

The program is written in Free Pascal and compiles in the LAZARUS PASCAL environment. The TTY5.EXE is verified to work under Windows 10 64 bit. No installation is needed, just invoke TTY5

Commands

   alt-B - Baudrate                      alt-I - info
   alt-C - COM-Port
   alt-H - help
   alt-D - debug
   alt-X - exit

Fixed parameters:
	word length = 8       
	stop bits = 1
	parity bit = none
	flow = no     

These parameters can be changed in the source code only.

ELEKTERMINAL commands
The ELEKTERMINAL uses the SF.F 96364 CRT Controller and some glue logic. The terminal displays 16 lines with 64 characters and interprets some ASCII command codes

Code 	Function
$08	Cursor <--
$09	Cursor -->
$0A	Cursor down
$0B	Cursor up
$0C	Home cursor + clear screen
$0D	Carriage Return
$1A	Clear current line
$1C	Home Cursor
$1D	Cursor to begin of line


Redistribution
--------------
Source code, and all documents, are freely redistributable in
any form. Please see the the COPYRIGHT file included in this
Repository.
