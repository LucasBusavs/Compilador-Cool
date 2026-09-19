# Testes auxiliares do scanner

- `cases/<categoria>/*.cl`: entradas de teste. O que cada uma deve produzir está em `../docs/TEST_PLAN.md`.
- Oráculo: por padrão, o lexer de referência `/var/tmp/cool/lib/.x86_64/lexer`, que roda automaticamente.
- `cases/**/<caso>.out` (opcional): saída esperada escrita à mão; tem prioridade sobre a referência. Existe só
  onde divergimos dela por decisão do grupo (D014): hoje `strings/null_char.gen.out` e
  `strings/too_long.gen.out`. Se `gen_cases.sh` mudar um desses casos, refaça o `.out`.
- `*.gen.cl`: gerados por `../scripts/gen_cases.sh` (bytes exatos: NUL, sem newline final...). Não edite à mão;
  mude o script e rode de novo.
- `out/`: saídas do runner (ignorado pelo Git).

Rodar, a partir de `PA2/`:

```bash
make lexer
scripts/run_tests.sh                       # todos os casos
scripts/run_tests.sh tests/cases/strings   # só uma categoria
REF_LEXER=/outro/lexer scripts/run_tests.sh   # trocar o oráculo
```

Os casos atuais são **sementes**. P3 consolida e expande; P1 e P2 adicionam os casos das próprias
funcionalidades na mesma PR que as implementa.
