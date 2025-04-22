%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);
%}

/* Declaração de precedência */
%left '+' '-'
%left '*' '/'
%right UMINUS  /* para tratar expressões com sinal negativo */

/* Tokens com tipos associados */
%token SE SENAO ENTAO FIM_SE
%token ENQUANTO FACA
%token IMPRIMA LEIA
%token INTEIRO REAL

%union {
    int intValue;
    float floatValue;
    char* strValue;
}

%token <intValue> NUM_INT 
%token <floatValue> NUM_REAL
%token <strValue> STRING IDENTIFICADOR

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
    | IMPRIMA expressao ';' { printf("%d\n", $2); }
    | IMPRIMA '(' STRING ')' ';' { printf("%s\n", $3); free($3); }
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
    | '-' expressao %prec UMINUS      { $$ = -$2; }
    | '(' expressao ')'               { $$ = $2; }
    ;

%%

extern char* yytext;

void yyerror(const char *s) {
    fprintf(stderr, "Erro sintático: %s próximo de '%s'\n", s, yytext);
}
