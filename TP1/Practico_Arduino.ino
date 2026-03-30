void setup() {
  noInterrupts();
  CLKPR = 0x80; 
  CLKPR = 0x00; // Divisor 1 (16 MHz)
  interrupts();

  pinMode(LED_BUILTIN, OUTPUT);
  Serial.begin(9600); 

  unsigned long start = millis();
  digitalWrite(LED_BUILTIN, HIGH);
  Serial.println("--- Test 16 MHz ---");

  volatile long sumaEnt = 0;
  volatile float sumaFl = 0.0;

  // Doble de iteraciones que en 8MHz
  for (long i = 0; i < 3055000; i++) sumaEnt++;
  for (long j = 0; j < 001000; j++) sumaFl += 1.1;

  digitalWrite(LED_BUILTIN, LOW);
  unsigned long end = millis();

  float tiempoReal = (end - start) / 1000.0;

  Serial.print("Tiempo real medido: ");
  Serial.print(tiempoReal);
  Serial.println(" segundos.");
}

void loop() {}

// El código configura el microcontrolador para operar a 16 MHz, luego realiza una serie de operaciones para medir el tiempo que tarda en ejecutarlas. Se utiliza la función `millis()` para medir el tiempo transcurrido entre el inicio y el final de las operaciones, y se imprime el resultado en segundos a través del monitor serial. 
// Para modificar la frecuencia del fcclk se debe modificar el valor de CLKPR y también el serial.begin() para que coincida con la nueva frecuencia. Por ejemplo, si se cambia a 8 MHz, se debe establecer CLKPR a 0x01 y Serial.begin(9600) a Serial.begin(4800).