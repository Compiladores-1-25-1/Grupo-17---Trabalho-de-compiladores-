%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tabela.h"
#include "ast.h"

int yylex(void);
void yyerror(const char *s);
void erro_semantico(const char *s);
#define MAX_NIVEL 100
int executando = 1;              /* flag corrente */
int exec_stack[MAX_NIVEL];       /* armazena flags pai */
int cond_stack[MAX_NIVEL];       /* armazena condição de cada if */
int exec_sp = 0;                 /* topo da pilha */
%}

%code requires {
#include "ast.h"
}

/* Declaração de precedência */
%right NOT_LOGICO NOT_BIT '~'     /* unários */
%left OR_LOGICO
%left AND_LOGICO

%nonassoc IGUAL DIFERENTE
%nonassoc MAIOR MAIOR_IGUAL MENOR MENOR_IGUAL
%nonassoc SENAO                   /* resolve dangling-else */
%left '|'
%left '^'
%left '&'
%left '+' '-'
%left '*' '/' MOD
%right UMINUS

/* Tokens e tipos associados */
%token SE ENTAO SENAO FIM_SE
%token ENQUANTO FACA IMPRIMA LEIA
%token OR_LOGICO AND_LOGICO NOT_LOGICO
%token OR_BIT AND_BIT XOR_BIT
%token IGUAL DIFERENTE MAIOR MAIOR_IGUAL MENOR MENOR_IGUAL
%token MOD NOT_BIT

%union {
    int    intValue;
    float  floatValue;
    char*  strValue;
    NoAST *no;
    Tipo   tipo;
}

/* Tokens com valores associados */
%token <intValue>    INTEIRO
%token <floatValue>  REAL
%token <strValue>    IDENTIFICADOR STRING CARACTERE

/* Tipos de regras */
%type <intValue>     expressao
%type <strValue>     expressao_string
%type <tipo>         tipo_var

%%

programa:
    lista_comandos
;

lista_comandos:
    lista_comandos comando
  | comando
;

tipo_var:
    INTEIRO { $$ = TIPO_INT; }
  | REAL    { $$ = TIPO_REAL; }
  | STRING  { $$ = TIPO_STRING; }
  | CARACTERE { $$ = TIPO_STRING; }
;

comando:
    tipo_var IDENTIFICADOR '\n' {
        if (buscarSimbolo($2)) yyerror("Redeclaracao de variavel");
        else inserirSimbolo($2, $1);
        free($2);
    }
  | IDENTIFICADOR '=' expressao '\n' {
        Simbolo *s = buscarSimbolo($1);
        if (!s) {
            yyerror("ID nao declarado");
        } else {
            if (s->tipo == TIPO_INT) s->valor.intValue = $3;
            else if (s->tipo == TIPO_REAL) s->valor.floatValue = $3;
            else yyerror("Atribuicao invalida a tipo nao suportado.");
        }
        free($1);
    }
  | IDENTIFICADOR '=' expressao_string '\n' {
        Simbolo *s = buscarSimbolo($1);
        if (!s) {
            yyerror("ID nao declarado");
        } else if (s->tipo == TIPO_STRING) {
            if (s->valor.strValue) free(s->valor.strValue);
            s->valor.strValue = strdup($3);
        } else {
            yyerror("Atribuicao de string a tipo nao string");
        }
        free($1);
        free($3);
    }
  | IMPRIMA expressao '\n' {
        if (executando) printf("%d\n", $2);
    }
  | IMPRIMA expressao_string '\n' {
        if (executando) printf("%s\n", $2);
        free($2);
    }
  | IMPRIMA IDENTIFICADOR '\n' {
        if (executando) {
            Simbolo *s = buscarSimbolo($2);
            if (!s) {
                yyerror("Erro: Variavel nao declarada.");
            } else if (s->tipo == TIPO_INT) {
                printf("%d\n", s->valor.intValue);
            } else if (s->tipo == TIPO_REAL) {
                printf("%f\n", s->valor.floatValue);
            } else if (s->tipo == TIPO_STRING) {
                printf("%s\n", s->valor.strValue);
            }
        }
        free($2);
    }
  | IMPRIMA '(' STRING ')' '\n' {
        if (executando) printf("%s\n", $3);
        free($3);
    }
  | LEIA IDENTIFICADOR '\n' {
        Simbolo *s = buscarSimbolo($2);
        if (!s) {
            yyerror("Erro: Variavel nao declarada.");
        } else if (s->tipo == TIPO_INT) {
            printf("Digite um valor inteiro para %s: ", s->nome);
            scanf("%d", &s->valor.intValue);
        } else if (s->tipo == TIPO_REAL) {
            printf("Digite um valor real para %s: ", s->nome);
            scanf("%f", &s->valor.floatValue);
        } else if (s->tipo == TIPO_STRING) {
          printf("Digite um valor string para %s: ", s->nome);
          s->valor.strValue = malloc(256);  // aloca memória
          if (!s->valor.strValue) {
              yyerror("Erro ao alocar memória para string.");
          } else {
              scanf("%255s", s->valor.strValue);  // limita a entrada
          }
        }
        free($2);
    }
  | SE expressao ENTAO '\n'{
        exec_stack[exec_sp] = executando;
        cond_stack[exec_sp] = $2;
        executando = executando && $2;
        exec_sp++;
    }
    lista_comandos comando_fim
  | ENQUANTO expressao FACA lista_comandos FIM_SE 
;

comando_fim:
    /* ELSE */
    SENAO '\n'{
        exec_sp--;
        executando = exec_stack[exec_sp] && !cond_stack[exec_sp];
        exec_stack[exec_sp] = exec_stack[exec_sp];
        exec_sp++;
    }
    lista_comandos FIM_SE '\n'{
        exec_sp--;
        executando = exec_stack[exec_sp];
    }

  | FIM_SE '\n'{
        exec_sp--;
        executando = exec_stack[exec_sp];
    }
;

expressao:
    expressao '+' expressao         { $$ = $1 + $3; }
  | expressao '-' expressao         { $$ = $1 - $3; }
  | expressao '*' expressao         { $$ = $1 * $3; }
  | expressao '/' expressao {
        if ($3 == 0) {
            erro_semantico("Divisao por zero!");
            $$ = -1;
        } else {
            $$ = $1 / $3;
        }
    }
  | expressao MOD expressao         { $$ = $1 % $3; }
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
  | INTEIRO                         { $$ = $1; }
  | REAL                            { $$ = $1; }
  | '(' expressao ')'               { $$ = $2; }
  | IDENTIFICADOR {
        Simbolo *s = buscarSimbolo($1);
        if (!s) {
            yyerror("Variavel nao declarada.");
            $$ = 0;
        } else if (s->tipo == TIPO_INT) {
            $$ = s->valor.intValue;
        } else if (s->tipo == TIPO_REAL) {
            $$ = s->valor.floatValue;
        } else {
            yyerror("Tipo nao suportado em expressao.");
            $$ = 0;
        }
        free($1);
    }
;

expressao_string:
    STRING { $$ = strdup($1); }
  | IDENTIFICADOR {
        Simbolo *s = buscarSimbolo($1);
        if (!s) {
            yyerror("Variavel nao declarada.");
            $$ = strdup("");
        } else if (s->tipo == TIPO_STRING) {
            $$ = strdup(s->valor.strValue);
        } else {
            yyerror("Tipo nao string em expressao string.");
            $$ = strdup("");
        }
        free($1);
    }
;

%%

extern int yylineno;
extern char *yytext;

void yyerror(const char *s) {
    fprintf(stderr, "\033[31mErro sintatico\033[0m na linha %d, proximo de '%s': %s\n", yylineno, yytext, s);
}

void erro_semantico(const char *s) {
    fprintf(stderr, "\033[33m[Erro semantico]\033[0m na linha %d: %s\n", yylineno, s);
    exit(1);
}