library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity game_logic is
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
        leds_time     : out std_logic_vector(3 downto 0);
        leds_seq      : out std_logic_vector(3 downto 0);
        
        -- Puertos expuestos para controlar la memoria externa (seq_mem)
        we            : out std_logic;
        addr_wr       : out std_logic_vector(4 downto 0);
        addr_rd       : out std_logic_vector(4 downto 0)
    );
end game_logic;

architecture Structural of game_logic is

    -- =========================================================
    -- 1. DECLARACIÓN DE COMPONENTES (Alineados con sus Entidades)
    -- =========================================================
    
    component game_fsm is
        Port (
            clk        : in  std_logic;
            reset      : in  std_logic;
            start      : in  std_logic;
            gen_done   : in  std_logic;
            seq_done   : in  std_logic;
            win        : in  std_logic;
            lose       : in  std_logic;
            
            rgb        : out std_logic_vector(2 downto 0);
            lvl        : out std_logic_vector(1 downto 0);
            num_seq    : out std_logic_vector(4 downto 0);
            en_lfsr    : out std_logic;
            en_show    : out std_logic;
            en_input   : out std_logic;
            mem_rd_sel : out std_logic;
            mux_sel    : out std_logic_vector(1 downto 0)
        );
    end component;

    component input_det is
        Port (
            clk       : in  std_logic;
            rst       : in  std_logic;
            btn_in    : in  std_logic_vector(3 downto 0);
            btn_out   : out std_logic_vector(3 downto 0);
            btn_valid : out std_logic
        );
    end component;

    component seq_cmp is
        Port (
            clk       : in  std_logic;
            rst       : in  std_logic;
            en_input  : in  std_logic;
            num_seq   : in  std_logic_vector(4 downto 0);
            btn_valid : in  std_logic;
            btn_data  : in  std_logic_vector(3 downto 0);
            mem_data  : in  std_logic_vector(3 downto 0);
            addr_rd   : out std_logic_vector(4 downto 0);
            win       : out std_logic;
            lose      : out std_logic
        );
    end component;

    component seq_dis is
        Generic (
            ADDR_WIDTH : positive := 5
        );
        Port (
            clk            : in  std_logic;
            tick           : in  std_logic;
            enable_display : in  std_logic;
            num_seq        : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
            data_from_mem  : in  std_logic_vector(3 downto 0);
            addr_rd        : out std_logic_vector(ADDR_WIDTH-1 downto 0);
            led            : out std_logic_vector(3 downto 0);
            seq_done       : out std_logic
        );
    end component;

    component timer is
        Port (
            clk       : in  std_logic;
            rst       : in  std_logic;
            en_input  : in  std_logic;
            tick      : in  std_logic;
            num_seq   : in  std_logic_vector(4 downto 0);
            leds_time : out std_logic_vector(3 downto 0);
            timeout   : out std_logic
        );
    end component;

    -- =========================================================
    -- 2. DECLARACIÓN DE SEÑALES INTERNAS (Cables)
    -- =========================================================
    signal sig_gen_done    : std_logic := '1'; -- '1' para avanzar directamente de GEN a SHOW
    signal sig_seq_done    : std_logic;
    signal sig_win         : std_logic;
    signal sig_lose        : std_logic;
    signal sig_cmp_lose    : std_logic;
    signal sig_timeout     : std_logic;
    
    signal sig_num_seq     : std_logic_vector(4 downto 0);
    signal sig_en_lfsr     : std_logic;
    signal sig_en_show     : std_logic;
    signal sig_en_input    : std_logic;
    signal sig_mem_rd_sel  : std_logic;
    
    signal sig_btn_valid   : std_logic;
    signal sig_btn_data    : std_logic_vector(3 downto 0);
    
    signal sig_addr_rd_dis : std_logic_vector(4 downto 0);
    signal sig_addr_rd_cmp : std_logic_vector(4 downto 0);

begin

    -- Asignaciones continuas hacia las salidas externas
    en_lfsr <= sig_en_lfsr;

    -- La FSM activa la escritura en la memoria cuando se pide un dato al LFSR
    we      <= sig_en_lfsr; 
    addr_wr <= (others => '0'); -- Puntero de escritura por defecto

    -- Multiplexor de direcciones de lectura (0: Modo Mostrar, 1: Modo Jugador)
    addr_rd <= sig_addr_rd_dis when sig_mem_rd_sel = '0' else sig_addr_rd_cmp;

    -- Condición de derrota (Lógica OR: Por error en botones O por tiempo agotado)
    sig_lose <= sig_cmp_lose or sig_timeout;

    -- =========================================================
    -- 3. INSTANCIACIÓN Y MAPEO DE PUERTOS
    -- =========================================================
    
    U_FSM: game_fsm port map (
        clk        => clk,
        reset      => rst,
        start      => start,
        gen_done   => sig_gen_done,
        seq_done   => sig_seq_done,
        win        => sig_win,
        lose       => sig_lose,
        rgb        => rgb,
        lvl        => lvl,
        num_seq    => sig_num_seq,
        en_lfsr    => sig_en_lfsr,
        en_show    => sig_en_show,
        en_input   => sig_en_input,
        mem_rd_sel => sig_mem_rd_sel,
        mux_sel    => mux_sel
    );

    U_INPUT: input_det port map (
        clk       => clk,
        rst       => rst,
        btn_in    => btn_in,
        btn_out   => sig_btn_data,
        btn_valid => sig_btn_valid
    );

    U_CMP: seq_cmp port map (
        clk       => clk,
        rst       => rst,
        en_input  => sig_en_input,
        num_seq   => sig_num_seq,
        btn_valid => sig_btn_valid,
        btn_data  => sig_btn_data,
        mem_data  => data_from_mem,
        addr_rd   => sig_addr_rd_cmp,
        win       => sig_win,
        lose      => sig_cmp_lose
    );

    U_DIS: seq_dis 
        generic map (
            ADDR_WIDTH => 5
        )
        port map (
            clk            => clk,
            tick           => tick,
            enable_display => sig_en_show,
            num_seq        => sig_num_seq,
            data_from_mem  => data_from_mem,
            addr_rd        => sig_addr_rd_dis,
            led            => leds_seq,
            seq_done       => sig_seq_done
        );

    U_TIMER: timer port map (
        clk       => clk,
        rst       => rst,
        en_input  => sig_en_input,
        tick      => tick,
        num_seq   => sig_num_seq,
        leds_time => leds_time,
        timeout   => sig_timeout
    );

end Structural;