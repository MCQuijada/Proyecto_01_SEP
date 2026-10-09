library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.game_pkg.all; -- Importación de tu package para cumplir AC6

entity seq_cmp is
    Port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        en_input  : in  std_logic;                     -- Señal de permiso de la FSM
        num_seq   : in  std_logic_vector(4 downto 0);  -- Límite de la secuencia actual
        
        btn_valid : in  std_logic;                     -- Pulso limpio desde input_det
        btn_data  : in  std_logic_vector(3 downto 0);  -- Qué botón se presionó
        mem_data  : in  std_logic_vector(3 downto 0);  -- Qué luz estaba guardada
        
        addr_rd   : out std_logic_vector(4 downto 0);  -- Puntero a la memoria
        win       : out std_logic;                     -- 1 si acierta todo
        lose      : out std_logic                      -- 1 si se equivoca
    );
end seq_cmp;

architecture Behavioral of seq_cmp is

    -- Señales internas para el manejo de punteros y estados del comparador
    signal ptr_reg   : integer range 0 to 31 := 0;
    signal win_reg   : std_logic := '0';
    signal lose_reg  : std_logic := '0';

begin

    -- Asignación continua de las salidas del componente
    addr_rd <= std_logic_vector(to_unsigned(ptr_reg, 5));
    win     <= win_reg;
    lose    <= lose_reg;

    process(clk)
        -- Variables de control locales para invocar el procedimiento (AC6)
        variable v_match : std_logic;
        variable v_error : std_logic;
    begin
        if rising_edge(clk) then
            if rst = '1' then
                ptr_reg  <= 0;
                win_reg  <= '0';
                lose_reg <= '0';
            else
                -- 3. Reiniciar variables y salidas cuando 'en_input' sea '0' (fuera de turno de juego)
                if en_input = '0' then
                    ptr_reg  <= 0;
                    win_reg  <= '0';
                    lose_reg <= '0';
                elsif en_input = '1' and win_reg = '0' and lose_reg = '0' then
                    
                    -- Si hay un botón válido presionado por el usuario en este ciclo de reloj
                    if btn_valid = '1' then
                        
                        -- 2. AC6 (Procedure): Llamar al procedure de 'game_pkg' para comparar
                        check_match(btn_data, mem_data, v_match, v_error);
                        
                        -- 3. Lógica de término
                        if v_error = '1' then
                            -- Si el procedimiento arroja error, emitir 'lose'
                            lose_reg <= '1';
                        elsif v_match = '1' then
                            -- Si acierta, evaluamos si era el último elemento de la secuencia actual
                            if ptr_reg = (to_integer(unsigned(num_seq)) - 1) then
                                -- Si el puntero llega al límite ('num_seq'), emitir 'win'
                                win_reg <= '1';
                            else
                                -- 1. Puntero: Avanzar 'addr_rd' si aún quedan botones por validar en el nivel
                                ptr_reg <= ptr_reg + 1;
                            end if;
                        end if;
                        
                    end if;
                    
                end if;
            end if;
        end if;
    end process;

end Behavioral;