%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);
%}

/* Tokens com tipos associados */
%token SE SENAO ENTAO FIM_SE
%token ENQUANTO FACA
%token IMPRIMA LEIA
%token INTEIRO REAL

%token <intValue> NUM_INT NUM_REAL
%token <strValue> STRING IDENTIFICADOR

%union {
    int intValue;
    char* strValue;
}

%type <intValue> expressao

%%

programa:
    lista_comandos
    ;

lista_comandos:
    lista_comandos comando
    | comando
    ;

comando:
    SE expressao ENTAO lista_comandos FIM_SE
    | SE expressao ENTAO lista_comandos SENAO lista_comandos FIM_SE
    | ENQUANTO expressao FACA lista_comandos
    | IMPRIMA expressao ';'
    | IMPRIMA '(' STRING ')' ';'
    | LEIA IDENTIFICADOR ';'
    | declaracao
    | atribuicao
    ;

declaracao:
    INTEIRO IDENTIFICADOR ';'
    | REAL IDENTIFICADOR ';'
    ;

atribuicao:
    IDENTIFICADOR '=' expressao ';'
    ;

expressao:
    NUM_INT                         { $$ = $1; }
    | NUM_REAL                      { $$ = $1; }
    | IDENTIFICADOR                 { $$ = 0; /* valor fictício */ }
    | expressao '+' expressao       { $$ = $1 + $3; }
    | expressao '-' expressao       { $$ = $1 - $3; }
    | expressao '*' expressao       { $$ = $1 * $3; }
    | expressao '/' expressao
        {
            if ($3 == 0) {
                yyerror("Divisão por zero!");
                $$ = 0;
            } else {
                $$ = $1 / $3;
            }
        }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro sintático: %s\n", s);
}
