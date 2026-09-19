# Instalação e execução

Guia único para deixar o ambiente pronto e rodar o scanner. Baseado no `00_config.pdf` da disciplina e
testado no WSL com Ubuntu 26.04. O ambiente validado pelo professor é o Ubuntu 16.04 (D015).

Ao final você terá:

- a infraestrutura da disciplina em `/var/tmp/cool` (esqueletos, headers, lexer de referência, `spim`);
- o repositório clonado no sistema de arquivos Linux;
- `PA2/` com os arquivos de trabalho, compilando `./lexer` e rodando a suíte de testes.

Todos os comandos abaixo rodam **no terminal Linux** (Ubuntu nativo, VM ou WSL), nunca no PowerShell. No
Windows, o passo 1 mostra como instalar e como abrir o Ubuntu; quem já usa Linux pode pular para o passo 2.

---

## 1. Linux (só para quem usa Windows)

### 1.1 Instalar (uma única vez)

Abra o PowerShell **como administrador** e rode:

```powershell
wsl --install -d Ubuntu
```

Reinicie o computador se for pedido. Ao terminar, o Ubuntu abre sozinho e pede para criar **usuário e senha**
do Linux (a senha não aparece enquanto você digita; anote-a, o `sudo` vai pedi-la).

### 1.2 Abrir o Ubuntu (toda vez que for trabalhar)

Use qualquer uma das opções:

| Opção | Como |
|---|---|
| Menu Iniciar | digite `Ubuntu` e abra o app |
| PowerShell ou Prompt de Comando | `wsl` (abre no Ubuntu padrão) ou `wsl -d Ubuntu` |
| Windows Terminal | seta ao lado do `+` → **Ubuntu** |
| VS Code | extensão *WSL*, depois `code .` dentro do Ubuntu |

Você está no Linux quando o prompt fica parecido com `usuario@computador:~$`. Para sair, `exit`. Para checar o
que está instalado: `wsl -l -v` (no PowerShell) deve listar `Ubuntu` com `VERSION 2`.

Todo o resto deste guia é digitado **nesse terminal**, não no PowerShell.

### 1.3 Acessar os arquivos do Windows a partir do Ubuntu

O disco `C:` aparece em `/mnt/c`. Por exemplo, a pasta Downloads é
`/mnt/c/Users/<seu-usuario-windows>/Downloads`. Só use `/mnt/c` para **copiar arquivos**; o repositório deve
ficar em `~/` (passo 4).

O comando para copiar é o `cp` (*copy*): `cp <origem> <destino>`.

```bash
ls /mnt/c/Users/                                   # descobrir o nome do seu usuário do Windows
ls /mnt/c/Users/<seu-usuario-windows>/Downloads    # conferir que o x86_64.u está lá
cp /mnt/c/Users/<seu-usuario-windows>/Downloads/x86_64.u /var/tmp/cool/
```

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
cp /mnt/c/Users/<seu-usuario-windows>/Downloads/x86_64.u /var/tmp/cool/   # copia o pacote (ver o passo 1.3)
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
git config user.name  "Nome Real"              # troque pelo SEU nome; o texto entre aspas vai em cada commit
git config user.email "email-do-github@exemplo.com"   # o e-mail da sua conta do GitHub
```

Use o seu nome e e-mail de verdade: copiar os exemplos acima literalmente faz os commits saírem com autor
falso. Para conferir: `git config user.name && git config user.email`.

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

Com o esqueleto original (só a regra `=>`), o `./lexer` apenas repete o texto do arquivo: é o comportamento
padrão do Flex para o que nenhuma regra reconhece. Os tokens só aparecem conforme o `cool.flex` for sendo
implementado.

O `make lexer` mostra muitos `warning: ISO C++ forbids converting a string constant to 'char*'`. Vêm dos
arquivos oficiais (`lextest.cc`, `utilities.cc`) e podem ser ignorados.

Comparar os dois scanners no mesmo arquivo. Troque `test.cl` por qualquer `.cl` que exista (por exemplo
`tests/cases/keywords/keywords.cl`); um nome inventado dá `Could not open input file`:

```bash
diff <(/var/tmp/cool/lib/.x86_64/lexer test.cl) <(./lexer test.cl) | head -20
```

Sem diferença = os dois scanners produzem a mesma saída. Com o esqueleto original haverá muita diferença; ela
diminui conforme o `cool.flex` é implementado.

Compilador completo e execução no simulador MIPS. Primeiro, confira o ambiente com o compilador **oficial**
(funciona desde o passo 3, sem depender do nosso scanner):

```bash
cp /var/tmp/cool/examples/hello_world.cl .
/var/tmp/cool/bin/coolc hello_world.cl       # gera hello_world.s
/var/tmp/cool/bin/spim -file hello_world.s   # deve imprimir "Hello, World."
rm -f hello_world.cl hello_world.s
```

Depois, com **o nosso** scanner (nosso `./lexer` + parser, semant e cgen de referência):

```bash
./mycoolc hello_world.cl                     # gera hello_world.s
```

O `mycoolc` só funciona quando o `cool.flex` estiver completo (M5). Antes disso, com o esqueleto, ele falha
com `unmatched text in token lexer; line number expected` (e `syntax error at or near EOF` se o arquivo não
existir). Os nomes `arquivo.cl` e `programa.cl` usados como exemplo neste guia são fictícios: use um `.cl`
que exista.

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
| `libfl.so: undefined reference to 'yylex'` no `make lexer` | o esqueleto não define `yywrap`, então o link cai no `libfl.so`, que referencia `yylex` (versões novas do Ubuntu) | garantir `%option noyywrap` no topo do `cool.flex` (já está no esqueleto versionado) e rodar `rm -f cool-lex.cc cool-lex.o && make lexer` |
| dezenas de `warning: ISO C++ forbids converting a string constant to 'char*'` | vêm de `lextest.cc` e `utilities.cc` (arquivos oficiais, não editáveis) compilados com g++ recente | ignorar; não são do nosso código. Só investigue warnings de `cool-lex.cc` |
| `./mycoolc`: `unmatched text in token lexer` ou `syntax error at or near EOF` | o `mycoolc` usa o nosso `./lexer`, que ainda não está implementado; ou o arquivo não existe | esperar o scanner completo (M5); enquanto isso usar `/var/tmp/cool/bin/coolc` |
| `Could not open input file <nome>` | o arquivo `.cl` não existe; `arquivo.cl`, `programa.cl` etc. nos exemplos são nomes fictícios | usar um arquivo real: `ls tests/cases/*/` ou `test.cl` |
| `make: flex: No such file or directory` | flex não instalado | passo 2 |
| `uudecode: command not found` | falta `sharutils` | passo 2 |
| `./mycoolc: /bin/csh: bad interpreter` | falta `csh` | `sudo apt-get install csh` |
| `make -f ...: No such file or directory` | infraestrutura ausente ou em outro caminho | passo 3 (tem que ser `/var/tmp/cool`) |
| `wsl` não é reconhecido, ou pede para ativar recursos | WSL não instalado ou virtualização desligada | passo 1.1; se persistir, ativar a virtualização na BIOS |
| `wsl` abre o `docker-desktop` em vez do Ubuntu | outra distro é a padrão | `wsl -d Ubuntu`, ou `wsl --set-default Ubuntu` |
| symlinks quebrados, build lento, `Permission denied` em `/mnt/c` | clone no Windows/OneDrive | clonar em `~/` (passo 4) |
| strings/linhas erradas só na máquina de alguém | arquivo com CRLF | o `.gitattributes` força LF; confira com `file arquivo.cl` e não edite casos `.gen.cl` à mão |
| teste para e dá `exit 124` | laço infinito no scanner | conferir as regras `<<EOF>>` e os coringas de cada estado |
