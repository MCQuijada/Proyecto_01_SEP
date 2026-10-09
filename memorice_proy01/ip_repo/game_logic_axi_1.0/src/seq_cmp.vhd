library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.game_pkg.all; -- Importación de tu package para cumplir AC6

entity seq_cmp is
    Port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        en_input  : in  std_logic;                    -- Señal de permiso de la FSM
        num_seq   : in  std_logic_vector(4 downto 0); -- Límite de la secuencia actual
        
        btn_valid : in  std_logic;                    -- Pulso limpio desde input_det
        btn_data  : in  std_logic_vector(3 downto 0); -- Qué botón se presionó
        mem_data  : in  std_logic_vector(3 downto 0); -- Qué luz estaba guardada
        
        addr_rd   : out std_logic_vector(4 downto 0); -- Puntero a la memoria
        win       : out std_logic;                    -- 1 si acierta todo
        lose      : out std_logic                     -- 1 si se equivoca
    );
end seq_cmp;

architecture Behavioral of seq_cmp is
begin
    -- TAREAS A PROGRAMAR AQUÍ:
    -- 1. Puntero: Crear un contador que avance 'addr_rd' cada vez que el jugador acierta un botón.
    -- 2. AC6 (Procedure): Llamar al procedure de 'game_pkg' para comparar 'btn_data' con 'mem_data'.
    -- 3. Lógica de término: Si el procedure arroja error, emitir 'lose'. Si arroja match y 
    --    el puntero llega a 'num_seq', emitir 'win'. Reiniciar variables cuando 'en_input' sea 0.
end Behavioral;