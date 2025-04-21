%{
#include "portugol.tab.h" // Tokens gerados pelo Bison
#include <stdio.h>
#include <stdlib.h>

extern int yylval;       // usado para valores inteiros (pode ser uma union no .y futuramente)
%}

DIGITO     [0-9]
LETRA      [a-zA-ZáÁéÉíÍóÓúÚçÇ_]
ID         {LETRA}({LETRA}|{DIGITO})*
INT        {DIGITO}+
REAL       {DIGITO}+"."{DIGITO}+
CARACTERE  \'(.|\\[nt\\'\"])\'   // caractere entre aspas simples, com escape opcional
LITERAL    \"([^\\"]|\\.)*\"     // string entre aspas duplas

%%

[ \t\r\n]+                   { /* ignora espaços, tabs e quebras de linha */ }

"inteiro"                   { return TIPO_INTEIRO; }
"real"                      { return TIPO_REAL; }
"caractere"                 { return TIPO_CARACTERE; }
"literal"                   { return TIPO_LITERAL; }
"lógico"                    { return TIPO_LOGICO; }
"vazio"                     { return TIPO_VAZIO; }

"se"                        { return SE; }
"senão"                     { return SENAO; }
"então"                     { return ENTAO; }
"fim-se"                    { return FIM_SE; }
"enquanto"                  { return ENQUANTO; }
"faça"                      { return FACA; }
"fim-enquanto"              { return FIM_ENQUANTO; }

"função"                    { return FUNCAO; }
"fim-função"                { return FIM_FUNCAO; }
"retorne"                   { return RETORNE; }

"leia"                      { return LEIA; }
"imprima"                   { return IMPRIMA; }

"verdadeiro"               { yylval.intValue = 1; return LOGICO; }
"falso"                    { yylval.intValue = 0; return LOGICO; }

{INT}                      { yylval.intValue = atoi(yytext); return NUM_INT; }
{REAL}                     { yylval.realValue = atof(yytext); return NUM_REAL; }

{CARACTERE}                { yylval.charValue = yytext[1]; return CARACTERE_LITERAL; }
{LITERAL}                  { yylval.stringValue = strdup(yytext); return STRING_LITERAL; }

{ID}                       { yylval.stringValue = strdup(yytext); return IDENTIFICADOR; }

"="                         { return ATRIBUICAO; }
"+"                         { return SOMA; }
"-"                         { return SUBTRACAO; }
"*"                         { return MULTIPLICACAO; }
"/"                         { return DIVISAO; }
"%"                         { return MODULO; }

"=="                        { return IGUAL; }
"!="                        { return DIFERENTE; }
">"                         { return MAIOR; }
"<"                         { return MENOR; }
">="                        { return MAIOR_IGUAL; }
"<="                        { return MENOR_IGUAL; }

"e"                         { return E_LOGICO; }
"ou"                        { return OU_LOGICO; }
"não"                       { return NAO_LOGICO; }

"&"                         { return E_BIT; }
"|"                         { return OU_BIT; }
"^"                         { return XOR_BIT; }

"("                         { return ABRE_PARENTESE; }
")"                         { return FECHA_PARENTESE; }
"{"                         { return ABRE_BLOCO; }
"}"                         { return FECHA_BLOCO; }
","                         { return VIRGULA; }
";"                         { return PONTO_VIRGULA; }

.                           { printf("Caractere inesperado: %s\n", yytext); return ERRO; }

%%

int yywrap(void) {
    return 1;
}

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *f = fopen(argv[1], "r");
        if (!f) {
            fprintf(stderr, "Erro ao abrir o arquivo %s\n", argv[1]);
            return 1;
        }
        yyin = f;
    }
    return yyparse();
}
