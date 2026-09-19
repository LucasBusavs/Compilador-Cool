# Arquitetura do scanner

> Nomes conferidos com o esqueleto oficial (`/var/tmp/cool/assignments/PA2/cool.flex.SKEL`). O esqueleto não
> declara estados: `COMMENT`, `STRING` e `STRING_ERROR` são decisão nossa (D006).
>
> O esqueleto já traz, e não devem ser removidos: os `#include`, `#define yylval cool_yylval`,
> `#define yylex cool_yylex`, `MAX_STR_CONST`, o `YY_INPUT` que lê de `fin`, `string_buf`/`string_buf_ptr`, os
> `extern` de `curr_lineno`/`verbose_flag`/`cool_yylval`, a definição `DARROW =>` e a regra `{DARROW}`.
>
> Acrescentamos `%option noyywrap` antes do bloco `%{ %}`: sem `yywrap()` o Makefile oficial liga com
> `-lfl`, e o `libfl.so` do Ubuntu recente falha com `undefined reference to 'yylex'` (o `#define yylex
> cool_yylex` esconde o símbolo). Verificado no WSL (flex 2.6.4, g++ 15). Não remover.

## Fluxo

```text
arquivo .cl ──► cool_yylex()  (gerado pelo Flex a partir de cool.flex)
                   │
                   ├─ retorna int: código do token (cool-parse.h) ou ASCII do caractere
                   ├─ preenche cool_yylval: .symbol | .boolean | .error_msg
                   └─ mantém curr_lineno
                   │
        TP02: lextest.cc / ./lexer imprime "#linha TOKEN valor"
        TP03: parser Bison consome o mesmo protocolo (nada muda no scanner)
```

## Estados

```text
                         +-----------+
          +------------->|  INITIAL  |<---------------------------+
          |              +-----+-----+                            |
          |       "(*"         |          "\""                    |
          |     depth=1        |        buf vazio                 |
          |        +-----------+-----------+                      |
          |        v                       v                      |
          |  +-----------+           +-----------+  too long /    |
          |  |  COMMENT  |           |  STRING   |--null char---->+----+
          |  +-----------+           +-----------+  (ERROR)       |    |
          |   "(*" depth++            "\"" → STR_CONST            |    v
          |   "*)" depth--            "\n" → ERROR Unterminated ──+  +--------------+
          |   depth==0 ───────────────────────────────────────────+  | STRING_ERROR |
          |   <<EOF>> → ERROR "EOF in comment"                    |  +--------------+
          |                           <<EOF>> → ERROR             |   descarta até
          |                                    "EOF in string"    |   "\"" ou "\n"
          +-------------------------------------------------------+----------+
```

- `--` (comentário de linha) é tratado em INITIAL por uma única regra `--.*`; o `\n` é consumido pela regra de
  newline normal. Não precisa de estado.
- Após retornar um ERROR de EOF, o estado volta para INITIAL para que a próxima chamada retorne 0 (fim).
  Sem isso o scanner entra em laço infinito devolvendo o mesmo erro.

## Variáveis compartilhadas (contrato)

| Nome | Origem | Quem escreve | Regra |
|---|---|---|---|
| `curr_lineno` | `extern` no esqueleto; o `lextest.cc` zera para 1 a cada arquivo | **quem consome o `\n`** | Toda regra que consome um `\n` incrementa exatamente uma vez. Evitar padrões que casam vários `\n` de uma vez. |
| `cool_yylval` | `extern YYSTYPE` no esqueleto (`cool-parse.h`) | todas as regras que retornam token com valor | `.symbol` p/ TYPEID/OBJECTID/INT_CONST/STR_CONST; `.boolean` p/ BOOL_CONST; `.error_msg` (`char*`) p/ ERROR |
| `comment_depth` | nosso (P3) | só regras de COMMENT e o `"(*"` de INITIAL | int ≥ 0 |
| `string_buf`, `string_buf_ptr` | esqueleto | só regras de STRING | reset ao entrar em STRING |
| `MAX_STR_CONST` | esqueleto (`#define` 1025 no `cool.flex`) | — | máx. 1024 caracteres **processados** + `'\0'` |

O `./lexer` imprime cada token com `dump_cool_token` (`utilities.cc`): `#<curr_lineno> <TOKEN> [valor]`,
depois do cabeçalho `#name "<arquivo>"`. A linha impressa é o `curr_lineno` **depois** de a regra rodar; por
isso o `ERROR "Unterminated string constant"` aparece com o número da linha seguinte.

Qualquer nova variável ou helper compartilhado deve ser adicionado nesta tabela na mesma PR.

## Protocolo de erro (único para todo o scanner)

- Retornar `ERROR` com `cool_yylval.error_msg` apontando para a mensagem. Nunca imprimir.
- Mensagens fixas são literais de string (vida estática).
- Caractere inválido: `yytext` é sobrescrito na próxima chamada. P1 decide, no M1, entre copiar para um
  buffer próprio e usar `yytext` direto (o `./lexer` imprime na hora, mas o parser do TP03 pode guardar o
  ponteiro). Registrar a escolha em DECISIONS.md.
- Too long / null character: o `ERROR` é retornado **no momento em que o problema é detectado**, e o estado
  passa para `STRING_ERROR`, que descarta o resto da string sem gerar novos erros, até `"` (retoma depois
  dela) ou `\n` sem escape (retoma na próxima linha, `curr_lineno++`). Assim o erro sai com a linha da string,
  como exigem os `.out` da D014.
- Mensagens: exatamente as do enunciado (D014), inclusive `String contains null character` sem ponto final e
  também para `\` seguido de NUL.

## Ordem das regras

O Flex escolhe o maior casamento; em empate, a regra que aparece primeiro. Consequências:

| Situação | Regra |
|---|---|
| Palavras-chave × OBJECTID/TYPEID | keywords e `true`/`false` **antes** dos identificadores (mesmo comprimento) |
| `(*` × `(` , `*)` × `*`/`)` , `--` × `-` , `=>`/`<=`/`<-` × `=`/`<` | resolvido pelo maior casamento; manter ainda assim os compostos antes por clareza |
| Coringa `.` de INITIAL | **última** regra de INITIAL |
| Estados exclusivos | cada um tem seu próprio coringa (inclusive `\n`) e seu `<<EOF>>` |

## Seções do `cool.flex` (ownership)

```text
Declarations      P1 (variáveis compartilhadas combinadas antes: ver tabela acima)
Definitions       P1 (DIGIT, LETTER...) + %x COMMENT (P3) + %x STRING STRING_ERROR (P2)
Rules
  COMMENTS        P3
  STRINGS         P2
  CORE TOKENS     P1
  FALLBACK/ERRORS P1
User subroutines  dono do helper; helpers compartilhados combinados com P1
```
