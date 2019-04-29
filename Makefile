takoyakimake: takoyaki.y takoyaki.l binwriter.c symboltable.c instrutable.c
	flex takoyaki.l
	yacc -d takoyaki.y
	gcc -o takoyaki binwriter.c symboltable.c instrutable.c y.tab.c lex.yy.c -ly -ll
