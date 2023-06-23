bison -d MM.y
flex MM.l
gcc lex.yy.c MM.tab.c -o MM -lm 
./MM
