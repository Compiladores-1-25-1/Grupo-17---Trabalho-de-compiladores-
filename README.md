# Grupo 17 - Trabalho de compiladores
## :scroll: Sobre o projeto
   Este repositório é dedicado à disciplina de Compiladores 1 ministrada pelo professor Dr. Sérgio Freitas. <br>
   A equipe optou por desenvolver um interpretador de portugol. <br>
   O objetivo deste projeto é desenvolver um interpretador para o pseudocódigo de programação Portugol, voltado para a disciplina de Compiladores. O interpretador foi implementado para ser capaz de ler, interpretar e executar programas simples escritos em Portugol, validando a sintaxe e executando as operações definidas. O interpretador reconhece e executa instruções escritas em Portugol, validando a estrutura sintática e semântica, e executando o programa por meio de uma Árvore Sintática Abstrata (AST).

## :star2: Contribuidores

<center>
<table style="margin-left: auto; margin-right: auto;">
    <tr>
        <td align="center">
            <a href="https://github.com/Caiomesvie">
                <img style="border-radius: 50%;" src="https://avatars.githubusercontent.com/u/96022527?v=4" width="150px;"/>
                <h5 class="text-center">Caio Mesquita</h5>
                <h5 class="text-center">222024283</h5>
            </a>
        </td>
        <td align="center">
            <a href="https://github.com/esteerlino">
                <img style="border-radius: 50%;" src="https://avatars.githubusercontent.com/u/90395392?v=4" width="150px;"/>
                <h5 class="text-center">Ester Flores Lino da Silva </h5>
              <h5 class="text-center">202063201</h5>
            </a>
        </td>
        <td align="center">
            <a href="https://github.com/GabrielMS00">
                <img style="border-radius: 50%;" src="https://avatars.githubusercontent.com/u/88348513?v=4" width="150px;"/>
                <h5 class="text-center">Gabriel Marques de Souza</h5>
                <h5 class="text-center">202016266</h5>
            </a>
        </td>
        <td align="center">
            <a href="https://github.com/Manoel835">
                <img style="border-radius: 50%;" src="https://avatars.githubusercontent.com/u/89036370?v=4" width="150px;"/>
                <h5 class="text-center">Manoel Felipe Teixeira Neto </h5>
                <h5 class="text-center">211041240</h5>
            </a>
        </td>      
        <td align="center">
            <a href="https://github.com/Mylena-angelica">
                <img style="border-radius: 50%;" src="https://github.com/Mylena-angelica.png" width="150px;"/>
                <h5 class="text-center">Mylena Angelica</h5>
              <h5 class="text-center">211029497</h5>
            </a>
        </td>
      <td align="center">
            <a href="https://github.com/wildemberg-sales">
                <img style="border-radius: 50%;" src="https://avatars.githubusercontent.com/u/92035272?v=4" width="150px;"/>
                <h5 class="text-center">Wildemberg Sales</h5>
              <h5 class="text-center">202017503</h5>
            </a>
        </td>
</table>
 <! -- ## :email: Site -->
<hr/>


## :bookmark_tabs: Estrutura do repositório


```bash
├─ docs/
|   ├── decisoes-tecnicas.md
|   ├── definicao-do-projeto.md
|   ├── index.md
|   ├── planejamento-sprints.md
|   └── planejamento-sprints.md
├─ src/
|   ├──  ast.c
|   ├── ast.h
|   ├──  portugol.l
|   ├──  portugol.y
|   ├──  tabela.c
|   ├──  tabela.h
|   ├──  tipos.h
|   └── tests/
│         ├── tests.sh
│         ├── portugol
│         └── tests_arquivos/
│                  ├── testes_ast/
│                             ├── ast_correct_1.txt
│                             ├── ast_correct_2.txt
│                             ├── ast_expressao_correta_1.txt
│                             ├── ast_expressao_correta_2.txt
│                             ├── ast_expressao_correta_3.txt
│                             ├── ast_incorrect_1.txt
│                             ├── ast_incorrect_2.txt
│                             ├── ast_incorrect_type_1.txt
│                             └── ast_incorrect_type_2.txt
│                  ├── testes_basicos/
│                             ├── imprima_resultado.txt
│                             ├── teste.txt
│                             ├── teste_debug.txt
│                             ├── teste_initial.txt
│                             └── teste_mensagem.txt
│                  ├── testes_decimais/
│                             ├── teste_decimal_correct.txt
│                             ├── teste_decimal_incorrect.txt
│                             └── teste_decimal_while.txt
│                  ├── testes_ifelse/
│                             ├── teste_if_correto_1.txt
│                             ├── teste_if_correto_2.txt
│                             ├── teste_if_correto_3.txt
│                             ├── teste_if_correto_4.txt
│                             ├── teste_if_debug.txt
│                             ├── teste_if_incorreto_1.txt
│                             ├── teste_if_incorreto_2.txt
│                             ├── teste_if_incorreto_3.txt
│                             └── teste_if_while.txt
│                  ├── testes_numeros_negativos/
│                             ├── teste_num_negativo_incorrect1.txt
│                             └── teste_numero_negativo_correct.txt
│                  ├── testes_operadores/
│                             ├── teste_aritimeticos.txt
│                             ├── teste_aritimeticos_incorretos.txt
│                             ├── testes_relacionais.txt
│                             └── testes_relacionais_incorretos.txt
│                  ├── teste_booleano.txt
│                  ├── teste_caractere.txt
│                  ├── teste_correcao_igual_operadores.txt
│                  ├── teste_logico.txt
│                  └── teste_vazio_erro_incompativel.txt
├─ mkdocs.yml
├─ README.md
└──

```

## :computer:  Como rodar os testes 

Depois de clonar o repositório, navegar até as pasta de testes.

```bash
cd src
cd testes
sh tests.sh
```

