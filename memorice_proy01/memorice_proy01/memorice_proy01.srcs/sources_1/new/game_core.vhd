library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity game_core is
    Port (
        sysclk : in  std_logic;
        sw     : in  std_logic_vector(3 downto 0);  -- SW(1:0) = LVL, SW(3:2) = SEL
        led    : out std_logic_vector(3 downto 0)
    );
end game_core;

architecture Structural of game_core is

    component gclk_sel is
        generic (
            CLK_HZ : positive := 125_000_000;
            T0_MS  : positive := 1200;
            T1_MS  : positive := 800;
            T2_MS  : positive := 500;
            T3_MS  : positive := 300
        );
        Port (
            sysclk : in  std_logic;
            lvl    : in  std_logic_vector(1 downto 0);
            tick   : out std_logic
        );
    end component;

    component rand_sec is
        Generic (
            SEED_DEFAULT : std_logic_vector(7 downto 0) := "10110011";
            STEPS        : positive := 8
        );
        Port (
            clk      : in  std_logic;
            reset    : in  std_logic;
            en       : in  std_logic;
            seedIn   : in  std_logic_vector(7 downto 0);
            rndOut   : out std_logic_vector(3 downto 0)
        );
    end component;

    component led_driver is
        Port ( 
            clk     : in  std_logic;
            sel     : in  std_logic_vector(1 downto 0);
            seq_led : in  std_logic_vector(3 downto 0);
            bar_led : in  std_logic_vector(3 downto 0);
            led     : out std_logic_vector(3 downto 0)
        );
    end component;

    -- SEÑALES INTERNAS ACTUALIZADAS
    signal sig_tick     : std_logic;
    signal sig_rand_bus : std_logic_vector(3 downto 0);

begin

    U_GCLK_SEL: gclk_sel
        generic map (
            CLK_HZ => 125_000_000,
            T0_MS  => 1200,
            T1_MS  => 800,
            T2_MS  => 500,
            T3_MS  => 300
        )
        port map (
            sysclk => sysclk,
            lvl    => sw(1 downto 0),   -- CONECTADO A SWITCHES PARA CAMBIAR VELOCIDAD EN VIVO
            tick   => sig_tick          -- EMITE PULSO EN UN CICLO DE SYSCLK
        );

    U_RAND_SEC: rand_sec
        generic map (
            SEED_DEFAULT => "10110011",
            STEPS        => 8
        )
        port map (
            clk    => sysclk, 
            reset  => '0',              -- RESET EN 0 PARA QUE LA PRUEBA FISICA FUNCIONE CONTINUAMENTE
            en     => sig_tick,         -- HABILITA EL SALTO DEL LFSR CON EL PULSO LENTO
            seedIn => (others => '0'),  -- PARA CARGAR LA SEED_DEFAULT
            rndOut => sig_rand_bus
        );

    U_LED_DRIVER: led_driver
        port map (
            clk     => sysclk,
            sel     => sw(3 downto 2),  -- "01" MUESTRA SECUENCIA, "10" APAGA LEDS EN VIVO
            seq_led => sig_rand_bus,    -- PATRON DE LEDS ALEATORIO DESDE EL LFSR
            bar_led => "0000",          -- NO SE USA EN ESTA ETAPA
            led     => led
        );

end Structural;
