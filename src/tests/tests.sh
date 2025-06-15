#!/bin/bash

rm -r portugol portugol.tab.c lex.yy.c portugol.tab.h

bison -d ../portugol.y
flex ../portugol.l


gcc -I.. -o portugol portugol.tab.c ../tabela.c ../ast.c lex.yy.c -lfl

for file in tests_arquivos/*.txt; do
    echo "=========================="
    echo "Arquivo: $file"
    echo "--------------------------"
    ./portugol < "$file"
    echo ""
done