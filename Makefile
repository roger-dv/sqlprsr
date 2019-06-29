# Based on original source code:
#
# $Header: /home/johnl/flnb/code/sql/RCS/Makefile,v 2.1 2009/11/08 02:53:39 johnl Exp $
# Companion source code for "flex & bison", published by O'Reilly
# Media, ISBN 978-0-596-15597-1
# Copyright (c) 2009, Taughannock Networks. All rights reserved.
# See the README file for license conditions and contact info.
#
# (Revisions by Roger Voss, May-June 2019)

CC = cc -g
LEX = flex
YACC = bison
CFLAGS = -DYYDEBUG=1

PROGRAM = sqlprsr

all: ${PROGRAM}

sqlprsr: sqlprsr.tab.o sqlprsr.o
	${CC} -o $@ sqlprsr.tab.o sqlprsr.o

sqlprsr.tab.c sqlprsr.tab.h: sqlprsr.y
	${YACC} -vd sqlprsr.y

sqlprsr.c: sqlprsr.l
	${LEX} -o $@ $<

sqlprsr.o: sqlprsr.c sqlprsr.tab.h

clean:
	rm -f sqlprsr sqlprsr.tab.o sqlprsr.o sqlprsr.tab.c sqlprsr.tab.h sqlprsr.c sqlprsr.output

.SUFFIXES: .l .y .c
