# Registro de decisões (ADR)

Formato: ID — título · Status (`Aceita`, `Proposta`, `Substituída`) · Decisão · Motivo · Impactos.

## D001 — Linguagem C++

Status: Aceita

Decisão: o compilador será implementado em C++ (enunciado permite C++ ou Java).

Motivo: integração direta com Flex/Bison e com a infraestrutura C++ da disciplina.

Impactos: uso de `cool_yylval`, `Symbol`, `idtable`/`inttable`/`stringtable` e `cool-parse.h`.

## D002 — Flex como gerador léxico

Status: Aceita

Decisão: o scanner é descrito exclusivamente em `PA2/cool.flex`. Funções auxiliares ficam na seção de
*User subroutines*/*Declarations* do próprio arquivo (exigência de E§3).

Impactos: nenhum `.cc` auxiliar próprio no TP02.

## D003 — Integração centralizada

Status: Aceita

Decisão: apenas o integrador (Pessoa 1) faz merge em `main`. `main` deve sempre compilar.

## D004 — Divisão de responsabilidades

Status: Aceita

Decisão: P1 = core/tokens/erros genéricos/build/integração; P2 = strings; P3 = comentários/QA/testes/README.
Detalhe em `CONTRIBUTING.md`. O repositório registra só os papéis, sem nomes (Q04).

## D005 — Estratégia de branches

Status: Aceita

Decisão: `main` + `feature/core-scanner`, `feature/strings`, `feature/comments` (P3 também mantém os testes
nela ou em `feature/tests`), `docs/*`. PR para `main` (D016); ver `CONTRIBUTING.md`.

## D006 — Estados léxicos exclusivos para comentário e string

Status: Aceita (o esqueleto oficial não declara estados; Q12: sem restrições ao uso de `%x`)

Decisão: usar estados exclusivos (`%x`) `COMMENT`, `STRING` e `STRING_ERROR` (descarta o restante de uma string
após `too long`/`null character` até `"` ou newline).

Motivo: em estado exclusivo, as regras de INITIAL (keywords, operadores, fallback) não se aplicam, o que evita
tokenizar conteúdo de comentário/string por acidente. Cada estado precisa então da **sua própria regra
coringa e da sua própria regra `<<EOF>>`**, o que torna a completude explícita e revisável.

## D007 — Documentação e testes versionados junto ao código

Status: Aceita

Decisão: `PA2/docs/` e `PA2/tests/` são versionados e atualizados na mesma PR da funcionalidade.

## D008 — Finais de linha LF forçados

Status: Aceita

Decisão: `.gitattributes` força `eol=lf`; casos gerados byte a byte usam sufixo `.gen.cl` e são binários.

Motivo: parte da equipe usa Windows. CRLF introduz `\r` antes de cada `\n`, mudando o valor de strings
multilinha e o resultado de casos de erro.

## D009 — Nomes do esqueleto oficial prevalecem

Status: Aceita

Decisão: onde o esqueleto oficial já declara variáveis (`string_buf`, `string_buf_ptr`, `curr_lineno`,
`MAX_STR_CONST`, confirmados no `cool.flex.SKEL`), usamos esses nomes em vez dos sugeridos no prompt de
bootstrap (ex.: `string_buffer`). Ver conflito C1.

## D010 — Repositório multi-TP com subdiretório `PA2/`

Status: Aceita

Decisão: o repositório `Compilador-Cool` guarda os TPs 02–05; cada TP vive em seu diretório (`PA2/`, depois
`PA3/`...), que é exatamente o diretório criado por `make -f /var/tmp/cool/assignments/PA2/Makefile` e
empacotado na entrega (`tar cvzf PA2.tar.gz PA2`).

## D011 — Não versionar os links simbólicos da infraestrutura

Status: Aceita (Q03 respondida pelo Makefile do pacote)

Decisão: versionamos só as cópias editáveis `cool.flex`, `test.cl` e `README`. Os symlinks que o Makefile cria
(`Makefile`, `lextest.cc`, `utilities.cc`, `stringtab.cc`, `handle_flags.cc`, `mycoolc`, `parser`, `semant`,
`cgen`) ficam no `.gitignore`; cada integrante os recria com `make -f /var/tmp/cool/assignments/PA2/Makefile`
depois de clonar. O `copy-skel` não sobrescreve arquivos existentes, então o comando é seguro sobre um clone.

Motivo: symlinks absolutos quebram em máquinas sem `/var/tmp/cool` e o clone no Windows
(`core.symlinks=false`) os transforma em arquivos de texto. Copiar os arquivos é explicitamente
desaconselhado pelo enunciado (E§3).

## D012 — Desenvolver em Linux/WSL, com a infraestrutura em `/var/tmp/cool`

Status: Aceita (Q01 respondida pelo `00_config`)

Decisão: cada integrante instala o `x86_64.u` em `/var/tmp/cool` num Linux (nativo, VM ou WSL) e faz o clone de
trabalho no sistema de arquivos Linux (`~/`), não em `C:\...\OneDrive` via `/mnt/c`.

Motivo: o caminho `/var/tmp/cool` é obrigatório (`00_config` §2). Symlinks, permissões de execução e
desempenho do build falham ou degradam em OneDrive/`/mnt/c`.

Impactos: o ambiente validado pela disciplina é o Ubuntu 16.04; versões novas funcionam (binários de
referência testados no Ubuntu 26.04), mas precisam de `libfl-dev` para o `-lfl`. Ver D015 e `SETUP.md`.

## D013 — Lexer de referência como oráculo de testes

Status: Aceita

Decisão: `scripts/run_tests.sh` usa `REF_LEXER=/var/tmp/cool/lib/.x86_64/lexer` como oráculo padrão. Arquivos
`.out` escritos à mão só para casos em que divergimos da referência (D014).

## D014 — Nas divergências, o texto do enunciado prevalece sobre o lexer de referência

Status: Aceita (Q14, 2026-09-18)

Decisão:

- C5: a mensagem é `String contains null character`, sem ponto final (E§4.1).
- C6: `\` seguido de NUL real também é um caractere nulo dentro da string, então gera a mesma mensagem
  `String contains null character`. E§4.1 define uma única mensagem para esse caso.
- C7: uma string que passa de 1024 caracteres gera `String constant too long` mesmo que depois termine num
  newline sem escape. O erro é reportado na linha da string; a análise retoma no início da linha seguinte
  (E§4.1, item 1 da definição de "final do string"). A linha do erro segue o mesmo critério que a referência
  usa para NUL seguido de newline: o erro sai antes de o `\n` ser consumido.

Motivo: o enunciado é a fonte de maior prioridade (ordem de fontes do projeto).

Impactos: `tests/cases/strings/null_char.gen.out` e `too_long.gen.out` guardam a saída esperada (a da
referência com essas três diferenças). Se `gen_cases.sh` mudar esses casos, os `.out` precisam ser refeitos.
A justificativa entra no README de entrega (DOC-001). Se a Q10 revelar correção automática contra a
referência, revisitar esta decisão.

## D015 — Desenvolvimento no WSL, validação final no Ubuntu 16.04

Status: Aceita (Q02, 2026-09-18)

Decisão: o dia a dia é no WSL (Ubuntu recente, com `libfl-dev`). No M5, o scanner é compilado e a suíte roda
uma vez num container `ubuntu:16.04` com o `x86_64.u` instalado, o ambiente validado pelo `00_config`.

Motivo: o WSL já roda os binários de referência; o 16.04 elimina o risco de o `cool.flex` depender de
comportamento de uma versão nova do flex ou do g++.

Impactos: tarefa M5.1 em `MILESTONES.md`. Qualquer diferença entre os dois ambientes vira bug a corrigir antes
da entrega. Com o prazo de 20/09 (Q05), a M5.1 só acontece se sobrar tempo.

## D016 — Fluxo de integração por Pull Request

Status: Aceita (Q07, 2026-09-18)

Decisão: todo código entra na `main` por PR. Review de outra pessoa é recomendado e passa a ser obrigatório
quando a mudança sai do próprio bloco de `cool.flex`.

---

## Conflitos registrados

| ID | Conflito | Resolução |
|---|---|---|
| C1 | Prompt sugere `string_buffer`; o esqueleto oficial declara `string_buf`/`string_buf_ptr` e `#define MAX_STR_CONST 1025` (no próprio `cool.flex`) | Esqueleto prevalece (D009). Confirmado no `cool.flex.SKEL` do pacote. |
| C2 | Prompt prevê docs próprios; E§8 diz "Apenas altere o arquivo fornecido" para o README | As notas de entrega vão **no README oficial**. `docs/` é apoio interno e fonte para o texto final. |
| C3 | Prompt mantém `test.cl` "oficial" e testes em `tests/cases/`; E§3 pede para **modificar** `test.cl` com nossos testes | Os dois: `tests/cases/` para isolar falhas; no M5/M6 os casos relevantes são consolidados em `test.cl`. |
| C4 | Prompt lista a entrega em `PA2.u` como dúvida | Confirmado por E§8: `PA2.u` via Canvas. |
| C5 | E§4.1: `String contains null character`; lexer de referência: `String contains null character.` (com ponto) | Enunciado (D014). |
| C6 | `\` seguido de NUL real: E§4.1 não cita; referência: `String contains escaped null character.` | Enunciado: mesma mensagem de C5 (D014). |
| C7 | String > 1024 caracteres que termina num newline sem escape: E§4.1 manda `String constant too long` e retomar na próxima linha; a referência reporta só `Unterminated string constant` | Enunciado (D014). |
| C8 | Slides `02-projeto-trabalho-pratico.pdf` dizem "equipes de até 05 alunos"; E§1 diz dupla ou trio | E§1 prevalece: os slides são de outro professor/semestre. |
