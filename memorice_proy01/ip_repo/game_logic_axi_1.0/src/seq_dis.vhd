library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seq_dis is
    Generic (
        ADDR_WIDTH : positive := 5
    );
    Port (
        clk            : in  std_logic;
        tick           : in  std_logic; -- PULSO LENTO DESDE GCLK_SEL
        enable_display : in  std_logic;
        num_seq        : in  std_logic_vector(ADDR_WIDTH-1 downto 0);   -- NUMERO DE SECUENCIAS
        data_from_mem  : in  std_logic_vector(3 downto 0);
        
        addr_rd        : out std_logic_vector(ADDR_WIDTH-1 downto 0);
        led            : out std_logic_vector(3 downto 0);
        seq_done       : out std_logic
    );
end seq_dis;

architecture Behavioral of seq_dis is
    signal ptr   : unsigned(ADDR_WIDTH-1 downto 0) := (others => '0');      -- PUNTERO QUE REPRESENTA EL NUMERO DE SECUENCIA ACTUAL
    signal phase : std_logic := '0';    -- FASES DE MOSTRAR DATO DE LA MEMORIA EN LEDS (0) O APAGADO
begin                                   -- INTERMEDIO PARA VISUALIZACION CORRECTA DE LA SECUENCIA (1)

    addr_rd <= std_logic_vector(ptr);   -- ASIGNACION CONCURRENTE PARA EVITAR DESFASE DE UN PASO AL LEER LA MEMORIA

    process(clk)
    begin
        if rising_edge(clk) then
            if enable_display = '0' then
                ptr      <= (others => '0');
                phase    <= '0';
                led      <= "0000";
                seq_done <= '0';
            elsif tick = '1' then   -- CICLO LENTO
                if phase = '0' then     -- FASE 1: DATO DE LA MEMORIA VALIDO SE MUESTRA EN LEDS
                    led   <= data_from_mem;
                    phase <= '1';
                else    -- FASE 2: APAGADO INTERMEDIO EN EL SIGUIENTE TICK (PARA MEJOR VISUALIZACION DE UN MISMO LED ENCENDIDO 2 VECES SEGUIDAS)
                    led <= "0000";
                    if ptr = unsigned(num_seq) - 1 then     -- SI SE LLEGA AL FINAL DE LA SECUENCIA
                        seq_done <= '1';
                    else        -- SI NO SIGUE LEYENDO DATOS DEL LA MEMORIA
                        ptr   <= ptr + 1;
                        phase <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process;

end Behavioral;