# Plano de testes

## Estratégia

1. **Casos pequenos e focados** em `tests/cases/<categoria>/`, cada um exercitando um requisito
   (válido, limítrofe e inválido). Falha em um caso aponta direto para a regra culpada.
2. **Oráculo** (D013):
   - padrão: lexer de referência `/var/tmp/cool/lib/.x86_64/lexer`, que o `scripts/run_tests.sh` usa
     automaticamente e roda na hora;
   - exceção: um arquivo `<caso>.out` ao lado do `.cl` tem prioridade. Só serve para casos em que decidirmos
     divergir da referência (D014), com justificativa no README.
3. **Regressão**: `scripts/run_tests.sh` roda todos os casos antes de cada PR e após cada merge em `main`.
   O runner usa `timeout` para detectar laço infinito (bug clássico no `<<EOF>>`).
4. **Integração**: `test.cl` + programas completos em `tests/cases/integration/` + `mycoolc` (M5).
5. Casos que dependem de bytes exatos (NUL, sem newline final, string de 1025 caracteres) são gerados por
   `scripts/gen_cases.sh` e salvos como `*.gen.cl` (binários no Git).

Formato da saída do `./lexer` (confirmado em `utilities.cc`): cabeçalho `#name "<arquivo>"` e uma linha
`#<linha> <TOKEN> [valor]` por token. Como rodar: [SETUP.md](SETUP.md), seção 7.

Estado atual: todos os casos abaixo existem em `tests/cases/`, e o runner foi validado com o lexer de
referência (26 casos batem; os 2 com `.out` divergem de propósito, D014).

## Casos

Legenda: V = válido, L = limítrofe, I = inválido.

### Tokens básicos — P1

| Caso | Tipo | Entrada (resumo) | Esperado |
|---|---|---|---|
| `basic/whitespace.gen.cl` | V | espaços, tabs, `\f`, `\v`, `\r`, linhas vazias entre tokens | só os tokens, com linhas corretas |
| `basic/integers.cl` | V/L | `0`, `007`, `123`, número com 40 dígitos, `12abc` | `INT_CONST` com o texto literal (sem overflow); `12abc` → INT_CONST `12` + OBJECTID `abc` |
| `keywords/keywords.cl` | V/L | todas as keywords em minúsculas, MAIÚSCULAS e mistas | tokens de keyword |
| `keywords/booleans.cl` | V/L/I | `true false`, `tRUE fAlSe`, `TRUE False`, `trueish falsey` | `BOOL_CONST` para as quatro primeiras; `TYPEID` para `TRUE`/`False`; OBJECTID para `trueish`/`falsey` |
| `identifiers/identifiers.cl` | V/L | `x`, `x_1`, `X`, `Foo_Bar9`, `_x` | OBJECTID/TYPEID; `_` inicial é inválido → ERROR `_` + OBJECTID `x` |
| `identifiers/special.cl` | V | `Object Int Bool String SELF_TYPE self` | TYPEID…, TYPEID `SELF_TYPE`, OBJECTID `self` |
| `identifiers/keyword_prefix.cl` | L | `classe iff ifx elsewhere letter notx newer` | OBJECTID (maior casamento vence a keyword) |
| `operators/operators.cl` | V | `=> <- <= + - * / ~ < = ( ) { } ; : . , @` | DARROW, ASSIGN, LE e os ASCII |
| `operators/adjacent.cl` | L | `a<-b<=c=>d`, `x<--1`, `<=>`, `f(x,y).g@A.h()` | maior casamento: `<-` e depois `-`, `1`; `<=` e depois `>` inválido |
| `errors/invalid_chars.cl` | I | `[ ] ! # $ % ^ & > ? ` + crase, barra vertical, barra invertida e `_` entre identificadores | um ERROR por caractere, scanner continua. A acrescentar: bytes ≥ 128 e caracteres de controle (via `gen_cases.sh`) |

### Comentários — P3

| Caso | Tipo | Entrada | Esperado |
|---|---|---|---|
| `comments/line.cl` | V/L | `x -- texto`, linha inteira comentada com `(*` dentro, `y ---` | só `x` e `y` |
| `comments/block.cl` | V/L | `(* x *)`, `(**)`, bloco em várias linhas | só `a`, `b`, `c`, `d`; linhas contadas |
| `comments/nested.cl` | V | `(* a (* b *) c *) x`, três níveis, aninhado em várias linhas | só `x`, `y`, `z` |
| `comments/unmatched.cl` | I | `*)` solto, `(* ok *) *)`, `**)` | ERROR `Unmatched *)` (em `**)`: `*` e depois o erro) |
| `comments/tricky.cl` | L | `(*)`, `(* -- *)`, `-- (*`, `(* "string *)` | só `a`, `b`, `c`, `d` (nota ¹) |
| `comments/line_eof.gen.cl` | L | `--` na última linha, sem newline final | só `x`, sem erro |
| `comments/eof_in_comment.gen.cl` | I | `(* sem fim` | um ERROR `EOF in comment`, depois fim |
| `comments/eof_in_nested_comment.gen.cl` | I | `(* (* *)` sem o fechamento externo | um ERROR `EOF in comment`, depois fim |

¹ `(*)` abre um comentário (`(*` casa primeiro), o `)` fica dentro. Confirmado com o lexer de referência.

### Strings — P2

| Caso | Tipo | Entrada | Esperado |
|---|---|---|---|
| `strings/basic.cl` | V/L | `"abc"`, `""`, `"a b c"`, string com `(* *)` dentro | STR_CONST; `(*` dentro de string não abre comentário |
| `strings/escapes.cl` | V | `"\b\t\n\f"`, `"\a\q\z"`, `\"`, `\\`, `"\0 ..."` | valores convertidos; `\c` → `c`; `\0` → `0` |
| `strings/escaped_newline.cl` | V | `"ab\` + newline + `cd"` | STR_CONST com `\n`; linha incrementada |
| `strings/unterminated.cl` | I | `"abc` + newline + `x`; outra sem fim; `y "ok"` | ERROR `Unterminated string constant` (numerado com a linha seguinte), depois os tokens da linha seguinte |
| `strings/too_long.gen.cl` | L/I | string com 1024 (ok) e 1025 caracteres; longa + newline sem escape; longa por escapes | STR_CONST / ERROR `String constant too long` e retomada após `"` ou na linha seguinte. Oráculo: `.out` (D014) |
| `strings/null_char.gen.cl` | I | NUL no meio da string; NUL seguido de newline sem escape; `\` + NUL; `\0` textual | ERROR `String contains null character` (sem ponto, D014); retomada correta; `\0` → STR_CONST `"0"`. Oráculo: `.out` |
| `strings/eof_in_string.gen.cl` | I | `"abc` sem newline final | ERROR `EOF in string constant`, depois fim |
| `strings/eof_after_backslash.gen.cl` | I | `"abc\` e EOF | ERROR `EOF in string constant`, depois fim |

### Integração — P3

| Caso | Esperado |
|---|---|
| `integration/small_program.cl` | programa COOL válido, sem nenhum ERROR |
| `integration/many_errors.cl` | vários erros no mesmo arquivo, todos reportados, tokens válidos entre eles preservados |
| `test.cl` (oficial) | roda sem crash; no M5 recebe a consolidação dos casos acima |
