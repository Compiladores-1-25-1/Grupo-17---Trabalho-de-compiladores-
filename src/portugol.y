%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);
%}

/* Declaração de precedência */
%right NOT_LOGICO NOT_BIT '~' /* mais alta: unários */
%left OR_LOGICO
%left AND_LOGICO
%nonassoc IGUAL DIFERENTE
%nonassoc MAIOR MAIOR_IGUAL MENOR MENOR_IGUAL
%left '|'
%left '^'
%left '&'
%left '+' '-'
%left '*' '/' MOD
%right UMINUS

/* Tokens com tipos associados */
%token SE ENTAO SENAO FIM_SE 
%token ENQUANTO FACA
%token IMPRIMA LEIA
%token INTEIRO REAL
%token OR_LOGICO AND_LOGICO NOT_LOGICO
%token OR_BIT AND_BIT XOR_BIT
%token IGUAL DIFERENTE MAIOR MAIOR_IGUAL MENOR MENOR_IGUAL
%token MOD
%token NOT_BIT

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
                $$ = -1;
            } else {
                $$ = $1 / $3;
            }
        }
    | expressao MOD expressao         {$$ = $1 % $3; }
    | expressao IGUAL expressao       { $$ = $1 == $3; }
    | expressao DIFERENTE expressao   { $$ = $1 != $3; }
    | expressao MAIOR expressao       { $$ = $1 > $3; }
    | expressao MENOR expressao       { $$ = $1 < $3; }
    | expressao MAIOR_IGUAL expressao { $$ = $1 >= $3; }
    | expressao MENOR_IGUAL expressao { $$ = $1 <= $3; }
    | expressao OR_LOGICO expressao   { $$ = $1 || $3; }
    | expressao AND_LOGICO expressao  { $$ = $1 && $3; }
    | NOT_LOGICO expressao            { $$ = !$2; }
    | expressao '|' expressao         { $$ = $1 | $3; }
    | expressao '&' expressao         { $$ = $1 & $3; }
    | expressao '^' expressao         { $$ = $1 ^ $3; }
    | NOT_BIT expressao               { $$ = ~$2; }
    | '+' expressao                   { $$ = $2; }
    | '-' expressao %prec UMINUS      { $$ = -$2; }
    | '(' expressao ')'               { $$ = $2; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro sintático: '%s'\n", s);
}
