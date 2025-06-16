// tipos.h
#ifndef TIPOS_H
#define TIPOS_H

typedef enum {
    TIPO_INT,
    TIPO_REAL,
    TIPO_STRING,
    TIPO_ERRO
} Tipo;

// Tipos de nós da AST
typedef enum {
    NO_OPERACAO,        
    NO_NUMERO,
    NO_IDENTIFICADOR,
    NO_IF,
    NO_WHILE,
    NO_IMPRIMA,
    NO_LEIA,
    NO_ATRIBUICAO,
    NO_BLOCO,
    NO_DECLARACAO
} TipoNo;

typedef struct NoAST {
    TipoNo tipoNo;      // Tipo do nó
    char operador;      // Para operações aritméticas/lógicas
    Tipo tipo;          // Tipo do dado
    union {
        int intValue;
        float floatValue;
        char *strValue;
    } valor;
    char *nome;         // Para identificadores
    struct NoAST *esquerda;
    struct NoAST *direita;
    struct NoAST *condicao;
    struct NoAST *bloco_then;
    struct NoAST *bloco_else;
    struct NoAST *bloco_body;
    struct NoAST *proximo;
} NoAST;

typedef struct Simbolo {
    char *nome;
    Tipo tipo;
    union {
        int intValue;
        float floatValue;
        char *strValue;
    } valor;
    struct Simbolo *proximo;
} Simbolo;

#endif