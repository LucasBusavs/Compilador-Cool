#!/bin/sh
# Roda ./lexer sobre os casos .cl e compara com a saída esperada.
#
# Uso (a partir de PA2/):
#   scripts/run_tests.sh                        # todos os casos em tests/cases
#   scripts/run_tests.sh tests/cases/strings    # só uma pasta (ou arquivos)
#   REF_LEXER=/outro/lexer scripts/run_tests.sh
#
# Oráculo (D013), nesta ordem:
#   1. <caso>.out ao lado do .cl: divergência intencional da referência (D014);
#   2. lexer de referência: REF_LEXER, por padrão /var/tmp/cool/lib/.x86_64/lexer.
# Casos sem oráculo são listados como SKIP, mas ainda rodam para detectar
# crash/laço infinito.
set -u
cd "$(dirname "$0")/.." || exit 2

LEXER=${LEXER:-./lexer}
REF_LEXER=${REF_LEXER:-/var/tmp/cool/lib/.x86_64/lexer}
TIMEOUT=${TIMEOUT:-5}
OUT=tests/out

[ -x "$LEXER" ] || { echo "erro: $LEXER não encontrado. Rode 'make lexer'."; exit 2; }
[ -x "$REF_LEXER" ] || { echo "aviso: lexer de referência $REF_LEXER indisponível; só .out será usado."; REF_LEXER=""; }
command -v timeout >/dev/null 2>&1 && RUN="timeout $TIMEOUT" || RUN=""

mkdir -p "$OUT"
pass=0 fail=0 skip=0

[ $# -eq 0 ] && set -- tests/cases
for f in $(find "$@" -name '*.cl' | sort); do
	name=$(echo "$f" | sed 's#^tests/cases/##; s#/#__#g; s#\.cl$##')
	got="$OUT/$name.got"

	$RUN "$LEXER" "$f" >"$got" 2>&1
	status=$?
	if [ "$status" -ne 0 ]; then
		# 124 = timeout (provável laço infinito, ex.: <<EOF>> sem voltar a INITIAL)
		echo "FAIL $f (exit $status)"
		fail=$((fail + 1))
		continue
	fi

	expected="${f%.cl}.out"
	if [ ! -f "$expected" ] && [ -n "$REF_LEXER" ]; then
		expected="$OUT/$name.ref"
		"$REF_LEXER" "$f" >"$expected" 2>&1
	fi

	if [ ! -f "$expected" ]; then
		echo "SKIP $f (sem saída esperada)"
		skip=$((skip + 1))
	elif diff -u "$expected" "$got" >"$OUT/$name.diff"; then
		rm -f "$OUT/$name.diff"
		pass=$((pass + 1))
	else
		echo "FAIL $f (ver $OUT/$name.diff)"
		fail=$((fail + 1))
	fi
done

echo "passou: $pass  falhou: $fail  sem oráculo: $skip"
[ "$fail" -eq 0 ]
