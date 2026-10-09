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
        
        led  : out std_logic_vector(3 downto 0); -- Visualización de barra de tiempo
        timeout    : out std_logic                     -- 1 si el tiempo se acaba (conecta a 'lose')
    );
end timer;

architecture Behavioral of timer is

    -- Señales para el detector de flanco de la señal 'tick'
    signal tick_d1, tick_d2 : std_logic := '0';
    signal tick_pulse       : boolean;

    -- Contador principal de tiempo transcurrido
    signal count : integer range 0 to 255 := 0;

begin

    -- Detector de flanco de subida para 'tick'
    process(clk)
    begin
        if rising_edge(clk) then
            tick_d1 <= tick;
            tick_d2 <= tick_d1;
        end if;
    end process;
    
    tick_pulse <= (tick_d1 = '1' and tick_d2 = '0');

    -- Proceso principal del temporizador
    process(clk)
        -- 1. AC4 (Variables): Declaración de variable local. 
        -- Es información local visible solo dentro del PROCESS y se actualiza de forma inmediata.
        variable v_limite : integer range 0 to 255 := 0;
    begin
        if rising_edge(clk) then
            if rst = '1' then
                count <= 0;
                led <= "0000";
                timeout <= '0';
            else
                if en_input = '0' then
                    -- Si no es el turno del jugador, el timer se reinicia y se pausa
                    count <= 0;
                    led <= "1111"; -- LEDs encendidos al 100%
                    timeout <= '0';
                else
                    
                    -- 1. AC4: Cálculo inmediato del límite de tiempo.
                    -- Multiplicador: Le damos 4 "ticks" de tiempo al jugador por cada paso de la secuencia.
                    v_limite := to_integer(unsigned(num_seq)) * 4;

                    -- Avance del contador usando el pulso lento
                    if tick_pulse then
                        if count < v_limite then
                            count <= count + 1;
                        end if;
                    end if;

                    -- 2. Animación y 3. Timeout
                    -- Evaluamos instantáneamente usando 'v_limite' para ir apagando los LEDs
                    if count >= v_limite then
                        led <= "0000";
                        timeout   <= '1'; -- 3. Timeout: Emite 1 para que la FSM pase al estado LOSE
                    elsif count >= (v_limite * 3 / 4) then
                        led <= "0001"; -- Queda el 25% del tiempo (1 LED encendido)
                        timeout   <= '0';
                    elsif count >= (v_limite * 2 / 4) then
                        led <= "0011"; -- Queda el 50% del tiempo (2 LEDs encendidos)
                        timeout   <= '0';
                    elsif count >= (v_limite * 1 / 4) then
                        led <= "0111"; -- Queda el 75% del tiempo (3 LEDs encendidos)
                        timeout   <= '0';
                    else
                        led <= "1111"; -- Tiempo completo
                        timeout   <= '0';
                    end if;
                    
                end if;
            end if;
        end if;
    end process;

end Behavioral;