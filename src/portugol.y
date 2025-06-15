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
        if (buscarSimbolo($2)) {
            erro_semantico("Redeclaracao de variavel");
        } else {
            inserirSimbolo($2, $1);
        }
        free($2);
    }
  | IDENTIFICADOR '=' expressao '\n' {
        Simbolo *s = buscarSimbolo($1);
        if (!s) {
            erro_semantico("ID nao declarado");
            liberarAST($3);
        } else {
            NoAST* resultado = interpretar($3);
            if(!resultado) {
                erro_semantico("Erro na interpretação");
                liberarAST($3);
            } else {
                if (s->tipo == resultado->tipo) {
                    switch (s->tipo) {
                        case TIPO_INT:
                            s->valor.intValue = resultado->valor.intValue;
                            break;
                        case TIPO_REAL:
                            s->valor.floatValue = resultado->valor.floatValue;
                            break;
                        default:
                            erro_semantico("Atribuicao invalida a tipo nao suportado.");
                            break;
                    }
                    liberarAST(resultado);
                } else {
                    erro_semantico("Tipos incompativeis na atribuicao.");
                    liberarAST(resultado);
                }
            }
        }
        free($1);
    }
  | IDENTIFICADOR '=' expressao_string '\n' {
        Simbolo *s = buscarSimbolo($1);
        if (!s) {
            erro_semantico("ID nao declarado");
            free($3);
        } else if (s->tipo == TIPO_STRING) {
            if (s->valor.strValue) free(s->valor.strValue);
            s->valor.strValue = strdup($3);
            free($3);
        } else {
            erro_semantico("Atribuicao de string a tipo nao string");
            free($3);
        }
        free($1);
    }
  | IMPRIMA expressao '\n' {
         if (executando) {
            NoAST* resultado = interpretar($2);
            if (resultado) {
                imprimirValor(resultado);
                printf("\n");
                liberarAST(resultado);
            } else {
                erro_semantico("Erro ao interpretar expressão");
            }
        }
        liberarAST($2);
    }
  | IMPRIMA expressao_string '\n' {
        if (executando) printf("%s\n", $2);
        free($2);
    }
  | IMPRIMA IDENTIFICADOR '\n' {
        Simbolo *s = buscarSimbolo($2);
        if (!s) {
            erro_semantico("ID nao declarado");
        } else {
            if (executando) {
                NoAST *no_id = criarNoId($2, s->tipo);
                NoAST* resultado = interpretar(no_id);
                if (resultado) {
                    imprimirValor(resultado);
                    printf("\n");
                    liberarAST(resultado);
                }
                liberarAST(no_id);
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
            erro_semantico("Erro: Variavel nao declarada.");
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
                erro_semantico("Erro ao alocar memoria para string.");
            } else {
                scanf("%255s", s->valor.strValue);
            }
        }
        free($2);
    }
    | SE expressao ENTAO '\n' {
        
        NoAST* resultado = interpretar($2);
        if (!resultado || resultado->tipo != TIPO_INT) {
            executando = 0;
            if (resultado) liberarAST(resultado);
            liberarAST($2);
            YYABORT;
        }

        if (exec_sp >= MAX_NIVEL) {
            liberarAST(resultado);
            liberarAST($2);
            exit(EXIT_FAILURE);
        }

       
        exec_stack[exec_sp] = executando;
        cond_stack[exec_sp] = resultado->valor.intValue;
        executando = executando && resultado->valor.intValue;
        
        exec_sp++;

        liberarAST($2);
    }
    lista_comandos comando_fim
;

// FIM_SE ou SENAO
comando_fim:
    FIM_SE '\n' {
        if (exec_sp <= 0) {
            fprintf(stderr, "[DEBUG] Erro: FIM_SE sem SE correspondente (exec_sp: %d)\n", exec_sp);
            exit(EXIT_FAILURE);
        }
        exec_sp--;
       
        executando = exec_stack[exec_sp];
    }
  | SENAO '\n' {
        if (exec_sp <= 0) {
            fprintf(stderr, "[DEBUG] Erro: SENAO sem SE correspondente (exec_sp: %d)\n", exec_sp);
            exit(EXIT_FAILURE);
        }
        
        executando = exec_stack[exec_sp - 1] && !cond_stack[exec_sp - 1];
    }
    lista_comandos
    comando_fim
;

expressao:
    expressao '+' expressao         { $$ = criarNoOp('+', $1, $3); $$->tipo = $1->tipo;}
  | expressao '-' expressao         { $$ = criarNoOp('-', $1, $3); $$->tipo = $1->tipo;}
  | expressao '*' expressao         { $$ = criarNoOp('*', $1, $3); $$->tipo = $1->tipo;}
  | expressao '/' expressao         { $$ = criarNoOp('/', $1, $3); $$->tipo = $1->tipo;}
  | expressao MAIOR expressao       { $$ = criarNoOp('>', $1, $3); $$->tipo = TIPO_INT;}
  | expressao MENOR expressao       { $$ = criarNoOp('<', $1, $3); $$->tipo = TIPO_INT;}
  | expressao IGUAL expressao       { $$ = criarNoOp('=', $1, $3); $$->tipo = TIPO_INT;}
  | expressao DIFERENTE expressao   { $$ = criarNoOp('!', $1, $3); $$->tipo = TIPO_INT;}
  | '(' expressao ')'               { $$ = $2; $$->tipo = $2->tipo;}
  | INTEIRO                         { $$ = criarNoNum($1); $$->tipo = TIPO_INT;}
  | IDENTIFICADOR {
        Simbolo *s = buscarSimbolo($1);
        if (!s) {
            yyerror("Variavel nao declarada.");
            $$ = criarNoNum(0); // Retorna um nó numérico para evitar erros em cascata
        } else {
            $$ = criarNoId($1, s->tipo);
        }
        free($1);
    }
;

expressao_string:
    STRING { $$ = strdup($1); }
;

%%

extern int yylineno;
extern char *yytext;

void yyerror(const char *s) {
    fprintf(stderr, "\033[31mErro sintatico\033[0m na linha %d, proximo de '%s': %s\n", yylineno, yytext, s);
}

void erro_semantico(const char *s) {
    fprintf(stderr, "\033[33m[Erro semantico]\033[0m na linha %d: %s\n", yylineno, s);
}