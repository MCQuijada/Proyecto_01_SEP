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

* # Plan de Implementación – Juego de Memoria en Zybo Z7
**Proyecto 1 · IEE2463 Sistemas Electrónicos Programables (PUC)**

## Enfoque

El orden sigue las dependencias naturales del sistema: primero los bloques generadores de datos y entrada (que luego se empaquetan como IP-cores), después la máquina de estados que orquesta el juego, luego la capa de puntuación/RAM (donde entra AXI), y al final el modo espectador junto con la depuración e integración. Así cada actividad obligatoria y complementaria queda cubierta en el momento en que naturalmente aparece en el código, no como un parche al final.

## Cronograma resumido

| Tarea del juego | S1 (31 ago–6 sep) | S2 (7–13 sep) | S3 (14–20 sep) | S4 (21–27 sep) |
|---|:---:|:---:|:---:|:---:|
| 1. Generador de secuencias aleatorias | ● | | | |
| 2. Entrada de usuario (botones) | ● | | | |
| 3. Estados vía LED RGB (máquina de estados) | | ● | | |
| 4. Visualización de la secuencia (LEDs) | | ● | | |
| 5. Sistema de rondas y dificultad | | ● | | |
| 6. Sistema de puntuación | | | ● | |
| 7. Almacenamiento de puntajes en RAM | | | ● | ○ |
| 8. Ingreso del nombre del jugador | | | ● | |
| 9. Modo espectador | | | | ● |
| Integración, VIO/ILA, informe y video | | ○ | ○ | ● |

`●` desarrollo principal · `○` continuación o cierre

---

## Semana 1 (31 ago – 6 sep): Bloques base

**1. Generador de secuencias aleatorias**
- Implementar un LFSR (o generador pseudoaleatorio equivalente) como *entity* independiente.
- Primer candidato a *package*/IP-core (**AO2**), con parámetros genéricos (ancho del registro, semilla inicial).
- Buen lugar para el operador XOR y el atributo `'event` (**AC3**), y para usar una variable interna que actualiza el registro en cada flanco (**AC4**).

**2. Entrada de usuario (botones)**
- Lógica de debounce + captura de qué botón (01–04) fue presionado.
- Excelente ejemplo para contrastar código secuencial (proceso de debounce con estados) vs. código concurrente (decodificación combinacional del botón activo) — deja evidencia clara para **AC5**.
- Segundo *package* candidato para **AO2**.

---

## Semana 2 (7 – 13 sep): Lógica central del juego

**3. Estados vía LED RGB → Máquina de estados**
- Aquí se construye la FSM principal del juego: `IDLE → MOSTRANDO_SECUENCIA → ESPERANDO_INPUT → RESPUESTA_INCORRECTA / VICTORIA → FIN_JUEGO`.
- Cubre directamente **AC1**.

**4. Visualización de la secuencia (LEDs)**
- Conecta el generador (S1) con un temporizador de despliegue controlado por la FSM.

**5. Sistema de rondas y dificultad**
- Contador de rondas dentro de la FSM; comparadores para reducir linealmente el tiempo de despliegue.
- Suma operadores y atributos adicionales para completar **AC3** (por ejemplo `'length`/`'range` sobre el vector de secuencia, operadores relacionales `<`, `=`).

**Cierre de semana:** integrar generador + entrada + FSM como *components* dentro de una *entity* superior (top-level del juego) → cumple **AO1** (≥3 components integrados).

---

## Semana 3 (14 – 20 sep): Puntuación, RAM y AXI

**6. Sistema de puntuación**
- Una *function* que calcule el puntaje (por ejemplo en base a ronda alcanzada y tiempo de respuesta) y una *procedure* que lo actualice — mostrando explícitamente en el informe la diferencia de uso entre ambas rutinas (**AC6**).

**7. Almacenamiento de puntajes en RAM**
- Empaquetar el módulo de RAM como IP-core con parámetros genéricos (profundidad, ancho de dato) → tercer *package*, completando **AO2**.
- Exponerlo como esclavo AXI y conectar un ATG maestro en **Test Mode** para validar la comunicación básica → primera mitad de **AO3**.

**8. Ingreso del nombre del jugador**
- Captura por botones/switches, actualizando el registro de nombre asociado al puntaje en la misma RAM.

---

## Semana 4 (21 – 27 sep): Modo espectador, depuración e integración final

**9. Modo espectador**
- Uso de switches para navegar los puntajes almacenados. Es un buen candidato para **AC7** (función no vista en el curso) si se implementa, por ejemplo, accediendo a la RAM mediante EMIO o una variante de acceso no cubierta en clases — hay que documentar explícitamente qué se aprendió por cuenta propia.

**Cierre de AO3:** conectar un segundo ATG maestro en **Advance Mode** (al mismo IP-core de RAM o al de nombre/puntaje) → completa **AO3**.

**VIO e ILA (AC2):** integrarlos para monitorear/modificar señales internas durante la demo — estado de la FSM, contenido de la secuencia, transacciones AXI. Útil también para las capturas que pide el informe/video.

**Integración final:**
- Limpieza del block design (sin bloques "basura", sin conexiones innecesarias).
- Revisión de comentarios en todo el código VHDL propio.
- Pruebas de punta a punta en la Zybo, grabación del video (5–15 min) y redacción del informe en LaTeX.

---

## Checklist de cobertura (10 actividades)

| Código | Actividad | Dónde se cubre |
|---|---|---|
| AO1 | ≥3 components en una entity superior | Cierre S2 |
| AO2 | ≥3 packages/IP-cores con genéricos | S1 (generador, entrada), S3 (RAM) |
| AO3 | AXI: ATG Test Mode + Advance Mode | S3 (Test Mode), S4 (Advance Mode) |
| AC1 | Máquina de estados | S2 |
| AC2 | VIO e ILA | S4 |
| AC3 | ≥2 operadores y ≥2 atributos | S1–S2 |
| AC4 | Variables | S1 |
| AC5 | Código secuencial vs. concurrente | S1 |
| AC6 | Functions y procedures | S3 |
| AC7 | Función no vista en el curso | S4 |

## Notas prácticas

- El proyecto es en parejas: las tareas de S1 y S2 (generador/entrada vs. FSM/visualización) se prestan bien para dividirse en paralelo entre los dos integrantes.
- Dejen margen antes del cierre de S4 para imprevistos de síntesis/implementación en Vivado — no dejen la primera generación de bitstream para los últimos días.
- El informe y el video dependen de capturas de Vivado/Vitis y de la Zybo funcionando, así que consideren tenerlos listos con un par de días de margen sobre la fecha de entrega real del curso.
