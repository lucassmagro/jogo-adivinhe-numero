# jogo-adivinhe-numero
# Projeto: Jogo de Adivinhe o Número (Arduino e Assembly MIPS)

Este repositório contém a implementação do mesmo jogo "Adivinhe o Número" em duas plataformas completamente diferentes. Este é um exercício acadêmico, do 2º semestre de Sistemas de Informação. Desenvolvido pelos acadêmicos: Alexandre Reitemeyer Beatriz Aparecida Miranda e Lucas Santos Magro. Pela disciplina: Arquitetura de Computadores, ministrada pelo doscente: Jacson Luiz Matte. 

## A Lógica do Jogo

O conceito básico é o mesmo para ambas as versões:

1.  O sistema define um número secreto (entre 1 e 100).
2.  O jogador digita palpites.
3.  O sistema responde se o palpite foi "muito alto", "muito baixo" ou "correto".
4.  O jogo termina quando o jogador acerta (ou, na versão MIPS, se ele digitar 0).

-----

## Parte 1: Implementação com Arduino (Tinkercad)

Esta versão é focada em hardware e interação física, projetada para ser simulada na plataforma Tinkercad. O jogador usa um teclado matricial (keypad) para inserir os palpites, e o feedback é dado por LEDs coloridos (verde, amarelo, vermelho) e também pelo Monitor Serial.

### Componentes Necessários (Hardware)

Para montar este projeto no Tinkercad, você vai precisar de:

  * `1x` Placa Arduino Uno R3
  * `1x` Keypad (Teclado Matricial) 4x4
  * `1x` LED Vermelho (para "Muito Alto")
  * `1x` LED Amarelo (para "Muito Baixo")
  * `1x` LED Verde (para "Acertou\!")
  * `3x` Resistores de 220Ω (para os LEDs)
  * `1x` Protoboard (Matriz de Contatos)
  * `Vários` Jumpers (fios de conexão)

### Lógica do Código (C++)

O código C++ utiliza a biblioteca `Keypad.h` para facilitar a leitura do teclado matricial.

1.  **Setup:** No `setup()`, iniciamos a Serial, configuramos os pinos dos LEDs e geramos o número secreto. É usada a função `randomSeed(analogRead(A0))` para garantir que o número sorteado seja diferente a cada simulação (ler uma porta analógica "flutuante" é um método comum para gerar uma semente aleatória).
2.  **Loop:** O `loop()` principal verifica constantemente se uma tecla foi pressionada.
      * Os dígitos são armazenados em um array de `char` (`numero[]`).
      * Quando a tecla `#` (nosso "Enter") é pressionada, o array de `char` é convertido para um `int` usando a função `atoi()` (ASCII to Integer).
      * Esse inteiro é comparado com o número secreto (`target`).
      * Os comandos `digitalWrite()` são usados para acender o LED correspondente (Vermelho para maior, Amarelo para menor, Verde para correto).
      * Se o jogador acertar, o jogo reinicia automaticamente, gerando um novo número.

### Montagem (Pinos)

  * **LEDs:**
      * LED Verde: Pino `13`
      * LED Amarelo: Pino `12`
      * LED Vermelho: Pino `10`
  * **Keypad 4x4:**
      * Linhas (Rows): Pinos `9`, `8`, `7`, `6`
      * Colunas (Cols): Pinos `5`, `4`, `3`, `2`
  * **Semente Aleatória:**
      * Pino `A0` deve ficar desconectado (flutuando).

### Código-Fonte: Arduino (C++)

```cpp
#include <Keypad.h>
#include <string.h>
#include <stdlib.h> 

int target;

const byte numRows= 4;
const byte numCols= 4;
const byte warning=3;
const byte pwdsize = 8;

char numero[pwdsize];

byte index=0;
byte failboy=0;

char keymap[numRows][numCols]=
{
{'1', '2', '3', 'A'},
{'4', '5', '6', 'B'},
{'7', '8', '9', 'C'},
{'*', '0', '#', 'D'}
};

byte rowPins[numRows] = {9,8,7,6};
byte colPins[numCols]= {5,4,3,2};

Keypad myKeypad= Keypad(makeKeymap(keymap), rowPins, colPins, numRows, numCols);

void setup(){
  Serial.begin(9600);
  
  randomSeed(analogRead(A0));
  target = random(1, 101); 

  Serial.println("JOGO DE ADIVINHAR O NUMERO");
  Serial.println("Digite um numero entre 1 e 100 e aperte #");
  Serial.print("DEBUG: O numero e: "); // Linha de debug para facilitar testes
  Serial.println(target);

  pinMode(13, OUTPUT); // LED Verde (Acertou)
  pinMode(12, OUTPUT); // LED Amarelo (Menor)
  pinMode(10, OUTPUT); // LED Vermelho (Maior)
}

void loop(){
  char keypressed = myKeypad.getKey();
  
  if (keypressed != NO_KEY)
  {
    if (keypressed == '#')
    {
      // CORREÇÃO 1: Adicionar o caractere nulo para finalizar a string
      numero[index] = '\0';

      Serial.print("Numero digitado: ");
      Serial.println(numero);

      // CORREÇÃO 2: Usar atoi() para converter a string para um inteiro
      int numeroInteiro = atoi(numero);
      
      if (numeroInteiro == target)
      {
        Serial.println("ACERTOU O NUMERO!");
        digitalWrite(13, HIGH);
        digitalWrite(12, LOW);
        digitalWrite(10, LOW);
        delay(3000);
        digitalWrite(13, LOW);
        
        // CORREÇÃO 3: Reinicia o jogo em vez de usar 'break'
        Serial.println("\nNOVO JOGO");
        target = random(1, 101); // Gera um novo número
        Serial.println("Digite um numero entre 1 e 100 e aperte #");
        Serial.print("DEBUG: O novo numero e: ");
        Serial.println(target);
      }
      else if (numeroInteiro > target)
      {
        failboy++;
        Serial.print("Numero digitado MAIOR que o alvo! Tentativa: ");
        Serial.println(failboy);
        digitalWrite(13, LOW);
        digitalWrite(12, LOW);
        digitalWrite(10, HIGH); // LED Vermelho (Maior)
        delay(1500);
        digitalWrite(10, LOW);
      }
      else // Se não é igual nem maior, só pode ser menor
      {
        failboy++;
        // CORREÇÃO 4: Mensagem correta para número menor
        Serial.print("Numero digitado MENOR que o alvo! Tentativa: ");
        Serial.println(failboy);
        digitalWrite(13, LOW);
        digitalWrite(12, HIGH); // LED Amarelo (Menor)
        digitalWrite(10, LOW);
        delay(1500);
        digitalWrite(12, LOW);
      }
      
      // Limpa o buffer para a próxima tentativa
      index = 0;
      memset(numero, 0, pwdsize); // Limpa o array 'numero' completamente
    }
    else
    {
      if (index < pwdsize - 1)
      {
        numero[index] = keypressed;
        index++;
        Serial.print(keypressed);
      }
    }
  }
}
```

-----

## Parte 2: Implementação em Assembly (MARS MIPS)

Esta versão é puramente baseada em software e foi desenvolvida para ser executada no **simulador MARS**. O foco aqui é entender a arquitetura do processador MIPS, o gerenciamento de registradores e o controle de fluxo em baixo nível. Toda a interação é feita pelo console (Run I/O) do simulador.

### Diferença na Lógica (Semente Determinística)

Como a geração de números aleatórios de verdade em Assembly é complexa, adotamos uma abordagem determinística. O programa primeiro pede ao usuário para digitar um número inteiro (a "semente" ou "seed"). O número secreto é então calculado com a fórmula: `target = (seed % 100) + 1`. Isso garante que o alvo esteja sempre entre 1 e 100.

### Lógica do Código (Assembly)

O código é dividido em `.data` (para armazenar as strings) e `.text` (para as instruções).

1.  **Setup:**
      * O programa usa `syscalls` (chamadas de sistema) para interagir com o usuário.
      * Usa `syscall 4` (print\_string) para pedir a semente.
      * Usa `syscall 5` (read\_int) para ler a semente e a armazena no registrador salvo `$s0`.
      * **Cálculo do Alvo:** Para calcular `(seed % 100)`, usamos a instrução `div $s0, $t0` (onde `$t0` tem o valor 100). O resultado da divisão MIPS armazena o resto (o módulo) no registrador especial `$HI`.
      * Usamos `mfhi $t1` (Move From HI) para mover o resto para `$t1`.
      * Usamos `addi $s1, $t1, 1` para somar 1 e guardar o alvo final em `$s1`.
2.  **Loop (`guess_loop`):**
      * O programa pede (`syscall 4`) e lê (`syscall 5`) o palpite do usuário, armazenando-o em `$t0`.
      * Verifica se o palpite é 0 (`beq $t0, $zero, exit_game`). Se for, pula para o fim.
      * **Comparação:** A lógica `if/else` é feita com `slt` (Set on Less Than) e `bne` (Branch if Not Equal).
          * `slt $t1, $t0, $s1` verifica se `palpite < alvo`.
          * `slt $t1, $s1, $t0` verifica se `alvo < palpite` (ou seja, `palpite > alvo`).
      * Dependendo do resultado, o código pula (`bne`) para as labels `is_low` ou `is_high`.
      * Se não pular, significa que são iguais, e o código "cai" na label `is_correct`.
3.  **Resultado:**
      * As labels `is_low` e `is_high` imprimem a mensagem de erro e usam `j guess_loop` para voltar ao início.
      * A label `is_correct` imprime a mensagem de vitória e pula (`j exit_game`) para o fim.
4.  **Saída (`exit_game`):**
      * Imprime a mensagem de despedida e usa `syscall 10` (exit) para encerrar o programa.

### Como Executar

1.  Abra o simulador MARS.
2.  Cole o código na janela de edição.
3.  Vá em `Run > Assemble` (ou F3) para compilar.
4.  Vá em `Run > Go` (ou F5) para executar.
5.  Toda a interação será feita no console na parte inferior, na aba "Run I/O".

### Código-Fonte: Assembly (MIPS)

```mips
# Jogo: Adivinhe o Número
# Descrição:
# 1. O programa solicita uma semente (seed) ao jogador.
# 2. O número secreto é calculado deterministicamente com a fórmula: target = (seed % 100) + 1.
# 3. O jogador entra em um loop de tentativas para adivinhar o número.
# 4. O programa informa se o palpite foi maior, menor ou igual ao número secreto.
# 5. O jogo termina se o jogador acertar ou se digitar 0 como palpite.

.data
    # Strings para interação com o usuário
    seed_prompt:    .asciiz "Digite um numero inteiro para a semente (seed): "
    guess_prompt:   .asciiz "Digite seu palpite (1-100), ou 0 para sair: "
    low_msg:        .asciiz "Muito baixo! Tente um numero maior.\n"
    high_msg:       .asciiz "Muito alto! Tente um numero menor.\n"
    correct_msg:    .asciiz "\nParabens! Voce acertou o numero!\n"
    exit_msg:       .asciiz "\nFim de jogo. Obrigado por jogar!\n"
    debug_msg:      .asciiz "(DEBUG: O numero secreto calculado e: "
    debug_end:      .asciiz ")\n"
    newline:        .asciiz "\n"

.text
.globl main

main:
    # Fase de Configuração (Setup)

    # 1. Solicitar a semente (seed) ao usuário
    li   $v0, 4            # Syscall 4: print_string
    la   $a0, seed_prompt  # Carrega o endereço da string do prompt da semente
    syscall

    # 2. Ler a semente (seed) informada pelo usuário
    li   $v0, 5            # Syscall 5: read_int
    syscall
    move $s0, $v0          # Armazena a semente no registrador salvo $s0

    # 3. Calcular o número secreto: target = (seed % 100) + 1
    li   $t0, 100          # Carrega o valor 100 em um temporário para o cálculo do módulo
    div  $s0, $t0          # Divide seed ($s0) por 100 ($t0). Quociente em $LO, Resto em $HI.
    mfhi $t1               # Move o resto (resultado de %) que está em $HI para $t1
    addi $s1, $t1, 1       # Soma 1 ao resto e armazena o resultado em $s1. $s1 é o nosso 'target'.

    # (Opcional) Exibir o número secreto para fins de debug
    li   $v0, 4
    la   $a0, debug_msg
    syscall
    li   $v0, 1
    move $a0, $s1
    syscall
    li   $v0, 4
    la   $a0, debug_end
    syscall

    # Loop de Tentativas
guess_loop:
    # 1. Solicitar um palpite ao usuário
    li   $v0, 4
    la   $a0, guess_prompt
    syscall

    # 2. Ler o palpite do usuário
    li   $v0, 5
    syscall
    move $t0, $v0          # Armazena o palpite do usuário em $t0

    # 3. Verificar condição de saída (palpite == 0)
    beq  $t0, $zero, exit_game  # Se $t0 for igual a 0, pula para o fim do jogo

    # 4. Comparar o palpite ($t0) com o alvo ($s1)
    
    # Verifica se palpite < alvo
    slt  $t1, $t0, $s1     # $t1 = 1 se ($t0 < $s1), senão $t1 = 0.
    bne  $t1, $zero, is_low  # Se $t1 != 0 (ou seja, se for 1), o palpite é baixo. Pula para 'is_low'.

    # Verifica se palpite > alvo
    slt  $t1, $s1, $t0     # $t1 = 1 se ($s1 < $t0), senão $t1 = 0.
    bne  $t1, $zero, is_high # Se $t1 != 0 (ou seja, se for 1), o palpite é alto. Pula para 'is_high'.

    # Se não é menor nem maior, só pode ser igual.
    # O código "cai" aqui se as duas condições acima falharem.
is_correct:
    li   $v0, 4
    la   $a0, correct_msg
    syscall
    j    exit_game         # O jogador acertou, então pula para o fim do jogo.

is_low:
    li   $v0, 4
    la   $a0, low_msg
    syscall
    j    guess_loop        # Volta para o início do loop para uma nova tentativa.

is_high:
    li   $v0, 4
    la   $a0, high_msg
    syscall
    j    guess_loop        # Volta para o início do loop para uma nova tentativa.

exit_game:
    # Exibe a mensagem de despedida e encerra o programa
    li   $v0, 4
    la   $a0, exit_msg
    syscall

    li   $v0, 10           # Syscall 10: exit
    syscall
```
