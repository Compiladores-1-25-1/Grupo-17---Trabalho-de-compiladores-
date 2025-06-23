// ast.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "tabela.h" // Inclui para usar buscarSimbolo

void erro_semantico(const char *s);

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


void inicializarNo(NoAST *no) {
    no->operador = 0;
    no->nome = NULL;
    no->esquerda = NULL;
    no->direita = NULL;
    no->condicao = NULL;
    no->bloco_then = NULL;
    no->bloco_else = NULL;
    no->bloco_body = NULL;
    no->proximo = NULL;
}

NoAST *criarNoOp(char op, NoAST *esq, NoAST *dir) {
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

    inicializarNo(no);
    no->tipoNo = NO_OPERACAO;
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

    inicializarNo(no);
    no->tipoNo = NO_NUMERO;
    no->tipo = TIPO_INT;
    no->valor.intValue = val;

    return no;
}

NoAST *criarNoReal(float val) {
    NoAST *no = (NoAST *)malloc(sizeof(NoAST));
    if (!no) {
        fprintf(stderr, "[DEBUG] criarNoReal: ERRO - falha ao alocar memória\n");
        return NULL;
    }

    inicializarNo(no);
    no->tipoNo = NO_NUMERO;
    no->tipo = TIPO_REAL;
    no->valor.floatValue = val;

    return no;
}

NoAST *criarNoId(char *nome, Tipo tipo) {
    NoAST *no = malloc(sizeof(NoAST));
    if (!no) {
        perror("Erro ao alocar memória para nó de identificador");
        exit(EXIT_FAILURE);
    }

    inicializarNo(no);
    no->tipoNo = NO_IDENTIFICADOR;
    no->nome = strdup(nome);
    if (!no->nome) {
        perror("Erro ao alocar memória para nome do identificador");
        exit(EXIT_FAILURE);
    }
    no->tipo = tipo;

    return no;
}

NoAST *criarNoIf(NoAST *condicao, NoAST *bloco_then, NoAST *bloco_else) {
    NoAST *no = malloc(sizeof(NoAST));
    if (!no) {
        perror("Erro ao alocar memória para nó IF");
        exit(EXIT_FAILURE);
    }

    inicializarNo(no);
    no->tipoNo = NO_IF;
    no->condicao = condicao;
    no->bloco_then = bloco_then;
    no->bloco_else = bloco_else;

    return no;
}

NoAST *criarNoWhile(NoAST *condicao, NoAST *bloco_body) {
    NoAST *no = malloc(sizeof(NoAST));
    if (!no) {
        perror("Erro ao alocar memória para nó WHILE");
        exit(EXIT_FAILURE);
    }

    inicializarNo(no);
    no->tipoNo = NO_WHILE;
    no->condicao = condicao;
    no->bloco_body = bloco_body;

    return no;
}

NoAST *criarNoImprima(NoAST *expressao) {
    NoAST *no = malloc(sizeof(NoAST));
    if (!no) {
        perror("Erro ao alocar memória para nó IMPRIMA");
        exit(EXIT_FAILURE);
    }

    inicializarNo(no);
    no->tipoNo = NO_IMPRIMA;
    no->esquerda = expressao;

    return no;
}

NoAST *criarNoLeia(char *nome) {
    NoAST *no = malloc(sizeof(NoAST));
    if (!no) {
        perror("Erro ao alocar memória para nó LEIA");
        exit(EXIT_FAILURE);
    }

    inicializarNo(no);
    no->tipoNo = NO_LEIA;
    no->nome = strdup(nome);
    if (!no->nome) {
        perror("Erro ao alocar memória para nome em LEIA");
        exit(EXIT_FAILURE);
    }

    return no;
}

NoAST *criarNoAtribuicao(char *nome, NoAST *expressao) {
    NoAST *no = malloc(sizeof(NoAST));
    if (!no) {
        perror("Erro ao alocar memória para nó ATRIBUICAO");
        exit(EXIT_FAILURE);
    }

    inicializarNo(no);
    no->tipoNo = NO_ATRIBUICAO;
    no->nome = strdup(nome);
    if (!no->nome) {
        perror("Erro ao alocar memória para nome em ATRIBUICAO");
        exit(EXIT_FAILURE);
    }
    no->esquerda = expressao;

    return no;
}

NoAST *criarNoDeclaracao(char *nome, Tipo tipo) {
    NoAST *no = malloc(sizeof(NoAST));
    if (!no) {
        perror("Erro ao alocar memória para nó DECLARACAO");
        exit(EXIT_FAILURE);
    }

    inicializarNo(no);
    no->tipoNo = NO_DECLARACAO;
    no->nome = strdup(nome);
    if (!no->nome) {
        perror("Erro ao alocar memória para nome em DECLARACAO");
        exit(EXIT_FAILURE);
    }
    no->tipo = tipo;

    return no;
}

NoAST *criarNoBloco() {
    NoAST *no = malloc(sizeof(NoAST));
    if (!no) {
        perror("Erro ao alocar memória para nó BLOCO");
        exit(EXIT_FAILURE);
    }

    inicializarNo(no);
    no->tipoNo = NO_BLOCO;

    return no;
}

void adicionarComandoBloco(NoAST *bloco, NoAST *comando) {
    if (!bloco || bloco->tipoNo != NO_BLOCO) {
        fprintf(stderr, "Erro: tentativa de adicionar comando a nó que não é bloco\n");
        return;
    }

    if (!bloco->esquerda) {
        bloco->esquerda = comando;
    } else {
        NoAST *atual = bloco->esquerda;
        while (atual->proximo) {
            atual = atual->proximo;
        }
        atual->proximo = comando;
    }
}

void imprimirAST(NoAST *no) {
    if (!no) return;

    switch (no->tipoNo) {
        case NO_OPERACAO:
            printf("(");
            imprimirAST(no->esquerda);
            printf(" %c ", no->operador);
            imprimirAST(no->direita);
            printf(")");
            break;
        case NO_NUMERO:
            printf("%d", no->valor.intValue);
            break;
        case NO_IDENTIFICADOR:
            printf("%s", no->nome);
            break;
        case NO_IF:
            printf("SE (");
            imprimirAST(no->condicao);
            printf(") ENTÃO { ");
            imprimirAST(no->bloco_then);
            if (no->bloco_else) {
                printf(" } SENÃO { ");
                imprimirAST(no->bloco_else);
            }
            printf(" }");
            break;
        case NO_WHILE:
            printf("ENQUANTO (");
            imprimirAST(no->condicao);
            printf(") FAÇA { ");
            imprimirAST(no->bloco_body);
            printf(" }");
            break;
        case NO_IMPRIMA:
            printf("IMPRIMA(");
            imprimirAST(no->esquerda);
            printf(")");
            break;
        case NO_LEIA:
            printf("LEIA(%s)", no->nome);
            break;
        case NO_ATRIBUICAO:
            printf("%s <- ", no->nome);
            imprimirAST(no->esquerda);
            break;
        case NO_DECLARACAO:
            printf("DECLARACAO(%s)", no->nome);
            break;
        case NO_BLOCO:
            {
                NoAST *comando = no->esquerda;
                while (comando) {
                    imprimirAST(comando);
                    if (comando->proximo) printf("; ");
                    comando = comando->proximo;
                }
            }
            break;
    }
}

int tiposCompativeis(Tipo t1, Tipo t2) {
    return t1 == t2;
}

void executarComando(NoAST *no) {
    if (!no) return;

    switch (no->tipoNo) {
        case NO_DECLARACAO:
            if (buscarSimbolo(no->nome)) {
                fprintf(stderr, "Erro: Redeclaração de variável %s\n", no->nome);
            } else {
                inserirSimbolo(no->nome, no->tipo);
            }
            break;

        case NO_ATRIBUICAO:
            {
                Simbolo *s = buscarSimbolo(no->nome);
                if (!s) {
                    fprintf(stderr, "Erro: Variável %s não declarada\n", no->nome);
                    return;
                }

                NoAST *resultado = interpretar(no->esquerda);
                if (!resultado) {
                    fprintf(stderr, "Erro na interpretação da expressão\n");
                    return;
                }

                if (s->tipo == resultado->tipo) {
                    switch (s->tipo) {
                        case TIPO_INT:
                            s->valor.intValue = resultado->valor.intValue;
                            break;
                        case TIPO_REAL:
                            s->valor.floatValue = resultado->valor.floatValue;
                            break;
                        case TIPO_STRING:
                            if (s->valor.strValue) free(s->valor.strValue);
                            s->valor.strValue = resultado->valor.strValue ? strdup(resultado->valor.strValue) : NULL;
                            break;
                        default:
                            fprintf(stderr, "Erro: Tipo não suportado na atribuição\n");
                            break;
                    }
                } else {
                    fprintf(stderr, "Erro: Tipos incompatíveis na atribuição\n");
                }
                liberarAST(resultado);
            }
            break;

        case NO_IMPRIMA:
            {
                NoAST *resultado = interpretar(no->esquerda);
                if (resultado) {
                    imprimirValor(resultado);
                    printf("\n");
                    liberarAST(resultado);
                } else {
                    fprintf(stderr, "Erro ao interpretar expressão do IMPRIMA\n");
                }
            }
            break;

        case NO_LEIA:
            {
                Simbolo *s = buscarSimbolo(no->nome);
                if (!s) {
                    fprintf(stderr, "Erro: Variável %s não declarada\n", no->nome);
                    return;
                }

                if (s->tipo == TIPO_INT) {
                    printf("Digite um valor inteiro para %s: ", s->nome);
                    scanf("%d", &s->valor.intValue);
                } else if (s->tipo == TIPO_REAL) {
                    printf("Digite um valor real para %s: ", s->nome);
                    scanf("%f", &s->valor.floatValue);
                } else if (s->tipo == TIPO_STRING) {
                    printf("Digite um valor string para %s: ", s->nome);
                    if (s->valor.strValue) free(s->valor.strValue);
                    s->valor.strValue = malloc(256);
                    if (s->valor.strValue) {
                        scanf("%255s", s->valor.strValue);
                    }
                }
            }
            break;

        case NO_IF:
            {
                NoAST *resultado = interpretar(no->condicao);
                if (!resultado || resultado->tipo != TIPO_INT) {
                    fprintf(stderr, "Erro: Condição do IF deve ser um valor inteiro\n");
                    if (resultado) liberarAST(resultado);
                    return;
                }

                if (resultado->valor.intValue) {
                    executarComando(no->bloco_then);
                } else if (no->bloco_else) {
                    executarComando(no->bloco_else);
                }

                liberarAST(resultado);
            }
            break;

        case NO_WHILE:
            {
                while (1) {
                    NoAST *resultado = interpretar(no->condicao);
                    if (!resultado || resultado->tipo != TIPO_INT) {
                        fprintf(stderr, "Erro: Condição do WHILE deve ser um valor inteiro\n");
                        if (resultado) liberarAST(resultado);
                        break;
                    }

                    if (!resultado->valor.intValue) {
                        liberarAST(resultado);
                        break;
                    }

                    liberarAST(resultado);
                    executarComando(no->bloco_body);
                }
            }
            break;

        case NO_BLOCO:
            {
                NoAST *comando = no->esquerda;
                while (comando) {
                    executarComando(comando);
                    comando = comando->proximo;
                }
            }
            break;

        default:
            break;
    }
}

NoAST* interpretar(NoAST *no) {
    if (!no) {
        fprintf(stderr, "[DEBUG] interpretar: nó nulo\n");
        return NULL;
    }

    switch (no->tipoNo) {
                case NO_IDENTIFICADOR:
            {
                Simbolo *s = buscarSimbolo(no->nome);
                if (!s) {
                    fprintf(stderr, "Erro: Variável '%s' não foi declarada\n", no->nome);
                    return NULL;
                }

                NoAST *resultado = (NoAST *)malloc(sizeof(NoAST));
                if (!resultado) {
                    fprintf(stderr, "[DEBUG] interpretar: ERRO - falha ao alocar memória para resultado\n");
                    return NULL;
                }

                inicializarNo(resultado);
                resultado->tipoNo = NO_NUMERO;
                resultado->tipo = s->tipo;

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

        case NO_NUMERO:
            {
                NoAST *resultado = (NoAST *)malloc(sizeof(NoAST));
                if (!resultado) {
                    fprintf(stderr, "[DEBUG] interpretar: ERRO - falha ao alocar memória para resultado\n");
                    return NULL;
                }

                inicializarNo(resultado);
                resultado->tipoNo = NO_NUMERO;
                resultado->tipo = no->tipo;

                if (no->tipo == TIPO_INT) {
                    resultado->valor.intValue = no->valor.intValue;
                } else if (no->tipo == TIPO_REAL) {
                    resultado->valor.floatValue = no->valor.floatValue;
                } else if (no->tipo == TIPO_STRING && no->valor.strValue) {
                    resultado->valor.strValue = strdup(no->valor.strValue);
                }

                return resultado;
            }

        case NO_OPERACAO:
            {
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
                    liberarAST(valEsq);
                    liberarAST(valDir);
                    return NULL;
                }

                inicializarNo(resultado);
                resultado->tipoNo = NO_NUMERO;

                if (valEsq->tipo != valDir->tipo) {
                    if ((valEsq->tipo == TIPO_INT && valDir->tipo == TIPO_REAL) ||
                        (valEsq->tipo == TIPO_REAL && valDir->tipo == TIPO_INT)) {
                        NoAST *novoEsq = malloc(sizeof(NoAST));
                        NoAST *novoDir = malloc(sizeof(NoAST));
                        inicializarNo(novoEsq);
                        inicializarNo(novoDir);
                        novoEsq->tipoNo = NO_NUMERO;
                        novoDir->tipoNo = NO_NUMERO;
                        novoEsq->tipo = TIPO_REAL;
                        novoDir->tipo = TIPO_REAL;
                        novoEsq->valor.floatValue = (valEsq->tipo == TIPO_INT)
                            ? (float)valEsq->valor.intValue : valEsq->valor.floatValue;
                        novoDir->valor.floatValue = (valDir->tipo == TIPO_INT)
                            ? (float)valDir->valor.intValue : valDir->valor.floatValue;

                        liberarAST(valEsq);
                        liberarAST(valDir);
                        valEsq = novoEsq;
                        valDir = novoDir;
                        resultado->tipo = TIPO_REAL;
                    } else {
                        fprintf(stderr, "[DEBUG] interpretar: tipos incompatíveis - esq: %d, dir: %d\n",
                                valEsq->tipo, valDir->tipo);
                        free(resultado);
                        liberarAST(valEsq);
                        liberarAST(valDir);
                        return NULL;
                    }
                } else {
                    resultado->tipo = valEsq->tipo;
                }
                switch (no->operador) {
                    case '+':
                        if (resultado->tipo == TIPO_INT) {
                            resultado->valor.intValue = valEsq->valor.intValue + valDir->valor.intValue;
                        } else if (resultado->tipo == TIPO_REAL) {
                            resultado->valor.floatValue = valEsq->valor.floatValue + valDir->valor.floatValue;
                        } else {
                            fprintf(stderr, "Erro: Operação '+' não suportada para o tipo.\n");
                            free(resultado);
                            liberarAST(valEsq);
                            liberarAST(valDir);
                            return NULL;
                        }
                        break;
                    case '-':
                        if (resultado->tipo == TIPO_INT) {
                            resultado->valor.intValue = valEsq->valor.intValue - valDir->valor.intValue;
                        } else if (resultado->tipo == TIPO_REAL) {
                            resultado->valor.floatValue = valEsq->valor.floatValue - valDir->valor.floatValue;
                        } else {
                            fprintf(stderr, "Erro: Operação '-' não suportada para o tipo.\n");
                            free(resultado);
                            liberarAST(valEsq);
                            liberarAST(valDir);
                            return NULL;
                        }
                        break;
                    case '*':
                        if (resultado->tipo == TIPO_INT) {
                            resultado->valor.intValue = valEsq->valor.intValue * valDir->valor.intValue;
                        } else if (resultado->tipo == TIPO_REAL) {
                            resultado->valor.floatValue = valEsq->valor.floatValue * valDir->valor.floatValue;
                        } else {
                            fprintf(stderr, "Erro: Operação '*' não suportada para o tipo.\n");
                            free(resultado);
                            liberarAST(valEsq);
                            liberarAST(valDir);
                            return NULL;
                        }
                        break;
                    case '/':
                        if (resultado->tipo == TIPO_INT || resultado->tipo == TIPO_REAL) {
                            if ((valDir->tipo == TIPO_INT && valDir->valor.intValue == 0) ||
                                (valDir->tipo == TIPO_REAL && valDir->valor.floatValue == 0.0)) {
                                erro_semantico("Divisão por zero.");
                                free(resultado);
                                liberarAST(valEsq);
                                liberarAST(valDir);
                                return NULL;
                            }
                            if (resultado->tipo == TIPO_INT) {
                                resultado->valor.intValue = valEsq->valor.intValue / valDir->valor.intValue;
                            } else {
                                resultado->valor.floatValue = valEsq->valor.floatValue / valDir->valor.floatValue;
                            }
                        } else {
                            fprintf(stderr, "Erro: Operação '/' não suportada para o tipo.\n");
                            free(resultado);
                            liberarAST(valEsq);
                            liberarAST(valDir);
                            return NULL;
                        }
                        break;
                    case '%':
                        if (resultado->tipo == TIPO_INT || resultado->tipo == TIPO_REAL) {
                            if ((valDir->tipo == TIPO_INT && valDir->valor.intValue == 0) ||
                                (valDir->tipo == TIPO_REAL && valDir->valor.floatValue == 0.0f)) {
                            fprintf(stderr, "Erro: módulo por zero.\n");
                            free(resultado);
                            liberarAST(valEsq);
                            liberarAST(valDir);
                            return NULL;
                            }
                            if (resultado->tipo == TIPO_INT) {
                                resultado->valor.intValue = valEsq->valor.intValue % valDir->valor.intValue;
                            } else {
                                float a = valEsq->valor.floatValue;
                                float b = valDir->valor.floatValue;
                                float quociente = (int)(a / b);
                                resultado->valor.floatValue = a - (b * quociente);
                            }
                        } else {
                            fprintf(stderr, "Erro: Operação '%%' não suportada para o tipo.\n");
                            free(resultado);
                            liberarAST(valEsq);
                            liberarAST(valDir);
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
                        liberarAST(valEsq);
                        liberarAST(valDir);
                        return NULL;
                }

                liberarAST(valEsq);
                liberarAST(valDir);
                return resultado;
            }

        default:
            fprintf(stderr, "[DEBUG] interpretar: Tipo de nó não suportado para interpretação: %d\n", no->tipoNo);
            return NULL;
    }
}

void liberarAST(NoAST *no) {
    if (!no) {
        return;
    }

    if (no->esquerda) {
        liberarAST(no->esquerda);
    }

    if (no->direita) {
        liberarAST(no->direita);
    }

    if (no->condicao) {
        liberarAST(no->condicao);
    }

    if (no->bloco_then) {
        liberarAST(no->bloco_then);
    }

    if (no->bloco_else) {
        liberarAST(no->bloco_else);
    }

    if (no->bloco_body) {
        liberarAST(no->bloco_body);
    }

    if (no->proximo) {
        liberarAST(no->proximo);
    }

    if (no->nome) {
        free(no->nome);
    }

    if (no->tipo == TIPO_STRING && no->valor.strValue) {
        free(no->valor.strValue);
    }

    free(no);
}