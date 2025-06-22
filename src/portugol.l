%option yylineno

%{
    #include "portugol.tab.h"
    #include <string.h>
    #include <stdlib.h>
    #include <stdio.h>
    #include "tabela.h"


    // Para evitar warnings do yyin
    extern FILE *yyin;
    extern int yylineno;
%}

%%

"se"            { return SE; }
"senão"         { return SENAO; }
"então"         { return ENTAO; }
"fim-se"        { return FIM_SE; }
"enquanto"      { return ENQUANTO; }
"faça"          { return FACA; }
"imprima"       { return IMPRIMA; }
"leia"          { return LEIA; }
"inteiro"       {  yylval.strValue = strdup(yytext);
    return INTEIRO; }
"real"          {  yylval.strValue = strdup(yytext);
    return REAL; }
"string"          {  yylval.strValue = strdup(yytext);
    return STRING; }
"caractere"          {  yylval.strValue = strdup(yytext);
    return CARACTERE; }

[0-9]+"."[0-9]+     { yylval.floatValue = atof(yytext); return REAL; }
[0-9]+              { yylval.intValue = atoi(yytext); return INTEIRO; }

\"([^\\\"]|\\.)*\"  {
    yytext[yyleng - 1] = '\0';                // Remove aspa final
    yylval.strValue = strdup(yytext + 1);     // Remove aspa inicial
    return STRING;  // Alterado de CARACTERE para STRING
}

[a-zA-Z_][a-zA-Z0-9_]* {
    yylval.strValue = strdup(yytext);  // Armazena o nome do identificador em yylval
    return IDENTIFICADOR;  // Retorna o token IDENTIFICADOR para o Bison
}

"("         { return '('; }
")"         { return ')'; }
"<-"        { return ATRIBUICAO; }
"+"         { return '+'; }
"-"         { return '-'; }
"*"         { return '*'; }
"/"         { return '/'; }
"="         { return IGUAL; }
"ou"        { return OR_LOGICO; }
"e"         { return AND_LOGICO; }
"não"       { return NOT_LOGICO; }
"|"         { return OR_BIT; }
"&"         { return AND_BIT; }
"ˆ"         { return XOR_BIT; }
"<>"        { return DIFERENTE; }
">="        { return MAIOR_IGUAL; }
"<="        { return MENOR_IGUAL; }
">"         { return MAIOR; }
"<"         { return MENOR; }
"%"         { return MOD; }
"˜"         { return NOT_BIT; }
(\r?\n)+     { return '\n'; }


[ \t\r]+      { /* Ignorar espaços e quebras de linha */ }

. { fprintf(stderr, "\033[31mErro lexico\033[0m na linha %d: Caractere invalido '%s'\n", yylineno, yytext); return 0; }


%%

int yywrap(void) {
    return 1;
}

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *f = fopen(argv[1], "r");
        if (!f) {
            fprintf(stderr, "Erro ao abrir arquivo: %s\n", argv[1]);
            return 1;
        }
        yyin = f;
    }

    return yyparse();
}
