#!/bin/bash

bison -d ../portugol.y
flex ../portugol.l

gcc -o portugol portugol.tab.c lex.yy.c -lfl

for file in tests_arquivos/*.txt; do
    echo "=========================="
    echo "Arquivo: $file"
    echo "--------------------------"
    ./portugol < "$file"
    echo ""
done