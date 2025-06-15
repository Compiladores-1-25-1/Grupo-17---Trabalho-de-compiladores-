// ast.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "tabela.h" // Inclui para usar buscarSimbolo

// Função auxiliar para imprimir o valor de um nó, tratando diferentes tipos
void imprimirValor(NoAST *no) {
    switch (no->tipo) {
        case TIPO_INT:
            printf("%d", no->valor.intValue);
            break;
        case TIPO_REAL:
            printf("%f", no->valor.floatValue);
            break;
        case TIPO_STRING:
            printf("%s", no->valor.strValue);
            break;
        default:
            printf("Tipo desconhecido");
            break;
    }
}

NoAST *criarNoOp(char op, NoAST *esq, NoAST *dir) {
    NoAST *no = malloc(sizeof(NoAST));
    if (!no) {
        perror("Erro ao alocar memória para nó de operação");
        exit(EXIT_FAILURE);
    }
    no->operador = op;
    no->esquerda = esq;
    no->direita = dir;
    no->tipo = (esq->tipo == dir->tipo) ? esq->tipo : TIPO_ERRO; //Verifica se os tipos são compatíveis
    return no;
}

NoAST *criarNoNum(int val) {
    NoAST *no = malloc(sizeof(NoAST));
    if (!no) {
        perror("Erro ao alocar memória para nó de número");
        exit(EXIT_FAILURE);
    }
    no->valor.intValue = val;
    no->operador = 0;
    no->tipo = TIPO_INT;
    no->esquerda = no->direita = NULL;
    return no;
}

NoAST *criarNoId(char *nome, Tipo tipo) {
    NoAST *no = malloc(sizeof(NoAST));
    if (!no) {
        perror("Erro ao alocar memória para nó de identificador");
        exit(EXIT_FAILURE);
    }
    no->nome = strdup(nome); // Aloca dinamicamente a string
    if (!no->nome) {
        perror("Erro ao alocar memória para nome do identificador");
        exit(EXIT_FAILURE);
    }
    no->operador = 0;
    no->tipo = tipo;
    no->esquerda = no->direita = NULL;
    return no;
}

void imprimirAST(NoAST *no) {
    if (!no) return;

    printf("("); // Adiciona parênteses no início

    if (no->operador) {
        imprimirAST(no->esquerda);
        printf(" %c ", no->operador);
        imprimirAST(no->direita);
    } else if (no->nome) {
        printf("%s", no->nome);
    } else {
        printf("%d", no->valor.intValue);
    }

    printf(")"); // Adiciona parênteses no final
}

int tiposCompativeis(Tipo t1, Tipo t2) {
    return t1 == t2;
}

//Modifiquei a função interpretar para retornar um NoAST*, assim podemos passar os tipos para cima
NoAST* interpretar(NoAST *no) {
    if (!no) return NULL;

    NoAST *resultado = malloc(sizeof(NoAST)); // Aloca um novo nó para o resultado
    if (!resultado) {
        perror("Erro ao alocar memória para o resultado da interpretação");
        exit(EXIT_FAILURE);
    }
    resultado->esquerda = resultado->direita = NULL; // Garante que os ponteiros estejam nulos

    // Nó de operação: calcular recursivamente
    if (no->operador) {
        NoAST *valEsq = interpretar(no->esquerda);
        NoAST *valDir = interpretar(no->direita);
        if (!valEsq || !valDir) {
            free(resultado);
            return NULL;
        }

        if (valEsq->tipo != valDir->tipo) {
            fprintf(stderr, "Erro: tipos incompatíveis na operação '%c'.\n", no->operador);
            free(resultado);
            return NULL;
        }

        resultado->tipo = valEsq->tipo; // O tipo do resultado é o mesmo dos operandos (por enquanto)

        switch (no->operador) {
            case '+':
                if (resultado->tipo == TIPO_INT) {
                    resultado->valor.intValue = valEsq->valor.intValue + valDir->valor.intValue;
                } else if (resultado->tipo == TIPO_REAL) {
                    resultado->valor.floatValue = valEsq->valor.floatValue + valDir->valor.floatValue;
                }else {
                    fprintf(stderr, "Erro: Operação '+' não suportada para o tipo.\n");
                    free(resultado);
                    return NULL;
                }
                break;
            case '-':
                if (resultado->tipo == TIPO_INT) {
                    resultado->valor.intValue = valEsq->valor.intValue - valDir->valor.intValue;
                } else if (resultado->tipo == TIPO_REAL) {
                    resultado->valor.floatValue = valEsq->valor.floatValue - valDir->valor.floatValue;
                }else {
                    fprintf(stderr, "Erro: Operação '-' não suportada para o tipo.\n");
                    free(resultado);
                    return NULL;
                }
                break;
            case '*':
                if (resultado->tipo == TIPO_INT) {
                    resultado->valor.intValue = valEsq->valor.intValue * valDir->valor.intValue;
                } else if (resultado->tipo == TIPO_REAL) {
                    resultado->valor.floatValue = valEsq->valor.floatValue * valDir->valor.floatValue;
                }else {
                    fprintf(stderr, "Erro: Operação '*' não suportada para o tipo.\n");
                    free(resultado);
                    return NULL;
                }
                break;
            case '/':
                if (resultado->tipo == TIPO_INT || resultado->tipo == TIPO_REAL) {
                if ((valDir->tipo == TIPO_INT && valDir->valor.intValue == 0) ||
                    (valDir->tipo == TIPO_REAL && valDir->valor.floatValue == 0.0)) {
                    fprintf(stderr, "Erro: divisão por zero.\n");
                    liberarAST(valEsq); // Libera a memória alocada para valEsq
                    liberarAST(valDir); // Libera a memória alocada para valDir
                    free(resultado);
                    return NULL;
                }
                if (resultado->tipo == TIPO_INT) {
                    resultado->valor.intValue = valEsq->valor.intValue / valDir->valor.intValue;
                } else {
                    resultado->valor.floatValue = valEsq->valor.floatValue / valDir->valor.floatValue;
                }
                } else {
                    fprintf(stderr, "Erro: Operação '/' não suportada para o tipo.\n");
                    liberarAST(valEsq); // Libera a memória alocada para valEsq
                    liberarAST(valDir); // Libera a memória alocada para valDir
                    free(resultado);
                    return NULL;
                }
            break;
            case '>':
            case '<':
            case '=':
            case '!':
            case 'G': //MAIOR_IGUAL
            case 'L': //MENOR_IGUAL
                resultado->tipo = TIPO_INT;  // Operadores de comparação retornam um inteiro (0 ou 1)
                if (no->operador == '>') {
                    resultado->valor.intValue = (valEsq->valor.intValue > valDir->valor.intValue);
                } else if (no->operador == '<') {
                    resultado->valor.intValue = (valEsq->valor.intValue < valDir->valor.intValue);
                } else if (no->operador == '=') {
                    resultado->valor.intValue = (valEsq->valor.intValue == valDir->valor.intValue);
                } else if (no->operador == '!') {
                    resultado->valor.intValue = (valEsq->valor.intValue != valDir->valor.intValue);
                } else if (no->operador == 'G') {
                    resultado->valor.intValue = (valEsq->valor.intValue >= valDir->valor.intValue);
                } else if (no->operador == 'L') {
                    resultado->valor.intValue = (valEsq->valor.intValue <= valDir->valor.intValue);
                }
                break;
            default:
                fprintf(stderr, "Operador desconhecido: %c\n", no->operador);
                free(resultado);
                return NULL;
        }
        free(valEsq);
        free(valDir);

        return resultado;
    }

    // Nó de variável: aqui você deveria buscar na tabela de símbolos
    if (no->nome) {
        Simbolo *s = buscarSimbolo(no->nome);  // Função que você já deve ter
        if (!s) {
            fprintf(stderr, "Erro: variável '%s' não declarada.\n", no->nome);
            free(resultado);
            return NULL;
        }

        resultado->tipo = s->tipo; // O tipo do resultado é o tipo da variável
        switch (s->tipo) {
            case TIPO_INT:
                resultado->valor.intValue = s->valor.intValue;
                break;
            case TIPO_REAL:
                resultado->valor.floatValue = s->valor.floatValue;
                break;
            case TIPO_STRING:
                resultado->valor.strValue = strdup(s->valor.strValue);  // Duplica a string
                break;
            default:
                fprintf(stderr, "Erro: Tipo de variável não suportado.\n");
                free(resultado);
                return NULL;
        }

        return resultado;
    }

    // Nó de número literal
    resultado->tipo = TIPO_INT;
    resultado->valor.intValue = no->valor.intValue;
    return resultado;
}

void liberarAST(NoAST *no) {
    if (!no) return;
    liberarAST(no->esquerda);
    liberarAST(no->direita);
    if (no->nome) free(no->nome);
    free(no);
}