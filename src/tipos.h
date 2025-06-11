// tipos.h
#ifndef TIPOS_H
#define TIPOS_H

typedef enum {
    TIPO_INT,
    TIPO_REAL,
    TIPO_STRING,
    TIPO_ERRO
} Tipo;

typedef struct NoAST {
    char operador;
    Tipo tipo;
    union {
        int intValue;
        float floatValue;
        char *strValue;
    } valor;
    char *nome;
    struct NoAST *esquerda;
    struct NoAST *direita;
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