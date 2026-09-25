library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity rand_sec is
    Generic (
        SEED_DEFAULT : std_logic_vector(7 downto 0) := "10110011";
        STEPS        : positive := 8    -- DESPLAZAMIENTO PARA ALEATORIEDAD DADO EL
    );                                  -- CAMBIO EN LA SEÑAL EN (1 EN UN TCLK, 0 EN
    Port (                              -- LOS SIGUIENTES HASTA CUMPLIR CICLO LENTO)
        clk      : in  std_logic;
        reset    : in  std_logic;
        en       : in  std_logic;
        seedIn   : in  std_logic_vector(7 downto 0);    --lfsrLEN = 8
        rndOut   : out std_logic_vector(3 downto 0)     --lfsrIter = 4
    );
end rand_sec;

architecture Behavioural of rand_sec is
    signal sr : std_logic_vector(7 downto 0) := SEED_DEFAULT;
    signal pre_map_value : std_logic_vector(1 downto 0);
begin

    process(clk)        -- (AC5: CODIGO SECUENCIAL)
        variable s : std_logic_vector(7 downto 0);      -- (AC4: USO DE VARIABLES PARA ACTUALIZAR VALORES INSTANTANEOS)
    begin
        if rising_edge(clk) then
            if reset = '1' then     
                if seedIn = "00000000" then
                    sr <= SEED_DEFAULT;     -- SEMILLA CONSTANTE PARA QUE FUNCIONE LA 
                else                        -- RETROALIMENTACION DE 8 BITS (LOS XOR)
                    sr <= seedIn;
                end if;
            elsif en = '1' then     -- EN EL CICLO DE SYSCLK DONDE EN = 1
                s := sr;            -- SE ACTUALIZA LA VARIABLE INTERMEDIA
                for i in 1 to STEPS loop                                        -- SE AVANZA MULTIPLES ESTADOS PARA QUE NO SEA PREDECIBLE LA SECUENCIA
                    s := s(6 downto 0) & (s(7) xor s(5) xor s(4) xor s(3));     -- EJ DE NO APLICARSE: TRAS UN 0001 (00 LSB de s) SOLO PUEDE 
                end loop;           -- (AC3 PARCIAL: USO DE OPERADORES)         -- VENIR 0001 O 0010 (01 LSB de s) DADA LA LOGICA DEL LFSR
                sr <= s;
            end if;
        end if;
    end process;

    pre_map_value <= sr(1 downto 0);

    -- (AC5: CODIGO CONCURRENTE)
    with pre_map_value select
        rndOut <= "0001" when "00",         -- DECODIFICACION DE LOS 2 BITS LSB
                  "0010" when "01",         -- PARA TRADUCIR EL LED A ENCENDER
                  "0100" when "10",
                  "1000" when "11",
                  "0001" when others;

end Behavioural;