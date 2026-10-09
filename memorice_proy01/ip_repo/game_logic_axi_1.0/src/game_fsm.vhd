library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity game_fsm is
    Port (
        clk        : in  std_logic; -- CLK DE TOP
        reset      : in  std_logic; -- RESET DE BOTON FISICO
        start      : in  std_logic; -- INICIO DEL JUEGO AL PRESIONAR CUALQUIER BOTON
        gen_done   : in  std_logic; -- GENERACION DE SECUENCIA LISTA
        seq_done   : in  std_logic; -- DISPLAY DE SECUENCIA AL USUARIO LISTO
        win        : in  std_logic; -- SI GANA EL NIVEL ACTUAL
        lose       : in  std_logic; -- ERROR AL PRESIONAR LA SECUENCIA O TIMEOUT
        
        rgb        : out std_logic_vector(2 downto 0);  -- LED RGB QUE INDICA ESTADOS DE LA FSM
        lvl        : out std_logic_vector(1 downto 0);  -- NIVEL DE DIFICULTAD A GCLK_SEL
        num_seq    : out std_logic_vector(4 downto 0);  -- LONGITUD DE LA SECUENCIA A ADIVINAR
        en_lfsr    : out std_logic; -- MANTIENE ENABLE DE LFSR ITERANDO EN IDLE PARA OBTENER SEMILLA RANDOM
        en_show    : out std_logic; -- HABILITA EL DISPLAY DE LA SECUENCIA EN LOS LEDS AL USUARIO
        en_input   : out std_logic; -- HABILITA LA EVALUACION DE LOS BOTONES PRESIONADOS POR EL USUARIO
        mem_rd_sel : out std_logic; -- CONTROLA LA DIRECCION DE LECTURA A SEQ_MEM (0=SHOW, 1=INPUT_DET)
        mux_sel    : out std_logic_vector(1 downto 0)   -- ENRUTA LOS LEDS A LA SECUENCIA (01) O AL TIEMPO RESTANTE (10)
    );
end game_fsm;

architecture Behavioral of game_fsm is

    type state_type is (IDLE, GEN, SHOW, INPUT, LEVEL_OK, LOSE, WIN);
    signal state, next_state : state_type;

    signal lvl_reg     : unsigned(1 downto 0) := "00";
    signal num_seq_reg : integer range 0 to 31 := 4; -- INICIA EN 4 SECUENCIAS

begin

    SYNC_PROC: process(clk)     -- SINCRONIZACION CON EL RELOJ
    begin
        if rising_edge(clk) then
            if reset = '1' then         -- RESET ESTADO VUELVE A IDLE, NIVEL FACIL Y 4 SECUENCIAS
                state <= IDLE;
                lvl_reg <= "00";
                num_seq_reg <= 4;
            else
                state <= next_state;

                if state = IDLE then
                    lvl_reg <= "00";
                    num_seq_reg <= 4;
                elsif state = LEVEL_OK then
                    if lvl_reg < "11" then      -- PASO AL SIGUIENTE NIVEL DE DIFICULTAD AUMENTANDO LAS SECUENCIAS A ADIVINAR (4->8->12)
                        lvl_reg <= lvl_reg + 1;
                        num_seq_reg <= num_seq_reg + 4;
                    end if;
                end if;
            end if;
        end if;
    end process;

    OUTPUT_DECODE: process(state, start, gen_done, seq_done, win, lose, lvl_reg)        -- LOGICA DE ESTADOS
    begin
        next_state <= state;
        rgb        <= "000";
        en_lfsr    <= '0';
        en_show    <= '0';
        en_input   <= '0';
        mem_rd_sel <= '0';
        mux_sel    <= "00"; 

        case state is       -- (AC1: MAQUINA DE ESTADOS)
            when IDLE =>        -- ESTADO DE ESPERA: LED BLANCO, MANTIENE EN_LFSR PARA OBTENER SEMILLA RANDOM
                rgb <= "111";
                en_lfsr <= '1'; 
                if start = '1' then     -- USUARIO PRESIONA BOTON INICIA EL JUEGO
                    next_state <= GEN;
                end if;

            when GEN =>         -- ESTADO GENERACION DE SECUENCIA: LED VERDE (INVISIBLE AL OJO, SALTA AL INSTANTE A SHOW)
                rgb <= "010";   
                if gen_done = '1' then  -- SI SE GENERO LA SECUENCIA PASA AL SIGUIENTE ESTADO
                    next_state <= SHOW;
                end if;

            when SHOW =>        -- ESTADO DISPLAY DE SECUENCIA: LED VERDE, EN_SHOW PARA MOSTRAR LA SECUENCIA,
                rgb <= "010";   -- MEM_RD_SEL PARA LEER MEMORIA POR SEQ_DIS, ENRUTAMIENTO DE LOS LEDS A LA SECUENCIA
                en_show <= '1';
                mem_rd_sel <= '0';
                mux_sel <= "01";   
                if seq_done = '1' then      -- SE TERMINA DE MOSTRAR LA SECUENCIA
                    next_state <= INPUT;
                end if;

            when INPUT =>       -- ESTADO DE ENTRADAS DEL USUARIO: LED AMARILLO, EN_INPUT PARA VALIDAR ENTRADAS, 
                rgb <= "110";   -- MEM_RD_SEL PARA LEER MEMORIA POR INPUT_DET, ENRUTAMIENTO DE LOS LEDS AL TIEMPO RESTANTE
                en_input <= '1';
                mem_rd_sel <= '1';
                mux_sel <= "10";   
                if lose = '1' then      -- SI SE EQUIVOCA PASA AL ESTADO DE PERDEDOR
                    next_state <= LOSE;
                elsif win = '1' then    
                    if lvl_reg = "11" then  -- SI LO HACE CORRECTAMENTE Y ESTABA EN EL ULTIMO NIVEL GANA
                        next_state <= WIN;
                    else                    -- SI LO HACE CORRECTAMENTE Y FALTAN NIVELES PASA AL SIGUIENTE
                        next_state <= LEVEL_OK;
                    end if;
                end if;

            when LEVEL_OK =>    -- ESTADO DE NIVEL CORRECTO: LED AZUL, ESPERA BOTON PARA PASAR AL SIGUIENTE NIVEL
                rgb <= "001"; 
                if start = '1' then
                    next_state <= GEN; 
                end if;

            when LOSE =>        -- ESTADO DE PERDEDOR: LED ROJO
                rgb <= "100"; 
                if start = '1' then     -- DEBE COMENZAR PARA JUGAR DE NUEVO
                    next_state <= IDLE;
                end if;

            when WIN =>         -- ESTADO DE GANADOR: LED MAGENTA (ARCOIRIS)
                rgb <= "101"; 
                if start = '1' then     -- DEBE COMENZAR PARA JUGAR DE NUEVO
                    next_state <= IDLE;
                end if;

            when others =>
                next_state <= IDLE;
        end case;
    end process;

    lvl     <= std_logic_vector(lvl_reg);
    num_seq <= std_logic_vector(to_unsigned(num_seq_reg, 5)); 

end Behavioral;