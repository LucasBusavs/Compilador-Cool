# Scripts auxiliares

Rodar sempre a partir de `PA2/`, num ambiente Linux com a infraestrutura da disciplina.

| Script | Função |
|---|---|
| `run_tests.sh` | Roda `./lexer` em cada `tests/cases/**/*.cl`, compara com o oráculo (`REF_LEXER` ou `<caso>.out`) e usa `timeout` para pegar laço infinito. Retorna ≠ 0 se algo falhar. |
| `gen_cases.sh` | Regenera os casos `*.gen.cl` (NUL, sem newline final, strings de 1024/1025 caracteres). |

Nenhum script altera `cool.flex` nem os arquivos da infraestrutura.
