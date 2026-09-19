# Requisitos — TP02 Análise Léxica (COOL, C++/Flex)

Fontes (em ordem de prioridade):

- **E** = Enunciado `02_analise-lexica-1.pdf` (seção indicada, ex.: E§4.1)
- **M** = Manual de Referência COOL, Seção 10 e Figura 1. **Ainda não está no repositório** (Q08: o
  responsável vai buscar no Canvas). Itens marcados `M*` vêm da versão padrão do manual e o lexer de referência
  já confirma o comportamento; a conferência no texto fica para quando o manual chegar.
- **H** = `cool-parse.h` oficial (`/var/tmp/cool/include/PA2/`). Os tokens marcados `H*` foram **confirmados**
  no pacote `x86_64.u`: `CLASS`…`LE` (258–282), `ERROR` (283), `LET_STMT` (285); `YYSTYPE` tem `symbol`,
  `boolean` e `error_msg`.
- **R** = lexer de referência (`/var/tmp/cool/lib/.x86_64/lexer`). Onde ele diverge de E, vale E (D014).

Status: `Pending` · `In progress` · `Done` · `Blocked`

## Matriz de rastreabilidade

### Tokens válidos — Pessoa 1 (Core)

| ID | Requisito | Fonte | Teste | Resp. | Status |
|---|---|---|---|---|---|
| LEX-001 | Palavras-chave case-insensitive: `class else fi if in inherits isvoid let loop pool then while case esac new of not` → tokens `CLASS ELSE FI IF IN INHERITS ISVOID LET LOOP POOL THEN WHILE CASE ESAC NEW OF NOT` | M*, H* | `tests/cases/keywords/` | P1 | Pending |
| LEX-002 | `true`/`false`: 1ª letra obrigatoriamente minúscula, restante case-insensitive → `BOOL_CONST`, valor em `cool_yylval.boolean` | E§5, M* | `tests/cases/keywords/booleans.cl` | P1 | Pending |
| LEX-003 | `TYPEID`: inicia com maiúscula, seguido de letras/dígitos/`_` → `cool_yylval.symbol = idtable.add_string(...)` | E§5, M* | `tests/cases/identifiers/` | P1 | Pending |
| LEX-004 | `OBJECTID`: inicia com minúscula, seguido de letras/dígitos/`_` → `idtable` | E§5, M* | `tests/cases/identifiers/` | P1 | Pending |
| LEX-005 | `Object Int Bool String SELF_TYPE self` tratados como identificadores comuns | E§4.2 | `tests/cases/identifiers/special.cl` | P1 | Pending |
| LEX-006 | `INT_CONST` = `[0-9]+` → `inttable`; **sem** checagem de overflow | E§4.2 | `tests/cases/basic/integers.cl` | P1 | Pending |
| LEX-007 | Operadores compostos: `=>` `DARROW`, `<-` `ASSIGN`, `<=` `LE` | M*, H* | `tests/cases/operators/` | P1 | Pending |
| LEX-008 | Tokens de 1 caractere retornados pelo próprio código ASCII: `+ - * / ~ < = ( ) { } ; : . , @` | E§5, M* | `tests/cases/operators/` | P1 | Pending |
| LEX-009 | Whitespace ignorado: espaço, `\n`, `\f`, `\r`, `\t`, `\v` | M* | `tests/cases/basic/whitespace.gen.cl` | P1 | Pending |
| LEX-010 | `curr_lineno` reflete a linha corrente em **todos** os estados (INITIAL, comentário, string) | E§4.4 | todos | P1 (contrato) | Pending |
| LEX-011 | Caractere inválido → `ERROR` com string contendo apenas esse caractere; retoma no próximo | E§4.1 | `tests/cases/errors/invalid_chars.cl` | P1 | Pending |

### Comentários — Pessoa 3

| ID | Requisito | Fonte | Teste | Resp. | Status |
|---|---|---|---|---|---|
| LEX-012 | Comentário de linha `--` até o fim da linha (ou EOF) | M* | `tests/cases/comments/line.cl`, `line_eof.gen.cl` | P3 | Pending |
| LEX-013 | Comentário de bloco `(* ... *)` **aninhável** | M* | `tests/cases/comments/block.cl`, `nested.cl`, `tricky.cl` | P3 | Pending |
| LEX-014 | EOF dentro de comentário → `ERROR "EOF in comment"`; a chamada seguinte retorna EOF (0) | E§4.1 | `tests/cases/comments/eof_in_comment.gen.cl`, `eof_in_nested_comment.gen.cl` | P3 | Pending |
| LEX-015 | Conteúdo de comentário não terminado **não** é tokenizado | E§4.1 | idem LEX-014 | P3 | Pending |
| LEX-016 | `*)` fora de comentário → `ERROR "Unmatched *)"` (não `*` + `)`) | E§4.1 | `tests/cases/comments/unmatched.cl` | P3 | Pending |

### Strings — Pessoa 2

| ID | Requisito | Fonte | Teste | Resp. | Status |
|---|---|---|---|---|---|
| LEX-017 | `STR_CONST` com valor já processado → `stringtable.add_string(...)` | E§4.3, E§5 | `tests/cases/strings/basic.cl` | P2 | Pending |
| LEX-018 | Escapes: `\b \t \n \f` viram os caracteres correspondentes; `\c` (qualquer outro c) vira `c`; `\0` vira o caractere `'0'` | E§4.3, M* | `tests/cases/strings/escapes.cl` | P2 | Pending |
| LEX-019 | Barra invertida seguida de newline real → newline no valor; incrementa `curr_lineno` | M* | `tests/cases/strings/escaped_newline.cl` | P2 | Pending |
| LEX-020 | Newline sem escape → `ERROR "Unterminated string constant"`; retoma no início da próxima linha | E§4.1 | `tests/cases/strings/unterminated.cl` | P2 | Pending |
| LEX-021 | String com mais de 1024 caracteres (após escapes; `MAX_STR_CONST` = 1025 no esqueleto) → `ERROR "String constant too long"`, inclusive quando depois vem um newline sem escape (D014/C7); retoma após `"` de fechamento ou no início da próxima linha | E§4.1 | `tests/cases/strings/too_long.gen.cl` + `.out` | P2 | Pending |
| LEX-022 | Caractere nulo real na string → `ERROR "String contains null character"`, **sem** ponto final (D014/C5); mesma regra de retomada de LEX-021 | E§4.1, E§4.3 | `tests/cases/strings/null_char.gen.cl` + `.out` | P2 | Pending |
| LEX-023 | EOF dentro de string → `ERROR "EOF in string constant"`; a chamada seguinte retorna EOF | E§4.1 | `tests/cases/strings/eof_in_string.gen.cl`, `eof_after_backslash.gen.cl` | P2 | Pending |
| LEX-028 | `\` seguido de NUL real → `ERROR "String contains null character"`, a mesma mensagem de LEX-022 (D014/C6; a referência usa outra) | E§4.1 | `tests/cases/strings/null_char.gen.cl` + `.out` | P2 | Pending |

### Transversais — Pessoa 1 (integrador)

| ID | Requisito | Fonte | Teste | Resp. | Status |
|---|---|---|---|---|---|
| LEX-024 | Erros vão para `cool_yylval.error_msg` (`char*` comum, não `Symbol`) com token `ERROR`; scanner **não imprime nada** | E§4.1, E§5 | todos os `errors/` | P1 | Pending |
| LEX-025 | Especificação completa: toda entrada casa com alguma regra, em todos os estados; sem core dump nem exceção | E§4, E§4.4 | `tests/cases/errors/`, `integration/` | P1 | Pending |
| LEX-026 | Ignorar os tokens `LET_STMT` e `error` (minúsculo) neste TP | E§4.1, E§4.4 | — (revisão) | P1 | Pending |
| LEX-027 | Scanner continua corretamente após erros recuperáveis (vários erros no mesmo arquivo) | E§4.1 | `tests/cases/integration/many_errors.cl` | P3 | Pending |

### Entrega e documentação

| ID | Requisito | Fonte | Resp. | Status |
|---|---|---|---|---|
| DOC-001 | Editar o **final do README oficial**: decisões de design, por que está correto, por que os testes são adequados | E§3, E§8 | P3 + P1 | Pending |
| DOC-002 | Modificar `test.cl` com testes que verifiquem adequadamente o scanner | E§3 | P3 | Pending |
| DOC-003 | Código de `cool.flex` comentado | E§3 | todos | Pending |
| ENT-001 | `make submit-clean` → `tar cvzf PA2.tar.gz PA2` → `uuencode` → um único `PA2.u` entregue no Canvas até 20/09/2026 23:59 | E§8, Q05, Q09 | P1 | Pending |

## Checklist rápida

```text
[ ] Keywords (LEX-001)            [ ] Comentário de linha (LEX-012)
[ ] BOOL_CONST (LEX-002)          [ ] Comentário aninhado (LEX-013)
[ ] TYPEID / OBJECTID (003-005)   [ ] EOF in comment (LEX-014/015)
[ ] INT_CONST (LEX-006)           [ ] Unmatched *) (LEX-016)
[ ] Operadores (LEX-007/008)      [ ] STR_CONST + escapes (017-019)
[ ] Whitespace (LEX-009)          [ ] Unterminated string (LEX-020)
[ ] curr_lineno (LEX-010)         [ ] String too long (LEX-021)
[ ] Caractere inválido (LEX-011)  [ ] Null character (LEX-022)
[ ] Protocolo de erro (LEX-024)   [ ] EOF in string (LEX-023)
[ ] Especificação completa (025)  [ ] Recuperação após erros (LEX-027)
[ ] Escaped null (LEX-028)        [ ] Código comentado (DOC-003)
[ ] README final (DOC-001)        [ ] test.cl atualizado (DOC-002)
[ ] PA2.u gerado e enviado (ENT-001)
```

## Pontos confirmados e pendentes

- Confirmado: limite de string = `MAX_STR_CONST` (1025, definido no próprio `cool.flex`), ou seja, 1024
  caracteres após processar escapes. Usar a constante, não o número.
- Confirmado com R: `\0` vira `"0"`; `(*)` abre comentário; retomada após `"` depois de too long / null.
- Decidido: nas divergências E × R, vale E (D014).
- Pendente: requisitos `M*` contra o Manual (Q08).
