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
begin
    -- TAREAS A PROGRAMAR AQUÍ:
    -- 1. Debouncer: Crear lógica anti-rebote usando registros para estabilizar 'btn_in'.
    -- 2. Edge Detector: Asegurar que al mantener presionado, 'btn_valid' solo dure 1 ciclo de reloj.
    -- 3. AC6 (Function): Llamar a la función de 'game_pkg' para asegurar que el ingreso 
    --    sea estrictamente One-Hot antes de validarlo.
end Behavioral;