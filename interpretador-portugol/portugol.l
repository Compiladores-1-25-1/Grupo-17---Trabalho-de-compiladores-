%{
    #include "portugol.tab.h"
    #include <string.h>
    #include <stdlib.h>
    #include <stdio.h>

    // Para evitar warnings do yyin
    extern FILE *yyin;
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
"inteiro"       { return INTEIRO; }
"real"          { return REAL; }

[0-9]+"."[0-9]+     { yylval.intValue = (int)atof(yytext); return NUM_REAL; }
[0-9]+              { yylval.intValue = atoi(yytext); return NUM_INT; }

\"([^\\\"]|\\.)*\"  {
                      yytext[yyleng - 1] = '\0';                // Remove aspa final
                      yylval.strValue = strdup(yytext + 1);     // Remove aspa inicial
                      return STRING;
                  }

[a-zA-Z_][a-zA-Z0-9_]*  { yylval.strValue = strdup(yytext); return IDENTIFICADOR; }

"("             { return '('; }
")"             { return ')'; }
"="             { return '='; }
";"             { return ';'; }
"+"             { return '+'; }
"-"             { return '-'; }
"*"             { return '*'; }
"/"             { return '/'; }

[ \t\r\n]+      { /* Ignorar espaços e quebras de linha */ }

.               { printf("Caractere inválido: %s\n", yytext); return 0; }

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
