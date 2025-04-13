%{
#include <stdio.h>
#include <stdlib.h>

/* Declarações explícitas para evitar warnings de funções não declaradas */
int yylex(void);
void yyerror(const char *s);

%}

/* Definições de tokens */
%token NUM SE SENAO ENTAO FIM_SE ENQUANTO FACHA IMPRIMA LEIA

%union {
    int intValue;  /* Para armazenar valores numéricos */
}

%type <intValue> NUM

%%

/* A gramática para o interpretador de Portugol */
programa:
    lista_comandos
    ;

lista_comandos:
      lista_comandos comando { /* Executar o comando */ }
    | comando
    ;

comando:
      SE expressao ENTAO lista_comandos FIM_SE   { printf("Comando Condicional: Se-Entao-Senao\n"); }
    | ENQUANTO expressao FACHA lista_comandos   { printf("Comando de Repetição: Enquanto-Faca\n"); }
    | IMPRIMA expressao                         { printf("Comando Imprimir\n"); }
    | LEIA variavel                             { printf("Comando Leia\n"); }
    ;

expressao:
      NUM                                     { $$ = $1; }
    | expressao '+' expressao                 { $$ = $1 + $3; }
    | expressao '-' expressao                 { $$ = $1 - $3; }
    ;

variavel:
      'x'                                     { $$ = 10; }  /* Exemplo simplificado */
    ;

%%

/* Definição de yyerror */
void yyerror(const char *s) {
    fprintf(stderr, "Erro sintático: %s\n", s);
}
