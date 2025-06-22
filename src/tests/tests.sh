#!/bin/bash

# Remove arquivos gerados da compilação
rm -r portugol portugol.tab.c lex.yy.c portugol.tab.h

# Compila o analisador
bison -d ../portugol.y
flex ../portugol.l

gcc -I.. -o portugol portugol.tab.c ../tabela.c ../ast.c lex.yy.c -lfl

# Executa todos os arquivos .txt dentro de subpastas de tests_arquivos
find tests_arquivos -type f -name '*.txt' | while read file; do
    echo "=========================="
    echo "Arquivo: $file"
    echo "--------------------------"
    ./portugol < "$file"
    echo ""
done
