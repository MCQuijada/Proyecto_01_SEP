library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity system_top is
    Port (
        -- Entradas físicas desde la Zybo Z7
        sysclk    : in  std_logic;
        rst       : in  std_logic;
        start     : in  std_logic;
        btn_in    : in  std_logic_vector(3 downto 0);
        sw        : in  std_logic_vector(3 downto 0);
        
        -- Salidas físicas hacia la Zybo Z7
        led       : out std_logic_vector(3 downto 0); -- LEDs básicos (desde game_core)
        rgb       : out std_logic_vector(2 downto 0) -- LED RGB (desde game_logic)
    );
end system_top;

architecture Structural of system_top is

    -- =========================================================
    -- 1. DECLARACIÓN DE COMPONENTES
    -- =========================================================
    
    component game_core is
        Port (
            sysclk   : in  std_logic;
            rst      : in  std_logic;                     -- AÑADIDO: Necesario para el LFSR y Ticks
            sw       : in  std_logic_vector(3 downto 0);
            en_lfsr  : in  std_logic;                     -- AÑADIDO: Para que game_logic pida un número
            tick     : out std_logic;                     -- AÑADIDO: Salida del reloj lento
            rand_out : out std_logic_vector(3 downto 0);  -- AÑADIDO: Salida del número aleatorio
            led      : out std_logic_vector(3 downto 0)
        );
    end component;

    component game_logic is
        Port (
            clk           : in  std_logic;
            rst           : in  std_logic;
            tick          : in  std_logic;
            start         : in  std_logic;
            btn_in        : in  std_logic_vector(3 downto 0);
            data_from_mem : in  std_logic_vector(3 downto 0);
            
            rgb           : out std_logic_vector(2 downto 0);
            lvl           : out std_logic_vector(1 downto 0);
            en_lfsr       : out std_logic;
            mux_sel       : out std_logic_vector(1 downto 0);
            led     : out std_logic_vector(3 downto 0);
            -- AÑADIDOS: Controles de escritura para la memoria
            we            : out std_logic;
            addr_wr       : out std_logic_vector(4 downto 0);
            addr_rd       : out std_logic_vector(4 downto 0)
        );
    end component;

    component seq_mem is
        Generic (
            DATA_WIDTH : positive := 4;
            ADDR_WIDTH : positive := 5
        );
        Port (
            clk      : in  std_logic;
            rst      : in  std_logic;
            we       : in  std_logic;
            data_in  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            addr_rd  : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
            addr_wr  : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
            data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;

    -- =========================================================
    -- 2. CABLES DE INTERCONEXIÓN (Signals)
    -- =========================================================
    
    signal sig_tick     : std_logic;
    signal sig_en_lfsr  : std_logic;
    signal sig_rand_out : std_logic_vector(3 downto 0);
    
    signal sig_we       : std_logic;
    signal sig_addr_wr  : std_logic_vector(4 downto 0);
    signal sig_addr_rd  : std_logic_vector(4 downto 0);
    signal sig_mem_data : std_logic_vector(3 downto 0);

begin

    -- =========================================================
    -- 3. INSTANCIACIÓN Y MAPEO DE PUERTOS
    -- =========================================================

    -- Instancia 1: El Core (Generador de Ticks y LFSR)
    U_GAME_CORE: game_core port map (
        sysclk   => sysclk,
        rst      => rst,
        sw       => sw,
        en_lfsr  => sig_en_lfsr,
        tick     => sig_tick,
        rand_out => sig_rand_out,
        led      => led
    );

    -- Instancia 2: La Lógica del Juego (Cerebro)
    U_GAME_LOGIC: game_logic port map (
        clk           => sysclk,
        rst           => rst,
        tick          => sig_tick,
        start         => start,
        btn_in        => btn_in,
        data_from_mem => sig_mem_data,
        
        rgb           => rgb,
        lvl           => open,
        en_lfsr       => sig_en_lfsr,
        mux_sel       => open,
        led     => led,
        
        we            => sig_we,
        addr_wr       => sig_addr_wr,
        addr_rd       => sig_addr_rd
    );

    -- Instancia 3: Memoria de Secuencias
    U_SEQ_MEM: seq_mem 
        generic map (
            DATA_WIDTH => 4,
            ADDR_WIDTH => 5
        )
        port map (
            clk      => sysclk,
            rst      => rst,
            we       => sig_we,
            data_in  => sig_rand_out, -- Escribe directamente lo que genera el LFSR
            addr_rd  => sig_addr_rd,
            addr_wr  => sig_addr_wr,
            data_out => sig_mem_data  -- Envía lo leído hacia el game_logic
        );

end Structural;