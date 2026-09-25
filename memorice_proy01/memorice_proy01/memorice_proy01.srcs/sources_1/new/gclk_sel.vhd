library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity gclk_sel is
    generic (
        CLK_HZ : positive := 125_000_000;
        T0_MS  : positive := 1200; -- CAMBIO A VALORES AJUSTABLES EN MS
        T1_MS  : positive := 800;
        T2_MS  : positive := 500;
        T3_MS  : positive := 300
    );
    Port (
        sysclk : in  std_logic;
        lvl    : in  std_logic_vector(1 downto 0);
        tick   : out std_logic  -- OTRO CLK PUEDE INTRODUCIR RETARDO/GLITCHES POR EL
    );                          -- RUTEO QUE HACE VIVADO.
end gclk_sel;

architecture Behavioral of gclk_sel is
    signal counter : natural := 0;
begin

    process(sysclk)
        variable limite : natural := 0;         -- (AC4: USO DE VARIABLES PARA ACTUALIZAR VALORES INSTANTANEOS)
    begin 
        if rising_edge(sysclk) then     -- PARA CADA CICLO DEL RELOJ
            case lvl is
                when "00" => limite := (CLK_HZ/1000) * T0_MS - 1;   -- EL LIMITE SE CALCULA EN BASE A LOS GENERICS.
                when "01" => limite := (CLK_HZ/1000) * T1_MS - 1;   -- SE CALCULAN LOS CICLOS POR MS DEL RELOJ DE
                when "10" => limite := (CLK_HZ/1000) * T2_MS - 1;   -- LA ZYBO Y SE MULTIPLICA POR LOS MILISEGUNDOS
                when "11" => limite := (CLK_HZ/1000) * T3_MS - 1;   -- DESEADOS DEL CICLO LENTO PARA OBTENER LOS CICLOS
                when others => limite := (CLK_HZ/1000) * T0_MS - 1; -- DEL SYSCLK EN QUE SE CUMPLE EL RELOJ LENTO
            end case;

            -- EVITA QUE SE CONGELE EL CONTADOR PARA EL CAMBIO DE VELOCIDAD
            if counter >= limite then   
                counter <= 0;
                tick    <= '1';             -- TICK SE MANTIENE EN 1 DURANTE UN CICLO DE
            else                            -- SYSCLK Y EN 0 DURANTE LOS CICLOS NECESARIOS 
                counter <= counter+ 1;      -- HASTA QUE TERMINE EL CICLO LENTO
                tick    <= '0';
            end if;
            
        end if;
    end process;

end Behavioral;