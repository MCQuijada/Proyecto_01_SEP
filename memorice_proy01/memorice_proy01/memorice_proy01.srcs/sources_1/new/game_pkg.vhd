library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package game_pkg is
    -- TAREAS A PROGRAMAR AQUÍ:
    -- 1. AC6 (Function): Declarar la firma de una función que reciba los botones 
    --    y retorne '1' si es One-Hot (solo un botón presionado a la vez).
    function is_one_hot (btn_in : std_logic_vector(3 downto 0)) return std_logic;
    
    -- 2. AC6 (Procedure): Declarar la firma de un procedure que compare el botón 
    --    ingresado con el dato de la memoria y devuelva si hay match o error.
    procedure check_match (
        btn_in   : in  std_logic_vector(3 downto 0);
        mem_data : in  std_logic_vector(3 downto 0);
        match    : out std_logic;
        error    : out std_logic
    );
end package game_pkg;


package body game_pkg is

    -- TAREAS A PROGRAMAR AQUÍ:
    -- 1. Escribir el código interno de la función (ej: un 'case' con las 4 opciones válidas).
    function is_one_hot (btn_in : std_logic_vector(3 downto 0)) return std_logic is
    begin
        case btn_in is
            when "0001" => return '1';
            when "0010" => return '1';
            when "0100" => return '1';
            when "1000" => return '1';
            when others => return '0'; -- Más de un botón, o ningún botón presionado
        end case;
    end function is_one_hot;

    -- 2. Escribir el código interno del procedure (ej: un 'if' que asigne las señales de salida).
    procedure check_match (
        btn_in   : in  std_logic_vector(3 downto 0);
        mem_data : in  std_logic_vector(3 downto 0);
        match    : out std_logic;
        error    : out std_logic
    ) is
    begin
        -- Comparamos directamente el vector ingresado con el de la memoria
        if btn_in = mem_data then
            match := '1';
            error := '0';
        else
            match := '0';
            error := '1';
        end if;
    end procedure check_match;

end package body game_pkg;