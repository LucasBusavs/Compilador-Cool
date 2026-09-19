# Milestones

Prazo final: **20/09/2026 às 23:59, no Canvas** (Q05). Começamos em 18/09, então o cronograma é apertado e
cada marco tem uma data-alvo com folga antes do prazo.

| Marco | Data-alvo | Observação |
|---|---|---|
| M0 | 18/09 (noite) | ambiente instalado por todos + esqueleto seccionado na `main` |
| M1 / M2 / M3 | 19/09, 18:00 | em paralelo; cada um com os próprios testes passando |
| M4 | 19/09, 23:00 | integração na `main` + regressão completa |
| M5 | 20/09, 16:00 | validação; M5.1 (16.04) só se sobrar tempo |
| M6 | 20/09, 21:00 | README final + `PA2.u` gerado e verificado; envio com ~3h de folga |

```text
M0 ──► M1 (P1) ─┐
   ├─► M2 (P3) ─┼─► M4 integração ─► M5 validação ─► M6 entrega
   └─► M3 (P2) ─┘
```

M1, M2 e M3 rodam **em paralelo** depois do M0. O único ponto de sincronização antes do M4 é o esqueleto
seccionado de `cool.flex` (tarefa M0.4). Instalação e comandos: [SETUP.md](SETUP.md).

---

## M0 — Bootstrap e entendimento · Status: em andamento

| # | Tarefa | Resp. | Status |
|---|---|---|---|
| 0.1 | Estrutura de docs/tests/scripts, `.gitignore`, `.gitattributes` | P1 | Feito |
| 0.2 | Todas as perguntas bloqueantes respondidas (`QUESTIONS.md`) | responsável | Feito |
| 0.3 | Cada integrante instala o ambiente seguindo [SETUP.md](SETUP.md), passos 1 a 5, e confere que o lexer de referência roda | todos | Pendente |
| 0.4 | P1 roda `make -f /var/tmp/cool/assignments/PA2/Makefile`, confere que `make lexer` compila o esqueleto e faz commit de `cool.flex`, `test.cl` e `README` originais, com os delimitadores de seção, os `%x` e as variáveis combinadas em ARCHITECTURE.md | P1 | Pendente |
| 0.5 | Conferir REQUIREMENTS/ARCHITECTURE contra o Manual quando ele chegar (Q08) | P3 | Aguardando o manual |

Conclusão: sabemos o que é editável, como compilar e testar, quais tokens existem, quem faz o quê e o que
ainda bloqueia. A 0.5 não trava o M1–M3.

## M1 — Scanner base · P1 · branch `feature/core-scanner`

Whitespace, linhas, keywords, booleanos, TYPEID, OBJECTID, INT_CONST, operadores, símbolos simples, caractere
inválido. Requisitos LEX-001…011, LEX-024…026.

Conclusão: casos em `tests/cases/{basic,keywords,identifiers,operators,errors}` passam.

## M2 — Comentários · P3 · branch `feature/comments`

Linha, bloco, aninhado, linhas dentro de comentário, EOF em comentário, `Unmatched *)`. LEX-012…016.

Conclusão: todos os casos de comentários do TEST_PLAN passam.

## M3 — Strings · P2 · branch `feature/strings`

STR_CONST, escapes, buffer, tamanho, NULL, newline, EOF, recuperação. LEX-017…023 e LEX-028, com as
mensagens do enunciado onde ele diverge da referência (D014).

Conclusão: todos os casos de strings do TEST_PLAN passam.

## M4 — Integração · P1

Merge de M1+M2+M3 em `main`, revisão de ordem de regras/estados/`cool_yylval`/string tables, regressão
completa com `scripts/run_tests.sh`.

Conclusão: `main` compila e passa todos os testes internos.

## M5 — Validação completa · P3 (lidera) + todos

`test.cl`, suíte auxiliar, `./lexer`, `mycoolc`, programas válidos e malformados, EOF em todos os estados,
revisão de `curr_lineno`, vários erros no mesmo arquivo. Consolidar casos em `test.cl` (DOC-002).

**M5.1 — Checagem no Ubuntu 16.04 (D015), se o prazo permitir:** num container `ubuntu:16.04` com as dependências do
`00_config` e o `x86_64.u` instalado, rodar `make lexer` e `scripts/run_tests.sh`. O resultado precisa ser
idêntico ao do WSL.

Conclusão: nenhum requisito da matriz sem teste, e a suíte passa no WSL e no 16.04.

## M6 — Documentação e entrega · P1 (entrega) + P3 (texto)

1. README oficial (DOC-001): começa com nomes e matrículas dos três integrantes (Q09); explica decisões de
   design (incluindo a D014), por que o scanner está correto e por que os testes são adequados.
2. Revisão final dos comentários de `cool.flex`.
3. `git status` limpo na `main`, com o merge final feito; criar a tag `tp02-entrega`.
4. Empacotar. `docs/`, `tests/` e `scripts/` vão junto (Q11); as saídas do runner não, e o
   `make submit-clean` não as remove:

```bash
cd ~/Compilador-Cool/PA2
make submit-clean          # roda ./lexer test.cl (gera test.output) e apaga objetos, lexer e cool-lex.cc
rm -rf tests/out
cd ..                      # Compilador-Cool/, o diretório que contém PA2/
tar cvzf PA2.tar.gz PA2
uuencode PA2.tar.gz PA2.tar.gz > PA2.u
rm PA2.tar.gz
```

5. Conferir o pacote numa pasta temporária antes de enviar:

```bash
mkdir -p /tmp/confere && cp PA2.u /tmp/confere && cd /tmp/confere
uudecode PA2.u && tar tzf PA2.tar.gz     # deve listar PA2/cool.flex, PA2/README, PA2/test.cl, PA2/docs/...
```

6. Um integrante envia o `PA2.u` no Canvas. O `PA2.u` não é versionado (`.gitignore`).

Conclusão: `PA2.u` gerado, verificado e enviado no Canvas.
