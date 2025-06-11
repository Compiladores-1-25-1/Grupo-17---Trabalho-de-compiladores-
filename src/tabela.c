// tabela.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tabela.h" // Inclui a definição de Simbolo

Simbolo *tabela[211] = { NULL };

unsigned hash(char *s) {
    unsigned h = 0;
    while (*s) h = (h << 4) + *s++;
    return h % 211;
}

void inserirSimbolo(char *nome, Tipo tipo) {
    unsigned i = hash(nome);
    Simbolo *s = malloc(sizeof(Simbolo));
    if (!s) {
        perror("Erro ao alocar memória para o símbolo");
        exit(EXIT_FAILURE);
    }

    s->nome = strdup(nome); // Usando strdup para alocar e copiar o nome
    if (!s->nome) {
        perror("Erro ao alocar memória para o nome do símbolo");
        free(s);
        exit(EXIT_FAILURE);
    }

    s->tipo = tipo;

    // Inicializa o valor da variável com um valor padrão
    switch (tipo) {
        case TIPO_INT:
            s->valor.intValue = 0;
            break;
        case TIPO_REAL:
            s->valor.floatValue = 0.0;
            break;
        case TIPO_STRING:
            s->valor.strValue = NULL; // Inicializa com NULL
            break;
        default:
            fprintf(stderr, "Erro: Tipo desconhecido ao inserir símbolo.\n");
            free(s->nome);
            free(s);
            exit(EXIT_FAILURE);
    }

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
            printf("Nome: %s, Tipo: ", s->nome);
            if (s->tipo == TIPO_INT) {
                printf("int, Valor: %d\n", s->valor.intValue);
            } else if (s->tipo == TIPO_REAL) {
                printf("float, Valor: %f\n", s->valor.floatValue);
            } else if (s->tipo == TIPO_STRING) {
                //Verificando se a string é nula
                printf("string, Valor: %s\n", s->valor.strValue ? s->valor.strValue : "(null)");
            } else {
                printf("desconhecido\n");
            }
        }
    }
}

void liberarTabela() {
    for (int i = 0; i < 211; i++) {
        Simbolo *s = tabela[i];
        while (s) {
            Simbolo *temp = s;
            s = s->proximo;
            free(temp->nome);
            if (temp->tipo == TIPO_STRING && temp->valor.strValue) {
                free(temp->valor.strValue); // Libera a string, se alocada
            }
            free(temp);
        }
        tabela[i] = NULL; // Importante: define como NULL após liberar
    }
}