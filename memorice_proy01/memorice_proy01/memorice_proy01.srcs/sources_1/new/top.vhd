library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity system_top is
    Port (
        sysclk    : in  std_logic;
        rst       : in  std_logic;
        start     : in  std_logic;
        btn_in    : in  std_logic_vector(3 downto 0);
        
        led       : out std_logic_vector(3 downto 0); 
        rgb       : out std_logic_vector(2 downto 0) 
    );
end system_top;

architecture Structural of system_top is
    
    component game_core is
        Port (
            sysclk   : in  std_logic;
            rst      : in  std_logic;
            lvl      : in  std_logic_vector(1 downto 0);
            en_lfsr  : in  std_logic;
            tick     : out std_logic;
            rand_out : out std_logic_vector(3 downto 0)
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
            led           : out std_logic_vector(3 downto 0);
            
            we            : out std_logic;
            addr_wr       : out std_logic_vector(4 downto 0);
            addr_rd       : out std_logic_vector(4 downto 0)
        );
    end component;

    component seq_mem is
        Generic ( DATA_WIDTH : positive := 4; ADDR_WIDTH : positive := 5 );
        Port (
            clk, rst, we : in std_logic;
            data_in      : in std_logic_vector(DATA_WIDTH-1 downto 0);
            addr_rd      : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            addr_wr      : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            data_out     : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;
    
    signal sig_tick, sig_en_lfsr, sig_we : std_logic;
    signal sig_lvl : std_logic_vector(1 downto 0);
    signal sig_rand_out, sig_mem_data : std_logic_vector(3 downto 0);
    signal sig_addr_wr, sig_addr_rd : std_logic_vector(4 downto 0);

begin

    U_GAME_CORE: game_core port map (
        sysclk   => sysclk,
        rst      => rst,
        lvl      => sig_lvl, -- Conectado internamente
        en_lfsr  => sig_en_lfsr,
        tick     => sig_tick,
        rand_out => sig_rand_out
    );

    U_GAME_LOGIC: game_logic port map (
        clk           => sysclk,
        rst           => rst,
        tick          => sig_tick,
        start         => start,
        btn_in        => btn_in,
        data_from_mem => sig_mem_data,
        rgb           => rgb,
        lvl           => sig_lvl, -- Transmite el nivel
        en_lfsr       => sig_en_lfsr,
        mux_sel       => open,
        led           => led,     -- Único controlador de LEDs
        we            => sig_we,
        addr_wr       => sig_addr_wr,
        addr_rd       => sig_addr_rd
    );

    U_SEQ_MEM: seq_mem generic map (DATA_WIDTH => 4, ADDR_WIDTH => 5) port map (
        clk => sysclk, rst => rst, we => sig_we, data_in => sig_rand_out,
        addr_rd => sig_addr_rd, addr_wr => sig_addr_wr, data_out => sig_mem_data
    );

end Structural;