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
    
    // Validação dos operandos
    if (!esq || !dir) {
        fprintf(stderr, "[DEBUG] criarNoOp: ERRO - operando inválido - esq: %p, dir: %p\n", 
                (void*)esq, (void*)dir);
        return NULL;
    }
    
    
            
    NoAST *no = malloc(sizeof(NoAST));
    if (!no) {
        perror("Erro ao alocar memória para nó de operação");
        exit(EXIT_FAILURE);
    }
    no->operador = op;
    no->esquerda = esq;
    no->direita = dir;
    no->tipo = (esq->tipo == dir->tipo) ? esq->tipo : TIPO_ERRO;
    
    
    return no;
}

NoAST *criarNoNum(int val) {
    NoAST *no = (NoAST *)malloc(sizeof(NoAST));
    if (!no) {
        fprintf(stderr, "[DEBUG] criarNoNum: ERRO - falha ao alocar memória\n");
        return NULL;
    }
    
    no->tipo = TIPO_INT;
    no->operador = 'N';  // N para número
    no->valor.intValue = val;
    no->esquerda = NULL;
    no->direita = NULL;
    no->nome = NULL;
    
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
    if (!no) {
        fprintf(stderr, "[DEBUG] interpretar: nó nulo\n");
        return NULL;
    }

    // Se for um nó identificador, busca o valor atual na tabela de símbolos
    if (no->nome) {
        Simbolo *s = buscarSimbolo(no->nome);
        if (!s) {
            fprintf(stderr, "[DEBUG] interpretar: variável não encontrada: %s\n", no->nome);
            return NULL;
        }
        
        NoAST *resultado = (NoAST *)malloc(sizeof(NoAST));
        if (!resultado) {
            fprintf(stderr, "[DEBUG] interpretar: ERRO - falha ao alocar memória para resultado\n");
            return NULL;
        }

        resultado->tipo = s->tipo;
        resultado->operador = 'N';
        resultado->esquerda = NULL;
        resultado->direita = NULL;
        resultado->nome = NULL;
        
        switch (s->tipo) {
            case TIPO_INT:
                resultado->valor.intValue = s->valor.intValue;
                break;
            case TIPO_REAL:
                resultado->valor.floatValue = s->valor.floatValue;
                break;
            case TIPO_STRING:
                resultado->valor.strValue = s->valor.strValue ? strdup(s->valor.strValue) : NULL;
                break;
            default:
                fprintf(stderr, "[DEBUG] interpretar: tipo desconhecido para variável %s\n", no->nome);
                free(resultado);
                return NULL;
        }
        
        return resultado;
    }

    // Se for um nó numérico, retorna uma cópia
    if (no->operador == 'N') {
        NoAST *resultado = (NoAST *)malloc(sizeof(NoAST));
        if (!resultado) {
            fprintf(stderr, "[DEBUG] interpretar: ERRO - falha ao alocar memória para resultado\n");
            return NULL;
        }

        resultado->tipo = no->tipo;
        resultado->operador = 'N';
        resultado->esquerda = NULL;
        resultado->direita = NULL;
        resultado->nome = NULL;
        
        if (no->tipo == TIPO_INT) {
            resultado->valor.intValue = no->valor.intValue;
        } else if (no->tipo == TIPO_REAL) {
            resultado->valor.floatValue = no->valor.floatValue;
        } else if (no->tipo == TIPO_STRING && no->valor.strValue) {
            resultado->valor.strValue = strdup(no->valor.strValue);
        }
        
        return resultado;
    }

    // Nó de operação: calcular recursivamente
    
    if (!no->esquerda || !no->direita) {
        fprintf(stderr, "[DEBUG] interpretar: ERRO - operando nulo - esq: %p, dir: %p\n", 
                (void*)no->esquerda, (void*)no->direita);
        return NULL;
    }
    
    NoAST *valEsq = interpretar(no->esquerda);
    
    if (!valEsq) {
        fprintf(stderr, "[DEBUG] interpretar: ERRO - falha ao avaliar operando esquerdo\n");
        return NULL;
    }
    
    NoAST *valDir = interpretar(no->direita);
    
    if (!valDir) {
        fprintf(stderr, "[DEBUG] interpretar: ERRO - falha ao avaliar operando direito\n");
        liberarAST(valEsq);
        return NULL;
    }

    NoAST *resultado = (NoAST *)malloc(sizeof(NoAST));
    if (!resultado) {
        fprintf(stderr, "[DEBUG] interpretar: ERRO - falha ao alocar memória para resultado\n");
        return NULL;
    }

    // Inicialização do nó resultado
    resultado->tipo = no->tipo;
    resultado->operador = 'N';
    resultado->esquerda = NULL;
    resultado->direita = NULL;
    resultado->nome = NULL;

    if (valEsq->tipo != valDir->tipo) {
        fprintf(stderr, "[DEBUG] interpretar: tipos incompatíveis - esq: %d, dir: %d\n", 
                valEsq->tipo, valDir->tipo);
        free(resultado);
        return NULL;
    }

    resultado->tipo = valEsq->tipo;

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
                liberarAST(valEsq); 
                liberarAST(valDir); 
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
                liberarAST(valEsq); 
                liberarAST(valDir); 
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

void liberarAST(NoAST *no) {
    if (!no) {
        fprintf(stderr, "[DEBUG] liberarAST: tentativa de liberar nó nulo\n");
        return;
    }
    
    
    
    if (no->esquerda) {
        liberarAST(no->esquerda);
    }
    
    if (no->direita) {
        liberarAST(no->direita);
    }
    
    if (no->nome) {
        free(no->nome);
    }
    
    free(no);
}