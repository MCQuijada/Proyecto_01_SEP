library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity led_driver is
    Port ( 
        clk     : in  std_logic;
        sel     : in  std_logic_vector(1 downto 0); -- SELECTOR DE FASE DEL JUEGO
        seq_led : in  std_logic_vector(3 downto 0); -- PATRON DE LA SECUENCIA
        bar_led : in  std_logic_vector(3 downto 0); -- BARRA DE TIEMPO EN LEDS
        led     : out std_logic_vector(3 downto 0) 
    );
end led_driver;

architecture Behavioral of led_driver is
begin

    LED_CTRL: process (clk)
    begin
        if rising_edge(clk) then 
            case sel is
                when "01" => 
                    led <= seq_led;  -- MOSTRAR LA SECUENCIA A MEMORIZAR
                when "10" => 
                    led <= bar_led;  -- MOSTRAR TIEMPO RESTANTE PARA RESPONDER
                when others => 
                    led <= "0000";   -- APAGADO
            end case;
        end if;
    end process;

end Behavioral;