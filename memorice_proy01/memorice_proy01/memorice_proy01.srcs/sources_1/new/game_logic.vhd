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
        led           : out std_logic_vector(3 downto 0);
        
        we            : out std_logic;
        addr_wr       : out std_logic_vector(4 downto 0);
        addr_rd       : out std_logic_vector(4 downto 0)
    );
end game_logic;

architecture Structural of game_logic is

    component game_fsm is
        Port (
            clk, reset, start, gen_done, seq_done, win, lose : in std_logic;
            rgb : out std_logic_vector(2 downto 0);
            lvl : out std_logic_vector(1 downto 0);
            num_seq : out std_logic_vector(4 downto 0);
            en_lfsr, en_gen, en_show, en_input, mem_rd_sel : out std_logic;
            mux_sel : out std_logic_vector(1 downto 0)
        );
    end component;

    component input_det is
        Port (
            clk, rst : in std_logic;
            btn_in : in std_logic_vector(3 downto 0);
            btn_out : out std_logic_vector(3 downto 0);
            btn_valid : out std_logic
        );
    end component;

    component seq_cmp is
        Port (
            clk, rst, en_input : in std_logic;
            num_seq : in std_logic_vector(4 downto 0);
            btn_valid : in std_logic;
            btn_data, mem_data : in std_logic_vector(3 downto 0);
            addr_rd : out std_logic_vector(4 downto 0);
            win, lose : out std_logic
        );
    end component;

    component seq_dis is
        Generic ( ADDR_WIDTH : positive := 5 );
        Port (
            clk, tick, enable_display : in std_logic;
            num_seq : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            data_from_mem : in std_logic_vector(3 downto 0);
            addr_rd : out std_logic_vector(ADDR_WIDTH-1 downto 0);
            led : out std_logic_vector(3 downto 0);
            seq_done : out std_logic
        );
    end component;

    component timer is
        Port (
            clk, rst, en_input, tick : in std_logic;
            num_seq : in std_logic_vector(4 downto 0);
            led : out std_logic_vector(3 downto 0);
            timeout : out std_logic
        );
    end component;

    signal sig_seq_done, sig_win, sig_lose, sig_cmp_lose, sig_timeout : std_logic;
    signal sig_num_seq     : std_logic_vector(4 downto 0);
    signal sig_en_lfsr, sig_en_gen, sig_en_show, sig_en_input, sig_mem_rd_sel : std_logic;
    signal sig_btn_valid   : std_logic;
    signal sig_btn_data    : std_logic_vector(3 downto 0);
    signal sig_addr_rd_dis, sig_addr_rd_cmp : std_logic_vector(4 downto 0);
    signal led_dis, led_tmr : std_logic_vector(3 downto 0);

    -- Señales para el generador automático de memoria
    signal gen_ptr : integer range 0 to 31 := 0;
    signal sig_gen_done : std_logic := '0';

begin

    en_lfsr <= sig_en_lfsr;
    addr_rd <= sig_addr_rd_dis when sig_mem_rd_sel = '0' else sig_addr_rd_cmp;
    sig_lose <= sig_cmp_lose or sig_timeout;

    -- Multiplexor correcto de LEDs usando las señales reales de la FSM
    led <= led_dis when sig_en_show = '1' else
           led_tmr when sig_en_input = '1' else
           "0000";

    -- PROCESO DE GENERACIÓN: Llena la memoria en microsegundos al entrar al estado GEN
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                gen_ptr <= 0;
                sig_gen_done <= '0';
            elsif sig_en_gen = '1' then
                if gen_ptr < to_integer(unsigned(sig_num_seq)) then
                    gen_ptr <= gen_ptr + 1;
                    sig_gen_done <= '0';
                else
                    sig_gen_done <= '1';
                end if;
            else
                gen_ptr <= 0;
                sig_gen_done <= '0';
            end if;
        end if;
    end process;

    -- Escribe en memoria solo mientras se está generando
    we      <= '1' when (sig_en_gen = '1' and sig_gen_done = '0') else '0';
    addr_wr <= std_logic_vector(to_unsigned(gen_ptr, 5));

    U_FSM: game_fsm port map (
        clk => clk, reset => rst, start => start,
        gen_done => sig_gen_done, seq_done => sig_seq_done,
        win => sig_win, lose => sig_lose, rgb => rgb, lvl => lvl,
        num_seq => sig_num_seq, en_lfsr => sig_en_lfsr, en_gen => sig_en_gen,
        en_show => sig_en_show, en_input => sig_en_input, 
        mem_rd_sel => sig_mem_rd_sel, mux_sel => mux_sel
    );

    U_INPUT: input_det port map (
        clk => clk, rst => rst, btn_in => btn_in, btn_out => sig_btn_data, btn_valid => sig_btn_valid
    );

    U_CMP: seq_cmp port map (
        clk => clk, rst => rst, en_input => sig_en_input, num_seq => sig_num_seq,
        btn_valid => sig_btn_valid, btn_data => sig_btn_data, mem_data => data_from_mem,
        addr_rd => sig_addr_rd_cmp, win => sig_win, lose => sig_cmp_lose
    );

    U_DIS: seq_dis generic map (ADDR_WIDTH => 5) port map (
        clk => clk, tick => tick, enable_display => sig_en_show,
        num_seq => sig_num_seq, data_from_mem => data_from_mem,
        addr_rd => sig_addr_rd_dis, led => led_dis, seq_done => sig_seq_done
    );

    U_TIMER: timer port map (
        clk => clk, rst => rst, en_input => sig_en_input, tick => tick,
        num_seq => sig_num_seq, led => led_tmr, timeout => sig_timeout
    );

end Structural;