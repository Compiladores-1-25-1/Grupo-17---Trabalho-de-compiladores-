# Decisões técnicas

## Definição do Escopo do Interpretador
O interpretador de Portugol será desenvolvido para processar e executar programas escritos na linguagem Portugol, com base nas diretrizes definidas pelo site oficial e o manual do G-Portugol. A linguagem tem como objetivo ser simples e didática, utilizando conceitos de programação imperativa. O interpretador suportará os seguintes componentes essenciais:

### Tipos de Dados Suportados
O interpretador suportará os seguintes tipos de dados básicos:

- Tipo Inteiro: Números inteiros, como 10, -5, 0.

- Tipo Real: Números reais com ponto flutuante, como 3.14, -0.5, 100.0.

- Tipo Caractere: Um único caractere, representado por aspas simples, como 'a', 'b'.

- Tipo Literal: Cadeias de caracteres entre aspas duplas, como "Olá Mundo", "Portugol".

- Tipo Lógico: Valores booleanos, verdadeiro ou falso.

- Tipo Vazio: Representa a ausência de valor (null).

Esses tipos serão usados para declarar variáveis e constantes, e o interpretador verificará se os valores atribuídos são compatíveis com os tipos declarados.

### Declarações
O interpretador suportará as seguintes declarações essenciais:

- Declaração de Variáveis;
- Declaração de Funções;
- Declaração de Matrizes;

### Entrada e Saída
O interpretador incluirá operações básicas de entrada e saída:

- Leia: Para ler valores inseridos pelo usuário.
- Imprima: Para exibir informações na tela.
 
### Operadores e Expressões
O interpretador suportará as seguintes operações:

- Operações Aritméticas: Soma, subtração, multiplicação, divisão e módulo.

- Operações Relacionais: Igualdade, diferença, maior que, menor que, maior ou igual, menor ou igual.

- Operações Lógicas: AND, OR, NOT.

- Operações Bit a Bit: AND, OR, XOR.

### Estruturas de Controle
O interpretador implementará as seguintes estruturas de controle:

- Condicionais (se/então/senão): Para executar comandos com base em uma condição.

- Laços de Repetição: Para executar comandos repetidamente enquanto uma condição for verdadeira.

### Funções
Funções serão suportadas.

## Linguagem e Ferramentas
### Flex (Analisador Léxico)
O Flex será utilizado para identificar tokens a partir do código em Portugol. As expressões regulares definidas no arquivo .l reconhecerão tokens como variáveis, operadores, palavras-chave e literais.

### Bison (Analisador Sintático)
O Bison será utilizado para definir a gramática e criar o parser que validará a estrutura do código, gerando a árvore sintática abstrata (AST). O arquivo .y do Bison conterá as regras de produção da gramática, conforme as necessidades do projeto.

### Estrutura de Dados - AST
A Árvore Sintática Abstrata (AST) será construída no momento da análise sintática. Ela representará a estrutura do programa de forma hierárquica, permitindo que o interpretador execute as instruções de forma eficiente.

### Interpretação
O interpretador percorrerá a AST e executará as operações diretamente. Operações como atribuição de variáveis, expressões aritméticas e fluxos de controle serão avaliadas de acordo com as regras da linguagem Portugol.

### Tratamento de Erros
O interpretador incluirá um sistema de tratamento de erros para verificar erros léxicos, sintáticos e semânticos, fornecendo mensagens claras para o usuário, indicando a localização e o tipo do erro.

## Referências
- [Portugol - Site Oficial](https://portugol.dev/)
- G-Portugol Manual: Referências e detalhes da linguagem G-Portugol.

### Histórico de versão
|Versão|Data  |
|--|--|
| 1.0 | 13/04/2025 | Criação do documento Decisões Técnicas |

