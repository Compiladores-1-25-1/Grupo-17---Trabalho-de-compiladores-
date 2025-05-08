#ifndef TABELA_H
#define TABELA_H


typedef enum {TIPO_INT, TIPO_REAL} Tipo;


typedef struct simbolo {
    char *nome;        
    Tipo tipo;        
    struct simbolo *proximo; 
} Simbolo;


Simbolo *tabela[211];


unsigned hash(char *s);


void inserirSimbolo(char *nome, Tipo tipo);


Simbolo *buscarSimbolo(char *nome);


void imprimirTabela();

#endif
