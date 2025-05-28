%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tabela.h"
#include "ast.h"

int yylex(void);
void yyerror(const char *s);
int variavel_declarada(char *nome);
int obter_valor_variavel(char *nome);
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
%token <intValue>    NUM_INT INTEIRO
%token <floatValue>  NUM_REAL REAL
%token <strValue>    IDENTIFICADOR STRING

/* Tipos de regras */
%type <intValue>     expressao
%type <no>           expr stmt
%type <tipo> tipo_var

%%

programa:
    lista_comandos
  | input
;

lista_comandos:
    lista_comandos comando
  | comando
;

tipo_var:
    INTEIRO { $$ = TIPO_INT; }
  | REAL    { $$ = TIPO_REAL; }
  | STRING  { $$ = TIPO_STRING; }
;


comando:
    /* IF com ou sem ELSE */
    SE expressao ENTAO {
        exec_stack[exec_sp] = executando;
        cond_stack[exec_sp] = $2;
        executando = executando && $2;
        exec_sp++;
    }
    lista_comandos comando_fim

  | ENQUANTO expressao FACA lista_comandos FIM_SE

  | IMPRIMA expressao ';' {
        if (executando) printf("%d\n", $2);
    }

  | IMPRIMA '(' STRING ')' ';' {
        if (executando) printf("%s\n", $3);
        free($3);
    }

  | LEIA IDENTIFICADOR ';' {
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
;

comando_fim:
    /* ELSE */
    SENAO {
        exec_sp--;
        executando = exec_stack[exec_sp] && !cond_stack[exec_sp];
        exec_stack[exec_sp] = exec_stack[exec_sp];
        exec_sp++;
    }
    lista_comandos FIM_SE {
        exec_sp--;
        executando = exec_stack[exec_sp];
    }

  | FIM_SE {
        exec_sp--;
        executando = exec_stack[exec_sp];
    }
;


expressao:
    NUM_INT                         { $$ = $1; }
  | NUM_REAL                        { $$ = $1; }
  | expressao '+' expressao         { $$ = $1 + $3; }
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

  | '(' expressao ')'               { $$ = $2; }
;

input:
    /* vazio */
  | input stmt '\n'
  | input stmt
;

stmt:
    tipo_var IDENTIFICADOR {
        if (buscarSimbolo($2)) yyerror("Redeclaracao de variavel");
        else inserirSimbolo($2, $1);
        $$ = NULL;
    }
  | IDENTIFICADOR '=' expr {
        Simbolo *s = buscarSimbolo($1);
        if (!s) {
            yyerror("ID nao declarado");
            $$ = criarNoNum(0);
        } else {
            $$ = criarNoOp('=', criarNoId($1, s->tipo), $3);
        }
        printf("\nAST: ");
        imprimirAST($$);
    }

  | expr {
        $$ = $1;
        printf("\nAST: ");
        imprimirAST($$);
    }
;

expr:
    expr '+' expr {
        if (!tiposCompativeis($1->tipo, $3->tipo))
            yyerror("Tipos incompativeis para '+'");
        $$ = criarNoOp('+', $1, $3);
    }

  | expr '-' expr {
        if (!tiposCompativeis($1->tipo, $3->tipo))
            yyerror("Tipos incompativeis para '-'");
        $$ = criarNoOp('-', $1, $3);
    }

  | NUM_INT { $$ = criarNoNum($1); }
  | NUM_REAL { $$ = criarNoNum($1); }

  | IDENTIFICADOR {
        Simbolo *s = buscarSimbolo($1);
        if (!s) {
            yyerror("ID nao declarado");
            $$ = criarNoNum(0);
        } else {
            $$ = criarNoId($1, s->tipo);
        }
    }
;


%%

extern int yylineno;
extern char *yytext;

void yyerror(const char *s) {
    fprintf(stderr, "\033[31mErro sintatico\033[0m na linha %d, proximo de '%s': %s\n", yylineno, yytext, s);
}

int variavel_declarada(char *nome) {
    return 0;
}

int obter_valor_variavel(char *nome) {
    return 0;
}

void erro_semantico(const char *s) {
    fprintf(stderr, "\033[33m[Erro semantico]\033[0m na linha %d: %s\n", yylineno, s);
    exit(1);
}