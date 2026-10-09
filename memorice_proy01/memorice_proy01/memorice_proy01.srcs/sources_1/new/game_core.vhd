library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity game_core is
    Port (
        sysclk   : in  std_logic;
        rst      : in  std_logic;
        lvl      : in  std_logic_vector(1 downto 0);  -- Nivel automático desde la FSM
        en_lfsr  : in  std_logic;
        tick     : out std_logic;
        rand_out : out std_logic_vector(3 downto 0)
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

    signal sig_tick     : std_logic;
    signal sig_rand_bus : std_logic_vector(3 downto 0);

begin

    tick     <= sig_tick;
    rand_out <= sig_rand_bus;

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
            lvl    => lvl,
            tick   => sig_tick
        );

    U_RAND_SEC: rand_sec
        generic map (
            SEED_DEFAULT => "10110011",
            STEPS        => 8
        )
        port map (
            clk    => sysclk, 
            reset  => rst,
            en     => en_lfsr,
            seedIn => (others => '0'),
            rndOut => sig_rand_bus
        );

end Structural;