#!/bin/sh
# Gera os casos de teste que dependem de bytes exatos (NUL, ausência de newline
# final, strings no limite de tamanho). Editores e o Git normalizam esses bytes,
# por isso os arquivos são gerados aqui e versionados como binários (*.gen.cl).
#
# Uso (a partir de PA2/): scripts/gen_cases.sh
#
# Limite de string: o esqueleto cool.flex define MAX_STR_CONST = 1025, ou seja,
# no máximo 1024 caracteres após processar escapes (confirmado com o lexer de
# referência: 1024 é aceito, 1025 é "String constant too long").
set -eu
cd "$(dirname "$0")/../tests/cases"

# rep N STR: STR repetido N vezes
rep() { i=0; while [ "$i" -lt "$1" ]; do printf '%s' "$2"; i=$((i + 1)); done; }

MAX=1024

# --- whitespace: \f \v \r \t entre tokens ---
printf 'a\tb\fc\vd\re  f\n\n\t\ng\n' > basic/whitespace.gen.cl

# --- comentário de linha terminando no EOF, sem newline ---
printf 'x -- comentario sem newline no fim' > comments/line_eof.gen.cl

# --- EOF dentro de comentário (um erro por arquivo: após EOF não há mais nada) ---
printf 'a (* nunca fecha\nlinha 2\n' > comments/eof_in_comment.gen.cl
printf 'b (* externo (* interno *) externo continua aberto' > comments/eof_in_nested_comment.gen.cl

# --- strings no limite de tamanho ---
{
	printf '"%s" ok_max\n' "$(rep $MAX a)"                   # 1024: válida
	printf '"%s" depois_das_aspas\n' "$(rep $((MAX + 1)) a)" # 1025: too long, retoma após "
	printf '"%s\n' "$(rep $((MAX + 1)) a)"                  # too long + newline sem escape
	printf 'proxima_linha\n'
	printf '"%s" escapes_max\n' "$(rep $MAX '\n')"           # 1024 após escapes: válida
	printf '"%s" escapes_long\n' "$(rep $((MAX + 1)) '\n')"  # 1025 após escapes: too long
} > strings/too_long.gen.cl

# --- caractere nulo real ---
{
	printf '"ab\000cd" depois_das_aspas\n'
	printf '"ab\000cd\n'                  # NUL e depois newline sem escape
	printf 'proxima_linha\n'
	printf '"ab\\\000cd" barra_nul\n'     # barra invertida seguida de NUL
	printf '"\\0" ok_barra_zero\n'        # \0 textual é válido e vira '0'
} > strings/null_char.gen.cl

# --- EOF dentro de string ---
printf 'x "sem fechamento' > strings/eof_in_string.gen.cl
printf 'y "termina com barra\\' > strings/eof_after_backslash.gen.cl

echo "casos gerados:"
find . -name '*.gen.cl' | sort
