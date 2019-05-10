takoyakimake: takoyaki.y takoyaki.l symboltable.c instrutable.c
	flex takoyaki.l
	yacc -d takoyaki.y
	gcc -o takoyaki symboltable.c instrutable.c y.tab.c lex.yy.c -ly -ll
