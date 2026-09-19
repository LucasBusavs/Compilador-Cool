# Perguntas do projeto

Prioridade: `BLOCKER` impede começar · `HIGH` impede concluir um milestone · `MEDIUM` afeta qualidade ·
`LOW` não trava nada (seguimos com a suposição indicada).

Resumo (2026-09-18): 12 respondidas; 2 em aberto (Q08 e Q10), nenhuma bloqueante.

Já respondido pelas fontes (não perguntar de novo): linguagem/ferramenta (D001/D002), formato de entrega
(`PA2.u` via Canvas, E§8), mensagens de erro exatas do enunciado (E§4.1), `\0` → `'0'` (E§4.3), sem
checagem de overflow (E§4.2), grupos de até 3 (E§1).

Material consultado:

- `02_analise-lexica-1.pdf`: enunciado do TP02;
- `00_config.pdf`: instalação do ambiente (Ubuntu 16.04, dependências, `/var/tmp/cool`);
- `x86_64.u`: pacote da disciplina (esqueletos, headers, código de suporte, binários de referência);
- `01_extra.pdf`: TP01 (individual; não afeta o TP02);
- `02-projeto-trabalho-pratico.pdf`: slides de introdução à COOL de **outro professor/semestre**. Não é o
  Manual e não vale como fonte de requisito (o "máximo de 05 alunos" ali não se aplica: E§1 diz dupla ou trio).

---

## Abertas

### Q08 · MEDIUM · Manual de Referência COOL usado na disciplina

- O pacote `x86_64.u` **não** traz o manual (`doc/` só tem flex, bison, make e spim; `handouts/` está vazia).
- Por quê: requisitos `M*` precisam ser conferidos na Seção 10 / Figura 1. Enquanto isso, o lexer de
  referência serve de oráculo prático.
- Andamento (2026-09-18): o responsável vai buscar o manual no Canvas e anexar. Quando chegar, P3 confere os
  itens `M*` de `REQUIREMENTS.md` contra a Seção 10 / Figura 1.
- Status: Aguardando o PDF

### Q10 · MEDIUM · Avaliação automática ou testes ocultos?

- Por quê: pela D014, seguimos o enunciado onde ele diverge da referência. Se a correção comparar byte a byte
  com o lexer de referência, os casos C5–C7 divergem; vale confirmar com o professor.
- Andamento (2026-09-18): o responsável não sabe; **perguntar ao professor**. Até lá, mantemos a D014 e
  justificamos no README. Se a resposta for "correção automática contra a referência", revisitar a D014: basta
  trocar três mensagens e apagar os dois `.out`.
- Status: Aguardando o professor

---

## Respondidas

### Q01 · BLOCKER · Onde está a infraestrutura `/var/tmp/cool`? — Respondida

- Resposta (`00_config` §2): cada integrante instala localmente o `x86_64.u` do Canvas em `/var/tmp/cool`
  (o caminho é obrigatório: o SPIM depende dele). Passo a passo em `SETUP.md`.
- Decisão resultante: desenvolvimento em Linux/WSL com a infraestrutura local (D012).

### Q02 · HIGH · Onde desenvolver e onde validar? — Respondida

- Contexto: o ambiente validado pela disciplina é o Ubuntu 16.04 (`00_config`). Os binários de referência
  rodam no WSL Ubuntu 26.04 (verificado em 2026-09-18).
- Resposta (responsável, 2026-09-18): **desenvolver no WSL atual e, no M5, compilar e testar uma vez num
  container `ubuntu:16.04`**.
- Decisão resultante: D015.

### Q03 · HIGH · Quais arquivos são symlink × cópia? — Respondida

- Resposta (`assignments/PA2/Makefile` do pacote):
  - cópias editáveis (`copy-skel`): `cool.flex`, `test.cl`, `README`;
  - symlinks para `/var/tmp/cool`: `Makefile` (`link-shared`); `lextest.cc`, `utilities.cc`, `stringtab.cc`,
    `handle_flags.cc`, `mycoolc` (`src/PA2`); `parser`, `semant`, `cgen` (`link-object`, `lib/.x86_64/PA2`);
  - headers não são copiados: o Makefile usa `-I/var/tmp/cool/include/PA2 -I/var/tmp/cool/src/PA2`;
  - gerados: `cool-lex.cc`, `*.o`, `*.d`, `lexer`, `test.output`.
- Decisão resultante: D011.

### Q04 · HIGH · Integrantes e papéis — Respondida

- Resposta (responsável, 2026-09-18): não importa quem ocupa cada papel.
- Decisão resultante: a documentação usa só os papéis P1 (core/integrador), P2 (strings) e P3
  (comentários/QA); o grupo distribui as pessoas entre si, sem registrar nomes no repositório.

### Q05 · HIGH · Data e horário exatos da entrega — Respondida

- Resposta (responsável, 2026-09-18): **20/09/2026 às 23:59**.
- Decisão resultante: cronograma datado em `MILESTONES.md`; a checagem no 16.04 (M5.1) passa a ser opcional.

### Q06 · HIGH · Existe lexer de referência? — Respondida

- Resposta: sim, `/var/tmp/cool/lib/.x86_64/lexer` (binário x86-64 de 2019). Testado no WSL.
- Decisão resultante: é o oráculo padrão do `run_tests.sh` (D013). Revelou os conflitos C5–C7 (Q14).

### Q07 · MEDIUM · PR e review obrigatórios? — Respondida

- Resposta (responsável, 2026-09-18): **PR obrigatório para `main`; review recomendado**, obrigatório só
  quando a mudança sai do próprio bloco de `cool.flex`.
- Decisão resultante: D016; regra descrita em `CONTRIBUTING.md` (seção "Pull requests").

### Q09 · MEDIUM · Identificação do grupo na entrega — Respondida

- Resposta (responsável, 2026-09-18): **um único `PA2.u` por grupo**, enviado por um integrante, com nomes e
  matrículas dos três no topo das notas do README oficial.
- Decisão resultante: incluído no M6 de `MILESTONES.md`. Os nomes entram só no README de entrega, na hora da
  entrega (Q04: o repositório não registra quem ocupa cada papel).

### Q11 · LOW · `docs/`, `tests/` e `scripts/` vão na entrega? — Respondida

- Resposta (responsável, 2026-09-18): **sim, vai tudo**. Mostram a estratégia de testes que o enunciado cobra.
- Decisão resultante: no M6, apagar `tests/out/` antes do `tar` (o `make submit-clean` não a remove).

### Q12 · LOW · Restrições a STL / `std::string` / `%x`? — Respondida

- Resposta (responsável, 2026-09-18): **sem restrições**.
- Decisão resultante: mesmo assim ficamos com a solução simples: `string_buf` do esqueleto, estados `%x`
  (D006) e helpers na seção de *User subroutines*. O esqueleto só pede para não remover nada do bloco `%{ %}`.

### Q13 · LOW · Prioridade do grupo — Respondida

- Resposta (responsável, 2026-09-18): **equilíbrio**. Scanner aderente e simples, testes cobrindo toda a
  matriz de requisitos e README claro, sem refatoração nem modularidade extra.

### Q14 · HIGH · Seguir o texto do enunciado ou a saída do lexer de referência? — Respondida

- Contexto: conflitos C5, C6 e C7 em `DECISIONS.md` (ponto final na mensagem de NUL; mensagem própria para `\`
  seguido de NUL; string longa que termina num newline sem escape).
- Resposta (responsável, 2026-09-18): **seguir o texto do enunciado**.
- Decisão resultante: D014. Os casos afetados têm `.out` manual em `tests/cases/strings/`.
- Risco aceito: se a correção comparar com o lexer de referência byte a byte (Q10), esses três casos
  divergem. A justificativa vai no README.
