# Juego de Memoria con Zybo Z7

## Descripción del proyecto

El proyecto consiste en desarrollar, utilizando la placa **Zybo Z7**, un juego de memoria basado en una secuencia aleatoria de LEDs.

El sistema mostrará una secuencia aleatoria de LEDs durante un determinado período de tiempo. Luego, el usuario deberá **adivinar y repetir la secuencia** presionando los botones correspondientes, del **01 al 04**.

El **LED RGB** se utilizará para indicar diferentes estados del juego, por ejemplo:

* Juego en progreso.
* Respuesta incorrecta.
* Victoria.
* Fin del juego.

El juego tendrá un número finito de aproximadamente **10 rondas** y la dificultad aumentará linealmente a medida que el jugador avance.

Además, el sistema contará con un sistema de puntuación:

* Se calculará un puntaje total para cada partida.
* Se almacenará un **puntaje máximo**.
* El puntaje máximo podrá visualizarse utilizando los switches de la placa.
* Una vez finalizado el juego, el usuario podrá ingresar su nombre utilizando los botones y switches.
* El puntaje y el nombre del jugador se almacenarán en **RAM**.
* Se podrá acceder a un **modo espectador**, donde será posible visualizar el puntaje máximo y los puntajes obtenidos por otros jugadores.

---

## Proyecto - Avance clase 24/08/2026

### Conceptos aprendidos

* Diferencia entre las asignaciones `:=` y `<=`.

  * `:=` realiza una asignación directa.
  * `<=` representa una asignación utilizada para describir la conexión/comportamiento de señales en VHDL.

* `others => 0` permite asignar `0` a todos los bits restantes de un vector.

  ```vhdl
  signal ejemplo : std_logic_vector(7 downto 0) := (others => '0');
  ```

* Para realizar multiplicaciones y otras operaciones aritméticas es necesario importar el paquete:

  ```vhdl
  IEEE.NUMERIC_STD
  ```

* Para la **ACT4** de la clase basta con tener una variable o contador que llegue hasta cierto valor mediante una condición y luego actualizarlo.

---

## Próximos avances

* Implementar el generador de secuencias aleatorias.
* Implementar la visualización de la secuencia mediante LEDs.
* Implementar la entrada del usuario mediante los botones.
* Implementar el sistema de rondas y dificultad.
* Implementar los estados mediante el LED RGB.
* Implementar el sistema de puntuación.
* Implementar el almacenamiento de puntajes en RAM.
* Implementar el ingreso del nombre del jugador.
* Implementar el modo espectador.
