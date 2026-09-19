# Compilador COOL — PUC Minas, Compiladores 2026.2

Compilador para a linguagem COOL em C++ (Flex/Bison), construído em etapas:

| TP | Fase | Diretório |
|---|---|---|
| 02 | Análise léxica (Flex) | [`PA2/`](PA2/) |
| 03 | Análise sintática (Bison) | `PA3/` (futuro) |
| 04 | Análise semântica | `PA4/` (futuro) |
| 05 | Geração de código | `PA5/` (futuro) |

Cada diretório `PAx/` é o que o Makefile da disciplina gera e o que é empacotado na entrega. O `PA2/README`
oficial é o documento de entrega; a documentação interna do grupo está em [`PA2/docs/`](PA2/docs/).

## Começando

1. **Instalação e execução:** [`PA2/docs/SETUP.md`](PA2/docs/SETUP.md) (Linux/WSL, dependências,
   `/var/tmp/cool`, compilar, rodar o scanner e a suíte de testes).
2. **Plano e prazos:** [`PA2/docs/MILESTONES.md`](PA2/docs/MILESTONES.md) (entrega do TP02: 20/09/2026, 23:59).
3. **Como contribuir:** [`PA2/docs/CONTRIBUTING.md`](PA2/docs/CONTRIBUTING.md) (papéis, branches, PRs).

Resumo rápido, depois do ambiente instalado:

```bash
cd PA2
make -f /var/tmp/cool/assignments/PA2/Makefile   # uma vez por clone
make lexer
./lexer test.cl
scripts/run_tests.sh
```

## Documentação

| Documento | Conteúdo |
|---|---|
| [SETUP.md](PA2/docs/SETUP.md) | instalação, execução e problemas comuns |
| [REQUIREMENTS.md](PA2/docs/REQUIREMENTS.md) | requisitos do enunciado com a matriz de rastreabilidade |
| [ARCHITECTURE.md](PA2/docs/ARCHITECTURE.md) | estados do scanner, variáveis compartilhadas, protocolo de erro, ordem das regras |
| [TEST_PLAN.md](PA2/docs/TEST_PLAN.md) | estratégia e casos de teste |
| [DECISIONS.md](PA2/docs/DECISIONS.md) | decisões (D001–D016) e conflitos entre fontes |
| [QUESTIONS.md](PA2/docs/QUESTIONS.md) | perguntas respondidas e em aberto |
| [MILESTONES.md](PA2/docs/MILESTONES.md) | marcos, datas e passo a passo da entrega |
| [CONTRIBUTING.md](PA2/docs/CONTRIBUTING.md) | ownership, Git, PR e Definition of Done |
