#!/bin/bash 
flex compiler.l
#gcc -o compiler lex.yy.c -ll
yacc -d compiler.y
gcc -o compiler y.tab.c lex.yy.c -ly -ll
