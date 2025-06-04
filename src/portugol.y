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
int executando = 1;
int exec_stack[MAX_NIVEL];
int cond_stack[MAX_NIVEL];
int exec_sp = 0;
%}

%code requires {
#include "ast.h"
}

%right NOT_LOGICO NOT_BIT '~'
%left OR_LOGICO
%left AND_LOGICO
%nonassoc IGUAL DIFERENTE
%nonassoc MAIOR MAIOR_IGUAL MENOR MENOR_IGUAL
%nonassoc SENAO
%left '|'
%left '^'
%left '&'
%left '+' '-'
%left '*' '/' MOD
%right UMINUS

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

%token <intValue>    INTEIRO
%token <floatValue>  REAL
%token <strValue>    IDENTIFICADOR STRING CARACTERE

%type <no>           expressao
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
            if (s->tipo == TIPO_INT) s->valor.intValue = $3->valor;
            else if (s->tipo == TIPO_REAL) s->valor.floatValue = $3->valor;
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
<<<<<<< HEAD
  | IMPRIMA expressao '\n' {
        if (executando) printf("%d\n", $2);
=======
  | IMPRIMA expressao ';' {
        if (executando) imprimirAST($2);
>>>>>>> a8d67ae (implementação inicial da AST no arquivo do FLEX)
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
          s->valor.strValue = malloc(256);
          if (!s->valor.strValue) {
              yyerror("Erro ao alocar memoria para string.");
          } else {
              scanf("%255s", s->valor.strValue);
          }
        }
        free($2);
    }
  | SE expressao ENTAO '\n'{
        exec_stack[exec_sp] = executando;
        cond_stack[exec_sp] = $2->valor;
        executando = executando && $2->valor;
        exec_sp++;
    }
    lista_comandos comando_fim
  | ENQUANTO expressao FACA lista_comandos FIM_SE 
;

comando_fim:
<<<<<<< HEAD
    /* ELSE */
    SENAO '\n'{
=======
    SENAO {
>>>>>>> a8d67ae (implementação inicial da AST no arquivo do FLEX)
        exec_sp--;
        executando = exec_stack[exec_sp] && !cond_stack[exec_sp];
        exec_stack[exec_sp] = exec_stack[exec_sp];
        exec_sp++;
    }
    lista_comandos FIM_SE '\n'{
        exec_sp--;
        executando = exec_stack[exec_sp];
    }
<<<<<<< HEAD

  | FIM_SE '\n'{
=======
  | FIM_SE {
>>>>>>> a8d67ae (implementação inicial da AST no arquivo do FLEX)
        exec_sp--;
        executando = exec_stack[exec_sp];
    }
;

expressao:
    expressao '+' expressao         { $$ = criarNoOp('+', $1, $3); }
  | expressao '-' expressao         { $$ = criarNoOp('-', $1, $3); }
  | expressao '*' expressao         { $$ = criarNoOp('*', $1, $3); }
  | expressao '/' expressao         { $$ = criarNoOp('/', $1, $3); }
  | INTEIRO                         { $$ = criarNoNum($1); }
  | IDENTIFICADOR {
        Simbolo *s = buscarSimbolo($1);
        if (!s) {
            yyerror("Variavel nao declarada.");
            $$ = criarNoNum(0);
        } else {
            $$ = criarNoId($1, s->tipo);
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
