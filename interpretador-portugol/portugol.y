    %{
    #include <stdio.h>
    #include <stdlib.h>

    /* Declarações explícitas para evitar warnings de funções não declaradas */
    int yylex(void);
    void yyerror(const char *s);
    %}

    /* Definições de tokens */
    %token SE SENAO ENTAO FIM_SE ENQUANTO FACHA IMPRIMA LEIA
    %token INTEIRO REAL LITERAL IDENTIFICADOR
    %token NUM_INT NUM_REAL STRING

    %union {
        int intValue;  /* Para armazenar valores numéricos */
        char* strValue;

    }

    %type <intValue> NUM_INT NUM_REAL expressao variavel
    %type <strValue> STRING


    %%

    /* A gramática para o interpretador de Portugol */
    programa:
        lista_comandos
        ;

    lista_comandos:
        lista_comandos comando { /* Executar o comando */ }
        | comando
        ;

    comando:
        SE expressao ENTAO lista_comandos FIM_SE
        | SE expressao ENTAO lista_comandos SENAO lista_comandos FIM_SE { printf("Comando Condicional com Senão\n"); }
        | ENQUANTO expressao FACHA lista_comandos    { printf("Comando de Repetição: Enquanto-Faca\n"); }
        | IMPRIMA expressao ';' { printf("Imprimir valor: %d\n", $2); }
        | IMPRIMA '(' STRING ')' ';'                 { printf("Comando Imprimir string: %s\n", $3); }
        | LEIA variavel                              { printf("Comando Leia\n"); }
        | declaracao
        | atribuicao
        ;


    declaracao:
        INTEIRO IDENTIFICADOR ';'                 { printf("Declaração de inteiro\n"); }
        | REAL IDENTIFICADOR ';'                    { printf("Declaração de real\n"); }
        ;

    atribuicao:
        IDENTIFICADOR '=' expressao ';'           { printf("Atribuição de valor\n"); }
        ;

    expressao:
        NUM_INT                                   { $$ = $1; }
        | NUM_REAL                                  { $$ = $1; }
        | IDENTIFICADOR                             { $$ = 0; /* valor fictício */ }
        | expressao '+' expressao                   { $$ = $1 + $3; }
        | expressao '-' expressao                   { $$ = $1 - $3; }
        | expressao '*' expressao                   { $$ = $1 * $3; }
        | expressao '/' expressao                   {
            if ($3 == 0) {
                yyerror("Divisão por zero!");
                $$ = 0;
            } else {
                $$ = $1 / $3;
            }
        }
        ;

    variavel:
        IDENTIFICADOR { $$ = 0; }

        ;

    %%

    /* Definição de yyerror */
    void yyerror(const char *s) {
        fprintf(stderr, "Erro sintático: %s\n", s);
    }
