library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity led_driver is
    Port ( 
        clk     : in  std_logic;                    -- Reloj de entrada
        data_in : in  std_logic_vector (3 downto 0); -- Array de 4 bits de entrada
        led    : out std_logic_vector (3 downto 0)  -- Salida directa a led 0-3
    );
end led_driver;

architecture Behavioral of led_driver is
begin

    -- Proceso síncrono para actualizar las salidas según la entrada recibida
    LED_CTRL: process (clk)
    begin
        if rising_edge(clk) then 
            led <= data_in;
        end if;
    end process;

end Behavioral;