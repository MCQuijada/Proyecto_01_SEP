library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity GSA is
    Generic (
        rondas : integer := 10                                         -- Valor genérico del numero de rondas
    );
    Port (
        clk : in std_logic;
        rst : in std_logic;
        nxt : in std_logic;                                             -- Siguiente ronda
        secuencia : out std_logic_vector((4 * rondas)-1 downto 0)        -- secuencia 4 bits por ronda, en etapa posterior separar de a 4
    );
end GSA;

architecture Behavioral of GSA is

    signal sec_reg : std_logic_vector((4 * rondas)-1 downto 0) := (others => '0');
    signal random_led : std_logic_vector(3 downto 0);

    -- Señales necesarias para la generación aleatoria de 2 bits 
    signal reg_random : std_logic_vector(7 downto 0) := "00101110";
    signal feedback : std_logic;

begin                                                                                   -- Polinomio primitivo, genera feedback tal que en cada
                                                                                        -- secuencia de 8 bits pasa por todas las combinaciones posibles
    feedback <= reg_random(7) XOR reg_random(5) XOR reg_random(4) XOR reg_random(3);    -- 1/4 AC3: Operador XOR

    with reg_random(7 downto 6) select
        random_led <=   "0001" when "00",   -- 00->Led0
                        "0010" when "01",   -- 01->Led1
                        "0100" when "10",   -- 10->Led2
                        "1000" when "11";   -- 11->Led3
    
    process (clk)
        begin
            if rising_edge(clk) then
                if (rst = '1') then
                    sec_reg <= (others => '0');
                    reg_random <= "00101110";
                else 
                    reg_random <= reg_random(6 downto 0) & feedback;        --Shift left 

                    if (nxt = '1') then
                        -- Lógica de desplazamiento de la secuencia 
                        sec_reg <= sec_reg((4 * rondas)-5 downto 0) & random_led;    -- random_led -> 0001, 1000, 0100 o 0010
                    end if;
                end if;
            end if;
        end process;
    
    secuencia <= sec_reg;       --AC4: Variable sec_reg interna que actualiza secuencia

end Behavioral;
