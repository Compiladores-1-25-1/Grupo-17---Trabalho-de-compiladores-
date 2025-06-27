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

- Declaração de Variáveis.

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

### Testes
Os testes foram organizados para validar diferentes aspectos do compilador de Portugol, incluindo análise léxica, sintática, semântica e geração da AST. Cada teste foi escrito como um arquivo .txt com trechos de código em Portugol, simulando diferentes situações da linguagem, desde estruturas básicas até casos de erro. Esses testes estão agrupados em diretórios conforme o tipo de funcionalidade testada, facilitando a manutenção e a identificação de falhas específicas no comportamento do compilador.

- Diretório src/tests/

    - tests.sh: script responsável por executar os testes.

    - portugol: binário do interpretador/compilador.

    - tests_arquivos/: pasta dos arquivos de teste organizados por tipo.

- Subdiretórios de tests_arquivos/
    - testes_ast:	Geração e validação da Árvore Sintática Abstrata (AST)
    - testes_basicos:	Testes simples de sintaxe e execução
    - testes_decimais:	Expressões com números decimais e operações com real
    - testes_ifelse:	Testes com estruturas condicionais se e senao
    - testes_numeros_negativos:	Expressões com números negativos e validação de sinais
    - testes_operadores:	Testes de operadores aritméticos e lógicos (+, -, e, ou, etc)
- Arquivos de teste individuais
    - teste_booleano.txt:	Testes com valores booleanos (verdadeiro / falso)
    - teste_caractere.txt: 	Declarações e uso de variáveis do tipo char
    - teste_correcao_igual_operadores.txt:	Correção e verificação de operadores de comparação
    - teste_logico.txt:	Expressões com operadores lógicos e, ou, nao
    - teste_vazio_erro_incompativel.txt:	Erros relacionados a tipo vazio e incompatibilidades

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
| 2.0 | 26/06/2025 | Inclusão dos testes |

