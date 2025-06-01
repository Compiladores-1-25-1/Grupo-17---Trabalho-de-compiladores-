#ifndef AST_H
#define AST_H

#include "tipos.h"

NoAST *criarNoOp(char op, NoAST *esq, NoAST *dir);
NoAST *criarNoNum(int val);
NoAST *criarNoId(char *nome, Tipo tipo);
void imprimirAST(NoAST *no);
int tiposCompativeis(Tipo t1, Tipo t2);

#endif