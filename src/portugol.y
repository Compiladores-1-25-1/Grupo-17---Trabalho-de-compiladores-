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

typedef struct {
    int tipo;
    union {
        int intValue;
        float floatValue;
    };
} Expressao;
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
    Expressao expr;
}

%token <intValue>    NUM_INT
%token <floatValue>  NUM_REAL
%token <strValue>    STRING IDENTIFICADOR

%type <expr> expressao

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
            yyerror("Erro: Variável não declarada.");
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
              yyerror("Erro: Variável já declarada.");
          } else {
              inserirSimbolo($2, TIPO_INT);  
          }
      }
  | REAL IDENTIFICADOR ';'
  {
          if (buscarSimbolo($2)) {
              yyerror("Erro: Variável já declarada.");
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
            yyerror("Erro: Variável não declarada.");
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
    NUM_INT {
        $$.tipo = TIPO_INT;
        $$.intValue = $1;
    }
  | NUM_REAL {
        $$.tipo = TIPO_REAL;
        $$.floatValue = $1;
    }
  | IDENTIFICADOR {
        Simbolo *s = buscarSimbolo($1);
        if (!s) {
            char msg[128];
            sprintf(msg, "Variável '%s' não declarada.", $1);
            erro_semantico(msg);
        }
        $$.tipo = s->tipo;
        if (s->tipo == TIPO_INT) {
            $$.intValue = s->valor.intValue;
        } else {
            $$.floatValue = s->valor.floatValue;
        }
        free($1);
    }
  | expressao '+' expressao {
        if ($1.tipo == TIPO_REAL || $3.tipo == TIPO_REAL) {
            $$.tipo = TIPO_REAL;
            float v1 = ($1.tipo == TIPO_REAL) ? $1.floatValue : $1.intValue;
            float v2 = ($3.tipo == TIPO_REAL) ? $3.floatValue : $3.intValue;
            $$.floatValue = v1 + v2;
        } else {
            $$.tipo = TIPO_INT;
            $$.intValue = $1.intValue + $3.intValue;
        }
    }
  | expressao '-' expressao {
        if ($1.tipo == TIPO_REAL || $3.tipo == TIPO_REAL) {
            $$.tipo = TIPO_REAL;
            float v1 = ($1.tipo == TIPO_REAL) ? $1.floatValue : $1.intValue;
            float v2 = ($3.tipo == TIPO_REAL) ? $3.floatValue : $3.intValue;
            $$.floatValue = v1 - v2;
        } else {
            $$.tipo = TIPO_INT;
            $$.intValue = $1.intValue - $3.intValue;
        }
    }
  | expressao '*' expressao {
        if ($1.tipo == TIPO_REAL || $3.tipo == TIPO_REAL) {
            $$.tipo = TIPO_REAL;
            float v1 = ($1.tipo == TIPO_REAL) ? $1.floatValue : $1.intValue;
            float v2 = ($3.tipo == TIPO_REAL) ? $3.floatValue : $3.intValue;
            $$.floatValue = v1 * v2;
        } else {
            $$.tipo = TIPO_INT;
            $$.intValue = $1.intValue * $3.intValue;
        }
    }
  | expressao '/' expressao {
        float v2 = ($3.tipo == TIPO_REAL) ? $3.floatValue : $3.intValue;
        if (v2 == 0) {
            erro_semantico("Divisão por zero!");
        }
        $$.tipo = TIPO_REAL;
        float v1 = ($1.tipo == TIPO_REAL) ? $1.floatValue : $1.intValue;
        $$.floatValue = v1 / v2;
    }
  | expressao MOD expressao {
        if ($1.tipo != TIPO_INT || $3.tipo != TIPO_INT) {
            erro_semantico("Operador MOD requer operandos inteiros.");
        }
        $$.tipo = TIPO_INT;
        $$.intValue = $1.intValue % $3.intValue;
    }
  | expressao IGUAL expressao {
        $$.tipo = TIPO_INT;
        if ($1.tipo == TIPO_REAL || $3.tipo == TIPO_REAL) {
            float v1 = ($1.tipo == TIPO_REAL) ? $1.floatValue : $1.intValue;
            float v2 = ($3.tipo == TIPO_REAL) ? $3.floatValue : $3.intValue;
            $$.intValue = (v1 == v2);
        } else {
            $$.intValue = ($1.intValue == $3.intValue);
        }
    }
  | expressao DIFERENTE expressao {
        $$.tipo = TIPO_INT;
        if ($1.tipo == TIPO_REAL || $3.tipo == TIPO_REAL) {
            float v1 = ($1.tipo == TIPO_REAL) ? $1.floatValue : $1.intValue;
            float v2 = ($3.tipo == TIPO_REAL) ? $3.floatValue : $3.intValue;
            $$.intValue = (v1 != v2);
        } else {
            $$.intValue = ($1.intValue != $3.intValue);
        }
    }
  | expressao MAIOR expressao {
        $$.tipo = TIPO_INT;
        if ($1.tipo == TIPO_REAL || $3.tipo == TIPO_REAL) {
            float v1 = ($1.tipo == TIPO_REAL) ? $1.floatValue : $1.intValue;
            float v2 = ($3.tipo == TIPO_REAL) ? $3.floatValue : $3.intValue;
            $$.intValue = (v1 > v2);
        } else {
            $$.intValue = ($1.intValue > $3.intValue);
        }
    }
  | expressao MENOR expressao {
        $$.tipo = TIPO_INT;
        if ($1.tipo == TIPO_REAL || $3.tipo == TIPO_REAL) {
            float v1 = ($1.tipo == TIPO_REAL) ? $1.floatValue : $1.intValue;
            float v2 = ($3.tipo == TIPO_REAL) ? $3.floatValue : $3.intValue;
            $$.intValue = (v1 < v2);
        } else {
            $$.intValue = ($1.intValue < $3.intValue);
        }
    }
  | expressao MAIOR_IGUAL expressao {
        $$.tipo = TIPO_INT;
        if ($1.tipo == TIPO_REAL || $3.tipo == TIPO_REAL) {
            float v1 = ($1.tipo == TIPO_REAL) ? $1.floatValue : $1.intValue;
            float v2 = ($3.tipo == TIPO_REAL) ? $3.floatValue : $3.intValue;
            $$.intValue = (v1 >= v2);
        } else {
            $$.intValue = ($1.intValue >= $3.intValue);
        }
    }
  | expressao MENOR_IGUAL expressao {
        $$.tipo = TIPO_INT;
        if ($1.tipo == TIPO_REAL || $3.tipo == TIPO_REAL) {
            float v1 = ($1.tipo == TIPO_REAL) ? $1.floatValue : $1.intValue;
            float v2 = ($3.tipo == TIPO_REAL) ? $3.floatValue : $3.intValue;
            $$.intValue = (v1 <= v2);
        } else {
            $$.intValue = ($1.intValue <= $3.intValue);
        }
    }
  | expressao OR_LOGICO expressao {
        $$.tipo = TIPO_INT;
        $$.intValue = valor_logico($1) || valor_logico($3);
    }
  | expressao AND_LOGICO expressao {
        $$.tipo = TIPO_INT;
        $$.intValue = valor_logico($1) && valor_logico($3);
    }
  | NOT_LOGICO expressao {
        $$.tipo = TIPO_INT;
        $$.intValue = !valor_logico($2);
    }
  | expressao '|' expressao {
        if ($1.tipo != TIPO_INT || $3.tipo != TIPO_INT) {
            erro_semantico("Operação bit a bit requer inteiros.");
        }
        $$.tipo = TIPO_INT;
        $$.intValue = $1.intValue | $3.intValue;
    }
  | expressao '&' expressao {
        if ($1.tipo != TIPO_INT || $3.tipo != TIPO_INT) {
            erro_semantico("Operação bit a bit requer inteiros.");
        }
        $$.tipo = TIPO_INT;
        $$.intValue = $1.intValue & $3.intValue;
    }
  | expressao '^' expressao {
        if ($1.tipo != TIPO_INT || $3.tipo != TIPO_INT) {
            erro_semantico("Operação bit a bit requer inteiros.");
        }
        $$.tipo = TIPO_INT;
        $$.intValue = $1.intValue ^ $3.intValue;
    }
  | NOT_BIT expressao {
        if ($2.tipo != TIPO_INT) {
            erro_semantico("Operação bit a bit requer inteiro.");
        }
        $$.tipo = TIPO_INT;
        $$.intValue = ~$2.intValue;
    }
  | '-' expressao %prec UMINUS {
        if ($2.tipo == TIPO_INT) {
            $$.tipo = TIPO_INT;
            $$.intValue = -$2.intValue;
        } else {
            $$.tipo = TIPO_REAL;
            $$.floatValue = -$2.floatValue;
        }
    }
  | '(' expressao ')' {
        $$ = $2;
    }
  ;

%%

extern int yylineno;
extern char *yytext;

int valor_logico(Expressao e) {
    return (e.tipo == TIPO_REAL) ? e.floatValue != 0.0 : e.intValue != 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "\033[31mErro sintático\033[0m na linha %d, próximo de '%s': %s\n", yylineno, yytext, s);
}

int variavel_declarada(char *nome) {
    return 0;
}

int obter_valor_variavel(char *nome) {
    return 0;
}

void erro_semantico(const char *s) {
    fprintf(stderr, "\033[33m[Erro semântico]\033[0m na linha %d: %s\n", yylineno, s);
    exit(1);
}