# Jogo: Adivinhe o Número (Assembly MIPS)

Este é um projeto desenvolvido para a disciplina de Arquitetura de Computadores (ou similar), focado em aprender os fundamentos da programação em Assembly MIPS. O código deve ser executado no simulador **MARS**.

O projeto implementa um jogo clássico de "adivinhe o número", mas com uma particularidade: o número "aleatório" é, na verdade, gerado de forma determinística a partir de uma "semente" (seed) fornecida pelo usuário.

## Funcionalidades

1.  **Geração de Número via Seed:** O programa não usa um gerador aleatório. Em vez disso, ele pede ao jogador para digitar um número (a semente).
2.  **Cálculo do Alvo:** O número secreto é calculado usando a fórmula: `target = (seed % 100) + 1`. Isso garante que o número secreto estará sempre entre 1 e 100.
3.  **Loop de Tentativas:** O jogador pode fazer múltiplos palpites.
4.  **Feedback:** Após cada palpite, o programa informa se o número é "Muito alto!" ou "Muito baixo!".
5.  **Condição de Vitória:** O jogo termina e parabeniza o jogador se ele acertar o número.
6.  **Condição de Saída:** O jogador pode digitar `0` a qualquer momento para desistir e sair do jogo.
7.  **Debug:** O programa imprime o número secreto calculado logo no início para facilitar os testes.

## Como o Código Funciona (Análise Técnica)

O código é dividido em duas seções principais: `.data` (onde ficam as variáveis estáticas, como nossas strings) e `.text` (onde fica a lógica do programa).

### Seção `.data`

Aqui, apenas declaramos todas as strings que vamos exibir no console. Usamos a diretiva `.asciiz` para criar strings terminadas com um caractere nulo (null-terminated), que é o que as *syscalls* de impressão esperam.

### Seção `.text` (A Lógica Principal)

O fluxo do programa é controlado por *labels* (como `main`, `guess_loop`, `is_low`, etc.) e *instruções de pulo* (`j`, `beq`, `bne`).

#### 1. Setup (Início do `main`)

1.  **Pedir a Semente:** Usamos a `syscall 4` (print_string) para mostrar o `seed_prompt`.
2.  **Ler a Semente:** Usamos a `syscall 5` (read_int) para ler o número que o usuário digitou. O resultado fica em `$v0`.
3.  **Armazenar a Semente:** Movemos o valor de `$v0` para `$s0` (`move $s0, $v0`). Usamos um registrador salvo (`$s`) porque precisamos desse valor por um bom tempo.
4.  **Calcular o Alvo (`$s1`):**
    * Para fazer `(seed % 100) + 1`:
    * `div $s0, $t0`: Divide a semente (`$s0`) por 100 (que carregamos em `$t0`).
    * O resultado da divisão em MIPS armazena o quociente em `$LO` e o **resto** (o módulo, `%`) em `$HI`.
    * `mfhi $t1`: "Move From HI". Pegamos o resto (que está em `$HI`) e colocamos em `$t1`.
    * `addi $s1, $t1, 1`: Somamos 1 ao resto e guardamos o resultado final em `$s1`. **`$s1` agora é o nosso número secreto!**

#### 2. O Loop Principal (`guess_loop`)

Este é o coração do jogo.

1.  **Pedir Palpite:** `syscall 4` para mostrar o `guess_prompt`.
2.  **Ler Palpite:** `syscall 5` para ler o inteiro. O palpite fica em `$v0`.
3.  **Armazenar Palpite:** Movemos o palpite para `$t0` (`move $t0, $v0`). Usamos um registrador temporário (`$t`).
4.  **Verificar Saída:** `beq $t0, $zero, exit_game`. "Branch if Equal". Se o palpite (`$t0`) for igual a 0 (`$zero`), pula direto para a label `exit_game`.

#### 3. A Lógica de Comparação

A lógica `if/else` é feita usando `slt` e `bne`/`beq`.

1.  **Verifica se é "Baixo" (`is_low`):**
    * `slt $t1, $t0, $s1`: "Set on Less Than". Coloca 1 em `$t1` se `palpite < alvo`, senão 0.
    * `bne $t1, $zero, is_low`: "Branch if Not Equal". Se `$t1` for 1 (não é zero), o palpite é menor, então pula para `is_low`.

2.  **Verifica se é "Alto" (`is_high`):**
    * Se o código chegou aqui, o palpite não é menor.
    * `slt $t1, $s1, $t0`: "Set on Less Than". Coloca 1 em `$t1` se `alvo < palpite` (ou seja, `palpite > alvo`).
    * `bne $t1, $zero, is_high`: Se `$t1` for 1, o palpite é maior. Pula para `is_high`.

3.  **Verifica se é "Correto" (`is_correct`):**
    * Se o código não pulou para `is_low` nem para `is_high`, a única opção restante é que o palpite é igual ao alvo. O código simplesmente "cai" na label `is_correct`.

#### 4. Labels de Resultado (`is_low`, `is_high`, `is_correct`)

* **`is_low` / `is_high`:**
    * Usam `syscall 4` para imprimir a mensagem de erro.
    * Usam `j guess_loop` ("Jump") para voltar incondicionalmente ao início do loop.
* **`is_correct`:**
    * Usa `syscall 4` para imprimir a mensagem de parabéns.
    * Usa `j exit_game` para pular para o fim do jogo.

#### 5. Fim do Jogo (`exit_game`)

1.  Imprime a mensagem de saída (`exit_msg`) com `syscall 4`.
2.  Usa a `syscall 10` (exit) para encerrar a execução do programa.

## Como Executar

1.  Abra o simulador **MARS**.
2.  Vá em `File > Open...` e selecione o arquivo `.asm` (ou copie e cole o código).
3.  Pressione `F3` (ou vá em `Run > Assemble`) para compilar o código.
4.  Pressione `F5` (ou vá em `Run > Go`) para executar.
5.  A interação (pedir semente, palpites) será feita no console na parte de baixo, na aba **"Run I/O"**.
