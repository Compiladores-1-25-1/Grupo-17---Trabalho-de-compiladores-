%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tabela.h"
#include "ast.h"

int yylex(void);
void yyerror(const char *s);
void erro_semantico(const char *s);


NoAST *programa_ast = NULL;
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
%token PARA ATE PASSO REPITA FIM_PARA FIM_REPITA
%token OR_LOGICO AND_LOGICO NOT_LOGICO
%token OR_BIT AND_BIT XOR_BIT
%token IGUAL DIFERENTE MAIOR MAIOR_IGUAL MENOR MENOR_IGUAL
%token MOD NOT_BIT
%token ATRIBUICAO
%token BOOLEANO VERDADEIRO FALSO
%token VAZIO



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


%type <no>           programa lista_comandos comando expressao comando_if comando_while comando_para comando_repita passo_opcional
%type <strValue>     expressao_string
%type <tipo>         tipo_var

%%

programa:
    lista_comandos {
        programa_ast = $1;
        executarComando(programa_ast);
    }
;

lista_comandos:
    lista_comandos comando {
        if ($1) {
            NoAST *bloco = $1;
            if (bloco->tipoNo != NO_BLOCO) {
                NoAST *novo_bloco = criarNoBloco();
                adicionarComandoBloco(novo_bloco, bloco);
                adicionarComandoBloco(novo_bloco, $2);
                $$ = novo_bloco;
            } else {
                adicionarComandoBloco(bloco, $2);
                $$ = bloco;
            }
        } else {
            $$ = $2;
        }
    }
  | comando {
        $$ = $1;
    }
  | comando_para { $$ = $1; }
  | comando_repita { $$ = $1; }

;

tipo_var:
    INTEIRO { $$ = TIPO_INT; }
  | REAL    { $$ = TIPO_REAL; }
  | STRING  { $$ = TIPO_STRING; }
  | CARACTERE { $$ = TIPO_CHAR; }
  | BOOLEANO { $$ = TIPO_BOOL; }
  | VAZIO     { $$ = TIPO_VAZIO; }

;

comando:
    tipo_var IDENTIFICADOR '\n' {
        if (buscarSimbolo($2)) {
            erro_semantico("A variavel ja foi declarada neste escopo");
        } else {
            $$ = criarNoDeclaracao($2, $1);
        }
        free($2);
    }
  | IDENTIFICADOR ATRIBUICAO expressao '\n' {
        $$ = criarNoAtribuicao($1, $3);
        free($1);
    }
    | IDENTIFICADOR ATRIBUICAO expressao_string '\n' {
        NoAST *no_string = malloc(sizeof(NoAST));
        if (no_string) {
            inicializarNo(no_string);
            no_string->tipoNo = NO_NUMERO;
            // Determina se é CHAR (1 caractere) ou STRING (mais de 1)
            if (strlen($3) == 1) {
                no_string->tipo = TIPO_CHAR;
            } else {
                no_string->tipo = TIPO_STRING;
            }
            no_string->valor.strValue = strdup($3);
        }
        $$ = criarNoAtribuicao($1, no_string);
        free($1);
        free($3);
    }
  | IMPRIMA expressao '\n' {
        $$ = criarNoImprima($2);
    }
  | IMPRIMA expressao_string '\n' {
        NoAST *no_string = malloc(sizeof(NoAST));
        if (no_string) {
            inicializarNo(no_string);
            no_string->tipoNo = NO_NUMERO;
            no_string->tipo = TIPO_STRING;
            no_string->valor.strValue = strdup($2);
        }
        $$ = criarNoImprima(no_string);
        free($2);
    }
  | IMPRIMA IDENTIFICADOR '\n' {
        NoAST *no_id = criarNoId($2, TIPO_INT);
        $$ = criarNoImprima(no_id);
        free($2);
    }
  | IMPRIMA '(' STRING ')' '\n' {
        NoAST *no_string = malloc(sizeof(NoAST));
        if (no_string) {
            inicializarNo(no_string);
            no_string->tipoNo = NO_NUMERO;
            no_string->tipo = TIPO_STRING;
            no_string->valor.strValue = strdup($3);
        }
        $$ = criarNoImprima(no_string);
        free($3);
    }
  | LEIA IDENTIFICADOR '\n' {
        $$ = criarNoLeia($2);
        free($2);
    }
  | comando_if {
        $$ = $1;
    }
  | comando_while {
        $$ = $1;
    }
  | comando_para { 
        $$ = $1; 
    }
  | comando_repita { 
        $$ = $1; 
    }
;

comando_if:
    SE expressao ENTAO '\n' lista_comandos FIM_SE '\n' {
        $$ = criarNoIf($2, $5, NULL);
    }
  | SE expressao ENTAO '\n' lista_comandos SENAO '\n' lista_comandos FIM_SE '\n' {
        $$ = criarNoIf($2, $5, $8);
    }
;

comando_while:
    ENQUANTO expressao FACA '\n' lista_comandos FIM_SE '\n' {
        $$ = criarNoWhile($2, $5);
    }
;

comando_para:
    PARA IDENTIFICADOR ATRIBUICAO expressao ATE expressao passo_opcional '\n' lista_comandos FIM_PARA '\n' {
        NoAST *inicio = criarNoAtribuicao($2, $4);
        NoAST *condicao = criarNoOp('L', criarNoId($2, TIPO_INT), $6);
        NoAST *incremento = criarNoAtribuicao($2, criarNoOp('+', criarNoId($2, TIPO_INT), $7));
        NoAST *bloco = criarNoBloco();
        adicionarComandoBloco(bloco, $9); // corpo
        adicionarComandoBloco(bloco, incremento);
        NoAST *loop = criarNoWhile(condicao, bloco);
        NoAST *blocoCompleto = criarNoBloco();
        adicionarComandoBloco(blocoCompleto, inicio);
        adicionarComandoBloco(blocoCompleto, loop);
        free($2);
        $$ = blocoCompleto;
    }

passo_opcional:
    PASSO expressao { $$ = $2; }
  | /* vazio */    { $$ = criarNoNum(1); }
;

comando_repita:
    REPITA '\n' lista_comandos ATE expressao '\n' FIM_REPITA '\n' {
        NoAST *condicaoNegada = criarNoOp('!', criarNoNum(1), $5);
        NoAST *loop = criarNoWhile(condicaoNegada, $3);
        NoAST *blocoCompleto = criarNoBloco();
        adicionarComandoBloco(blocoCompleto, $3);   // Executa 1x
        adicionarComandoBloco(blocoCompleto, loop); // Depois repete
        $$ = blocoCompleto;
    }
;

expressao:
    expressao '+' expressao         { $$ = criarNoOp('+', $1, $3); }
  | expressao '-' expressao         { $$ = criarNoOp('-', $1, $3); }
  | expressao '*' expressao         { $$ = criarNoOp('*', $1, $3); }
  | expressao '/' expressao         { $$ = criarNoOp('/', $1, $3); }
  | expressao MOD expressao         { $$ = criarNoOp('%', $1, $3); }
  | expressao MAIOR expressao       { $$ = criarNoOp('>', $1, $3); }
  | expressao MENOR expressao       { $$ = criarNoOp('<', $1, $3); }
  | expressao IGUAL expressao       { $$ = criarNoOp('=', $1, $3); }
  | expressao DIFERENTE expressao   { $$ = criarNoOp('!', $1, $3); }
  | expressao MAIOR_IGUAL expressao { $$ = criarNoOp('G', $1, $3); }
  | expressao MENOR_IGUAL expressao { $$ = criarNoOp('L', $1, $3); }
  | expressao AND_LOGICO expressao   { $$ = criarNoOp('&', $1, $3); }
  | expressao OR_LOGICO  expressao   { $$ = criarNoOp('|', $1, $3); }
  | VERDADEIRO { $$ = criarNoNum(1); $$->tipo = TIPO_BOOL; }
  | FALSO      { $$ = criarNoNum(0); $$->tipo = TIPO_BOOL; }

  | NOT_LOGICO expressao %prec NOT_LOGICO { $$ = criarNoOp('!', criarNoNum(1), $2); }

  | '(' expressao ')'               { $$ = $2; }
  | '-' expressao %prec UMINUS      {$$ = criarNoOp('-', criarNoNum(0), $2); }
  | INTEIRO                         { $$ = criarNoNum($1); }
  | REAL                            { $$ = criarNoReal($1); }
  | IDENTIFICADOR {
        $$ = criarNoId($1, TIPO_INT);
        free($1);
    }
;

expressao_string:
     STRING     { $$ = strdup($1); }
  | CARACTERE  { $$ = strdup($1); }
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