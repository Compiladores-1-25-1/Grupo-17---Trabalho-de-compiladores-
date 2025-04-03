
# Planejamento de Sprints grupo 17

Abaixo tem um quadro exemplificando como funcionaram as sprints planejadas pelo grupo 017 para o desenvolvimento de um interpretador de [portugol](https://portugol.dev/).

|Sprint| Março | Abril | Maio | Junho |Julho |
|--|--|--|--|--|--
|Sprint 1  | ✅ | ✅ |  |   |
|Sprint 2  |  | ✅ |  |   |
|Sprint 3  |  |  | ✅ |   |
|Sprint 4  |  |  | ✅ | ✅ |
|Sprint 5  |  |  |  |  ✅ |
|Sprint 6  |  |  |  | ✅  | ✅ |

## Sprint 1 (24/03 a 09/04)  
### **Principais Entregas**  
  - Documento inicial descrevendo a linguagem (tokens, estruturas, exemplos de código).  
  - Protótipo de gramática reconhecida pelo Bison (ainda não funcional, mas já planejada).  
  - Ambiente configurado e testado (cada membro deve conseguir compilar e rodar um “hello world” com Flex/Bison).  

### **Tarefas e Atividades**  
 - []  **Definir o escopo do interpretador**: quais construções essenciais da linguagem serão suportadas (tipos de dados, operadores, estruturas de controle etc.).  
 - [ ] **Configurar repositório** (GitHub ou similar) e adicionar todos os membros (incluindo o professor: “sergioaafreitas” ou “sergiofreitas@unb.br”).  
 - [ ] **Configurar ferramentas**: Flex, Bison, compilador C/C++ (ou outra linguagem) no ambiente local.  
 - [ ] **Criar gramática inicial** no Bison (arquivo `.y`) e o arquivo de regras léxicas no Flex (arquivo `.l`), ainda que incompletos.  
 - [ ] **Montagem da documentação**: elaborar e validar as documentações que serão entregues.
---

## Sprint 2 (10/04 a 30/04)  
### **Principais Entregas**  
  - Arquivo `.l` completo para reconhecimento de tokens (identificadores, números, símbolos, palavras-chave).  
  - Primeiras regras sintáticas no arquivo `.y`, permitindo testar códigos simples na linguagem.  
  - Formulário de P1 preenchido até 28/04 (23h59), com apresentação em 30/04.  

### **Tarefas e Atividades**  
 - [ ] **Finalizar** as expressões regulares no arquivo `.l` (tratando espaços, comentários, etc.). 
 - [ ] **Desenvolver** regras sintáticas no Bison (estruturas básicas de atribuição, expressões, comandos simples).  
 - [ ] **Testar** tokens e parser em pequenos exemplos, validando o fluxo léxico-sintático.
 - [ ] **Preencher** Formulário P1
 - [ ] **Preparar** material de apresentação (P1) sobre o progresso (mostrar tokens reconhecidos e regras sintáticas iniciais).  
 - [ ]  **Montagem da documentação**: elaborar e validar as documentações que serão entregues.

---

## Sprint 3 (01/05 a 14/05)  
### **Principais Entregas**  
  - AST consolidada (estruturas de dados ou classes para cada tipo de nó: expressões, comandos, etc.).  
  - Módulo de análise semântica inicial (por exemplo, verificação de variáveis declaradas e tipos simples).  
  - Parser que já constrói a AST durante a análise sintática, facilitando a etapa de interpretação futura.  

### **Tarefas e Atividades**  
   - [ ] **Implementar** as ações semânticas no arquivo `.y` de modo a criar nós da AST para cada construção reconhecida.  
   - [ ] **Criar tabela de símbolos** (se for necessária) para verificar declarações de variáveis, escopos, etc.  
   - [ ] **Tratar** erros sintáticos e semânticos básicos, exibindo mensagens significativas ao usuário.  
   - [ ] **Testar** a AST em pequenos programas (tanto corretos quanto com falhas de sintaxe/semântica). 
   - [ ]  **Montagem da documentação**: elaborar e validar as documentações que serão entregues. 
---

## Sprint 4 (15/05 a 04/06)  
### **Principais Entregas**  
  - **Módulo interpretador**: capaz de percorrer a AST e executar instruções (atribuições, expressões, fluxos de controle).  
  - Análise semântica mais robusta (ex.: tipos, escopo, variáveis não declaradas, e possíveis alertas em tempo de execução).  
  - Formulário de P2 preenchido até 02/06 (23h59) e apresentação em 04/06.  

### **Tarefas e Atividades**  

 - [ ]  **Criar** a lógica de interpretação recursiva (ex.: `interpretNode()`, que avalia nós de expressão/comando).  
 - [ ] **Consolidar** estruturas de controle (if, while, etc.), garantindo que a AST as represente adequadamente.  
 - [ ] **Testar** o interpretador com programas de exemplo que demonstrem a execução de comandos básicos.  
 - [ ] **Preencher** Formulário P2
 - [ ] **Preparar** a apresentação P2, mostrando as novidades desde o P1 e a interpretação funcionando.  
 - [ ]  **Montagem da documentação**: elaborar e validar as documentações que serão entregues.
 
---

## Sprint 5 (05/06 a 25/06)  
### **Principais Entregas**  
  - Interpretador ampliado, com eventuais otimizações e funcionalidades extras.  
  - Testes de integração em diversos programas de exemplo.  
  - Versão final pronta para entrega até 27/06 (23h59) via Teams.  

### **Tarefas e Atividades**  

 - [ ]  **Implementar otimizações** simples (constant folding, remoção de nós redundantes, etc.).
 - [ ]  **Estender** a linguagem com novos recursos (desde que caiba no cronograma). 
 - [ ] **Testar** intensivamente (abordando construções avançadas e casos-limite).  
 - [ ]  **Entregar** o projeto final (repositório atualizado, acesso ao professor, e arquivo zip, se exigido).  
 - [ ]  **Montagem da documentação**: elaborar e validar as documentações que serão entregues.

---

## Sprint 6 (26/06 a 09/07)  
### **Principais Entregas**  
  - **Entrevistas** de entrega do projeto final (toda a equipe deve estar presente).  
  - **Documentação** completa (README, manual de uso, explicações sobre a AST e a execução).  
  - Ajustes finais (caso o professor detecte problemas).  

### **Tarefas e Atividades**  

 - [ ]  **Preparar-se** para as entrevistas: cada membro deve entender bem o parser, a AST, a análise semântica e o interpretador.  
 - [ ] **Corrigir** eventuais falhas apontadas pelo professor durante as entrevistas ou testes.
 - [ ] **Finalizar** documentação e organizar exemplos de uso.  

---

## Observações

1. Alguns dias de aula, na quarta feira, serão utilizadas para rodar as “dailies” e revisar backlog de tarefas, mantendo transparência sobre o que cada um está fazendo, assim como para reuniões de review para demonstrar o que foi concluído e alinhar o que entra no próximo Sprint.  
2. Sempre que possível será mantido testes automatizados para cada fase: léxica, sintática, semântica, geração de código e execução final.  
3.  No dia 26/03 (qua), aula prática para configurar o ambiente de desenvolvimento de interpretadores.  
4. A Sprint 2 fecha em 30/04 com a **apresentação** do P1.  
5.  As quartas-feiras (07/05 e 14/05) são dedicadas ao desenvolvimento prático e integração das tarefas.  
6. Mantenha commits estáveis no repositório para evitar regressões (e documentem bem a AST)
7. Aulas práticas (21/05, 28/05 e 04/06) para integrar e corrigir bugs. 
8. A Sprint 4 termina com a **apresentação** P2 (04/06).  
9. Aulas dos dias (11/06, 18/06, 25/06) são fundamentais para corrigir bugs e integrar tudo.
10. As entrevistas ocorrerão em 30/06 (seg) e 02/07 (qua). Falta de comparecimento pode zerar a nota da apresentação final.

### Histórico de versão
|Versão|Data  |
|--|--|
| 1.0 | 03/04/2025 |
