// ast.h
#ifndef AST_H
#define AST_H

#include "tipos.h" // Inclui a definição de Tipo e NoAST

NoAST *criarNoOp(char op, NoAST *esq, NoAST *dir);
NoAST *criarNoNum(int val);
NoAST *criarNoId(char *nome, Tipo tipo);
void imprimirAST(NoAST *no);
int tiposCompativeis(Tipo t1, Tipo t2);
NoAST* interpretar(NoAST *no);
void liberarAST(NoAST *no);
void imprimirValor(NoAST *no); // Declaração de imprimirValor
#endif