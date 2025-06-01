#ifndef TIPOS_H
#define TIPOS_H

typedef enum { TIPO_INT, TIPO_REAL, TIPO_STRING, TIPO_ERRO } Tipo;

typedef struct noAST {
    char operador;
    int valor;
    char nome[32];
    Tipo tipo;
    struct noAST *esquerda;
    struct noAST *direita;
} NoAST;

typedef struct simbolo {
    char *nome;        
    Tipo tipo;
    union {
        int intValue;
        float floatValue;
        char* strValue;
    } valor;        
    struct simbolo *proximo; 
} Simbolo;
#endif
