# Instalação e execução

Guia único para deixar o ambiente pronto e rodar o scanner. Baseado no `00_config.pdf` da disciplina e
testado no WSL com Ubuntu 26.04. O ambiente validado pelo professor é o Ubuntu 16.04 (D015).

Ao final você terá:

- a infraestrutura da disciplina em `/var/tmp/cool` (esqueletos, headers, lexer de referência, `spim`);
- o repositório clonado no sistema de arquivos Linux;
- `PA2/` com os arquivos de trabalho, compilando `./lexer` e rodando a suíte de testes.

Todos os comandos abaixo rodam **no terminal Linux** (Ubuntu nativo, VM ou WSL), nunca no PowerShell.

---

## 1. Linux (só para quem usa Windows)

No PowerShell, **como administrador**, uma única vez:

```powershell
wsl --install -d Ubuntu
```

Reinicie se for pedido, abra o app **Ubuntu** e crie usuário e senha. Todo o resto deste guia é nesse
terminal.

## 2. Dependências

```bash
sudo apt-get update
sudo apt-get install -y g++ make csh sharutils flex bison libfl-dev git
```

| Pacote | Para quê |
|---|---|
| `g++`, `make` | compilar o scanner |
| `flex` | gerar `cool-lex.cc` a partir de `cool.flex` |
| `libfl-dev` | biblioteca `-lfl` usada pelo Makefile (nas versões novas do Ubuntu não vem com o `flex`) |
| `csh` | o script `mycoolc` é escrito em csh |
| `sharutils` | `uudecode`/`uuencode` (instalar o pacote da disciplina e gerar o `PA2.u`) |
| `bison` | não é usado no TP02; já fica pronto para o TP03 |

## 3. Infraestrutura da disciplina (`/var/tmp/cool`)

1. Baixe o `x86_64.u` do Canvas.
2. Instale em `/var/tmp/cool`. O caminho é obrigatório: os Makefiles e o `spim` dependem dele.

```bash
mkdir -p /var/tmp/cool
cp /mnt/c/Users/<seu-usuario-windows>/Downloads/x86_64.u /var/tmp/cool/   # no WSL; ajuste o caminho
cd /var/tmp/cool
uudecode x86_64.u
tar xvpf x86_64.tar.gz
make install
```

Se o `mkdir` der "Permission denied", use `sudo mkdir -p /var/tmp/cool && sudo chown "$USER" /var/tmp/cool`.

Conferir:

```bash
ls /var/tmp/cool/assignments/PA2              # Makefile  README.SKEL  cool.flex.SKEL  test.cl.SKEL ...
/var/tmp/cool/lib/.x86_64/lexer /var/tmp/cool/examples/hello_world.cl
```

O segundo comando deve imprimir `#name "..."` seguido de linhas como `#1 CLASS`, `#1 TYPEID Main`.

> `/var/tmp` pode ser limpo em alguns sistemas depois de um tempo sem uso. Se `/var/tmp/cool` sumir, repita
> este passo; o repositório não é afetado.

## 4. Clonar o repositório

Clone **dentro do Linux** (`~/`), não em `/mnt/c/...` nem no OneDrive: symlinks, permissões de execução e
desempenho falham ali (D012).

```bash
cd ~
git clone https://github.com/LucasBusavs/Compilador-Cool.git
cd Compilador-Cool
git config user.name  "Seu Nome"
git config user.email "seu-email@exemplo.com"
```

## 5. Preparar `PA2/`

```bash
cd ~/Compilador-Cool/PA2
make -f /var/tmp/cool/assignments/PA2/Makefile
```

O comando:

- cria os **symlinks** para a infraestrutura (`Makefile`, `lextest.cc`, `utilities.cc`, `stringtab.cc`,
  `handle_flags.cc`, `mycoolc`, `parser`, `semant`, `cgen`). Não edite esses arquivos; eles estão no
  `.gitignore`;
- copia `cool.flex`, `test.cl` e `README` **só se ainda não existirem**. Depois que o esqueleto estiver no
  repositório (tarefa M0.4), o comando não mexe neles.

Conferir: `ls -l` deve mostrar os symlinks apontando para `/var/tmp/cool/...`, e `git status` não deve listar
nenhum deles.

## 6. Compilar e rodar o scanner

Sempre a partir de `PA2/`:

```bash
make lexer                                   # flex cool.flex -> cool-lex.cc -> ./lexer
./lexer test.cl                              # nosso scanner: um token por linha
/var/tmp/cool/lib/.x86_64/lexer test.cl      # scanner de referência, para comparar
make dotest                                  # atalho: compila e roda ./lexer test.cl
```

Formato da saída: `#name "<arquivo>"` e, para cada token, `#<linha> <TOKEN> [valor]`.

Comparar os dois scanners num arquivo qualquer:

```bash
diff <(/var/tmp/cool/lib/.x86_64/lexer arquivo.cl) <(./lexer arquivo.cl)
```

Compilador completo (nosso lexer + parser/semant/cgen de referência) e execução no simulador MIPS:

```bash
./mycoolc programa.cl                        # gera programa.s
/var/tmp/cool/bin/spim -file programa.s
```

## 7. Testes

```bash
scripts/run_tests.sh                         # todos os casos em tests/cases
scripts/run_tests.sh tests/cases/comments    # uma categoria
scripts/run_tests.sh tests/cases/strings/escapes.cl   # um caso
scripts/gen_cases.sh                         # regenerar os casos *.gen.cl
```

Para cada caso, o runner compara a saída de `./lexer` com o oráculo: o `<caso>.out` se existir (divergência
intencional, D014), senão o lexer de referência (D013). Resultado:

- `passou`: saída idêntica;
- `FAIL ... (ver tests/out/<caso>.diff)`: o diff mostra `-` esperado / `+` obtido;
- `FAIL ... (exit 124)`: estourou o tempo, provável laço infinito (típico de `<<EOF>>` que não volta para
  INITIAL);
- `SKIP`: sem oráculo disponível.

Se aparecer `Permission denied` ao rodar um script, use `sh scripts/run_tests.sh` ou `chmod +x scripts/*.sh`.

## 8. Fluxo de trabalho do dia a dia

```bash
git switch main && git pull
git switch -c feature/<tema>                 # ou continue na sua branch (CONTRIBUTING.md)
# ... editar cool.flex / tests ...
make lexer && scripts/run_tests.sh
git add -p && git commit -m "feat: ..."
git push -u origin feature/<tema>            # abrir PR para main
```

Regras de branch, commit, PR e ownership em [CONTRIBUTING.md](CONTRIBUTING.md). Entrega em
[MILESTONES.md](MILESTONES.md), M6.

## 9. Problemas comuns

| Sintoma | Causa | Solução |
|---|---|---|
| `make: *** No rule to make target 'lexer'` | falta o symlink do `Makefile` | rodar o passo 5 |
| `/usr/bin/ld: cannot find -lfl` | falta a biblioteca do flex | `sudo apt-get install libfl-dev` |
| `make: flex: No such file or directory` | flex não instalado | passo 2 |
| `uudecode: command not found` | falta `sharutils` | passo 2 |
| `./mycoolc: /bin/csh: bad interpreter` | falta `csh` | `sudo apt-get install csh` |
| `make -f ...: No such file or directory` | infraestrutura ausente ou em outro caminho | passo 3 (tem que ser `/var/tmp/cool`) |
| symlinks quebrados, build lento, `Permission denied` em `/mnt/c` | clone no Windows/OneDrive | clonar em `~/` (passo 4) |
| strings/linhas erradas só na máquina de alguém | arquivo com CRLF | o `.gitattributes` força LF; confira com `file arquivo.cl` e não edite casos `.gen.cl` à mão |
| teste para e dá `exit 124` | laço infinito no scanner | conferir as regras `<<EOF>>` e os coringas de cada estado |
