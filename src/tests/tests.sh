#!/bin/bash

bison -d ../portugol.y
flex ../portugol.l

gcc -o portugol portugol.tab.c lex.yy.c -lfl

./portugol teste.pg