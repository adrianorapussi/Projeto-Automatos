all: shell

rapussiBison.tab.c rapussiBison.tab.h:	rapussiBison.y
	bison -d rapussiBison.y

lex.yy.c: rapussiFlex.lex rapussiBison.tab.h
	flex rapussiFlex.lex

shell: lex.yy.c rapussiBison.tab.c rapussiBison.tab.h
	gcc -o rapussi rapussiBison.tab.c lex.yy.c -lfl

clean:
	rm rapussi rapussiBison.tab.c lex.yy.c rapussiBison.tab.h
