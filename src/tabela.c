#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tabela.h"
#include "tipos.h"

Simbolo *tabela[211] = { NULL }; 


unsigned hash(char *s) {
    unsigned h = 0;
    while (*s) h = (h << 4) + *s++;
    return h % 211;
}


void inserirSimbolo(char *nome, Tipo tipo) {
    unsigned i = hash(nome);
    Simbolo *s = malloc(sizeof(Simbolo));
    s->nome = malloc(strlen(nome) + 1);  
    strcpy(s->nome, nome);               
    s->tipo = tipo;
    s->proximo = tabela[i];
    tabela[i] = s;
}


Simbolo *buscarSimbolo(char *nome) {
    unsigned i = hash(nome);
    for (Simbolo *s = tabela[i]; s; s = s->proximo) {
        if (strcmp(s->nome, nome) == 0) return s;
    }
    return NULL;
}


void imprimirTabela() {
    for (int i = 0; i < 211; i++) {
        for (Simbolo *s = tabela[i]; s; s = s->proximo) {
            printf("Nome: %s, Tipo: %s\n", s->nome, s->tipo == TIPO_INT ? "int" : (TIPO_REAL ? "float" : "string"));
        }
    }
}
