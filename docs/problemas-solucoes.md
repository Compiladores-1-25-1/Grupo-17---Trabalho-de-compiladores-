# Problemas encontrados e soluções adotadas

Durante o desenvolvimento do interpretador para a linguagem de programação Portugol, alguns problemas foram encontrados, principalmente no que se refere à construção e implementação da gramática e ao tratamento de conflitos durante o processo de análise sintática. Abaixo estão as dificuldades encontradas e as soluções implementadas para superá-las.

## 1. Conflitos de Shift/Reduce

Um dos primeiros problemas foi a ocorrência de **conflitos de shift/reduce** durante a análise sintática. Esse tipo de conflito ocorreu quando o parser não sabia se deveria "deslocar" para o próximo token ou "reduzir" a produção de uma regra gramatical. Os conflitos estavam relacionados a comandos como `SE`, `SENAO`, `ENQUANTO`, e operadores como `IGUAL`, `MAIOR`, entre outros.

### **Solução Encontrada**

```yacc
comando:
  SE expressao ENTAO lista_comandos FIM_SE
  | SE expressao ENTAO lista_comandos SENAO lista_comandos FIM_SE
  | SENAO lista_comandos
```

Uso da diretiva `%nonassoc` para resolver ambiguidade de `SENAO`: A diretiva `%nonassoc SENAO` foi utilizada para garantir que o comando `SENAO` fosse corretamente atribuído a um bloco condicional e não causasse ambiguidades.

## 2. Ambiguidade na Gramática do Comando `SE`

Os comandos `SE`, `SENAO` e `FIM_SE` estavam sendo interpretados de forma ambígua em algumas situações, causando dificuldades no controle de fluxo da execução. Isso ficou especialmente evidente quando o SE estava aninhado ou quando não havia um `SENAO`.

### **Solução Encontrada**

Uso de pilhas (exec_stack e cond_stack) para controle de execução dentro dos blocos condicionais. As pilhas permitiram armazenar o estado de execução para cada nível de `SE`, garantindo que os comandos fossem executados ou ignorados corretamente.

```c
  exec_stack[exec_sp] = executando;
  cond_stack[exec_sp] = $2;  // Condição do SE
  executando = executando && $2;
  exec_sp++;
```

Correção do tratamento do comando `SENAO`: O comando `SENAO` foi tratado de forma que, ao ser executado, ele reverte o estado da execução para garantir que apenas o ramo correto seja executado. A pilha `exec_stack` foi usada para armazenar o estado do "pai", enquanto `cond_stack` mantinha o estado das condições, permitindo alternar corretamente entre os blocos `SE` e `SENAO`.

## 3. Identificadores Não Reconhecidos em Expressões do Parser

Durante os testes com expressões envolvendo variáveis, como o exemplo abaixo, foi detectado um erro sintático na linha onde ocorre a atribuição `media = (x + y);`. O analisador sintático (parser) não reconhecia identificadores `(x, y)` como operandos válidos em expressões aritméticas. Isso ocorria porque a gramática do parser (`portugol.y`) não contemplava a possibilidade de IDENTIFICADORES serem utilizados dentro da regra `expressao`.

```portugol
inteiro x;
x = 0;

inteiro y;
y = 10;

real media;
media = (x + y);
```

### **Solução Encontrada**

Como solução foi adicionada uma nova produção à regra `expressao` no arquivo `portugol.y` para permitir o uso de variáveis já declaradas nas operações. A nova produção trata a recuperação do valor do identificador de acordo com o seu tipo, acessando a tabela de símbolos. A regra adicionada foi:

```portugol
| IDENTIFICADOR {
    Simbolo *s = buscarSimbolo($1);
    if (!s) {
        yyerror("Variavel nao declarada.");
        $$ = 0;
    } else if (s->tipo == TIPO_INT) {
        $$ = s->valor.intValue;
    } else if (s->tipo == TIPO_REAL) {
        $$ = s->valor.floatValue;
    } else {
        yyerror("Tipo nao suportado em expressao.");
        $$ = 0;
    }
    free($1);
}
```

Com essa modificação, o parser passa a aceitar expressões do tipo `x + y`, onde `x` e `y` são variáveis previamente declaradas e atribuídas, permitindo o uso mais realista de variáveis em expressões matemáticas no interpretador.


## Conclusão
As principais dificuldades enfrentadas no desenvolvimento do interpretador de Portugol estavam relacionadas a conflitos de análise sintática e a correta implementação do fluxo de execução de comandos condicionais. As soluções adotadas envolveram ajustes na gramática para evitar ambiguidade e implementação de pilhas para controle de execução. Essas correções permitiram que o interpretador fosse capaz de processar corretamente os programas escritos em Portugol.

### Histórico de versão
|Versão|Data|Descrição|
|--|--|--|
| 1.0 | 28/04/2025 | Criação do documento de Problemas e soluções encontrados |
| 1.1 | 01/06/2025 | Adição dos Problemas e Soluções das sprints 3 e 4 |

