library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity timer is
    Port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        en_input   : in  std_logic;                    -- Habilita la cuenta regresiva
        tick       : in  std_logic;                    -- Pulso lento de gclk_sel
        num_seq    : in  std_logic_vector(4 downto 0); -- Para calcular el tiempo proporcional
        
        leds_time  : out std_logic_vector(3 downto 0); -- Visualización de barra de tiempo
        timeout    : out std_logic                     -- 1 si el tiempo se acaba (conecta a 'lose')
    );
end timer;

architecture Behavioral of timer is
begin
    -- TAREAS A PROGRAMAR AQUÍ:
    -- 1. AC4 (Variables): Usar una 'variable' dentro del proceso para calcular el límite
    --    de tiempo instantáneamente (ej: limite := num_seq * multiplicador).
    -- 2. Animación: Apagar un LED de 'leds_time' cada cierto porcentaje del límite alcanzado.
    -- 3. Timeout: Si el contador alcanza el límite antes de que 'en_input' baje a 0, 
    --    emitir 'timeout = 1' para que la FSM pase al estado LOSE.
end Behavioral;
