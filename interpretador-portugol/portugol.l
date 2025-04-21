%{
#include "portugol.tab.h"  /* Inclusão do cabeçalho gerado pelo Bison, que contém as definições de tokens */
%}

/* Definições de padrões de token e ações */
%%

[ \t\r\n]+            { /* Ignora espaços, tabulações, quebra de linha e \r do Windows */ }

[+\-]?[0-9]+          {
                        yylval.intValue = atoi(yytext);  /* Converte para inteiro */
                        return NUM_INT;
                      }

"se"                  { return SE; }
"senão"               { return SENAO; }
"então"               { return ENTAO; }
"fim-se"              { return FIM_SE; }
"enquanto"            { return ENQUANTO; }
"faça"                { return FACHA; }
"imprima"             { return IMPRIMA; }
"leia"                { return LEIA; }

.                      { return yytext[0]; }  /* Caso não seja um token válido, retorna o próprio caractere */

%%

/* Função auxiliar do Flex (quando termina o arquivo de entrada) */
int yywrap(void) {
    return 1;
}

/* Função principal: chamará o parser ao ser executado */
int main(int argc, char **argv) {
    /* Se houver arquivo de entrada como parâmetro, redireciona o yyin */
    if (argc > 1) {
        FILE *f = fopen(argv[1], "r");
        if (f) {
            yyin = f;
        }
    }
    return yyparse();
}
