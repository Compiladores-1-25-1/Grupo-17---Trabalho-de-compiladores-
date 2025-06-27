// tabela.h
#ifndef TABELA_H
#define TABELA_H

#include "tipos.h" // Inclui a definição de Tipo e Simbolo

void inserirSimbolo(char *nome, Tipo tipo);
Simbolo *buscarSimbolo(char *nome);
void imprimirTabela();
void liberarTabela();

#endif