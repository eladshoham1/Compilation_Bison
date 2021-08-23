build:
	flex olympics.lex
	bison -d olympics.y
	gcc -o olympics lex.yy.c olympics.tab.c

clean:
	rm -rf *.c *.h olympics

run:
	./olympics test_olympics.txt