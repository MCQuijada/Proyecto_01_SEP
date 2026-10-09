library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity game_fsm is
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
        en_gen     : out std_logic; -- Habilita el guardado en memoria
        en_show    : out std_logic;
        en_input   : out std_logic;
        mem_rd_sel : out std_logic;
        mux_sel    : out std_logic_vector(1 downto 0)
    );
end game_fsm;

architecture Behavioral of game_fsm is
    type state_type is (IDLE, GEN, SHOW, INPUT, LEVEL_OK, S_LOSE, S_WIN);
    signal state, next_state : state_type;

    signal lvl_reg     : unsigned(1 downto 0) := "00";
    signal num_seq_reg : integer range 0 to 31 := 4;
begin

    SYNC_PROC: process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state <= IDLE;
                lvl_reg <= "00";
                num_seq_reg <= 4;
            else
                state <= next_state;
                if state = IDLE then
                    lvl_reg <= "00";
                    num_seq_reg <= 4;
                elsif state = LEVEL_OK then
                    if lvl_reg < "11" then
                        lvl_reg <= lvl_reg + 1;
                        num_seq_reg <= num_seq_reg + 4;
                    end if;
                end if;
            end if;
        end if;
    end process;

    OUTPUT_DECODE: process(state, start, gen_done, seq_done, win, lose, lvl_reg)
    begin
        next_state <= state;
        rgb        <= "000";
        en_lfsr    <= '0';
        en_gen     <= '0';
        en_show    <= '0';
        en_input   <= '0';
        mem_rd_sel <= '0';
        mux_sel    <= "00"; 

        case state is
            when IDLE =>
                rgb <= "111";
                en_lfsr <= '1'; -- Genera aleatoriedad constante en reposo
                if start = '1' then
                    next_state <= GEN;
                end if;

            when GEN =>
                rgb <= "010";
                en_lfsr <= '1';
                en_gen  <= '1'; -- Indica a game_logic que guarde los datos
                if gen_done = '1' then
                    next_state <= SHOW;
                end if;

            when SHOW =>
                rgb <= "010";
                en_show <= '1';
                mem_rd_sel <= '0';
                mux_sel <= "01";   
                if seq_done = '1' then
                    next_state <= INPUT;
                end if;

            when INPUT =>
                rgb <= "110";
                en_input <= '1';
                mem_rd_sel <= '1';
                mux_sel <= "10";   
                if lose = '1' then
                    next_state <= S_LOSE;
                elsif win = '1' then
                    if lvl_reg = "11" then  
                        next_state <= S_WIN;
                    else                    
                        next_state <= LEVEL_OK;
                    end if;
                end if;

            when LEVEL_OK =>
                rgb <= "001"; 
                if start = '1' then
                    next_state <= GEN; 
                end if;

            when S_LOSE =>
                rgb <= "100"; 
                if start = '1' then
                    next_state <= IDLE;
                end if;

            when S_WIN =>
                rgb <= "101"; 
                if start = '1' then
                    next_state <= IDLE;
                end if;

            when others =>
                next_state <= IDLE;
        end case;
    end process;

    lvl     <= std_logic_vector(lvl_reg);
    num_seq <= std_logic_vector(to_unsigned(num_seq_reg, 5)); 

end Behavioral;