library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity rand_led is
    Port (
        sysclk : in  std_logic;                    -- Reloj principal de la FPGA (ej. 125 MHz Zybo Z7)
        led   : out std_logic_vector(3 downto 0)  -- Salida física conectada a los LEDs 0 al 3
    );
end rand_led;

architecture Structural of rand_led is

    -- 1. DECLARACIÓN DE COMPONENTES
    
    -- Componente 1: Seleccionador/Divisor de Reloj
    component gclk_sel is
        Port (
            sysclk : in  std_logic;
            sclk   : out std_logic
        );
    end component;

    -- Componente 2: Generador de Secuencia Aleatoria (LFSR 4 bits)
    component rand_sec is
        Port (
            clk : in  std_logic;
            rand_out : out std_logic_vector(3 downto 0)
        );
    end component;

    -- Componente 3: Controlador de LED
    component led_driver is
        Port ( 
            clk     : in  std_logic;
            data_in : in  std_logic_vector (3 downto 0);
            led    : out std_logic_vector (3 downto 0)
        );
    end component;

    -- 2. DECLARACIÓN DE SEÑALES INTERNAS (Cables de interconexión)
    signal sig_sclk     : std_logic;                    -- Conecta la salida de gclk_sel con rand_sec
    signal sig_rand_bus : std_logic_vector(3 downto 0); -- Conecta rand_sec con led_driver

begin

    -- 3. INSTANCIACIÓN Y MAPEO DE PUERTOS (Port Mapping)

    -- Instancia 1: Generación del reloj lento (sclk)
    U_GCLK_SEL: gclk_sel
        port map (
            sysclk => sysclk,
            sclk   => sig_sclk
        );

    -- Instancia 2: Generación del número aleatorio en base a sclk
    U_RAND_SEC: rand_sec
        port map (
            clk      => sig_sclk,     -- Recibe el reloj dividido
            rand_out => sig_rand_bus  -- Envía el arreglo de 4 bits
        );

    -- Instancia 3: Driver que enciende los LEDs de salida
    U_LED_DRIVER: led_driver
        port map (
            clk     => sysclk,       -- Corre con el reloj maestro para pronta respuesta
            data_in => sig_rand_bus, -- Recibe el arreglo generado
            led    => led          -- Salida final hacia los pines físicos
        );

end Structural;