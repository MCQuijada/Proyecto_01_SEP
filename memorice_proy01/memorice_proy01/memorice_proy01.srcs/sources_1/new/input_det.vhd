library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.game_pkg.all; -- Importación de tu package para cumplir AC6

entity input_det is
    Port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        btn_in    : in  std_logic_vector(3 downto 0); -- Botones físicos crudos
        
        btn_out   : out std_logic_vector(3 downto 0); -- Botón presionado limpio
        btn_valid : out std_logic                     -- Pulso de 1 ciclo cuando hay un ingreso válido
    );
end input_det;

architecture Behavioral of input_det is

    -- Constante para el contador de debounce. 
    -- Para un reloj de 100MHz, 1_000_000 de ciclos equivalen a 10 ms (suficiente para estabilizar el rebote).
    constant DEBOUNCE_LIMIT : integer := 1_000_000; 
    signal count : integer range 0 to DEBOUNCE_LIMIT := 0;

    -- Señales internas para el Debouncer
    signal sync1, sync2   : std_logic_vector(3 downto 0) := (others => '0');
    signal btn_debounced  : std_logic_vector(3 downto 0) := (others => '0');
    
    -- Señal interna para el Edge Detector
    signal btn_prev       : std_logic_vector(3 downto 0) := (others => '0');

begin

    -- TAREAS A PROGRAMAR AQUÍ:
    
    -- 1. Debouncer: Crear lógica para detectar un botón presionado y eliminar el ruido.
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                sync1 <= (others => '0');
                sync2 <= (others => '0');
                btn_debounced <= (others => '0');
                count <= 0;
            else
                -- a) Sincronización de 2 etapas (evita metaestabilidad al traer señales asíncronas externas)
                sync1 <= btn_in;
                sync2 <= sync1;

                -- b) Lógica de Debounce (espera a que la señal se mantenga estable)
                if sync2 /= btn_debounced then
                    if count = DEBOUNCE_LIMIT - 1 then
                        btn_debounced <= sync2; -- Actualizamos el estado limpio
                        count <= 0;
                    else
                        count <= count + 1;
                    end if;
                else
                    count <= 0; -- Si la señal no ha cambiado, mantenemos el contador en 0
                end if;
            end if;
        end if;
    end process;

    -- 2. Edge Detector y 3. AC6 (Function) - Validación One-Hot
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                btn_prev  <= (others => '0');
                btn_out   <= (others => '0');
                btn_valid <= '0';
            else
                -- Actualizamos el estado anterior con el actual debounced para detectar cambios
                btn_prev  <= btn_debounced;
                
                -- Por defecto, btn_valid es 0 (así garantizamos que dure solo 1 ciclo de reloj)
                btn_valid <= '0'; 

                -- DETECCIÓN DE FLANCO DE SUBIDA: 
                -- Si actualmente hay un botón presionado (distinto de "0000") pero en el ciclo 
                -- anterior no había nada ("0000"), significa que acaba de ser presionado.
                if btn_debounced /= "0000" and btn_prev = "0000" then
                    
                    -- LLAMADA A LA FUNCIÓN DEL PACKAGE (AC6)
                    -- Solo validamos la entrada si es estrictamente One-Hot (un solo botón a la vez).
                    if is_one_hot(btn_debounced) = '1' then
                        btn_out   <= btn_debounced;
                        btn_valid <= '1'; -- Disparamos el pulso de 1 ciclo
                    end if;
                    
                end if;
            end if;
        end if;
    end process;

end Behavioral;