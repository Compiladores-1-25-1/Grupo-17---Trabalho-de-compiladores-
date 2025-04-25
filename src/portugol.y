%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);
#define MAX_NIVEL 100
int executando = 1;              /* flag corrente */
int exec_stack[MAX_NIVEL];       /* armazena flags pai */
int cond_stack[MAX_NIVEL];       /* armazena condição de cada if */
int exec_sp = 0;                 /* topo da pilha */
%}

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
%token ENQUANTO FACA IMPRIMA LEIA INTEIRO REAL
%token OR_LOGICO AND_LOGICO NOT_LOGICO
%token OR_BIT AND_BIT XOR_BIT
%token IGUAL DIFERENTE MAIOR MAIOR_IGUAL MENOR MENOR_IGUAL
%token MOD NOT_BIT

%union {
    int    intValue;
    float  floatValue;
    char*  strValue;
}

%token <intValue>    NUM_INT
%token <floatValue>  NUM_REAL
%token <strValue>    STRING IDENTIFICADOR

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
    /* if (sem ou com else) */
    SE expressao ENTAO
      {
        /* push no estado */
        exec_stack[exec_sp] = executando;
        cond_stack[exec_sp] = $2;
        executando = executando && $2;
        exec_sp++;
      }
    lista_comandos
    comando_fim
  | ENQUANTO expressao FACA lista_comandos
  | IMPRIMA expressao ';'
      {
        if (executando) printf("%d\n", $2);
      }
  | IMPRIMA '(' STRING ')' ';'
      {
        if (executando) printf("%s\n", $3);
        free($3);
      }
  | LEIA IDENTIFICADOR ';'
  | declaracao
  | atribuicao
  ;

comando_fim:
    /* — ramo COM ELSE — */
    SENAO
      {

       /* sai do then */
       exec_sp--;
       /* calcula flag para o else (pai && !cond) */
       {
         int pai  = exec_stack[exec_sp];
         int cond = cond_stack[exec_sp];
         executando = pai && !cond;
       }
       /* empilha de novo o estado pai para o pop final */
       exec_stack[exec_sp] = exec_stack[exec_sp];
       exec_sp++;
      }
    lista_comandos FIM_SE
      {

       /* pop final após o bloco else */
       exec_sp--;
       executando = exec_stack[exec_sp];
      }
  | /* — ramo SEM ELSE — */
    FIM_SE
      {
       /* pop e restaura flag pai */
       exec_sp--;
       executando = exec_stack[exec_sp];
      }
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
  | NUM_REAL                        { $$ = $1; }
  | IDENTIFICADOR                   { $$ = 0; /* valor fictício */ }
  | expressao '+' expressao         { $$ = $1 + $3; }
  | expressao '-' expressao         { $$ = $1 - $3; }
  | expressao '*' expressao         { $$ = $1 * $3; }
  | expressao '/' expressao
      {
        if ($3 == 0) {
          yyerror("Divisão por zero!");
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

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro sintático: '%s'\n", s);
}
