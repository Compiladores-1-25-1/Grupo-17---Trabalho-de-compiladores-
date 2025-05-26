%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tabela.h"

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
  | ENQUANTO expressao FACA lista_comandos FIM_SE
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
    {
        Simbolo *s = buscarSimbolo($2);
        if (!s) {
            yyerror("Erro: Variavel nao declarada.");
        } else {
            if (s->tipo == TIPO_INT) {
                printf("Digite um valor inteiro para %s: ", s->nome);
                scanf("%d", &s->valor.intValue);
            } else if (s->tipo == TIPO_REAL) {
                printf("Digite um valor real para %s: ", s->nome);
                scanf("%f", &s->valor.floatValue);
            }
        }
        free($2);
    }
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
     {
          if (buscarSimbolo($2)) {
              yyerror("Erro: Variavel ja declarada.");
          } else {
              inserirSimbolo($2, TIPO_INT);  
          }
      }
  | REAL IDENTIFICADOR ';'
  {
          if (buscarSimbolo($2)) {
              yyerror("Erro: Variavel ja declarada.");
          } else {
              inserirSimbolo($2, TIPO_REAL);  // Insere a variável na tabela com tipo real
          }
      }
  ;

atribuicao:
    IDENTIFICADOR '=' expressao ';'
    {
          Simbolo *s = buscarSimbolo($1);
          if (!s) {
            yyerror("Erro: Variavel nao declarada.");
          } else {
            if (s->tipo == TIPO_INT) {
              s->valor.intValue = $3;
            } else if (s->tipo == TIPO_REAL) {
              s->valor.floatValue = (float) $3;
            }
          }
        free($1);
      }
  ;

expressao:
    NUM_INT                         { $$ = $1; }
  | NUM_REAL                        { $$ = $1; }
  | IDENTIFICADOR {
      if (!variavel_declarada($1)) {
          char mensagem[256];
          sprintf(mensagem, "Variavel '%s' nao declarada.", $1);
          erro_semantico(mensagem);
      }
      $$ = obter_valor_variavel($1);
  }
  | expressao '+' expressao         { $$ = $1 + $3; }
  | expressao '-' expressao         { $$ = $1 - $3; }
  | expressao '*' expressao         { $$ = $1 * $3; }
  | expressao '/' expressao
      {
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