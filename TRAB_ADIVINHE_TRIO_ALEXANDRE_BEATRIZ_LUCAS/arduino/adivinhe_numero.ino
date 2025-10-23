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