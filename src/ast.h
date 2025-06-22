// ast.h
#ifndef AST_H
#define AST_H

#include "tipos.h" // Inclui a definição de Tipo e NoAST

NoAST *criarNoOp(char op, NoAST *esq, NoAST *dir);
NoAST *criarNoNum(int val);
NoAST *criarNoReal(float val);
NoAST *criarNoId(char *nome, Tipo tipo);


NoAST *criarNoIf(NoAST *condicao, NoAST *bloco_then, NoAST *bloco_else);
NoAST *criarNoWhile(NoAST *condicao, NoAST *bloco_body);
NoAST *criarNoImprima(NoAST *expressao);
NoAST *criarNoLeia(char *nome);
NoAST *criarNoAtribuicao(char *nome, NoAST *expressao);
NoAST *criarNoDeclaracao(char *nome, Tipo tipo);
NoAST *criarNoBloco();
void adicionarComandoBloco(NoAST *bloco, NoAST *comando);


void inicializarNo(NoAST *no);


void imprimirAST(NoAST *no);
int tiposCompativeis(Tipo t1, Tipo t2);
void executarComando(NoAST *no);
NoAST* interpretar(NoAST *no);
void liberarAST(NoAST *no);
void imprimirValor(NoAST *no); // Declaração de imprimirValor
#endif