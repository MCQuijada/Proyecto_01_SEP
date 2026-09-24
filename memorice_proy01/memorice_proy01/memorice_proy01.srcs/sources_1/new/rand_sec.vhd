library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity rand_sec is
    Generic (
        lfsrLen  : integer := 8; -- Registro interno de 8 bits (255 estados de profundidad)
        lfsrIter : integer := 4  -- Salida mapeada de 4 bits para los LEDs (0001, 0010, 0100, 1000)
    );
    Port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        en       : in  std_logic;                                 -- Habilitador (1 pulso = 1 avance)
        seedIn   : in  std_logic_vector((lfsrLen-1) downto 0);   -- Semilla opcional de 8 bits
        rndOut   : out std_logic_vector((lfsrIter-1) downto 0)    -- Arreglo de 4 bits con solo una luz activa
    );
end rand_sec;

architecture Behavioural of rand_sec is
    constant SEED_DEFAULT : std_logic_vector(7 downto 0) := "10110011";
    signal sr : std_logic_vector(7 downto 0) := SEED_DEFAULT;
    signal pre_map_value : std_logic_vector(1 downto 0);
begin

    process(clk)
        variable feedback : std_logic;
    begin
        if rising_edge(clk) then
            if reset = '1' then
                if seedIn = (seedIn'range => '0') then
                    sr <= SEED_DEFAULT; 
                else
                    sr <= seedIn;
                end if;
            elsif en = '1' then
                feedback := sr(7) xor sr(5) xor sr(4) xor sr(3);
                sr <= sr(6 downto 0) & feedback;
            end if;
        end if;
    end process;

    pre_map_value <= sr(1 downto 0);

    process(pre_map_value)
    begin
        case pre_map_value is
            when "00"   => rndOut <= "0001";
            when "01"   => rndOut <= "0010";
            when "10"   => rndOut <= "0100";
            when "11"   => rndOut <= "1000";
            when others => rndOut <= "0001";
        end case;
    end process;

end Behavioural;