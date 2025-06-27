# Definição do Projeto: Interpretador de Portugol
## Introdução

O objetivo deste projeto é desenvolver um interpretador para o pseudocódigo de programação Portugol, voltado para a disciplina de Compiladores. O interpretador foi implementado para ser capaz de ler, interpretar e executar programas simples escritos em Portugol, validando a sintaxe e executando as operações definidas. O interpretador reconhece e executa instruções escritas em Portugol, validando a estrutura sintática e semântica, e executando o programa por meio de uma Árvore Sintática Abstrata (AST).

## Descrição do Sistema
O Portugol é pseudocódigo de fácil compreensão, com uma sintaxe semelhante à linguagem natural, o que facilita seu aprendizado. Ela é comumente utilizada no ensino de lógica de programação. O interpretador desenvolverá a capacidade de reconhecer e executar comandos básicos da linguagem.

## Funcionalidades implementadas

O interpretador possui as seguintes funcionalidades:

- Analisador Léxico: Identificação de tokens, como palavras-chave, identificadores, operadores e literais.

- Analisador Sintático : Verificação da estrutura gramatical do código, criando a árvore de sintaxe abstrata (AST).

- Execução: O interpretador deve executar os programas, considerando as variáveis, controle de fluxo (condicionais e loops) e operações matemáticas.

- Tratamento de Erros: Mensagens de erro claras e detalhadas para problemas léxicos, sintáticos e semânticos.

## Requisitos Funcionais
- O interpretador deve ser capaz de ler um código fonte em Portugol.
- O código deve ser analisado sintaticamente para garantir sua validade.
- O programa deve ser executado em tempo real, exibindo resultados ou erros, conforme o código fornecido.
- O código-fonte será dado como entrada e a saída consistirá em resultados da execução ou mensagens de erro.


## Arquitetura
### Componentes Principais

|Componente|Arquivo|Descrição|
|----------|-------|---------|
| Scanner (Analisador Léxico) | portugol.l |  Responsável por dividir o código em tokens |
| Parser (Analisador Sintático) | portugol.y |  Responsável por verificar a sintaxe e construir a AST |
| AST | ast.h e ast.c | 	Representa o programa como uma estrutura hierárquica | 
| Tabela de símbolos | tabela.h e tabela.c | Gerencia variáveis, tipos e valores |
| Tipos | tipos.h | Define os tipos e estruturas base do sistema |
| Executor |   | Responsável pela execução das instruções da AST|
| Testes | tests/ | Arquivos de teste de implementações e erros | 

### Fluxo de Execução
- O código-fonte é fornecido ao scanner, que converte o texto em tokens.
- O parser verifica a sintaxe e gera a árvore de sintaxe abstrata (AST).
- O executor interpreta e executa o código representado pela AST.
- Erros são capturados durante a execução, e o sistema retorna mensagens detalhadas.

### Histórico de versão
|Versão|Data  |
|--|--|
| 1.0 | 03/04/2025 | Criação do documento Definição do Projeto |
| 2.0 | 23/06/2025 | Ajustes para entrega final |
