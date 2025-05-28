#ifndef TABELA_H
#define TABELA_H
#include "ast.h"
#include "tipos.h"
// typedef enum {TIPO_INT, TIPO_REAL} Tipo;


// typedef struct simbolo {
//     char *nome;        
//     Tipo tipo;
//     union {
//         int intValue;
//         float floatValue;
//     } valor;        
//     struct simbolo *proximo; 
// } Simbolo;


extern Simbolo *tabela[211];


unsigned hash(char *s);


void inserirSimbolo(char *nome, Tipo tipo);


Simbolo *buscarSimbolo(char *nome);


void imprimirTabela();

#endif
