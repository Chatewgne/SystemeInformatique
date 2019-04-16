#!/bin/bash 
flex takoyaki.l
#gcc -o compiler lex.yy.c -ll
yacc -d takoyaki.y
gcc -o takoyaki binwriter.c symboltable.c instrutable.c y.tab.c lex.yy.c -ly -ll
