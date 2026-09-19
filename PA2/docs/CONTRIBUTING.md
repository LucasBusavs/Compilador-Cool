# Como contribuir

## Ownership

| Pessoa | Papel | Branch | Bloco em `cool.flex` |
|---|---|---|---|
| P1 | Core / Integrador | `feature/core-scanner` | Declarations, Definitions, CORE TOKENS, FALLBACK / ERRORS |
| P2 | Strings | `feature/strings` | STRINGS (+ `%x STRING STRING_ERROR`) |
| P3 | Comentários / QA | `feature/comments` (e `feature/tests`, se quiser separar) | COMMENTS (+ `%x COMMENT`), `tests/`, `test.cl`, README final |

O repositório registra só os papéis; o grupo decide entre si quem ocupa cada um (Q04).

Regras:

- Não editar o bloco de outra pessoa sem avisar o dono e o integrador.
- Variáveis e helpers compartilhados: combinar antes e registrar em `ARCHITECTURE.md`.
- `curr_lineno`: cada estado incrementa só no `\n` que ele consome. Ninguém cria contagem paralela.
- Erros: todos seguem o protocolo único de `ARCHITECTURE.md`. Ninguém imprime nada.
- Nunca editar os arquivos da infraestrutura (symlinks para `/var/tmp/cool`).

## Branches

- `main`: sempre compila. Só o integrador faz merge.
- `feature/<tema>`, `fix/<tema>`, `docs/<tema>`, `test/<tema>`.
- Atualize com `git pull --rebase origin main` antes de abrir PR.

## Commits

Conventional commits, pequenos e em português ou inglês (sem misturar na mesma mensagem):

```text
feat: recognize COOL keywords
feat: add nested comment state
fix: recover scanner after unterminated string
test: add EOF in comment cases
docs: update requirements matrix
chore: add test runner
```

Proibido: `update`, `changes`, `final`, `fix stuff`.

## Pull requests

Todo código entra na `main` por PR (D016). Review de outra pessoa é recomendado e **obrigatório** quando a
mudança sai do próprio bloco de `cool.flex`. Ambiente e comandos: [SETUP.md](SETUP.md).

Checklist na descrição:

- [ ] branch atualizada com `main`
- [ ] `make lexer` compila sem warnings novos
- [ ] `scripts/run_tests.sh` passa (anexar o resumo)
- [ ] nenhum arquivo gerado (`cool-lex.cc`, `lexer`, `*.o`) ou symlink da infraestrutura no diff
- [ ] `REQUIREMENTS.md` (status) e `TEST_PLAN.md` atualizados
- [ ] revisado por pelo menos 1 outra pessoa (obrigatório se mexe fora do próprio bloco)
- [ ] mensagens de erro exatamente como no enunciado (D014), sem `printf`/`cout` no scanner

## Definition of Done

Implementado · compila · tem caso de teste (válido, limítrofe e inválido quando aplicável) · comportamento
esperado documentado · erros aplicáveis testados · regressão passa · integração revisada.

## Estilo

- `snake_case` para variáveis/funções nossas; `UPPER_CASE` para constantes.
- Não renomear nomes da infraestrutura: `cool_yylval`, `curr_lineno`, `cool_yylex`, `yytext`, tokens.
- Comentar decisões não óbvias, ordem crítica de regras, mudanças de estado e recuperação de erro. Nada de
  comentário que só repete o código.
- Não reorganizar regras por estética: a ordem muda o comportamento.
- Arquivos sempre em LF (garantido por `.gitattributes`).
