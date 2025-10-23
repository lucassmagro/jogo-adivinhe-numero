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
    li   $v0, 4              # Syscall 4: print_string
    la   $a0, seed_prompt    # Carrega o endereço da string do prompt da semente
    syscall

    # 2. Ler a semente (seed) informada pelo usuário
    li   $v0, 5              # Syscall 5: read_int
    syscall
    move $s0, $v0            # Armazena a semente no registrador salvo $s0

    # 3. Calcular o número secreto: target = (seed % 100) + 1
    li   $t0, 100            # Carrega o valor 100 em um temporário para o cálculo do módulo
    div  $s0, $t0            # Divide seed ($s0) por 100 ($t0). Quociente em $LO, Resto em $HI.
    mfhi $t1                 # Move o resto (resultado de %) que está em $HI para $t1
    addi $s1, $t1, 1         # Soma 1 ao resto e armazena o resultado em $s1. $s1 é o nosso 'target'.

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
    move $t0, $v0            # Armazena o palpite do usuário em $t0

    # 3. Verificar condição de saída (palpite == 0)
    beq  $t0, $zero, exit_game  # Se $t0 for igual a 0, pula para o fim do jogo

    # 4. Comparar o palpite ($t0) com o alvo ($s1)
    
    # Verifica se palpite < alvo
    slt  $t1, $t0, $s1       # $t1 = 1 se ($t0 < $s1), senão $t1 = 0.
    bne  $t1, $zero, is_low  # Se $t1 != 0 (ou seja, se for 1), o palpite é baixo. Pula para 'is_low'.

    # Verifica se palpite > alvo
    slt  $t1, $s1, $t0       # $t1 = 1 se ($s1 < $t0), senão $t1 = 0.
    bne  $t1, $zero, is_high # Se $t1 != 0 (ou seja, se for 1), o palpite é alto. Pula para 'is_high'.

    # Se não é menor nem maior, só pode ser igual.
    # O código "cai" aqui se as duas condições acima falharem.
is_correct:
    li   $v0, 4
    la   $a0, correct_msg
    syscall
    j    exit_game           # O jogador acertou, então pula para o fim do jogo.

is_low:
    li   $v0, 4
    la   $a0, low_msg
    syscall
    j    guess_loop          # Volta para o início do loop para uma nova tentativa.

is_high:
    li   $v0, 4
    la   $a0, high_msg
    syscall
    j    guess_loop          # Volta para o início do loop para uma nova tentativa.

exit_game:
    # Exibe a mensagem de despedida e encerra o programa
    li   $v0, 4
    la   $a0, exit_msg
    syscall

    li   $v0, 10             # Syscall 10: exit
    syscall
